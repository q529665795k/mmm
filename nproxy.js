// 固定密钥 跟你对接的UUID
const UUID = "8014ba50-a0f1-41b4-949f-066b7948ed0d";

export default {
  async fetch(req) {
    const url = new URL(req.url);

    // 根目录 / 只展示节点（纯文字，不占用隧道）
    if (url.pathname === "/") {
      return new Response(`
✅ 正常运行
地址: ${url.host}
端口: 443
类型: VMess+WS+TLS
隧道路径: /vmess
UUID: ${UUID}
`, {
        headers: { "Content-Type": "text/plain;charset=utf-8" }
      });
    }

    // 严格绑定隧道路径 /vmess  带斜杠，和配置完全一致
    if (url.pathname === "/vmess") {
      // 校验是否为WebSocket请求
      if (req.headers.get("upgrade")?.toLowerCase() !== "websocket") {
        return new Response("400 Only WebSocket", { status: 400 });
      }

      const [clientWs, serverWs] = new WebSocketPair();
      serverWs.accept();

      // 纯本地双向转发，不带任何外部域名
      serverWs.addEventListener("message", (event) => {
        if (serverWs.readyState === WebSocket.OPEN) {
          serverWs.send(event.data);
        }
      });

      serverWs.addEventListener("close", () => serverWs.close());
      serverWs.addEventListener("error", () => serverWs.close());

      // 完成101握手
      return new Response(null, {
        status: 101,
        headers: {
          "Upgrade": "websocket",
          "Connection": "Upgrade"
        },
        webSocket: clientWs
      });
    }

    return new Response("404", { status: 404 });
  }
};
