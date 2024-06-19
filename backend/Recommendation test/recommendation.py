import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
from scipy.sparse import csr_matrix
from firebase_connection import fetch_collection

# Fetch each collection with the correct ID mapping
users = fetch_collection('Users', 'user_id')
print("Users DataFrame structure:\n", users.head())

products = fetch_collection('Product', 'product_id')
print("Products DataFrame structure:\n", products.head())

clicks = fetch_collection('Click', 'click_id')
print("Clicks DataFrame structure:\n", clicks.head())

comments = fetch_collection('Comment', 'comment_id')
print("Comments DataFrame structure:\n", comments.head())

likes = fetch_collection('Likes', 'likes_id')
print("Likes DataFrame structure:\n", likes.head())

purchases = fetch_collection('Purchase', 'purchase_id')
print("Purchases DataFrame structure:\n", purchases.head())

shares = fetch_collection('Shares', 'share_id')
print("Shares DataFrame structure:\n", shares.head())

views = fetch_collection('View', 'view_id')
print("Views DataFrame structure:\n", views.head())

videos = fetch_collection('Videos', 'video_id')
print("Videos DataFrame structure:\n", videos.head())

# Define interaction type to score mapping
interaction_type_scores = {
    'Click': 1.5,
    'Comment': 2,
    'Likes': 3,
    'Shares': 4,
    'Purchase': 5,
    'View': 1
}

# Combine all interactions into a single DataFrame with scores
def aggregate_interactions(clicks, comments, likes, purchases, shares, views):
    clicks['interaction_score'] = interaction_type_scores['Click']
    comments['interaction_score'] = interaction_type_scores['Comment']
    likes['interaction_score'] = interaction_type_scores['Likes']
    purchases['interaction_score'] = interaction_type_scores['Purchase']
    shares['interaction_score'] = interaction_type_scores['Shares']
    views['interaction_score'] = interaction_type_scores['View']

    interactions = pd.concat([clicks, comments, likes, purchases, shares, views], ignore_index=True)

    try:
        aggregated_interactions = interactions.groupby(['userID', 'videoID'])['interaction_score'].mean().reset_index()
    except KeyError as e:
        print(f"KeyError: {e}. Please check if the columns exist in the DataFrame.")
        aggregated_interactions = pd.DataFrame(columns=['userID', 'videoID', 'interaction_score'])

    return aggregated_interactions[['userID', 'videoID', 'interaction_score']]

# Test aggregate_interactions function
try:
    interactions = aggregate_interactions(clicks, comments, likes, purchases, shares, views)
    print("Aggregated interactions:\n", interactions.head())
except KeyError as e:
    print(f"KeyError occurred: {str(e)}")

# Preprocess videos
def preprocess_videos(videos):
    if videos.empty:
        print("Warning: Videos DataFrame is empty. Check Firestore data retrieval.")
        return None, None

    # Normalize 'likeCount'
    scaler = StandardScaler()
    videos['likeCount'] = scaler.fit_transform(videos[['likeCount']].fillna(0))  # Fill NaNs with 0

    # Convert 'categories' to one-hot encoding
    encoder = OneHotEncoder(sparse_output=False)  # Use sparse_output for Scikit-learn 0.22 or later
    # categories_encoded = encoder.fit_transform(videos[['categories']].fillna('unknown'))  # Fill NaNs with 'unknown'

    # Vectorize 'description' and 'title' using TF-IDF
    vectorizer_desc = TfidfVectorizer(max_features=500)
    description_tfidf = vectorizer_desc.fit_transform(videos['description'].fillna('')).toarray()

    vectorizer_title = TfidfVectorizer(max_features=500)
    title_tfidf = vectorizer_title.fit_transform(videos['title'].fillna('')).toarray()

    # Combine all features
    # video_features = np.hstack((videos[['likeCount']], categories_encoded, description_tfidf, title_tfidf))
    video_features = np.hstack((videos[['likeCount']], description_tfidf, title_tfidf))

    return videos, video_features

# Preprocess videos and get video features
videos, video_features = preprocess_videos(videos)

# Ensure `video_features` is defined before using it
if video_features is not None and video_features.size > 0:
    # Create user-item interaction matrix
    user_item_matrix = interactions.pivot(index='userID', columns='videoID', values='interaction_score').fillna(0)

    # Filter video features to match the order of video IDs in the user-item matrix
    video_ids_order = user_item_matrix.columns
    video_features = video_features[np.isin(videos['video_id'], video_ids_order)]
    cosine_similarities = cosine_similarity(video_features)

    # Convert to sparse matrix format
    user_item_sparse = csr_matrix(user_item_matrix.values)

    # Apply Truncated SVD for matrix factorization
    def apply_svd(user_item_sparse, n_components=None):
        if n_components is None:
            n_components = min(user_item_sparse.shape[0], user_item_sparse.shape[1]) - 1
        svd = TruncatedSVD(n_components=n_components, random_state=42)
        user_factors = svd.fit_transform(user_item_sparse)
        item_factors = svd.components_.T
        return user_factors, item_factors

    # Perform SVD with appropriate n_components
    user_factors, item_factors = apply_svd(user_item_sparse)

    # Compute cosine similarities for video features
    print("Cosine Similarities Shape:", cosine_similarities.shape)
else:
    cosine_similarities = None

# Function to get hybrid recommendations including video IDs
def hybrid_recommendations(user_id, top_n=10, weight_cf=0.5, weight_cb=0.5):
    if user_id in users['user_id'].values:
        user_idx = users.index[users['user_id'] == user_id][0]
    else:
        raise ValueError(f"User ID {user_id} not found in the dataset.")

    user_interactions = user_item_matrix.iloc[user_idx].values

    # Ensure user_interactions is correctly shaped
    user_interactions = user_interactions.reshape(1, -1)

    print("User Interactions Shape:", user_interactions.shape)
    print("User Factors Shape:", user_factors.shape)
    print("Item Factors Shape:", item_factors.shape)

    cf_recommendations = weight_cf * user_factors[user_idx].dot(item_factors.T)
    print("CF Recommendations Shape:", cf_recommendations.shape)

    if cosine_similarities is not None:
        print("Cosine Similarities Shape:", cosine_similarities.shape)
        # Ensure cosine_similarities matrix has the correct shape for multiplication
        user_interactions = user_interactions.flatten()  # Flatten to make it 1D
        print("Adjusted User Interactions Shape:", user_interactions.shape)
        cb_recommendations = weight_cb * cosine_similarities.dot(user_interactions.T)
        cb_recommendations = cb_recommendations.flatten()  # Flatten to make it 1D
        print("CB Recommendations Shape:", cb_recommendations.shape)
        combined_scores = cf_recommendations + cb_recommendations
    else:
        combined_scores = cf_recommendations

    top_indices = combined_scores.argsort()[-top_n:][::-1]
    recommended_videos = videos[videos['video_id'].isin(user_item_matrix.columns[top_indices])].copy()

    return recommended_videos[['video_id', 'title']]  # Assuming 'title' is a column in videos

