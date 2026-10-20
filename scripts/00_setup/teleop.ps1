# リーダーアームでフォロワーアームを操作し、カメラ2台の映像を確認する。
lerobot-teleoperate `
  --robot.type=so101_follower --robot.port=COM7 --robot.id=my_follower `
  --teleop.type=so101_leader  --teleop.port=COM6 --teleop.id=my_leader `
  --robot.cameras='{wrist: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30, fourcc: MJPG}, top: {type: opencv, index_or_path: 1, width: 640, height: 480, fps: 30, fourcc: MJPG}}' `
  --display_data=true
