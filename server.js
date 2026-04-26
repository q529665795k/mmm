const express=require('express');
const axios=require('axios');
const app=express();
app.use(express.json());
let reqCount=0;
setInterval(()=>reqCount=0,3*60*1000);

app.post('/',async(req,res)=>{
  if(reqCount>=30) return res.send("服务器保护中，稍后再发~");
  reqCount++;
  try{
    let r=await axios.post("http://127.0.0.1:11434/api/chat",{
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
