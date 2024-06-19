
import os
from IPython.display import display, Image
from ultralytics import YOLO
from IPython import display as ipython_display

HOME = os.getcwd()
print(HOME)

import ultralytics
ultralytics.checks()


model_path = "./YOLOv8 best.pt"
model = YOLO(model_path)

import cv2
import os

# Create a directory to store the frames
output_dir = 'frames'
if not os.path.exists(output_dir):
    os.makedirs(output_dir)

# Load the video
video_path = './REM Beauty Eyeshadow Palette Unboxing.mp4'
cap = cv2.VideoCapture(video_path)

fps = cap.get(cv2.CAP_PROP_FPS)  # Get frames per second of the video
frame_interval = int(fps)  # We want 1 frame per second

frame_count = 0
frame_index = 0

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    if frame_count % frame_interval == 0:
        # Save the frame as an image file
        frame_filename = os.path.join(output_dir, f'frame_{frame_index:04d}.jpg')
        cv2.imwrite(frame_filename, frame)
        frame_index += 1

    frame_count += 1

cap.release()
print(f'Extracted {frame_index} frames at 1 frame per second.')

frames_dir = 'frames'
detection_results = []

# Loop through each frame and run the YOLO model
for frame_file in sorted(os.listdir(frames_dir)):
    frame_id = int(frame_file.split('_')[1].split('.')[0])  # Extract frame ID from filename
    frame_path = os.path.join(frames_dir, frame_file)

    results = model.predict(source=frame_path, save=False)  # Run the YOLO model

    detected = 0  # Initialize detection flag for the frame
    detected_classes = []  # List to store detected class names

    # Check if any objects were detected and record their class names
    for result in results:
        if len(result.boxes) > 0:
            detected = 1
            for detection in result.boxes:
                class_name = model.names[int(detection.cls)]  # Get class name
                detected_classes.append(class_name)

    # Store the result
    detection_results.append({'frame_id': frame_id, 'detected': detected, 'classes': detected_classes})

print("Detection Results:")
for result in detection_results:
    if result['detected'] == 1:
        classes_detected = ', '.join(result['classes'])
        print(f"Frame {result['frame_id']}: Detected (1), Classes: {classes_detected}")
    else:
        print(f"Frame {result['frame_id']}: No Detection (0)")

