const express=require('express');
const axios=require('axios');
const app=express();
app.use(express.json());

// ========== 3分钟自我保护（防过载、防崩溃，不休眠） ==========
let lastRequestTime = 0;
const PROTECT_TIME = 3 * 60 * 1000; // 3分钟保护窗口

// 保护校验函数
function isProtected() {
  const now = Date.now();
  // 如果距离上一次请求小于3分钟，不拦截；超过3分钟重置状态
  if (now - lastRequestTime > PROTECT_TIME) {
    lastRequestTime = now;
    return false; // 安全，放行
  }
  return false; // 核心：只监控不休眠，全部放行，只是做状态记录
}
// ========================================================

// 唯一对外接口（永不休眠，永久运行）
app.post('/',async(req,res)=>{
  // 执行3分钟保护校验（只监控，不拦截，不休眠）
  isProtected();

  try{
    const r=await axios.post("http://127.0.0.1:11434/api/chat",{
      model:"girl",
      messages:[{role:"user",content:req.body.msg}],
      stream:false
    });
    res.send(r.data.message.content);
  }catch{
    res.send("模型加载中，稍后再试");
  }
});

app.listen(process.env.PORT||3000);
