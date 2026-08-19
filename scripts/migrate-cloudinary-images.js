/**
 * Migrate old Cloudinary post images → ispot.cc (new upload host).
 *
 * Flow per image URL in posts.images:
 *   1. Skip if not Cloudinary
 *   2. Download from Cloudinary (skip if 404 / gone)
 *   3. Upload to IMAGE_UPLOAD_URL (ispot)
 *   4. Replace URL in posts.images (+ public_ids)
 *
 * Usage (from Api_osoul):
 *   # preview only (no DB writes)
 *   node scripts/migrate-cloudinary-images.js --dry-run
 *
 *   # migrate (needs DATABASE_URL in .env or env)
 *   node scripts/migrate-cloudinary-images.js --apply
 *
 *   # limit how many posts to process
 *   node scripts/migrate-cloudinary-images.js --apply --limit=50
 *
 * IMPORTANT:
 * - Images already deleted from Cloudinary (HTTP 404) CANNOT be recovered.
 * - Run --dry-run first and check how many are "missing" vs "ok".
 */
require("dotenv").config();
const { Pool } = require("pg");
const crypto = require("crypto");

const DATABASE_URL = process.env.DATABASE_URL;
const UPLOAD_URL =
  process.env.IMAGE_UPLOAD_URL ||
  "https://st79068.ispot.cc/ousoul/upload.php";
const IMAGE_BASE_URL =
  process.env.IMAGE_BASE_URL || "https://st79068.ispot.cc";
const IMAGE_PATH = process.env.IMAGE_PATH || "/ousoul/images";

const args = process.argv.slice(2);
const DRY_RUN = !args.includes("--apply");
const limitArg = args.find((a) => a.startsWith("--limit="));
const LIMIT = limitArg ? Number(limitArg.split("=")[1]) : null;

function isCloudinaryUrl(url) {
  return typeof url === "string" && url.includes("res.cloudinary.com");
}

function filenameFromUrl(url) {
  try {
    const name = new URL(url).pathname.split("/").pop() || "image.jpg";
    return name.includes(".") ? name : `${name}.jpg`;
  } catch {
    return `image_${Date.now()}.jpg`;
  }
}

function buildPublicUrl(uploadPath) {
  const base = IMAGE_BASE_URL.replace(/\/$/, "");
  const folder = IMAGE_PATH.replace(/^\/|\/$/g, "");
  const filename = uploadPath.split("/").pop();
  return `${base}/${folder}/${encodeURIComponent(filename)}`;
}

async function downloadImage(url) {
  const res = await fetch(url, { redirect: "follow" });
  if (res.status === 404) {
    return { ok: false, missing: true, status: 404 };
  }
  if (!res.ok) {
    return { ok: false, missing: false, status: res.status };
  }
  const buf = Buffer.from(await res.arrayBuffer());
  if (!buf.length) {
    return { ok: false, missing: true, status: res.status };
  }
  const contentType = res.headers.get("content-type") || "image/jpeg";
  return { ok: true, buffer: buf, contentType };
}

async function uploadToIspot(buffer, filename, mimeType) {
  const form = new FormData();
  const blob = new Blob([buffer], { type: mimeType });
  form.append("file", blob, filename);

  const res = await fetch(UPLOAD_URL, { method: "POST", body: form });
  const text = await res.text();
  let data;
  try {
    data = JSON.parse(text);
  } catch {
    throw new Error(`Upload returned non-JSON: ${text.slice(0, 200)}`);
  }
  if (!res.ok || !data.success || !data.path) {
    throw new Error(data.error || `Upload failed (${res.status})`);
  }
  return {
    path: data.path,
    url: buildPublicUrl(data.path),
  };
}

async function migrateUrl(url) {
  if (!isCloudinaryUrl(url)) {
    return { status: "skipped", url };
  }

  const downloaded = await downloadImage(url);
  if (!downloaded.ok) {
    return {
      status: downloaded.missing ? "missing" : "download_failed",
      url,
      httpStatus: downloaded.status,
    };
  }

  if (DRY_RUN) {
    return {
      status: "would_migrate",
      url,
      bytes: downloaded.buffer.length,
    };
  }

  const filename = `migrated_${Date.now()}_${crypto
    .randomBytes(3)
    .toString("hex")}_${filenameFromUrl(url)}`;
  const uploaded = await uploadToIspot(
    downloaded.buffer,
    filename,
    downloaded.contentType
  );

  return {
    status: "migrated",
    url,
    newUrl: uploaded.url,
    path: uploaded.path,
  };
}

async function main() {
  if (!DATABASE_URL) {
    console.error("Missing DATABASE_URL. Set it in .env or the environment.");
    process.exit(1);
  }

  console.log(DRY_RUN ? "MODE: dry-run (no writes)" : "MODE: apply (will update DB)");
  console.log("UPLOAD_URL:", UPLOAD_URL);
  console.log("IMAGE_BASE_URL:", IMAGE_BASE_URL);

  const pool = new Pool({
    connectionString: DATABASE_URL,
    ssl:
      process.env.DATABASE_SSL === "true"
        ? { rejectUnauthorized: false }
        : false,
  });

  const stats = {
    posts: 0,
    urls: 0,
    migrated: 0,
    would_migrate: 0,
    missing: 0,
    download_failed: 0,
    skipped: 0,
    updated_posts: 0,
    errors: 0,
  };

  try {
    let query = `
      SELECT id, images, public_ids
      FROM posts
      WHERE images IS NOT NULL
        AND cardinality(images) > 0
        AND EXISTS (
          SELECT 1
          FROM unnest(images) AS img
          WHERE img ILIKE '%res.cloudinary.com%'
        )
      ORDER BY created_at DESC NULLS LAST
    `;
    const params = [];
    if (LIMIT && Number.isFinite(LIMIT) && LIMIT > 0) {
      query += ` LIMIT $1`;
      params.push(LIMIT);
    }

    const { rows } = await pool.query(query, params);
    console.log(`Found ${rows.length} posts with Cloudinary images`);

    for (const row of rows) {
      stats.posts += 1;
      const images = Array.isArray(row.images) ? row.images : [];
      const publicIds = Array.isArray(row.public_ids) ? [...row.public_ids] : [];
      const nextImages = [];
      const nextPublicIds = [...publicIds];
      let changed = false;

      for (let i = 0; i < images.length; i++) {
        const url = images[i];
        stats.urls += 1;
        try {
          const result = await migrateUrl(url);
          stats[result.status] = (stats[result.status] || 0) + 1;

          if (result.status === "migrated") {
            nextImages.push(result.newUrl);
            nextPublicIds[i] = result.path;
            changed = true;
            console.log(`  OK  ${row.id} ← ${result.newUrl}`);
          } else if (result.status === "would_migrate") {
            nextImages.push(url);
            console.log(
              `  DRY ${row.id} ${url.slice(0, 80)}... (${result.bytes} bytes)`
            );
          } else if (result.status === "missing") {
            // Keep old URL so you can see which ones are dead; or drop them:
            // nextImages.push is skipped intentionally? Keep for now.
            nextImages.push(url);
            console.log(`  404 ${row.id} ${url}`);
          } else if (result.status === "skipped") {
            nextImages.push(url);
          } else {
            nextImages.push(url);
            console.log(`  FAIL download ${row.id} ${url} (${result.httpStatus})`);
          }
        } catch (err) {
          stats.errors += 1;
          nextImages.push(url);
          console.error(`  ERR ${row.id} ${url}:`, err.message);
        }
      }

      if (!DRY_RUN && changed) {
        await pool.query(
          `UPDATE posts
           SET images = $1::text[],
               public_ids = $2::text[]
           WHERE id = $3`,
          [nextImages, nextPublicIds, row.id]
        );
        stats.updated_posts += 1;
      }
    }
  } finally {
    await pool.end();
  }

  console.log("\n=== Summary ===");
  console.log(stats);
  if (DRY_RUN) {
    console.log(
      "\nDry-run only. Re-run with --apply to upload + update the database."
    );
  }
  if (stats.missing) {
    console.log(
      `\n${stats.missing} Cloudinary URLs returned 404 — those files are gone and cannot be migrated.`
    );
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
