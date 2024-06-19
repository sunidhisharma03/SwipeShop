import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import requests

cred = credentials.Certificate("./service-account.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

def convert_doc_ref_to_string(doc_ref):
    if isinstance(doc_ref, firestore.DocumentReference):
        return doc_ref.path
    return doc_ref

def fetch_collection(collection_name, id_column_name):
    collection_ref = db.collection(collection_name)
    documents = collection_ref.stream()
    data = []
    for doc in documents:
        doc_data = doc.to_dict()
        for key, value in doc_data.items():
            doc_data[key] = convert_doc_ref_to_string(value)
        doc_data[id_column_name] = doc.id
        data.append(doc_data)
    return pd.DataFrame(data)

def fetch_video_data(video_id):
    doc_ref = db.collection("Videos").document(video_id)
    doc = doc_ref.get()
    if doc.exists:
        return doc.to_dict()
    else:
        return None

def download_video(video_url, local_path):
    response = requests.get(video_url)
    with open(local_path, 'wb') as file:
        file.write(response.content)
