import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler
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
    # Assign interaction types and merge into a single DataFrame
    clicks['interaction_score'] = interaction_type_scores['Click']
    comments['interaction_score'] = interaction_type_scores['Comment']
    likes['interaction_score'] = interaction_type_scores['Likes']
    purchases['interaction_score'] = interaction_type_scores['Purchase']
    shares['interaction_score'] = interaction_type_scores['Shares']
    views['interaction_score'] = interaction_type_scores['View']
    
    # Concatenate all interaction DataFrames
    interactions = pd.concat([clicks, comments, likes, purchases, shares, views], ignore_index=True)
    
    # Example: Aggregate interactions by grouping and computing mean score
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

# Preprocess products as before
def preprocess_products(products):
    if products.empty:
        print("Warning: Products DataFrame is empty. Check Firestore data retrieval.")
        return None, None, None

    scaler = StandardScaler()
    numeric_columns = ['price', 'rating']

    for col in numeric_columns:
        if col not in products.columns:
            products[col] = None

    products[numeric_columns] = scaler.fit_transform(products[numeric_columns])

    product_features = products[['price', 'rating']]  # Adjust as per your actual features
    product_categories = products['category']  # Adjust as per your actual categories

    return products, product_features, product_categories

# Preprocess products
products, product_features, product_categories = preprocess_products(products)

# Create user-item interaction matrix
user_item_matrix = interactions.pivot(
    index='userID', columns='videoID', values='interaction_score').fillna(0)

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

# Ensure correct cosine similarity matrix
if product_features is not None and not product_features.empty:
    cosine_similarities = cosine_similarity(product_features)
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
    recommended_products = products.iloc[top_indices].copy()

    recommended_products = recommended_products.merge(
        videos[['video_id']], on='product_id', how='left')

    return recommended_products[['product_id', 'video_id']]

# Example usage
# try:
#     user_id = users['user_id'].iloc[0]  # Replace with an actual user ID from your dataset
#     recommendations = hybrid_recommendations(user_id, top_n=10)
#     print("Recommendations:\n", recommendations)
# except ValueError as e:
#     print(f"Error: {e}")
