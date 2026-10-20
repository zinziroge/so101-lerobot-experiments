# SmolVLA に言語で指示して実機で動かし、カメラ映像をデータセットとして記録する。
# 机の上には毎回 黄色と青の両方のブロックを置くこと（学習データと同じ条件）。
# 箱: 左 = ピンクで大きい / 右 = 白っぽくて小さい
#
# -Combo で指示を選ぶ:
#   [学習済みの指示]
#   yellow_right : Put the yellow block in the right box
#   blue_left    : Put the blue block in the left box
#   blue_right   : Put the blue block in the right box
#   [学習データにない組み合わせ = 汎化テスト]
#   yellow_left  : Put the yellow block in the left box
#   [学習データにない言い方 (箱を色・大きさで指定)]
#   yellow_pink  : Put the yellow block in the pink box    (正解 = 左)
#   yellow_big   : Put the yellow block in the big box     (正解 = 左)
#   yellow_white : Put the yellow block in the white box   (正解 = 右)
#   yellow_small : Put the yellow block in the small box   (正解 = 右)
#   blue_pink    : Put the blue block in the pink box      (正解 = 左)
#   blue_big     : Put the blue block in the big box       (正解 = 左)
#   blue_white   : Put the blue block in the white box     (正解 = 右)
#   blue_small   : Put the blue block in the small box     (正解 = 右)
# -Task で任意の指示文も渡せる（-Combo より優先。データセット名は custom になる）。
#
# 使い方:
#   .\rollout_lang_record.ps1 -Combo yellow_left                         # 最新チェックポイントで5エピソード
#   .\rollout_lang_record.ps1 -Combo blue_white -Episodes 10 -Step 010000
#   .\rollout_lang_record.ps1 -Task "Put the yellow block in the large pink box"
#   .\rollout_lang_record.ps1 -Combo blue_left -Rtc                     # 推論中の停止をなくす
#   .\rollout_lang_record.ps1 -Combo blue_left -NumSteps 5              # 推論を速くする
# キー操作: → 次のエピソードへ / ← 撮り直し / Esc 終了
# 保存先: ~/.cache/huggingface/lerobot/zinziroge/rollout_smolvla_<Combo>_<Step>_<日時>
param(
    [ValidateSet("yellow_right", "blue_left", "blue_right", "yellow_left",
                 "yellow_pink", "yellow_big", "yellow_white", "yellow_small",
                 "blue_pink", "blue_big", "blue_white", "blue_small")]
    [string]$Combo,
    [string]$Task,
    [string]$Step = "last",
    [int]$Episodes = 5,
    # 1エピソードの制限時間 (秒)
    [int]$EpisodeTime = 30,
    # 次の動作チャンクを裏で計算し、推論中の停止 (~0.4秒) をなくす (Real-Time Chunking)
    [switch]$Rtc,
    # flow matching のステップ数 (学習時 10)。減らすと推論が速くなるが精度が落ちることがある
    [int]$NumSteps = 0
)

$extra = @()
if ($Rtc) { $extra += "--inference.type=rtc", "--inference.rtc.execution_horizon=10" }
if ($NumSteps -gt 0) { $extra += "--policy.num_steps=$NumSteps" }

$tasks = @{
    yellow_right = "Put the yellow block in the right box"
    blue_left    = "Put the blue block in the left box"
    blue_right   = "Put the blue block in the right box"
    yellow_left  = "Put the yellow block in the left box"
    yellow_pink  = "Put the yellow block in the pink box"
    yellow_big   = "Put the yellow block in the big box"
    yellow_white = "Put the yellow block in the white box"
    yellow_small = "Put the yellow block in the small box"
    blue_pink    = "Put the blue block in the pink box"
    blue_big     = "Put the blue block in the big box"
    blue_white   = "Put the blue block in the white box"
    blue_small   = "Put the blue block in the small box"
}

if ($Task) {
    $name = "custom"
} elseif ($Combo) {
    $Task = $tasks[$Combo]
    $name = $Combo
} else {
    Write-Error "-Combo か -Task のどちらかを指定してください。"
    exit 1
}

Write-Host "Task      : $Task"
Write-Host "Checkpoint: $Step"
Write-Host "Options   : $($extra -join ' ')"

lerobot-rollout `
  --strategy.type=episodic `
  --policy.path=outputs/train/smolvla_so101_sort_language/checkpoints/$Step/pretrained_model `
  --rename_map='{observation.images.top: observation.images.camera1, observation.images.wrist: observation.images.camera2}' `
  --robot.type=so101_follower `
  --robot.port=COM7 `
  --robot.id=my_follower `
  --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
  --task="$Task" `
  --device=cuda `
  --display_data=true `
  --dataset.repo_id=zinziroge/rollout_smolvla_${name}_$Step `
  --dataset.single_task="$Task" `
  --dataset.num_episodes=$Episodes `
  --dataset.episode_time_s=$EpisodeTime `
  --dataset.reset_time_s=15 `
  --dataset.push_to_hub=false `
  @extra
