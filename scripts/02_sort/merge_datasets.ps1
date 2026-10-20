# 黄色(右の箱)と青(左の箱)のデータセットを1つにまとめ、タスク名を付け直す。
# 元のデータセットは変更されない（まとめた新しいデータセットだけを書き換える）。

$yellow_old = "zinziroge/sp101_pick_the_block_20261017_115300"     # 昨日の黄色 42本
$yellow_new = "zinziroge/so101_yellow_right"                       # 今日の黄色 18本（record_yellow.ps1）
$blue       = "zinziroge/so101_blue_left"                          # 青 60本（record_blue.ps1）
$merged     = "zinziroge/so101_sort_yellow_blue"

# 1. まとめる（episode 0-41: 昨日の黄色, 42-59: 今日の黄色, 60-119: 青）
lerobot-edit-dataset `
    --new_repo_id=$merged `
    --operation.type=merge `
    --operation.repo_ids="['$yellow_old', '$yellow_new', '$blue']"
if (-not $?) { exit 1 }

# 2. 昨日の黄色のタスク名を変更する（まとめたデータセットを in-place で書き換える）
#    PowerShell 5.1 では引数内の " が消えるので、YAML の引用符なし形式で書く
lerobot-edit-dataset `
    --repo_id=$merged `
    --operation.type=modify_tasks `
    --operation.task_replacements='{Grab the block: Put the yellow block in the right box}'
if (-not $?) { exit 1 }

# 3. 確認（エピソード数とタスク一覧: 120本、タスク2種類になっていればOK）
lerobot-edit-dataset `
    --repo_id=$merged `
    --operation.type=info
