import os
import cv2
from ultralytics import YOLO
import torch
from firebase_connection import db

# from torchvision.models.detection import fasterrcnn_resnet50_fpn, FasterRCNN, FasterRCNN_ResNet50_FPN_Weights

# Initialize YOLO model
model_path = "./YOLOv8 best.pt"
model = YOLO(model_path)

# Initialize Faster R-CNN model with updated weights parameter
# weights = FasterRCNN_ResNet50_FPN_Weights.COCO_V1  # or FasterRCNN_ResNet50_FPN_Weights.DEFAULT
# detection_model = fasterrcnn_resnet50_fpn(weights=weights, pretrained_backbone=False)

def extract_frames(video_path, frame_interval=1):
    output_dir = 'frames'
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)
    frame_interval = int(fps)

    frame_count = 0
    frame_index = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        if frame_count % frame_interval == 0:
            frame_filename = os.path.join(output_dir, f'frame_{frame_index:04d}.jpg')
            cv2.imwrite(frame_filename, frame)
            frame_index += 1

        frame_count += 1

    cap.release()
    return frame_index

def detect_objects_in_frames(frames_dir):
    detection_results = []

    for frame_file in sorted(os.listdir(frames_dir)):
        frame_id = int(frame_file.split('_')[1].split('.')[0])
        frame_path = os.path.join(frames_dir, frame_file)

        results = model.predict(source=frame_path, save=False)

        detected = 0
        detected_classes = []

        for result in results:
            if len(result.boxes) > 0:
                detected = 1
                for detection in result.boxes:
                    class_name = model.names[int(detection.cls)]
                    detected_classes.append(class_name)

        detection_results.append({'frame_id': frame_id, 'detected': detected, 'classes': detected_classes})

    return detection_results

def update_firebase_with_detection_results(video_id, detection_results):
    try:
        # Count occurrences of each detected class
        class_counts = {}
        for result in detection_results:
            for class_name in result['classes']:
                if class_name in class_counts:
                    class_counts[class_name] += 1
                else:
                    class_counts[class_name] = 1
        
        # Find the class with the maximum count
        most_common_class = max(class_counts, key=class_counts.get)
        
        # Reference to the specific video document in the Firestore
        video_ref = db.collection('Videos').document(video_id)
        
        # Prepare the detection data to be updated
        detection_data = {
            'category': most_common_class  # Set the most repeated category as the document's category
        }

        # Update the document
        video_ref.update(detection_data)

        print(f"Successfully updated video {video_id} with most detected object: {most_common_class}")

    except Exception as e:
        print(f"An error occurred while updating Firebase: {e}")

