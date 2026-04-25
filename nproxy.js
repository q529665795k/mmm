const UUID = "8014ba50-a0f1-41b4-949f-066b7948ed0d";

export default {
  async fetch(req) {
    const url = new URL(req.url);
    const host = url.host;

    // 直接用根路径 / 处理所有请求
    if (req.headers.get("Upgrade")?.toLowerCase() === "websocket") {
      // 是 WebSocket 握手请求，直接返回 101
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
    } else {
      // 是浏览器访问，显示节点信息 + 一键复制JSON
      const json = JSON.stringify({
        "v": "2",
        "ps": "CF-WS代理",
        "add": host,
        "port": "443",
        "id": UUID,
        "aid": 0,
        "scy": "auto",
        "net": "ws",
        "type": "none",
        "host": host,
        "path": "/",
        "tls": "tls",
        "sni": host
      });

      const html = `
===== 节点信息 =====
地址: ${host}
端口: 443
UUID: ${UUID}
传输: ws
路径: /
TLS: 开启
SNI: ${host}

===== 一键复制JSON =====
${json}
      `;

      return new Response(html.trim(), {
        headers: { "Content-Type": "text/plain;charset=utf-8" }
      });
    }
  }
};
