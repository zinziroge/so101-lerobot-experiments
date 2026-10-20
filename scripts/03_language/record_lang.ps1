# 言語指示つきデータ (VLA 用) を記録する。机の上には毎回 黄色と青の両方のブロックを置くこと。
# 2つのブロックの左右の位置は毎回入れ替える / ずらす。
#
# -Combo で指示を選ぶ:
#   yellow_right : Put the yellow block in the right box
#   blue_left    : Put the blue block in the left box
#   blue_right   : Put the blue block in the right box
#   (yellow_left はテスト専用なので記録しない)
#
# 使い方:
#   .\record_lang.ps1 -Combo yellow_right -Episodes 10            # 1回目（データセットを新規作成）
#   .\record_lang.ps1 -Combo yellow_right -Episodes 10 -Resume    # 2回目以降（同じデータセットに追加）
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("yellow_right", "blue_left", "blue_right")]
    [string]$Combo,
    [int]$Episodes = 10,
    [switch]$Resume
)

$tasks = @{
    yellow_right = "Put the yellow block in the right box"
    blue_left    = "Put the blue block in the left box"
    blue_right   = "Put the blue block in the right box"
}
$task = $tasks[$Combo]
$repo_id = "zinziroge/so101_lang_$Combo"
$root = "$env:USERPROFILE\.cache\huggingface\lerobot\$repo_id"

Write-Host "Task   : $task"
Write-Host "Dataset: $repo_id ($Episodes episodes, resume=$($Resume.IsPresent))"

lerobot-record `
    --robot.type=so101_follower `
    --robot.port=COM7 `
    --robot.id=my_follower `
    --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
    --teleop.type=so101_leader `
    --teleop.port=COM6 `
    --teleop.id=my_leader `
    --display_data=true `
    --dataset.single_task="$task" `
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
