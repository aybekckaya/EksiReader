import { SERVICE_NAME } from "../config";
import { jsonResponse } from "../utils/response";

export function healthRoute(): Response {
  return jsonResponse({ status: "ok", service: SERVICE_NAME });
}
