import crypto from "crypto";
import dotenv from "dotenv";
import convert from "heic-convert";

dotenv.config();

const UPLOAD_URL =
  process.env.IMAGE_UPLOAD_URL ||
  "https://st79068.ispot.cc/ousoul/upload.php";
const IMAGE_BASE_URL =
  process.env.IMAGE_BASE_URL || "https://st79068.ispot.cc";
const IMAGE_PATH = process.env.IMAGE_PATH || "/ousoul/images";

type UploadResponse = {
  success?: boolean;
  path?: string;
  error?: string;
};

export type UploadedImage = {
  url: string;
  path: string;
};

type DetectedImage = {
  mimeType: string;
  extension: string;
};

function encodePathSegment(segment: string): string {
  try {
    return encodeURIComponent(decodeURIComponent(segment));
  } catch {
    return encodeURIComponent(segment);
  }
}

function buildImageUrl(filename: string): string {
  const base = IMAGE_BASE_URL.replace(/\/$/, "");
  const folder = IMAGE_PATH.replace(/^\/|\/$/g, "");
  return `${base}/${folder}/${encodePathSegment(filename)}`;
}

function encodeImageUrl(url: string): string {
  try {
    const parsed = new URL(url);
    const segments = parsed.pathname.split("/").filter(Boolean);
    parsed.pathname = `/${segments.map(encodePathSegment).join("/")}`;
    return parsed.toString();
  } catch {
    return url;
  }
}

function filenameFromPath(path: string): string {
  return path.split("/").pop() || path;
}

function pathToPublicUrl(uploadPath: string): string {
  return buildImageUrl(filenameFromPath(uploadPath));
}

function uniqueFilename(extension: string): string {
  return `upload_${Date.now()}_${crypto.randomBytes(4).toString("hex")}.${extension}`;
}

function isHeicBuffer(buffer: Buffer): boolean {
  if (buffer.length < 12 || buffer.toString("ascii", 4, 8) !== "ftyp") {
    return false;
  }
  const brand = buffer.toString("ascii", 8, 12).toLowerCase();
  return (
    brand.includes("heic") ||
    brand.includes("heif") ||
    brand === "mif1" ||
    brand === "msf1"
  );
}

async function convertHeicToJpeg(buffer: Buffer): Promise<Buffer> {
  const output = await convert({
    buffer,
    format: "JPEG",
    quality: 0.9,
  });
  return Buffer.from(new Uint8Array(output));
}

function detectImageMime(buffer: Buffer): DetectedImage {
  if (
    buffer.length >= 3 &&
    buffer[0] === 0xff &&
    buffer[1] === 0xd8 &&
    buffer[2] === 0xff
  ) {
    return { mimeType: "image/jpeg", extension: "jpg" };
  }

  if (
    buffer.length >= 8 &&
    buffer[0] === 0x89 &&
    buffer[1] === 0x50 &&
    buffer[2] === 0x4e &&
    buffer[3] === 0x47
  ) {
    return { mimeType: "image/png", extension: "png" };
  }

  if (
    buffer.length >= 6 &&
    (buffer.toString("ascii", 0, 6) === "GIF87a" ||
      buffer.toString("ascii", 0, 6) === "GIF89a")
  ) {
    return { mimeType: "image/gif", extension: "gif" };
  }

  if (
    buffer.length >= 12 &&
    buffer.toString("ascii", 0, 4) === "RIFF" &&
    buffer.toString("ascii", 8, 12) === "WEBP"
  ) {
    return { mimeType: "image/webp", extension: "webp" };
  }

  return { mimeType: "image/jpeg", extension: "jpg" };
}

async function parseUploadResponse(
  response: Response
): Promise<UploadedImage> {
  const text = await response.text();
  let data: UploadResponse;

  try {
    data = JSON.parse(text) as UploadResponse;
  } catch {
    throw new Error(text || "Image upload failed");
  }

  if (!response.ok || !data.success || !data.path) {
    throw new Error(data.error || "Image upload failed");
  }

  return {
    path: data.path,
    url: encodeImageUrl(pathToPublicUrl(data.path)),
  };
}

export async function uploadImageBuffer(
  buffer: Buffer,
  filename: string,
  mimeType = "image/jpeg"
): Promise<UploadedImage> {
  const formData = new FormData();
  const blob = new Blob([new Uint8Array(buffer)], { type: mimeType });
  formData.append("file", blob, filename);

  const response = await fetch(UPLOAD_URL, {
    method: "POST",
    body: formData,
  });

  return parseUploadResponse(response);
}

export async function uploadBase64Image(image: string): Promise<UploadedImage> {
  const dataUrlMatch = image.match(/^data:(image\/[\w+.-]+);base64,(.+)$/i);
  const base64 = dataUrlMatch ? dataUrlMatch[2] : image;
  let buffer = Buffer.from(base64, "base64");

  if (buffer.length === 0) {
    throw new Error("Empty image data received");
  }

  const declaredMime = dataUrlMatch?.[1]?.toLowerCase();
  const isHeic =
    isHeicBuffer(buffer) ||
    declaredMime === "image/heic" ||
    declaredMime === "image/heif";

  if (isHeic) {
    try {
      buffer = await convertHeicToJpeg(buffer);
    } catch {
      throw new Error(
        "Failed to convert HEIC image. Please use JPG or PNG photos."
      );
    }
  }

  const detected = detectImageMime(buffer);
  const filename = uniqueFilename(detected.extension);

  return uploadImageBuffer(buffer, filename, detected.mimeType);
}

export function normalizeImageList(
  images: string[] | null | undefined
): string[] {
  if (!images?.length) return [];
  return images.map(toPublicImageUrl);
}

export function toPublicImageUrl(storedValue: string): string {
  if (!storedValue) return storedValue;

  let url = storedValue;
  if (url.startsWith("http://") || url.startsWith("https://")) {
    url = url.replace(
      /^(https?:\/\/[^/]+)\/images\//,
      `$1${IMAGE_PATH}/`
    );
  } else {
    url = pathToPublicUrl(storedValue);
  }

  return encodeImageUrl(url);
}

export async function deleteImages(paths: string[]): Promise<void> {
  if (paths.length === 0) return;
  console.log("Image delete skipped (no remote delete API):", paths);
}
