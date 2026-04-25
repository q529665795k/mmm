// Worker 启动时自动生成一个随机 UUID
let UUID = crypto.randomUUID();

export default {
  async fetch(request) {
    const url = new URL(request.url);
    const host = url.host;

    // 访问根路径，自动生成节点信息
    if (url.pathname === "/") {
      const nodeInfo = `
===== V2RayNG 节点信息 =====
协议: VMess
地址: ${host}
端口: 443
UUID: ${UUID}
额外ID(alterId): 0
加密方式: auto
传输协议: ws
Host: ${host}
路径: /ws
TLS: 开启
SNI: ${host}
=========================
复制下面的 JSON 直接导入 V2RayNG:
{
  "v": "2",
  "ps": "CF-WS-Proxy",
  "add": "${host}",
  "port": "443",
  "id": "${UUID}",
  "aid": "0",
  "scy": "auto",
  "net": "ws",
  "type": "none",
  "host": "${host}",
  "path": "/ws",
  "tls": "tls",
  "sni": "${host}"
}
`;
      return new Response(nodeInfo.trim(), {
        headers: { "Content-Type": "text/plain; charset=utf-8" }
      });
    }

    // WebSocket 代理核心逻辑
    if (url.pathname === "/ws") {
      if (request.headers.get("Upgrade") !== "websocket") {
        return new Response("Bad Request: Need WebSocket", { status: 400 });
      }

      const [client, server] = Object.values(new WebSocketPair());
      server.accept();

      server.addEventListener("message", async (event) => {
        try {
          const decoder = new TextDecoder();
          const msg = JSON.parse(decoder.decode(event.data));
          const targetHost = msg.host;
          const targetPort = msg.port || 443;

          const targetSocket = new WebSocket(`wss://${targetHost}:${targetPort}`);
          targetSocket.addEventListener("open", () => {
            targetSocket.addEventListener("message", (e) => {
              server.send(e.data);
            });
          });

          server.addEventListener("message", (e) => {
            if (targetSocket.readyState === WebSocket.OPEN) {
              targetSocket.send(e.data);
            }
          });

          targetSocket.addEventListener("close", () => server.close());
          targetSocket.addEventListener("error", () => server.close());
        } catch (err) {
          server.close();
        }
      });

      return new Response(null, {
        status: 101,
        headers: {
          "Upgrade": "websocket",
          "Connection": "Upgrade"
        },
        webSocket: client
      });
    }

    return new Response("404 Not Found", { status: 404 });
  }
};
