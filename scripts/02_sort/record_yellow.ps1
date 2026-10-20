# 黄色いブロックを右の箱に入れるデータを追加で記録する（昨日の42本 + 今日の18本 = 60本）。
# record_blue.ps1 と同じ配置・設定で撮ること。
#
# 使い方:
#   .\record_yellow.ps1 -Episodes 6           # 1回目（データセットを新規作成）
#   .\record_yellow.ps1 -Episodes 6 -Resume   # 2回目以降（同じデータセットに追加）
param(
    [int]$Episodes = 6,
    [switch]$Resume
)

$repo_id = "zinziroge/so101_yellow_right"
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
    --dataset.single_task="Put the yellow block in the right box" `
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
