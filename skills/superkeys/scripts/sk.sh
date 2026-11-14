#!/usr/bin/env bash
# SuperKeys 命令行小工具
#   sk.sh search "tiktok comments" [data|model] [limit]   找能力（不用 Key）
#   sk.sh exec <id> '<params json>'                       调用数据能力
#   sk.sh models [关键词] [limit]                          找模型
#   sk.sh task <model> '<input json>'                     提交图片、视频、语音、音乐任务
#   sk.sh task-get <task id>                              查任务结果
#   sk.sh me                                              余额和最近的调用
set -euo pipefail
BASE="${SUPERKEYS_BASE_URL:-https://api.superkeys.ai}"
BASE="${BASE%/}"
KEY="${SUPERKEYS_API_KEY:-}"
need_key() { [[ -n "$KEY" ]] || { echo "缺少 SUPERKEYS_API_KEY（在 https://superkeys.ai/console/keys 创建）" >&2; exit 2; }; }
# id、模型名只允许字母数字和 . _ - ~ /，避免拼 JSON 时出错
check_id() { [[ "$1" =~ ^[A-Za-z0-9._~/-]+$ ]] || { echo "id 格式不对：$1" >&2; exit 2; }; }
cmd="${1:-}"; shift || true
case "$cmd" in
  search)
    q="${1:?用法: sk.sh search <关键词> [data|model] [limit]}"
    curl -sS -G "$BASE/v1/search" --data-urlencode "q=$q" --data-urlencode "kind=${2:-}" --data-urlencode "limit=${3:-10}" ;;
  exec|execute)
    need_key
    id="${1:?用法: sk.sh exec <id> '<params json>'}"; params="${2:-}"; [[ -n "$params" ]] || params='{}'
    check_id "$id"
    curl -sS "$BASE/v1/execute" -H "Authorization: Bearer $KEY" -H 'content-type: application/json' \
      -d "{\"id\":\"$id\",\"params\":$params}" ;;
  models)
    curl -sS -G "$BASE/v1/search" --data-urlencode "q=${1:-}" --data-urlencode "kind=model" --data-urlencode "limit=${2:-20}" ;;
  task)
    need_key
    model="${1:?用法: sk.sh task <model> '<input json>'}"; input="${2:-}"; [[ -n "$input" ]] || input='{}'
    check_id "$model"
    curl -sS "$BASE/v1/tasks" -H "Authorization: Bearer $KEY" -H 'content-type: application/json' \
      -d "{\"model\":\"$model\",\"input\":$input}" ;;
  task-get)
    need_key
    id="${1:?用法: sk.sh task-get <task id>}"; check_id "$id"
    curl -sS "$BASE/v1/tasks/$id" -H "Authorization: Bearer $KEY" ;;
  me)
    need_key
    curl -sS "$BASE/v1/me" -H "Authorization: Bearer $KEY" ;;
  *)
    sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//' >&2; exit 2 ;;
esac
