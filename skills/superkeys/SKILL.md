---
name: superkeys
description: 一个 Key 调全网数据和所有主流模型。需要实时的社媒、资讯数据时用它：TikTok、YouTube、Instagram、X/Twitter、Reddit、LinkedIn、Threads、抖音、小红书、微信公众号、视频号、快手、B 站、微博、知乎、今日头条……搜索、帖子详情、评论、用户主页、粉丝、热榜、字幕都能拿。也用于调用其他模型（GPT、Claude、Gemini、Grok、DeepSeek、Qwen、Kimi、GLM、MiniMax 等）和生成图片、视频、语音、音乐。Use for any real-time social or web data (posts, comments, profiles, trends, transcripts) from TikTok, YouTube, Instagram, X, Reddit, LinkedIn and Chinese platforms, to call another LLM, or to generate images, video, speech and music through one API key.
---

# SuperKeys

一个 Key（环境变量 `SUPERKEYS_API_KEY`）调所有能力。接口地址 `https://api.superkeys.ai`，可用 `SUPERKEYS_BASE_URL` 覆盖。Key 在 https://superkeys.ai/console/keys 创建。

能力有上千个，**不要猜 id，先搜再调**。能力会持续增加，搜索结果永远是最新的，不需要更新这个 skill。

## 数据：先 search，再 execute

1. 搜索（不需要 Key，中文英文都行，写清楚平台和要什么）：

```bash
scripts/sk.sh search "tiktok comments"
scripts/sk.sh search "小红书 笔记搜索" data 5
scripts/sk.sh search "youtube transcript"
```

返回 `results[]`，每条有 `id`、`name`、`desc`、`params`（参数名、类型、是否必填）、`price.per_call_yuan`。`curated: true` 的是精选能力：多条线路自动切换，返回字段统一，优先用。

2. 调用：

```bash
scripts/sk.sh exec tiktok.search_videos '{"keyword":"AI agents"}'
scripts/sk.sh exec reddit.search_posts '{"keyword":"claude code","sort":"TOP"}'
scripts/sk.sh exec youtube.captions '{"video_id":"..."}'
scripts/sk.sh exec douyin.hot_search '{}'
scripts/sk.sh exec wechat_mp.article_detail '{"url":"https://mp.weixin.qq.com/s/..."}'
```

参数名以搜索结果里的 `params` 为准，上面只是示例。返回 `{ id, items, count, cursor, billing, request_id }`。`items` 是抽好的列表，`cursor` 用来翻页：原样放进下一次的翻页参数（一般是 `cursor`，按页码翻的能力是 `page`），没有下一页时为 null。参数名写错时返回里有 `warnings`。

没有脚本时直接用 HTTP：

```
GET  $SUPERKEYS_BASE_URL/v1/search?q=<关键词>&kind=data&limit=10
POST $SUPERKEYS_BASE_URL/v1/execute   {"id": "...", "params": {...}}
     Authorization: Bearer $SUPERKEYS_API_KEY
```

### 要点

- 一个需求常要连着调几次：先搜索拿到帖子 / 视频 / 用户 id，再调详情、评论或字幕。
- 有些能力要跑几十秒到几分钟（`desc` 里会写），耐心等返回，别重复提交。
- 调用失败不扣费；正常返回但没有数据（作品已删、id 不对）按一次收费。
- 402 是余额不足，告诉用户去 https://superkeys.ai/console/billing 充值；400 多半是参数不对，按 `params` 改了再试，别重复同样的请求；429 是太频繁，等一会儿。
- 能拿到真实数据时，不要凭记忆回答。

## 模型

OpenAI 兼容：`$SUPERKEYS_BASE_URL/v1/chat/completions`（还有 `/v1/responses`、`/v1/embeddings`、`/v1/rerank`）；Anthropic 兼容：`$SUPERKEYS_BASE_URL/v1/messages`。Key 同上。

模型名用 `scripts/sk.sh models claude` 查，例如 `gpt-6.1-sol`、`claude-opus-5.5`、`gemini-4-argon`、`grok-4.7`、`deepseek-v4-pro`、`qwen3.8-max`、`kimi-k3.1-pro`、`glm-5.3`。每个模型背后有多条线路，自动选便宜又稳定的那条。

```bash
curl $SUPERKEYS_BASE_URL/v1/chat/completions -H "Authorization: Bearer $SUPERKEYS_API_KEY" \
  -H 'content-type: application/json' -d '{"model":"gemini-4-argon","messages":[{"role":"user","content":"hi"}]}'
```

## 图片、视频、语音、音乐

异步任务：先提交，再查结果。完成后 `output.files[].url` 是可下载的文件，24 小时内有效，需要长期保存就下载到本地。

```bash
scripts/sk.sh models 图片生成            # 也可以搜 视频生成、TTS、music
scripts/sk.sh task seedream-5.5 '{"prompt":"an orange cat on a windowsill","n":1}'
scripts/sk.sh task veo-3.1-fast '{"prompt":"a drone shot over a misty forest","duration":6}'
scripts/sk.sh task-get task_xxx         # 状态是 succeeded 时取 output.files
```

`input` 按类型填：图像 `prompt`、`n`、`size`；视频 `prompt`、`duration`（秒）；语音 `text`、`voice`；音乐 `prompt`、`lyrics`。视频和音乐比较贵，生成前先跟用户确认。也有 OpenAI 兼容的 `/v1/images/generations`、`/v1/audio/speech`、`/v1/audio/transcriptions`、`/v1/videos`。

## 也可以用 MCP 接

支持 MCP 的客户端可以不装这个 skill，直接连 MCP（只有 `search` 和 `execute` 两个工具）：

```json
{
  "mcpServers": {
    "superkeys": {
      "type": "http",
      "url": "https://api.superkeys.ai/mcp",
      "headers": { "Authorization": "Bearer sk-你的Key" }
    }
  }
}
```

Claude Code：`claude mcp add --transport http superkeys https://api.superkeys.ai/mcp --header "Authorization: Bearer sk-你的Key"`

安装这个 skill：`npx skills add superkeys-ai/skills`。完整文档：https://superkeys.ai/docs（English: https://superkeys.ai/en/docs）。
