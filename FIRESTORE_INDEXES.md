# Firestore Indexes Deployment Guide

## What is firestore.indexes.json?

This file defines all the composite indexes your Firestore database needs. Instead of manually creating indexes through the Firebase Console each time you get an error, you can manage them in code.

## How to Deploy Indexes

### Method 1: Using Firebase CLI (Recommended)

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase** (if not already done):
   ```bash
   firebase init firestore
   ```
   - Select your project
   - Accept the default paths for rules and indexes

4. **Deploy the indexes**:
   ```bash
   firebase deploy --only firestore:indexes
   ```

### Method 2: Manual Upload via Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project `home-repair-app-46c2d`
3. Navigate to **Firestore Database** → **Indexes**
4. Click **Import/Export** → **Import indexes**
5. Upload the `firestore.indexes.json` file

## What Indexes Are Included?

The file includes indexes for:

- **Orders**: Various combinations of `technicianId`, `customerId`, `status`, and `dateRequested`
- **Reviews**: Queries by `technicianId` ordered by `timestamp`
- **Services**: Active services filtered by category
- **Users**: Filtering by role and status
- **Addresses**: User addresses ordered by usage
- **Chats**: User chats with participants array
- **Notifications**: User notifications ordered by time
- **Social Interactions**: Likes/comments queries

## Monitoring Index Build Status

After deployment:
1. Go to Firebase Console → Firestore → Indexes
2. You'll see all indexes with their build status
3. Wait for all indexes to show **"Enabled"** (usually 2-10 minutes)
4. Once enabled, your app queries will work without errors

## Tips

- **Always deploy after adding new queries** that combine filtering + sorting
- **Check the console** for index requirement errors - they include direct links
- **Version control**: Keep this file in Git so your team shares the same indexes
