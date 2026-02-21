FROM lmsysorg/sglang:v0.4.8.post1-cu126

# sglang의 4bit quant(awq/bitsandbytes/gptq 등)가 vLLM ops를 요구하는 케이스가 있음
# (서버로 vLLM을 쓰는 게 아니라 CUDA ops 라이브러리 용도)
# 4bit quant에 필요한 op들
RUN python3 -m pip install --no-cache-dir \
    "vllm==0.9.0.1" \
    "bitsandbytes>=0.45.3"