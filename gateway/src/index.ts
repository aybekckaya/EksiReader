import { createServer } from "node:http";
import { createGatewayHandler } from "./server.js";

const token = process.env.GATEWAY_TOKEN ?? "";
const port = Number(process.env.PORT ?? "10000");

if (!Number.isSafeInteger(port) || port < 1 || port > 65_535) {
  throw new Error("PORT geçerli bir TCP portu olmalıdır.");
}

const handleRequest = createGatewayHandler({ token });
const server = createServer(async (incoming, outgoing) => {
  try {
    const host = incoming.headers.host ?? `localhost:${port}`;
    const headers = new Headers();
    for (const [name, value] of Object.entries(incoming.headers)) {
      if (Array.isArray(value)) {
        for (const item of value) {
          headers.append(name, item);
        }
      } else if (value !== undefined) {
        headers.set(name, value);
      }
    }
    const request = new Request(`http://${host}${incoming.url ?? "/"}`, {
      method: incoming.method ?? "GET",
      headers,
    });
    const response = await handleRequest(request);
    outgoing.writeHead(response.status, Object.fromEntries(response.headers.entries()));
    if (response.body === null) {
      outgoing.end();
      return;
    }
    outgoing.end(Buffer.from(await response.arrayBuffer()));
  } catch (error) {
    console.error("Gateway request işlenemedi.", error);
    outgoing.writeHead(500, { "Content-Type": "application/json; charset=utf-8" });
    outgoing.end(JSON.stringify({
      success: false,
      error: { code: "INTERNAL_ERROR", message: "Beklenmeyen bir hata oluştu." },
    }));
  }
});

server.listen(port, "0.0.0.0", () => {
  console.log(`EksiReader fetch gateway 0.0.0.0:${port} üzerinde çalışıyor.`);
});

function shutdown(): void {
  server.close((error) => {
    if (error) {
      console.error("Gateway kapatılamadı.", error);
      process.exitCode = 1;
    }
  });
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
