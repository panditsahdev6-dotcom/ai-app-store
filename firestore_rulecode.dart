rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ✅ Apps Collection (Public Read, Admin Write Only)
    match /apps/{appId} {
      allow read: if true;

      // 🔐 ONLY ADMIN CAN WRITE
      allow create, update, delete: if request.auth != null 
        && request.auth.token.admin == true;
    }

    // ✅ Uploads Collection (Users can upload, Admin approves)
    match /uploads/{uploadId} {

      // 👤 Logged-in users can create upload request
      allow create: if request.auth != null;

      // 👤 User can read only their uploads
      allow read: if request.auth != null 
        && request.auth.uid == resource.data.userId;

      // 🔐 ONLY ADMIN can approve/update/delete
      allow update, delete: if request.auth != null 
        && request.auth.token.admin == true;
    }

    // ✅ Users Collection (User profile data)
    match /users/{userId} {

      // 👤 User can read/write their own data
      allow read, write: if request.auth != null 
        && request.auth.uid == userId;
    }

  }
}