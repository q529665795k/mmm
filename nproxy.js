// 固定 UUID，和你之前生成的保持一致，不会再变
const UUID = "8014ba50-a0f1-41b4-949f-066b7948ed0d";

export default {
  async fetch(req) {
    const u = new URL(req.url);
    const h = u.host;

    if (u.pathname === "/") {
      const txt = `
——————————————
  CF WS 代理节点（固定版）
——————————————
地址：${h}
端口：443
类型：VMess
网络：ws
路径：/ws
TLS：开启
SNI：${h}
UUID：${UUID}
AID：0

【一键导入JSON】
{"v":"2","ps":"CF-WS","add":"${h}","port":"443","id":"${UUID}","aid":0,"scy":"auto","net":"ws","type":"none","host":"${h}","path":"/ws","tls":"tls","sni":"${h}"}
`;
      return new Response(txt.trim(), {
        headers: { "Content-Type":"text/plain;charset=utf-8" }
      });
    }

    if (u.pathname === "/ws") {
      const [client, sock] = Object.values(new WebSocketPair());
      sock.accept();
      return new Response(null, { status: 101, webSocket: client });
    }

    return new Response("404", {status:404});
  }
};
