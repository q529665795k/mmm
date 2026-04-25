const USER = "longge";
const PASS = "longge";

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // 访问根路径返回节点信息
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

    // 代理鉴权
    const auth = request.headers.get("proxy-authorization");
    if (!auth || !auth.startsWith("Basic ")) {
      return new Response("Proxy Auth Required", { status: 407 });
    }

    const [user, pass] = atob(auth.slice(6)).split(":");
    if (user !== USER || pass !== PASS) {
      return new Response("Unauthorized", { status: 403 });
    }

    // 代理转发
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
