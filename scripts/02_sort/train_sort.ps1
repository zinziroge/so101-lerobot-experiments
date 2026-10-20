#lerobot-train `
#    --dataset.repo_id=zinziroge/so101_sort_yellow_blue `
#    --policy.type=act `
#    --policy.device=cuda `
#    --policy.repo_id=zinziroge/act_so101_sort_yellow_blue `
#    --output_dir=outputs/train/act_so101_sort_yellow_blue `
#    --job_name=act_so101_sort_yellow_blue `
#    --batch_size=8 `
#    --steps=100000 `
#    --save_freq=5000 `
#    --wandb.enable=true

# 途中で落ちたときの再開用（上を全部置き換える）:
 lerobot-train `
     --config_path=outputs/train/act_so101_sort_yellow_blue/checkpoints/last/pretrained_model/train_config.json `
     --resume=true
