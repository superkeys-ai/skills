# SuperKeys Skills

一个 API Key 接通主流大模型和全网数据。装上这个 Skill，Agent 就能搜 TikTok、YouTube、X、Reddit、小红书、抖音、公众号等平台的实时数据，调用 GPT、Claude、Gemini、DeepSeek、Qwen 等模型，生成图片、视频、语音和音乐。

One API key for every major AI model and live data from the open web. With this skill, your agent can pull real-time posts, comments, profiles, trends and transcripts from TikTok, YouTube, X, Reddit, Instagram, Xiaohongshu, Douyin and more, call GPT, Claude, Gemini, DeepSeek or Qwen, and generate images, video, speech and music.

## 安装 / Install

```bash
npx skills add superkeys-ai/skills
```

支持 Claude Code、Codex、Cursor、OpenClaw 等。Works with Claude Code, Codex, Cursor, OpenClaw and other agents that support skills.

然后设置 Key / Then set your key:

```bash
export SUPERKEYS_API_KEY=sk-...
```

Key 在 https://superkeys.ai 注册后创建。Get a key at https://superkeys.ai.

## MCP

不装 Skill 也可以直接连 MCP（工具：`search`、`execute`）。Or connect over MCP instead (tools: `search`, `execute`):

```bash
claude mcp add --transport http superkeys https://api.superkeys.ai/mcp --header "Authorization: Bearer sk-..."
```

## 文档 / Docs

- 中文：https://superkeys.ai/docs
- English: https://superkeys.ai/en/docs
- OpenAI 兼容 base URL / OpenAI-compatible base URL: `https://api.superkeys.ai/v1`
- Anthropic 兼容 base URL / Anthropic-compatible base URL: `https://api.superkeys.ai`

## License

MIT
