import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

# Initialize Firebase Admin
cred = credentials.Certificate("./service-account.json")
firebase_admin.initialize_app(cred)

# Get Firestore client
db = firestore.client()

# Convert DocumentReference to string
def convert_doc_ref_to_string(doc_ref):
    if isinstance(doc_ref, firestore.DocumentReference):
        return doc_ref.path
    return doc_ref

# Fetch data from Firestore collections
def fetch_collection(collection_name, id_column_name):
    collection_ref = db.collection(collection_name)
    documents = collection_ref.stream()
    data = []
    for doc in documents:
        doc_data = doc.to_dict()
        # Convert DocumentReference fields to strings
        for key, value in doc_data.items():
            doc_data[key] = convert_doc_ref_to_string(value)
        doc_data[id_column_name] = doc.id
        data.append(doc_data)
    return pd.DataFrame(data)
