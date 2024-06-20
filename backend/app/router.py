from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict
import logging
from firebase_connection import db
from recommendation import recommend_videos
from firebase_connection import fetch_video_data, download_video, fetch_collection
from obj_Dec import extract_frames, detect_objects_in_frames,  update_firebase_with_detection_results
import os
import pandas as pd

# Initialize the router
router = APIRouter()

# Set up logging
logger = logging.getLogger(__name__)

# Define the request model for the API endpoint


class RecommendationRequest(BaseModel):
    user_id_1: str 
    # top_n: int = 15


class VideoDetectionRequest(BaseModel):
    video_id: str


@router.post("/recommendations/", response_model=List[Dict])
def get_recommendations(request: RecommendationRequest) -> List[Dict]:
    # Retrieve user data
    users_ref = db.collection('Users')
    users_docs = users_ref.stream()

    users_data = {}
    for doc in users_docs:
        users_data[doc.id] = doc.to_dict()

    # Convert user data to DataFrame
    liked_videos_dict = {user['name']: user.get('likedVideos', []) for user in users_data.values()}

    # Create a list of all unique videos
    all_videos = list(set(video for videos in liked_videos_dict.values() for video in videos))

    # Create a binary matrix of user-video interactions
    binary_data = {user: [1 if video in liked_videos else 0 for video in all_videos] for user, liked_videos in liked_videos_dict.items()}
    df = pd.DataFrame(binary_data, index=all_videos).T

    # Get recommendations
    recommendations = recommend_videos(df, user1=request.user_id_1)
    return [recommendations]


@router.post("/videoDetection/", response_model=Dict)
def detect_video(request: VideoDetectionRequest):
    video_data = fetch_video_data(request.video_id)
    if not video_data:
        raise HTTPException(status_code=404, detail="Video not found")

    video_url = video_data.get('url')
    if not video_url:
        raise HTTPException(
            status_code=400, detail="Video URL not found in document")
    local_video_path = f"./{request.video_id}.mp4"
    download_video(video_url, local_video_path)

    frame_count = extract_frames(local_video_path, frame_interval=1)
    detection_results = detect_objects_in_frames('frames')

    os.remove(local_video_path)
    for frame_file in os.listdir('frames'):
        os.remove(os.path.join('frames', frame_file))
    os.rmdir('frames')

    update_firebase_with_detection_results(request.video_id, detection_results)

    return {"video_id": request.video_id, "detection_results": detection_results}
