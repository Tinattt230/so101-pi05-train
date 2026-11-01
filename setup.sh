#!/bin/bash
set -e
export UV_DEFAULT_INDEX=https://pypi.tuna.tsinghua.edu.cn/simple
export HF_ENDPOINT=https://hf-mirror.com
cd /hy-tmp/interactive-robotic-arm

uv sync

uv pip install torch==2.11.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 --force-reinstall

grep -v -E "^(torch|torchvision|torchaudio)==" requirements-lock.txt > /tmp/reqs-no-torch.txt
uv pip install -r /tmp/reqs-no-torch.txt

uv pip install "lerobot[dataset,peft]@git+https://githubproxy.cc/https://github.com/huggingface/lerobot.git@3f797de5952432284a7c77ad2760218cb74e2f26" --upgrade

uv run python -c "import torch; print('torch:', torch.__version__, 'cuda:', torch.cuda.is_available())"
uv run python -c "import lerobot; print('lerobot:', lerobot.__version__)"
uv run python -c "from lerobot.policies.pi05.modeling_pi05 import PI05Policy; print('pi05 ok')"

mkdir -p /hy-tmp/datasets
uv run hf download Project-IRA/TPSoSe2026_Dataset_Lego_LeRobot_SO101 --repo-type dataset --local-dir /hy-tmp/datasets/lego_dataset
uv run hf download lerobot/pi05_base --local-dir /hy-tmp/pi05_base
uv run hf download Tianxian1/pi05-lego-lora --repo-type model --local-dir /hy-tmp/pi05_lego_lora

echo "setup done"
