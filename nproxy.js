export default {
  async fetch(request, env, ctx) {
    const targetHost = "shuttle.proxy.rlwy.net:29613";
    const authStr = "long:123456";
    const auth = "Basic " + btoa(authStr);

    // 只处理 GET/POST 等常规请求，不处理 CONNECT
    if (request.method === "CONNECT") {
      return new Response("Not Implemented", { status: 501 });
    }

    const newUrl = new URL(request.url);
    newUrl.host = targetHost;

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
