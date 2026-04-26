export default {
  async fetch(req) {
    const upHost = "shuttle.proxy.rlwy.net:29613";
    const authStr = "long:123456";
    const auth = "Basic " + btoa(authStr);
    const u = new URL(req.url);
    u.host = upHost;
    const newReq = new Request(u, req);
    newReq.headers.set("Proxy-Authorization", auth);
    return fetch(newReq);
  }
};
