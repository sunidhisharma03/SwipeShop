import obj_Dec  # Assuming obj_Dec.py is in the same directory as this script

# Replace with your actual test video path
video_path = 'REM Beauty Eyeshadow Palette Unboxing.mp4'

# Test extract_frames function
print("Testing extract_frames...")
num_frames = obj_Dec.extract_frames(video_path)
print(f"Extracted {num_frames} frames from the video.")

# Test detect_objects_in_frames function
print("Testing detect_objects_in_frames...")
frames_dir = 'frames'
detection_results = obj_Dec.detect_objects_in_frames(frames_dir)
print("Detection Results:")
for result in detection_results:
    if result['detected'] == 1:
        classes_detected = ', '.join(result['classes'])
        print(f"Frame {result['frame_id']}: Detected (1), Classes: {classes_detected}")
    else:
        print(f"Frame {result['frame_id']}: No Detection (0)")
