# 色で箱を振り分けるポリシーを実機で動かし、カメラ映像をデータセットとして記録する。
# 使い方:
#   .\rollout_sort_record.ps1                              # 最新のチェックポイントで10エピソード
#   .\rollout_sort_record.ps1 -Step 065000 -Episodes 10    # ステップとエピソード数を指定
# キー操作: → 次のエピソードへ / ← 撮り直し / Esc 終了
# 保存先: ~/.cache/huggingface/lerobot/zinziroge/rollout_act_so101_sort_<Step>_<日時>
param(
    [string]$Step = "last",
    [int]$Episodes = 10
)

lerobot-rollout `
  --strategy.type=episodic `
  --policy.path=outputs/train/act_so101_sort_yellow_blue/checkpoints/$Step/pretrained_model `
  --robot.type=so101_follower `
  --robot.port=COM7 `
  --robot.id=my_follower `
  --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
  --task="Sort the block by color" `
  --device=cuda `
  --display_data=true `
  --dataset.repo_id=zinziroge/rollout_act_so101_sort_$Step `
  --dataset.single_task="Sort the block by color" `
  --dataset.num_episodes=$Episodes `
  --dataset.episode_time_s=20 `
  --dataset.reset_time_s=15 `
  --dataset.push_to_hub=false
