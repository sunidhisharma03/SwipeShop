# app.py

from typing import List
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import MinMaxScaler
from sklearn.feature_extraction.text import TfidfVectorizer
from scipy.sparse import csr_matrix
from sklearn.decomposition import TruncatedSVD

app = FastAPI()

# Load datasets
users = pd.read_csv('synthetic_users.csv')
products = pd.read_csv('synthetic_products.csv')
interactions = pd.read_csv('synthetic_interactions.csv')

# Define interaction type to score mapping
interaction_type_scores = {
    'view': 1,
    'comment': 2,
    'like': 3,
    'share': 4,
    'purchase': 5,
    'click': 1.5  # Assign a score to 'click'
}

# Convert interaction types to scores
interactions['interaction_score'] = interactions['interaction_type'].map(interaction_type_scores)

# Identify and handle any unmapped interaction types
unmapped_types = interactions[interactions['interaction_score'].isnull()]['interaction_type'].unique()
if len(unmapped_types) > 0:
    raise ValueError(f"Some interaction types were not mapped correctly to scores: {unmapped_types}")

# Function to preprocess products data
def preprocess_products(products):
    # Normalize numerical features
    scaler = MinMaxScaler()
    products[['price', 'rating']] = scaler.fit_transform(products[['price', 'rating']])

    # Vectorize product descriptions using TF-IDF
    vectorizer = TfidfVectorizer(stop_words='english', max_features=500)
    product_descriptions_matrix = vectorizer.fit_transform(products['description'])

    # Combine product metadata into a single feature set
    product_features = np.hstack((products[['price', 'rating']], product_descriptions_matrix.toarray()))

    # Separate and manage product categories and other non-feature columns
    product_categories = products[['product_id', 'category', 'video_id']]
    products = products.drop(columns=['category', 'video_id'])  # Drop these columns if not used in features

    return products, product_features, product_categories

# Preprocess products
products, product_features, product_categories = preprocess_products(products)

# Aggregate the interactions by taking the average score for each user-product pair
aggregated_interactions = interactions.groupby(['user_id', 'product_id'])['interaction_score'].mean().reset_index()

# Create user-item interaction matrix
user_item_matrix = aggregated_interactions.pivot(index='user_id', columns='product_id', values='interaction_score').fillna(0)

# Convert to sparse matrix format
user_item_sparse = csr_matrix(user_item_matrix.values)

# Apply Truncated SVD for matrix factorization
def apply_svd(user_item_sparse, n_components=50):
    svd = TruncatedSVD(n_components=n_components, random_state=42)
    user_factors = svd.fit_transform(user_item_sparse)
    item_factors = svd.components_.T
    return user_factors, item_factors

# Perform SVD
user_factors, item_factors = apply_svd(user_item_sparse, n_components=50)

# Compute cosine similarity between product features
cosine_similarities = cosine_similarity(product_features)

# Function to get hybrid recommendations including video IDs
def hybrid_recommendations(user_id, top_n=10, weight_cf=0.5, weight_cb=0.5):
    # Get the index of the user
    if user_id in users['user_id'].values:
        user_idx = users.index[users['user_id'] == user_id][0]
    else:
        raise ValueError(f"User ID {user_id} not found in the dataset.")
    
    user_interactions = user_item_matrix.iloc[user_idx].values
    
    # Weighted average of collaborative filtering and content-based recommendations
    cf_recommendations = weight_cf * user_factors[user_idx].dot(item_factors.T)
    cb_recommendations = weight_cb * cosine_similarities.dot(user_interactions)
    
    combined_scores = cf_recommendations + cb_recommendations
    top_indices = combined_scores.argsort()[-top_n:][::-1]

    # Get the recommended product details including video IDs
    recommended_products = products.iloc[top_indices].copy()
    recommended_products = recommended_products.merge(product_categories, on='product_id', how='left')
    
    return recommended_products[['product_id', 'video_id']]

# Define the request model for the API endpoint
class RecommendationRequest(BaseModel):
    user_id: int
    top_n: int = 10

# API endpoint to get recommendations
@app.post("/recommendations/", response_model=List[dict])
def get_recommendations(request: RecommendationRequest):
    try:
        recommendations = hybrid_recommendations(user_id=request.user_id, top_n=request.top_n)
        return recommendations.to_dict(orient='records')
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
