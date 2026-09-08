import type { ErrorResponse } from "../models/api";

const CORS_HEADERS: HeadersInit = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Max-Age": "86400",
};

export function jsonResponse(data: unknown, status = 200): Response {
  return Response.json(data, {
    status,
    headers: CORS_HEADERS,
  });
}

export function errorResponse(code: string, message: string, status: number): Response {
  const body: ErrorResponse = {
    success: false,
    error: { code, message },
  };
  return jsonResponse(body, status);
}

export function optionsResponse(): Response {
  return new Response(null, { status: 204, headers: CORS_HEADERS });
}
