# record_lang.ps1 で記録した3つのデータセットを1つにまとめる。
# 元のデータセットは変更されない。

$merged = "zinziroge/so101_sort_language"
$sources = @(
    "zinziroge/so101_lang_yellow_right",
    "zinziroge/so101_lang_blue_left",
    "zinziroge/so101_lang_blue_right"
)
$repo_ids = "[" + (($sources | ForEach-Object { "'$_'" }) -join ", ") + "]"

lerobot-edit-dataset `
    --new_repo_id=$merged `
    --operation.type=merge `
    --operation.repo_ids="$repo_ids"
if (-not $?) { exit 1 }

# 確認（エピソード数とタスク一覧: タスク3種類になっていればOK）
lerobot-edit-dataset `
    --repo_id=$merged `
    --operation.type=info
