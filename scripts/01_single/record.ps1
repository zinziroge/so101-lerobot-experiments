# 実験1: 黄色いブロックを掴んで右の箱に入れるデータを記録する。
# 途中で落ちて撮り直したため、学習には 42 エピソードのデータセット (sp101_pick_the_block_20261017_115300) を使用した。
lerobot-record `
    --robot.type=so101_follower `
    --robot.port=COM7 `
    --robot.id=my_follower `
    --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
    --teleop.type=so101_leader `
    --teleop.port=COM6 `
    --teleop.id=my_leader `
    --display_data=true `
    --dataset.single_task="Grab the block" `
    --dataset.episode_time_s=20 `
    --dataset.reset_time_s=10 `
    --dataset.streaming_encoding=true `
    --dataset.encoder_threads=2 `
    --dataset.push_to_hub=true `
    --dataset.repo_id=zinziroge/sp101_pick_the_block `
    --dataset.num_episodes=50

# 途中で落ちたときの再開用（上の2行を差し替える。repo_id/root は日時付きの名前、num_episodes は追加で撮る数）:
#    --dataset.repo_id=zinziroge/sp101_pick_the_block_YYYYMMDD_HHMMSS `
#    --dataset.root="$env:USERPROFILE\.cache\huggingface\lerobot\zinziroge\sp101_pick_the_block_YYYYMMDD_HHMMSS" `
#    --dataset.num_episodes=<残り本数> `
#    --resume=true

