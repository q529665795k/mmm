export default {
  async fetch(request, env, ctx) {
    // 你的 Railway 节点是纯 HTTP，所以协议要写 http://
    const upHost = "shuttle.proxy.rlwy.net:29613";
    const authStr = "long:123456";
    const auth = "Basic " + btoa(authStr);

    // 拒绝 CONNECT 请求（因为 Worker 不支持）
    if (request.method === "CONNECT") {
      return new Response("CONNECT method not supported", { status: 501 });
    }

    // 强制用 http:// 去连你的节点
    const newUrl = new URL(`http://${upHost}${new URL(request.url).pathname}${new URL(request.url).search}`);

    const newHeaders = new Headers(request.headers);
    newHeaders.set("Proxy-Authorization", auth);

    const newRequest = new Request(newUrl, {
      method: request.method,
      headers: newHeaders,
      body: request.body,
      redirect: "follow"
    });

    return fetch(newRequest);
  }
};
