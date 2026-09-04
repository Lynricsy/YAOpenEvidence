#!/usr/bin/env bash
# 由 ./PICOSGpt start 调用。用 vLLM 在 8000 端口提供 Qwen3。用法: scripts/vllm.sh [14b|4b] [GPU_ID]
set -e
SIZE="${1:-14b}"; GPU="${2:-2}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV=/data/anaconda3/envs/clarify
case "$SIZE" in
  14b) MODEL=/data1/clarify/qwen14b; NAME=Qwen3-14B; EXTRA="--reasoning-parser qwen3";;
  4b)  MODEL=/data1/clarify/qwen4b;  NAME=Qwen3-4B;  EXTRA="";;
  *) echo "unknown size $SIZE"; exit 1;;
esac
export PATH="$ENV/bin:$PATH"
export CUDA_DEVICE_ORDER=PCI_BUS_ID CUDA_VISIBLE_DEVICES="$GPU"
mkdir -p "$ROOT/logs"
echo "Starting vLLM: $NAME on GPU $GPU -> http://0.0.0.0:8000  (log: $ROOT/logs/vllm.log)"
exec "$ENV/bin/vllm" serve "$MODEL" \
  --host 0.0.0.0 --port 8000 \
  --served-model-name "$NAME" \
  --gpu-memory-utilization 0.90 \
  --max-model-len 32768 \
  --enable-auto-tool-choice --tool-call-parser hermes \
  $EXTRA 2>&1 | tee -a "$ROOT/logs/vllm.log"
