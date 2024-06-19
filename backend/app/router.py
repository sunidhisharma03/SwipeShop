from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict
import logging
from recommendation import hybrid_recommendations
from firebase_connection import fetch_video_data, download_video, fetch_collection
from obj_Dec import extract_frames, detect_objects_in_frames,  update_firebase_with_detection_results
import os

# Initialize the router
router = APIRouter()

# Set up logging
logger = logging.getLogger(__name__)

# Define the request model for the API endpoint
class RecommendationRequest(BaseModel):
    user_id: str
    top_n: int = 15

class VideoDetectionRequest(BaseModel):
    video_id: str


@router.post("/recommendations/", response_model=List[Dict])
def get_recommendations(request: RecommendationRequest):
    user_data = fetch_collection("Users", "user_id")
    product_data = fetch_collection("Products", "product_id")
    
    recommendations = hybrid_recommendations(
        user_id=request.user_id, top_n=request.top_n)
    return recommendations.to_dict(orient='records')


@router.post("/videoDetection/", response_model=Dict)
def detect_video(request: VideoDetectionRequest):
    video_data = fetch_video_data(request.video_id)
    if not video_data:
        raise HTTPException(status_code=404, detail="Video not found")

    video_url = video_data.get('url')
    if not video_url:
        raise HTTPException(status_code=400, detail="Video URL not found in document")
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
