# auto_cap.py
import os
import cv2
import json
import numpy as np
from mediapipe import solutions as mp

os.makedirs('frames', exist_ok=True)
FRAME_SKIP = 5    # 抽帧间隔
MAX_LAG = 200     # 测自相关找周期时最大滞后帧数

# 定义关键点名称映射
LANDMARK_NAMES = {
    0: "nose",
    11: "left_shoulder",
    12: "right_shoulder",
    13: "left_elbow",
    14: "right_elbow",
    15: "left_wrist",
    16: "right_wrist",
    23: "left_hip",
    24: "right_hip",
    25: "left_knee",
    26: "right_knee",
    27: "left_ankle",
    28: "right_ankle",
    # 可以根据需要添加更多关键点
}

def process_video(video_path):
    print(f"\n处理视频: {video_path}")
    video_name = os.path.splitext(os.path.basename(video_path))[0]
    
    # —— 1) 抽帧 + Pose 采样 + 存图 —— 
    cap = cv2.VideoCapture(video_path)
    mp_pose = mp.pose.Pose()
    frame_idx = 0
    all_landmarks = []  # 每项：{'idx', 'timestamp', 'landmarks': {}, 'img_path'}
    fps = cap.get(cv2.CAP_PROP_FPS)

    while cap.isOpened():
        ret, img = cap.read()
        if not ret:
            break

        # 抽帧
        if frame_idx % FRAME_SKIP != 0:
            frame_idx += 1
            continue
        
        timestamp = frame_idx / fps  # 计算时间戳
        frame_idx += 1

        # Pose 检测
        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        res = mp_pose.process(rgb)
        if not res.pose_landmarks:
            continue

        # 转换为命名的字典格式
        landmarks_dict = {}
        for idx, name in LANDMARK_NAMES.items():
            point = res.pose_landmarks.landmark[idx]
            landmarks_dict[name] = [point.x, point.y, point.z]

        # 存图到 frames/
        img_path = f'frames/{video_name}_frame_{frame_idx:04d}.jpg'
        cv2.imwrite(img_path, img)

        all_landmarks.append({
            'idx': frame_idx,
            'timestamp': timestamp,
            'landmarks': landmarks_dict,
            'img_path': img_path
        })

    cap.release()

    if len(all_landmarks) == 0:
        print(f'❌ {video_name}: 未能提取到任何姿态数据')
        return

    # —— 2) 为每个关键点生成信号，并选出"最周期"的那一条 —— 
    # 构造信号数组
    signals = []
    for name in LANDMARK_NAMES.values():
        for dim in range(3):
            # 提取特定关键点的特定维度的时间序列
            s = np.array([frame['landmarks'][name][dim] for frame in all_landmarks])
            signals.append((name, dim, s))

    T = len(all_landmarks)
    best_score = -1
    best_signal = None

    for name, dim, s in signals:
        # 去趋势 + 标准化
        s = (s - s.mean())
        # 计算自相关
        ac = np.correlate(s, s, mode='full')[T-1 : T-1+MAX_LAG]
        ac[0] = 0  # 忽略 lag=0
        score = ac.max()
        if score > best_score:
            best_score = score
            best_signal = (name, dim, s)
            best_ac = ac

    # 找出周期 L
    L = int(best_ac.argmax())
    print(f'🔍 {video_name}: 选出了最周期信号 ({best_signal[0]} 维度 {best_signal[1]})，检测到周期 ≈ {L} 帧')

    # —— 3) 切出第一整周并保存 —— 
    if L > 1 and T >= L:
        cycle = all_landmarks[0:L]
        cycle_json = f'standard_{video_name}.json'
        with open(cycle_json, 'w', encoding='utf-8') as f:
            json.dump(cycle, f, indent=2, ensure_ascii=False)
        print(f'✅ {video_name}: 已导出标准单次循环：前 {L} 帧 → {cycle_json}')
    else:
        print(f'❌ {video_name}: 周期检测失败，请增大 MAX_LAG 或换个动作再试')

    # —— 4) 保存完整视频长度的JSON文件 —— 
    full_json = f'{video_name}.json'
    with open(full_json, 'w', encoding='utf-8') as f:
        json.dump(all_landmarks, f, indent=2, ensure_ascii=False)
    print(f'✅ {video_name}: 已导出完整视频数据：共 {len(all_landmarks)} 帧 → {full_json}')

def main():
    # 获取01目录下所有MP4文件
    video_dir = '01'
    video_files = [f for f in os.listdir(video_dir) if f.endswith('.mp4')]
    
    print(f"找到 {len(video_files)} 个视频文件需要处理...")
    
    # 处理每个视频文件
    for video_file in video_files:
        video_path = os.path.join(video_dir, video_file)
        process_video(video_path)

if __name__ == "__main__":
    main()