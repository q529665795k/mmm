let UUID = "8014ba50-a0f1-41b4-949f-066b7948ed0d";
export default {
  async fetch(request) {
    let url = new URL(request.url);
    // 首页显示节点
    if (url.pathname === "/") {
      return new Response(`
地址：${url.host}
端口：443
类型：VMess+WS+TLS
路径：/ws
UUID：${UUID}
`, { headers: { "Content-Type": "text/plain" } });
    }
    // 真正隧道转发
    if (url.pathname === "/ws") {
      if (request.headers.get("upgrade") !== "websocket") {
        return new Response("Error", { status: 400 });
      }
      const [client, server] = new WebSocketPair();
      server.accept();
      async function forward(from, to) {
        from.onmessage = e => to.send(e.data);
        from.onclose = () => to.close();
        from.onerror = () => to.close();
      }
      return new Response(null, {
        status: 101,
        headers: {
          "Upgrade": "websocket",
          "Connection": "upgrade"
        },
        webSocket: client
      });
    }
    return new Response("404");
  }
}
