export default {
  async fetch(request) {
    const host = request.headers.get('host');
    const uuid = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

    // 处理WebSocket代理
    if (request.headers.get('upgrade') === 'websocket') {
      const { 0: client, 1: server } = new WebSocketPair();
      server.accept();
      client.onmessage = e => server.send(e.data);
      server.onmessage = e => client.send(e.data);
      return new Response(null, { status: 101, webSocket: client });
    }

    // 网页一键复制节点
    const link = `vless://${uuid}@${host}:443?path=%2F&security=tls&encryption=none&type=ws&host=${host}#自用纯净节点`;
    return new Response(`
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>自用节点</title>
</head>
<body style="background:#000;color:#fff;padding:30px;">
<h2>✅ 节点链接（长按复制）</h2>
<p style="color:#0f0;word-break:break-all;">${link}</p>
</body>
</html>
`, { headers: { 'content-type': 'text/html' } });
  }
};
