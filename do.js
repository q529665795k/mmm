export class SOCKS_DO {
  constructor(state, env) {
    this.state = state;
    this.env = env;
  }
  async fetch(request) {
    const [client, server] = Object.values(new WebSocketPair());
    server.accept();
    server.addEventListener("message", async (e) => {
      try {
        await this.handle(server, e.data);
      } catch {
        server.close();
      }
    });
    return new Response(null, {
      status: 101,
      webSocket: client,
    });
  }
  async handle(ws, data) {
    const v = new Uint8Array(data);
    if (v[0] === 0x05) {
      ws.send(new Uint8Array([0x05, 0x00]));
      return;
    }
    if (v[0] === 0x05 && v[1] === 0x01) {
      const atyp = v[3];
      let host, port;
      if (atyp === 0x01) {
        host = `${v[4]}.${v[5]}.${v[6]}.${v[7]}`;
        port = (v[8] << 8) | v[9];
      } else if (atyp === 0x03) {
        const len = v[4];
        host = new TextDecoder().decode(v.slice(5, 5 + len));
        port = (v[5 + len] << 8) | v[6 + len];
      } else {
        ws.close();
        return;
      }
      try {
        const conn = await Deno.connect({ hostname: host, port });
        ws.send(new Uint8Array([0x05, 0x00, 0x00, 0x01, 0, 0, 0, 0, 0, 0]));
        ws.readable.pipeTo(conn.writable);
        conn.readable.pipeTo(ws.writable);
      } catch {
        ws.close();
      }
    }
  }
}
