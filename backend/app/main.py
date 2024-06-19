# app/main.py
from fastapi import FastAPI
from router import router


app = FastAPI()

# Include the router
app.include_router(router)
