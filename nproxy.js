export default {
  async fetch(request) {
    // 进到请求内部再生成随机UUID，规避10021报错
    const uuid = crypto.randomUUID();
    const url = new URL(request.url);
    const host = url.host;

    if (url.pathname === "/") {
      const info = `
===== 自动生成节点 =====
地址：${host}
端口：443
协议：VMess+WS+TLS
UUID：${uuid}
AID：0
传输：ws
路径：/ws
TLS：开启
SNI：${host}

===== 一键复制JSON =====
{"v":"2","ps":"CF代理","add":"${host}","port":"443","id":"${uuid}","aid":0,"scy":"auto","net":"ws","type":"none","host":"${host}","path":"/ws","tls":"tls","sni":"${host}","alpn":"h2,http/1.1"}
      `;
      return new Response(info.trim(), {
        headers: { "Content-Type": "text/plain;charset=utf-8" }
      });
    }

    if (url.pathname === "/ws") {
      if (request.headers.get("Upgrade") !== "websocket") {
        return new Response("400", { status: 400 });
      }
      const [client, server] = Object.values(new WebSocketPair());
      server.accept();
      return new Response(null, {
        status: 101,
        webSocket: client
      });
    }

    return new Response("404", { status: 404 });
  }
};
