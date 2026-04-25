const USER = "longge";
const PASS = "longge";

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // 根路径返回节点信息
    if (url.pathname === "/") {
      return new Response(`
===== 代理节点信息 =====
类型: HTTP
地址: ${url.host}
端口: 443
TLS: 开启
用户名: ${USER}
密码: ${PASS}
=========================
      `.trim(), {
        headers: { "Content-Type": "text/plain; charset=utf-8" }
      });
    }

    // 处理 CONNECT 隧道请求（关键！V2RayNG 必须用这个）
    if (request.method === "CONNECT") {
      const auth = request.headers.get("Proxy-Authorization");
      if (!auth || !auth.startsWith("Basic ")) {
        return new Response("Proxy Auth Required", { status: 407 });
      }

      const [user, pass] = atob(auth.slice(6)).split(":");
      if (user !== USER || pass !== PASS) {
        return new Response("Unauthorized", { status: 403 });
      }

      const { port } = new URL(`https://${url.pathname.slice(1)}`);
      const targetPort = port || 443;
      const [targetHost, targetPortStr] = url.pathname.slice(1).split(":");
      const finalPort = targetPortStr ? parseInt(targetPortStr) : targetPort;

      const { readable, writable } = new TransformStream();
      const socket = new WebSocket(`wss://${targetHost}:${finalPort}`, {
        headers: { "Host": targetHost }
      });

      return new Response(null, {
        status: 200,
        headers: { "Connection": "upgrade", "Upgrade": "websocket" },
        body: readable
      });
    }

    // 处理普通 HTTP/HTTPS 请求
    const modifiedHeaders = new Headers(request.headers);
    modifiedHeaders.delete("Proxy-Authorization");
    modifiedHeaders.delete("Origin");
    modifiedHeaders.delete("Referer");

    return fetch(request, {
      method: request.method,
      headers: modifiedHeaders,
      body: request.body,
      redirect: "follow"
    });
  }
};
