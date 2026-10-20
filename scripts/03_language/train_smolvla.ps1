# 事前学習済み SmolVLA (lerobot/smolvla_base) を言語指示つきデータでファインチューニングする。
# VRAM 不足 (CUDA out of memory) になったら --batch_size を 8 に下げる。
# Windows では --policy.path=lerobot/smolvla_base が 'lerobot\smolvla_base' に変換されて Hub から取得できないため、
# 事前にローカルへダウンロードしたものを指定している:
#   python -c "from huggingface_hub import snapshot_download; snapshot_download('lerobot/smolvla_base', local_dir='outputs/pretrained/smolvla_base')"
# smolvla_base はカメラ名 camera1-3 を前提にしているため、--rename_map で top/wrist を読み替える
# (PowerShell 5.1 では引数内の " が消えるので、YAML の引用符なし形式で書く)。
lerobot-train `
    --policy.path=outputs/pretrained/smolvla_base `
    --policy.device=cuda `
    --policy.repo_id=zinziroge/smolvla_so101_sort_language `
    --dataset.repo_id=zinziroge/so101_sort_language `
    --rename_map='{observation.images.top: observation.images.camera1, observation.images.wrist: observation.images.camera2}' `
    --output_dir=outputs/train/smolvla_so101_sort_language `
    --job_name=smolvla_so101_sort_language `
    --batch_size=16 `
    --steps=20000 `
    --save_freq=2000 `
    --wandb.enable=true

# 途中で落ちたときの再開用（上を全部置き換える）:
# lerobot-train `
#     --config_path=outputs/train/smolvla_so101_sort_language/checkpoints/last/pretrained_model/train_config.json `
#     --resume=true
