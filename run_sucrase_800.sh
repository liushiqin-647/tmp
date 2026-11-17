#!/usr/bin/env bash
# alangpierce__sucrase-800.replay.json 里的重点命令（npx tsc / npm test），按原轨迹顺序执行
# 用法: bash /home/liushiqin/tmp/run_sucrase_800.sh   （需要先准备 /testbed）

cd /testbed || { echo "没有 /testbed 目录，先准备好代码"; exit 1; }

TOTAL_MS=0
FAILS=0
RESULTS=()

run() {
  echo
  echo ">>> 开始 $(date '+%H:%M:%S.%3N')  $1"
  local start=$(date +%s%3N)
  bash -lc "$1"
  local rc=$?
  local end=$(date +%s%3N)
  local ms=$((end - start))
  echo "<<< 结束 $(date '+%H:%M:%S.%3N')  用时 ${ms}ms  退出码 $rc"
  TOTAL_MS=$((TOTAL_MS + ms))
  [ "$rc" -ne 0 ] && FAILS=$((FAILS + 1))
  RESULTS+=("$(printf '%8sms  rc=%-3s %s' "$ms" "$rc" "${1:0:100}")")
  return $rc
}

run 'npx tsc 2>&1 | head -30'
run 'npx tsc --noEmit test.ts 2>&1'
run 'npx tsc --project tsconfig.json 2>&1 | grep -i error | head -10'
run 'npm test 2>&1 | tail -50'

echo
echo "===== 汇总 ====="
printf '%s\n' "${RESULTS[@]}"
echo "----------------"
echo "命令数: ${#RESULTS[@]}  失败: ${FAILS}  总耗时: ${TOTAL_MS}ms"
