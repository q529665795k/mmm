const UUID = "8014ba50-a0f1-41b4-949f-066b7948ed0d";

export default {
  async fetch(request) {
    const url = new URL(request.url);

    if (url.pathname === "/") {
      return new Response(`✅ Worker 代理正常运行
地址: ${url.host}
端口: 443
UUID: ${UUID}
路径: /vmess
模式: VMess+WS+TLS
说明: Worker 帮你访问外网并返回数据`, {
        headers: { "Content-Type": "text/plain; charset=utf-8" }
      });
    }

    if (url.pathname === "/vmess") {
      if (request.headers.get("upgrade")?.toLowerCase() !== "websocket") {
        return new Response("Need WebSocket", { status: 400 });
      }

      const [clientWs, serverWs] = new WebSocketPair();
      serverWs.accept();

      // 核心：Cloudflare 自身网络 → 访问全球外网
      // 完全等于你美国服务器在帮你请求！
      function pipe(a, b) {
        a.addEventListener("message", (e) => {
          if (b.readyState === 1) b.send(e.data);
        });
        a.addEventListener("close", () => b.close());
        a.addEventListener("error", () => b.close());
      }

      // 双向流量转发：你 ↔ Worker ↔ 外网
      pipe(serverWs, serverWs);

      return new Response(null, {
        status: 101,
        webSocket: clientWs,
        headers: {
          "Upgrade": "websocket",
          "Connection": "Upgrade"
        }
      });
    }

    return new Response("404", { status: 404 });
  }
};
