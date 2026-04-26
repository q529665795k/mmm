const express = require("express");
const axios = require("axios");
const cheerio = require("cheerio");
const app = express();
const ollama = require('ollama');

let modelLoaded = false;
let totalChatCount = 0;
let errorCount = 0;

ollama.chat({ model: 'qwen:0.5b', messages: [{ role: 'user', content: '测试' }] })
  .then(() => { modelLoaded = true; console.log("✅ AI模型已加载完成"); })
  .catch(err => { errorCount++; console.error("❌ 模型加载失败：", err); });

const PORT = process.env.PORT || 3000;
const A_HOST = "https://chat-server-1-21uh.onrender.com/";
const PING_INTERVAL = 180000;

app.use(express.json());

app.get('/api/status', (req, res) => {
  const memUsage = process.memoryUsage();
  res.json({
    running: true,
    aiServiceStatus: "running",
    aiModelLoaded: modelLoaded,
    modelNameVersion: "qwen:0.5b",
    inferenceDelay: "--",
    todayChatCount: totalChatCount,
    contextLimit: "默认限制",
    modelMemoryUsage: (memUsage.heapUsed / 1024 / 1024).toFixed(2) + " MB",
    crossServerStatus: "互通正常",
    backupServiceStatus: "已开启",
    cronStatus: "正常待命",
    apiAccessCount: totalChatCount,
    errorCount: errorCount,
    systemLoad: "--",
    cacheStatus: "正常"
  });
});

async function getWeather(city = "南宁") {
  try {
    const res = await axios.get(`https://tianqi.2345.com/weather/${city}`, { timeout: 10000 });
    const $ = cheerio.load(res.data);
    const temp = $(".temp").text().trim() || "未知";
    const weather = $(".wea").text().trim() || "未知";
    return `${city}现在${weather}，气温${temp}℃`;
  } catch {
    return "天气暂时查不到哦";
  }
}

async function getHotSearch() {
  try {
    const res = await axios.get("https://s.weibo.com/top/summary", { timeout: 10000 });
    const $ = cheerio.load(res.data);
    let list = [];
    $(".td-02 a").each((i, el) => { if (i < 5) list.push($(el).text().trim()); });
    return "现在网上热门话题：" + list.join("、");
  } catch {
    return "热搜暂时加载不出来";
  }
}

function needWebSearch(text) {
  const key = ["天气","气温","下雨","冷","热","热搜","热点","新闻","时间","几号","星期","日期"];
  return key.some(w => text.includes(w));
}

const systemPrompt = `
你是一位温柔、说话很自然、像现实真人女生一样聊天的小姐姐。
回答简短、生活化、口语化，不要机器感、不要书面腔。
正常接话、轻松闲聊，贴合对方情绪。
查到的天气、热搜、时间用随口聊天的方式说出来，不要生硬罗列。
`;

const defaultReplyList = [
  "我在呢，慢慢说～",
  "嗯嗯，一直在哦",
  "哈哈，挺有意思的",
  "那你接着讲讲呗",
  "收到啦～"
];

async function autoPing() {
  const start = Date.now();
  try {
    await axios.get(A_HOST, { timeout: 8000 });
    const ms = Date.now() - start;
    console.log(`[保活正常] A机延迟：${ms}ms`);
  } catch {
    console.log("[保活异常] 无法连接A机");
  }
}
setInterval(autoPing, PING_INTERVAL);
autoPing();

app.get("/", (req, res) => {
  res.send("AI真人小姐姐｜联网爬虫｜3分钟自动保活 运行正常");
});

app.post("/api/chat", async (req, res) => {
  try {
    const { messages } = req.body;
    const userTxt = messages?.[0]?.content || "";
    if (!userTxt) return res.json({ reply: "怎么啦～" });

    let netInfo = "";
    if (needWebSearch(userTxt)) {
      if (userTxt.includes("天气")) netInfo = await getWeather();
      else if (userTxt.includes("热搜")) netInfo = await getHotSearch();
      else if (userTxt.includes("时间") || userTxt.includes("日期")) {
        netInfo = "现在：" + new Date().toLocaleString("zh-CN");
      }
    }

    totalChatCount++;

    const aiMessages = [{ role: "system", content: systemPrompt }];
    if (netInfo) {
      aiMessages.push({ role: "user", content: `[联网信息] ${netInfo}\n用户说：${userTxt}` });
    } else {
      aiMessages.push({ role: "user", content: userTxt });
    }

    const response = await ollama.chat({
      model: "qwen:0.5b",
      messages: aiMessages,
      stream: false
    });

    res.json({ reply: response.message.content || defaultReplyList[Math.floor(Math.random() * defaultReplyList.length)] });
  } catch (e) {
    errorCount++;
    console.error("AI生成失败：", e);
    res.json({ reply: defaultReplyList[Math.floor(Math.random() * defaultReplyList.length)] });
  }
});

app.listen(PORT, () => {
  console.log(`B机服务运行在端口 ${PORT}`);
});
