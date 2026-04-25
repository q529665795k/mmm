const PROXY_USER = "longge";
 const PROXY_PASS = "123456";

export default {
  async fetch(request) {
    const url = new URL(request.url);

    // 访问根路径直接输出节点信息
    if (url.pathname === "/" || url.pathname === "") {
      const workerHost = url.host;
      const proxyInfo = `
===== 代理节点信息 =====
类型: HTTP
地址: ${workerHost}
端口: 443
TLS: 开启
用户名: ${PROXY_USER}
密码: ${PROXY_USER}
=========================
      `;
      return new Response(proxyInfo.trim(), {
        headers: { "Content-Type": "text/plain; charset=utf-8" }
      });
    }

    // 正向代理核心逻辑
    const authHeader = request.headers.get("proxy-authorization");
    if (!authHeader) {
      return new Response("Proxy Auth Required", { status: 407 });
    }

    const [scheme, encoded] = authHeader.split(" ");
    if (scheme !== "Basic" || !encoded) {
      return new Response("Invalid Auth", { status: 403 });
    }

    const decoded = atob(encoded);
    const [user, pass] = decoded.split(":");
    if (user !== PROXY_USER || pass !== PROXY_PASS) {
      return new Response("Wrong User/Pass", { status: 403 });
    }

    const newHeaders = new Headers(request.headers);
    newHeaders.delete("Origin");
    newHeaders.delete("Referer");
    newHeaders.delete("CF-Connecting-IP");

    return fetch(request, {
      method: request.method,
      headers: newHeaders,
      body: request.body,
      redirect: "follow"
    });
  }
};
