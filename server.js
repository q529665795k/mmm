const express = require("express");
const axios = require("axios");
const cheerio = require("cheerio");
const app = express();
// 动态端口，彻底解决端口占用、固定端口冲突
const PORT = process.env.PORT || 3000;

const A_HOST = "https://chat-server-1-21uh.onrender.com/";
const PING_INTERVAL = 180000;

app.use(express.json());

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
    $(".td-02 a").each((i, el) => {
      if (i < 5) list.push($(el).text().trim());
    });
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

// 内置兜底回复（集成后端里，最简单省事）
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

    const content = netInfo ? `实时信息：${netInfo}\n对方：${userTxt}` : userTxt;

    // 极低配置小模型，低配机器也能跑，CPU占用极低
    const aiRes = await axios.post("http://127.0.0.1:11434/api/chat", {
      model: "qwen:0.5b",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: content }
      ],
      stream: false
    }, { timeout: 8000 });

    const reply = aiRes.data?.message?.content || defaultReplyList[Math.floor(Math.random() * defaultReplyList.length)];
    res.json({ reply });

  } catch (err) {
    console.error(err);
    // 异常直接调用后端内置回复，不崩服务
    const rndReply = defaultReplyList[Math.floor(Math.random() * defaultReplyList.length)];
    res.json({ reply: rndReply });
  }
});

app.listen(PORT, () => {
  console.log(`B机服务启动成功，动态端口：${PORT}`);
});
