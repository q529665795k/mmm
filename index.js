export default {
  async fetch(request, env) {
    const upgrade = request.headers.get("Upgrade");
    if (!upgrade || upgrade !== "websocket") {
      return new Response("Not found", { status: 404 });
    }
    const id = env.SOCKS_DO.idFromName("socks-proxy");
    const obj = env.SOCKS_DO.get(id);
    return obj.fetch(request);
  }
};
export { SOCKS_DO } from "./do.js";
