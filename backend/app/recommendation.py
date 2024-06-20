import firebase_admin
from firebase_admin import credentials, firestore
from firebase_connection import db
import pandas as pd
from typing import Dict, List

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

# Function to recommend videos
def recommend_videos(df: pd.DataFrame) -> Dict[str, List[str]]:
    user1 = "ash"
    user2 = "Anon"
    liked_by_user1 = df.loc[user1] == 1
    liked_by_user2 = df.loc[user2] == 1
    liked_by_both = liked_by_user1 & liked_by_user2

    # Recommend videos liked by user1 but excluding those liked by both
    recommended_videos_1_to_2 = df.columns[(df.loc[user1] == 1) & ~liked_by_both].tolist()

    # Recommend videos liked by user2 but excluding those liked by both
    recommended_videos_2_to_1 = df.columns[(df.loc[user2] == 1) & ~liked_by_both].tolist()

    recommendations = {
        f"{user2}_based_on_{user1}": recommended_videos_1_to_2,
        f"{user1}_based_on_{user2}": recommended_videos_2_to_1,
  
    }



    return recommendations

