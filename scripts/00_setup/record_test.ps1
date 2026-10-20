lerobot-record `
    --robot.type=so101_follower `
    --robot.port=COM7 `
    --robot.id=my_follower `
    --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
    --teleop.type=so101_leader `
    --teleop.port=COM6 `
    --teleop.id=my_leader `
    --display_data=true `
    --dataset.repo_id=zinziroge/record-test `
    --dataset.num_episodes=5 `
    --dataset.single_task="Grab the blue block" `
    --dataset.episode_time_s=20 `
    --dataset.reset_time_s=10 `
    --dataset.streaming_encoding=true `
    --dataset.encoder_threads=2 `
    --dataset.push_to_hub=false

