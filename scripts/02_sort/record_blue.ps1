# 青いブロックを左の箱に入れるデータを記録する（60本）。
# 黄色のデータ (sp101_pick_the_block_20261017_115300, 42本 + record_yellow.ps1 の18本) と同じ配置・設定で撮ること。
#
# 使い方:
#   .\record_blue.ps1 -Episodes 20            # 1回目（データセットを新規作成）
#   .\record_blue.ps1 -Episodes 20 -Resume    # 2回目以降（同じデータセットに追加）
param(
    [int]$Episodes = 20,
    [switch]$Resume
)

$repo_id = "zinziroge/so101_blue_left"
$root = "$env:USERPROFILE\.cache\huggingface\lerobot\$repo_id"

lerobot-record `
    --robot.type=so101_follower `
    --robot.port=COM7 `
    --robot.id=my_follower `
    --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
    --teleop.type=so101_leader `
    --teleop.port=COM6 `
    --teleop.id=my_leader `
    --display_data=true `
    --dataset.single_task="Put the blue block in the left box" `
    --dataset.episode_time_s=20 `
    --dataset.reset_time_s=10 `
    --dataset.streaming_encoding=true `
    --dataset.encoder_threads=2 `
    --dataset.push_to_hub=false `
    --dataset.repo_id=$repo_id `
    --dataset.root=$root `
    --dataset.no_stamp=true `
    --dataset.num_episodes=$Episodes `
    --resume=$($Resume.IsPresent.ToString().ToLower())
