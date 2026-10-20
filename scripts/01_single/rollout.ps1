lerobot-rollout `
  --strategy.type=base `
  --policy.path=outputs/train/act_so101_pick_the_block_v2/checkpoints/last/pretrained_model `
  --robot.type=so101_follower `
  --robot.port=COM7 `
  --robot.id=my_follower `
  --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
  --task="Grab the block" `
  --device=cuda `
  --display_data=true `
  --duration=60

# Hub にアップロードしたモデルを使う場合:
#   --policy.path=zinziroge/act_so101_pick_the_block `
