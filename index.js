// 全网最简VLESS代理 - 免KV免密码免多账号
export default {
  async fetch(request) {
    const host = request.headers.get('host');
    const uuid = '6ba7b810-9dad-11d1-80b4-00c04fd430c8'; // 固定唯一ID，不用改
    
    // 处理WebSocket代理请求
    if (request.headers.get('upgrade') === 'websocket') {
      const { 0: client, 1: server } = new WebSocketPair();
      server.accept();
      client.addEventListener('message', e => server.send(e.data));
      server.addEventListener('message', e => client.send(e.data));
      return new Response(null, { status: 101, webSocket: client });
    }
    
    // 网页界面 - 一键复制节点
    const nodeLink = `vless://${uuid}@${host}:443?path=%2F&security=tls&encryption=none&type=ws&host=${host}#自用Worker节点`;
    return new Response(`
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<title>自用节点</title>
<style>
body{background:#0d1117;color:#fff;font-family:Arial;padding:20px;}
.box{background:#161b22;padding:20px;border-radius:10px;max-width:600px;margin:0 auto;}
h2{color:#58a6ff;}
.link{background:#21262d;padding:15px;border-radius:5px;word-break:break-all;margin:20px 0;color:#7ee787;}
.copy{background:#238636;border:none;color:#fff;padding:10px 20px;border-radius:5px;cursor:pointer;font-size:16px;}
</style>
</head>
<body>
<div class="box">
<h2>✅ 你的专属节点（一键复制）</h2>
<div class="link" id="node">${nodeLink}</div>
<button class="copy" onclick="navigator.clipboard.writeText(document.getElementById('node').innerText);alert('复制成功！去NekoBox导入即可')">一键复制节点</button>
</div>
</body>
</html>
`, { headers: { 'content-type': 'text/html' } });
  }
};
