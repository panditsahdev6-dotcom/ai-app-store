from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import uuid

app = FastAPI(title="AI App Store Backend 🚀")

# ------------------------------
# 🧠 Fake Database (temporary)
# बाद में Firebase / DB से connect करेंगे
# ------------------------------

apps_db = []
uploads_db = []

# ------------------------------
# 📦 Models
# ------------------------------

class AppModel(BaseModel):
    name: str
    description: str
    category: str
    iconUrl: str
    downloadUrl: str
    version: str = "1.0.0"

class UploadModel(BaseModel):
    name: str
    description: str
    category: str
    iconUrl: str
    downloadUrl: str
    userId: str


# ------------------------------
# 🏠 Home Route
# ------------------------------

@app.get("/")
def home():
    return {"message": "AI App Store API Running 🚀"}


# ------------------------------
# 📱 Get All Apps
# ------------------------------

@app.get("/apps", response_model=List[dict])
def get_apps():
    return apps_db


# ------------------------------
# 📱 Add App (Admin Only)
# ------------------------------

@app.post("/apps")
def add_app(app_data: AppModel):
    app_id = str(uuid.uuid4())

    app_dict = app_data.dict()
    app_dict.update({
        "id": app_id,
        "downloads": 0,
        "rating": 0
    })

    apps_db.append(app_dict)

    return {"message": "App added successfully 🚀", "app_id": app_id}


# ------------------------------
# 📥 Download Tracking
# ------------------------------

@app.post("/apps/{app_id}/download")
def download_app(app_id: str):
    for app in apps_db:
        if app["id"] == app_id:
            app["downloads"] += 1
            return {"message": "Download counted 📊"}

    raise HTTPException(status_code=404, detail="App not found")


# ------------------------------
# 📤 Public Upload (Pending)
# ------------------------------

@app.post("/upload")
def upload_app(upload: UploadModel):
    upload_id = str(uuid.uuid4())

    upload_dict = upload.dict()
    upload_dict.update({
        "id": upload_id,
        "status": "pending"
    })

    uploads_db.append(upload_dict)

    return {"message": "Upload submitted for review ⏳"}


# ------------------------------
# 🔐 Admin Approve Upload
# ------------------------------

@app.post("/admin/approve/{upload_id}")
def approve_upload(upload_id: str):
    for upload in uploads_db:
        if upload["id"] == upload_id and upload["status"] == "pending":

            new_app = upload.copy()
            new_app.update({
                "id": str(uuid.uuid4()),
                "downloads": 0,
                "rating": 0
            })

            apps_db.append(new_app)
            upload["status"] = "approved"

            return {"message": "App approved and published 🚀"}

    raise HTTPException(status_code=404, detail="Upload not found")


# ------------------------------
# 🤖 AI Recommendation (Basic)
# ------------------------------

@app.get("/recommend/{category}")
def recommend_apps(category: str):
    recommended = [app for app in apps_db if app["category"] == category]
    return {"recommended": recommended}


# ------------------------------
# 📊 Top Apps (Trending)
# ------------------------------

@app.get("/top-apps")
def top_apps():
    sorted_apps = sorted(apps_db, key=lambda x: x["downloads"], reverse=True)
    return sorted_apps[:5]