from fastapi import APIRouter, HTTPException
from typing import List
from pydantic import BaseModel
from recommendation import hybrid_recommendations  # Import the recommendation function

# Initialize the router
router = APIRouter()

# Define the request model for the API endpoint
class RecommendationRequest(BaseModel):
    user_id: str
    top_n: int = 15

# API endpoint to get recommendations
@router.post("/recommendations/", response_model=List[dict])
def get_recommendations(request: RecommendationRequest):
    try:
        recommendations = hybrid_recommendations(
            user_id=request.user_id, top_n=request.top_n)
        return recommendations.to_dict(orient='records')
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    
# @router.post("/imageDetection/",response_model=List[dict])
# def detect_image(request: )