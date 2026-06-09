import dotenv from "dotenv";

dotenv.config();

const UPLOAD_URL =
  process.env.IMAGE_UPLOAD_URL || "https://st79068.ispot.cc/upload.php";
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

function buildImageUrl(filename: string): string {
  const base = IMAGE_BASE_URL.replace(/\/$/, "");
  const folder = IMAGE_PATH.replace(/^\/|\/$/g, "");
  return `${base}/${folder}/${filename}`;
}

function filenameFromPath(path: string): string {
  return path.split("/").pop() || path;
}

async function parseUploadResponse(
  response: Response
): Promise<UploadedImage> {
  const data = (await response.json()) as UploadResponse;

  if (!response.ok || !data.success || !data.path) {
    throw new Error(data.error || "Image upload failed");
  }

  const filename = filenameFromPath(data.path);
  return {
    path: data.path,
    url: buildImageUrl(filename),
  };
}

export async function uploadImageBuffer(
  buffer: Buffer,
  filename: string,
  mimeType = "image/jpeg"
): Promise<UploadedImage> {
  const formData = new FormData();
  const blob = new Blob([buffer], { type: mimeType });
  formData.append("file", blob, filename);

  const response = await fetch(UPLOAD_URL, {
    method: "POST",
    body: formData,
  });

  return parseUploadResponse(response);
}

export async function uploadBase64Image(image: string): Promise<UploadedImage> {
  const dataUrlMatch = image.match(/^data:(image\/[\w+.-]+);base64,(.+)$/);
  const base64 = dataUrlMatch ? dataUrlMatch[2] : image;
  const mimeType = dataUrlMatch?.[1] || "image/jpeg";
  const extension = mimeType.split("/")[1]?.replace("jpeg", "jpg") || "jpg";
  const filename = `upload_${Date.now()}.${extension}`;

  const response = await fetch(UPLOAD_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      base64,
      filename,
    }),
  });

  return parseUploadResponse(response);
}

export function normalizeImageList(
  images: string[] | null | undefined
): string[] {
  if (!images?.length) return [];
  return images.map(toPublicImageUrl);
}

export function toPublicImageUrl(storedValue: string): string {
  if (!storedValue) return storedValue;
  if (storedValue.startsWith("http://") || storedValue.startsWith("https://")) {
    return storedValue;
  }

  const filename = filenameFromPath(storedValue);
  return buildImageUrl(filename);
}

export async function deleteImages(paths: string[]): Promise<void> {
  if (paths.length === 0) return;
  console.log("Image delete skipped (no remote delete API):", paths);
}
