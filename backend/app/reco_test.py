from your_module import fetch_collection, aggregate_interactions, preprocess_products, apply_svd, hybrid_recommendations
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

try:
    # Fetch data
    users = fetch_collection('Users', 'user_id')
    products = fetch_collection('Product', 'product_id')
    clicks = fetch_collection('Click', 'click_id')
    comments = fetch_collection('Comment', 'comment_id')
    likes = fetch_collection('Likes', 'likes_id')
    purchases = fetch_collection('Purchase', 'purchase_id')
    shares = fetch_collection('Shares', 'share_id')
    views = fetch_collection('View', 'view_id')
    videos = fetch_collection('Videos', 'video_id')

    # Aggregate interactions
    interactions = aggregate_interactions(clicks, comments, likes, purchases, shares, views)
    
    # Preprocess products
    products, product_features, product_categories = preprocess_products(products)
    
    # Apply SVD
    user_factors, item_factors = apply_svd(interactions, n_components=None)
    
    # Test hybrid recommendations
    test_user_id = '2jCObd8X091T3R4myZvu'
    recommendations = hybrid_recommendations(test_user_id, top_n=10)
    logger.info(f"Recommendations for {test_user_id}:")
    logger.info(recommendations)
    
except Exception as e:
    logger.error(f"Error occurred: {str(e)}")
