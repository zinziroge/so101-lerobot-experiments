# SO-101 × LeRobot 模倣学習実験

SO-101 ロボットアームと [LeRobot](https://github.com/huggingface/lerobot) を用いて、テレオペレーションによるデータ収集 → 方策の学習 → 実機での評価を行った実験の実行スクリプト。

難易度を段階的に上げた3つの実験を行った。

| 実験 | タスク | 方策 | 机上のブロック | ディレクトリ |
|---|---|---|---|---|
| 1 | 黄色いブロックを掴んで右の箱に入れる | ACT | 黄1個 | [scripts/01_single](scripts/01_single) |
| 2 | ブロックの色で箱を振り分ける（黄→右、青→左） | ACT | 黄 or 青の1個 | [scripts/02_sort](scripts/02_sort) |
| 3 | 言語指示に従って指定のブロックを指定の箱に入れる | SmolVLA | 黄・青の2個 | [scripts/03_language](scripts/03_language) |

実験3では「黄→左」の組み合わせを学習データから除外し、未学習の組み合わせ・言い回しへの汎化を評価した。

## 実験環境

| 項目 | 内容 |
|---|---|
| ロボット | SO-101 フォロワー（COM7）＋ SO-101 リーダー（COM6） |
| カメラ | 俯瞰 `top`（OpenCV index 1）、手首 `wrist`（OpenCV index 2）、いずれも 640×480 / 30fps / MJPG |
| PC | Windows 11、RTX 5060 Laptop GPU（8GB）、Core 7 240H、RAM 32GB |
| LeRobot | [`146d8474`](https://github.com/huggingface/lerobot/commit/146d8474)（v0.6.2）。**LeRobot 本体には変更を加えていない** |
| 主要パッケージ | torch 2.11.0+cu128、torchvision 0.26.0+cu128、transformers 5.5.4、accelerate 1.15.0、wandb 0.27.2 |

COM ポート、カメラ index、キャリブレーション ID（`my_follower` / `my_leader`）は各スクリプトに直接書いているため、環境に合わせて書き換えること。

## セットアップ

```powershell
# 1. LeRobot を実験時のコミットで取得
git clone https://github.com/huggingface/lerobot.git
cd lerobot
git checkout 146d8474

# 2. 仮想環境と依存パッケージ
uv venv
uv pip install -e ".[feetech,training,smolvla]"

# 3. RTX 50 シリーズ用に CUDA 12.8 版 PyTorch に入れ替える
#    （Windows では既定で CPU 版が入る。uv sync を実行すると CPU 版に戻るので注意）
uv pip install --reinstall-package torch --reinstall-package torchvision "torch==2.11.0" torchvision --index-url https://download.pytorch.org/whl/cu128

# 4. ログイン
hf auth login
wandb login
```

### Windows での注意点
- **PowerShell は管理者権限で実行しない。** 管理者で記録したデータセットは、通常ユーザーから読み書きできなくなる。
- **開発者モードを ON にする**（設定 → システム → 開発者向け）。学習時のチェックポイントの `last` シンボリックリンク作成に必要。
- スクリプトは **UTF-8（BOM 付き）** で保存している。Windows PowerShell 5.1 は BOM なし UTF-8 を Shift-JIS として読むため、日本語コメントがあると構文エラーになる。
- PowerShell 5.1 は外部コマンドの引数内の `"` を除去するため、辞書型の引数は `'{key: value}'` のように YAML の引用符なし形式で書いている。
- `--policy.path=lerobot/smolvla_base` は Windows ではパス区切りが `\` に変換されて Hub から取得できないため、ローカルにダウンロードしたものを指定している（[train_smolvla.ps1](scripts/03_language/train_smolvla.ps1) 参照）。

## 実行方法

スクリプトは **LeRobot のルートディレクトリをカレントにして** 実行する（学習結果の `outputs/` などは相対パスで指定している）。

```powershell
cd path\to\lerobot
& path\to\so101-lerobot-experiments\scripts\00_setup\teleop.ps1
```

### 0. 動作確認（[scripts/00_setup](scripts/00_setup)）
| スクリプト | 内容 |
|---|---|
| `teleop.ps1` | テレオペレーションとカメラ映像の確認 |
| `record_test.ps1` | 記録の試し撮り（5 エピソード） |

### 実験1（[scripts/01_single](scripts/01_single)）
| 手順 | スクリプト | 内容 |
|---|---|---|
| 記録 | `record.ps1` | 黄→右の箱（42 エピソードを使用） |
| 学習 | `train.ps1` | ACT、batch 8、100,000 ステップ |
| 評価 | `rollout.ps1` / `rollout_record.ps1` | 実機で実行（後者はカメラ映像を記録） |

### 実験2（[scripts/02_sort](scripts/02_sort)）
| 手順 | スクリプト | 内容 |
|---|---|---|
| 記録 | `record_yellow.ps1 -Episodes 6 [-Resume]` | 黄→右の箱（実験1の 42 ＋ 追加 18） |
| 記録 | `record_blue.ps1 -Episodes 20 [-Resume]` | 青→左の箱（60） |
| 統合 | `merge_datasets.ps1` | 3つのデータセットを統合し、タスク名を統一（120 エピソード） |
| 学習 | `train_sort.ps1` | ACT、batch 8、100,000 ステップ |
| 評価 | `rollout_sort.ps1` / `rollout_sort_record.ps1 -Step 065000` | 実機で実行 |

### 実験3（[scripts/03_language](scripts/03_language)）
| 手順 | スクリプト | 内容 |
|---|---|---|
| 記録 | `record_lang.ps1 -Combo <yellow_right\|blue_left\|blue_right> -Episodes 10 [-Resume]` | 各 30 エピソード（黄→左は記録しない） |
| 統合 | `merge_lang.ps1` | 90 エピソードに統合 |
| 学習 | `train_smolvla.ps1` | `lerobot/smolvla_base` からファインチューニング、batch 16、20,000 ステップ |
| 評価 | `rollout_lang_record.ps1 -Combo <指示> [-Rtc] [-NumSteps 5]` | 学習済み3指示、未学習の組み合わせ（`yellow_left`）、箱を色・大きさで指定する未学習の言い回し（`blue_pink` など） |

記録時のキー操作：→ 次のエピソード / ← 撮り直し / Esc 終了

### 評価動画の作成（[scripts/tools](scripts/tools)）
`rollout_*_record.ps1` で記録したデータセットから、top と wrist の映像を横に並べ、指示文・カメラ名・エピソード番号・成功/失敗を書き込んだ動画を作る（ffmpeg が必要）。

```powershell
python scripts\tools\make_rollout_video.py `
    $env:USERPROFILE\.cache\huggingface\lerobot\zinziroge\rollout_smolvla_blue_small_last_20261020_174609 `
    exp3_blue_small_top_wrist.mp4 --success 0
```
`--success` には成功したエピソードの番号（0 始まり）を指定する。それ以外は FAIL と表示される。

## 学習済みモデル（Hugging Face Hub）

| 実験 | モデル |
|---|---|
| 1 | [zinziroge/act_so101_pick_the_block](https://huggingface.co/zinziroge/act_so101_pick_the_block) |
| 2 | [zinziroge/act_so101_sort_yellow_blue](https://huggingface.co/zinziroge/act_so101_sort_yellow_blue) |
| 3 | [zinziroge/smolvla_so101_sort_language](https://huggingface.co/zinziroge/smolvla_so101_sort_language) |

## データセット（Hugging Face Hub）

| 実験 | データセット |
|---|---|
| 1 | [zinziroge/sp101_pick_the_block_20261017_115300](https://huggingface.co/datasets/zinziroge/sp101_pick_the_block_20261017_115300)（42 エピソード） |
| 2 | [zinziroge/so101_sort_yellow_blue](https://huggingface.co/datasets/zinziroge/so101_sort_yellow_blue)（120 エピソード） |
| 3 | [zinziroge/so101_sort_language](https://huggingface.co/datasets/zinziroge/so101_sort_language)（90 エピソード） |

データセットの中身は [LeRobot Dataset Visualizer](https://huggingface.co/spaces/lerobot/visualize_dataset) で確認できる。

## 結果（概要）

| 実験 | 結果 |
|---|---|
| 1 | 成功率 約 1/2 |
| 2 | 4/10（青 3/5、黄 1/5）。箱の選択は 10/10 正解で、失敗はすべて把持の失敗 |
| 3 | 学習済み指示 2/20、未学習の組み合わせ（黄→左）0/5、箱を色・大きさで指定 3/20（運搬した 7 回はすべて右の箱）。言語の構成的な理解・汎化は得られなかった |

詳細はレポートを参照。
