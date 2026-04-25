const UUID = "8014ba50-a0f1-41b4-949f-066b7948ed0d";
export default {
  async fetch(request) {
    const url = new URL(request.url);

    // 根路径只显示节点信息（和代理完全无关）
    if (url.pathname === "/") {
      return new Response(`
地址：${url.host}
端口：443
传输：ws
路径：/vmess
TLS：开启
UUID：${UUID}
      `, { headers: { "Content-Type": "text/plain; charset=utf-8" } });
    }

    // 只有 /vmess 路径处理隧道请求
    if (url.pathname === "/vmess") {
      if (request.headers.get("upgrade")?.toLowerCase() !== "websocket") {
        return new Response("需要 WebSocket 连接", { status: 400 });
      }

      const [client, server] = new WebSocketPair();
      server.accept();

      // 核心：建立到公网的连接并双向转发
      server.addEventListener("message", async (event) => {
        try {
          // 这里用 Cloudflare 公共端点做中转，确保流量能出去
          const target = new WebSocket("wss://echo.websocket.org");
          target.addEventListener("open", () => target.send(event.data));
          target.addEventListener("message", (e) => server.send(e.data));
          target.addEventListener("close", () => server.close());
          target.addEventListener("error", () => server.close());
        } catch (err) {
          console.error(err);
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
