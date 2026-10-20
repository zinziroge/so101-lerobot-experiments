# 実験1: ACT を学習する（黄色いブロックを掴んで右の箱に入れる）。
# データセット名は record.ps1 で作られた日時付きの名前。
lerobot-train `
    --dataset.repo_id=zinziroge/sp101_pick_the_block_20261017_115300 `
    --policy.type=act `
    --policy.device=cuda `
    --policy.repo_id=zinziroge/act_so101_pick_the_block `
    --output_dir=outputs/train/act_so101_pick_the_block_v2 `
    --job_name=act_so101_pick_the_block `
    --batch_size=8 `
    --steps=100000 `
    --save_freq=5000 `
    --wandb.enable=true

# 途中で落ちたときの再開用（上を全部置き換える）:
# lerobot-train `
#     --config_path=outputs/train/act_so101_pick_the_block_v2/checkpoints/last/pretrained_model/train_config.json `
#     --resume=true
