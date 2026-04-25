const UUID = "8014ba50-a0f1-41b4-949f-066b7948ed0d";

export default {
  async fetch(req) {
    const url = new URL(req.url);
    const host = url.host;

    if (url.pathname === "/") {
      return new Response(`
===== 节点信息 =====
地址: ${host}
端口: 443
UUID: ${UUID}
传输: ws
路径: /ws
TLS: 开启
SNI: ${host}
      `, { headers: { "Content-Type": "text/plain;charset=utf-8" } });
    }

    if (url.pathname === "/ws") {
      if (req.headers.get("Upgrade") !== "websocket") {
        return new Response("Bad Request", { status: 400 });
      }

      // 这是关键！用 WebSocketPair 正确握手
      const [client, server] = new WebSocketPair();
      server.accept();

      return new Response(null, {
        status: 101,
        headers: {
          "Upgrade": "websocket",
          "Connection": "Upgrade"
        },
        webSocket: client
      });
    }

    return new Response("Not Found", { status: 404 });
  }
};
