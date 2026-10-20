# 色で箱を振り分けるポリシーを実機で試す。
# 使い方:
#   .\rollout_sort.ps1                 # 最新のチェックポイント (checkpoints/last)
#   .\rollout_sort.ps1 -Step 065000    # ステップを指定
param(
    [string]$Step = "last"
)

lerobot-rollout `
  --strategy.type=base `
  --policy.path=outputs/train/act_so101_sort_yellow_blue/checkpoints/$Step/pretrained_model `
  --robot.type=so101_follower `
  --robot.port=COM7 `
  --robot.id=my_follower `
  --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
  --task="Sort the block by color" `
  --device=cuda `
  --display_data=true `
  --duration=60
