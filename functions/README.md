# Cloud Functions Setup Guide

## Overview

This directory contains Firebase Cloud Functions for automated email verification reminders and other backend tasks.

## Features

- **24-Hour Reminder**: Sends email reminder to users who haven't verified after 24 hours
- **48-Hour Final Reminder**: Sends final reminder to users still unverified after 48 hours
- **User Creation Tracking**: Logs new unverified users for analytics
- **Email Verification Sync**: Syncs email verification status between Auth and Firestore

---

## Setup Instructions

### 1. Install Dependencies

```bash
cd functions
npm install
```

### 2. Configure Firebase

Make sure you have Firebase CLI installed and logged in:

```bash
npm install -g firebase-tools
firebase login
```

### 3. Initialize Firebase (if not done)

If this is your first time setting up functions:

```bash
# From project root
firebase init functions

# Select:
# - TypeScript
# - Use ESLint
# - Install dependencies
```

### 4. Configure Email Service

#### Option A: SendGrid (Recommended)

1. Sign up at [sendgrid.com](https://sendgrid.com)
2. Create an API key
3. Set environment variable:

```bash
firebase functions:config:set sendgrid.key="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"
```

4. Install SendGrid SDK:

```bash
cd functions
npm install @sendgrid/mail
```

5. Update `src/index.ts` to use SendGrid (uncomment SendGrid code)

#### Option B: Firebase Extensions

Use the [Trigger Email from Firestore](https://extensions.dev/extensions/firebase/firestore-send-email) extension:

```bash
firebase ext:install firebase/firestore-send-email
```

### 5. Build Functions

```bash
npm run build
```

### 6. Test Locally (Optional)

```bash
npm run serve
```

This starts the Firebase Emulator Suite for local testing.

### 7. Deploy to Firebase

```bash
# Deploy all functions
npm run deploy

# Or deploy specific function
firebase deploy --only functions:emailVerificationReminder24h
```

---

## Function Details

### `emailVerificationReminder24h`

- **Trigger**: Scheduled (every 24 hours)
- **Purpose**: Find users created 24h ago who haven't verified
- **Action**: Send reminder email
- **Logs**: Stores email logs in `email_logs` collection

### `emailVerificationReminder48h`

- **Trigger**: Scheduled (every 24 hours)
- **Purpose**: Find users created 48h ago who still haven't verified
- **Action**: Send final reminder email
- **Logs**: Stores email logs in `email_logs` collection

### `onUserCreated`

- **Trigger**: Firestore document created in `users/{userId}`
- **Purpose**: Track new unverified users
- **Action**: Log to analytics

### `syncEmailVerification`

- **Trigger**: Auth user created
- **Purpose**: Sync email verification status to Firestore
- **Action**: Update `emailVerified` field in user document

---

## Email Templates

Create HTML email templates in `functions/src/templates/` directory:

**Example: `verification-reminder.html`**
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .button { background-color: #4CAF50; color: white; padding: 15px 32px; text-decoration: none; display: inline-block; border-radius: 4px; }
  </style>
</head>
<body>
  <div class="container">
    <h2>Hi {{name}},</h2>
    <p>You're almost there! Please verify your email to start using Home Repair App.</p>
    <p><a href="{{verificationLink}}" class="button">Verify Email</a></p>
    <p>Or copy this link: {{verificationLink}}</p>
    <p>This link will expire in 7 days.</p>
  </div>
</body>
</html>
```

---

## Monitoring

### View Logs

```bash
firebase functions:log
```

### Specific Function Logs

```bash
firebase functions:log --only emailVerificationReminder24h
```

### Email Logs Collection

Query `email_logs` collection in Firestore:

```javascript
db.collection('email_logs')
  .where('type', '==', 'verification_reminder_24h')
  .orderBy('sentAt', 'desc')
  .limit(100)
  .get()
```

---

## Costs

Firebase Functions pricing:
- **Invocations**: 2M free per month, then $0.40 per million
- **Compute Time**: 400K GB-seconds free, then $0.0000025 per GB-second
- **Network**: 5GB free egress per month

Estimated cost for 1000 users/month: **< $1**

---

## Troubleshooting

### Functions Not Deploying

```bash
# Check Firebase project
firebase use

# Re-authenticate
firebase login --reauth

# Check service account permissions
# Go to Firebase Console > Project Settings > Service Accounts
```

### Scheduled Functions Not Running

```bash
# Check Cloud Scheduler in GCP Console
# https://console.cloud.google.com/cloudscheduler
```

### Email Not Sending

1. Check SendGrid API key is set correctly
2. Verify sender email is verified in SendGrid
3. Check function logs for errors
4. Test with Firebase Emulator first

---

## Next Steps

1. **Prod Testing**: Deploy functions and test on staging environment
2. **Email Templates**: Create professional email templates
3. **Unsubscribe**: Add unsubscribe links to comply with regulations
4. **Analytics**: Track email open/click rates
5. **A/B Testing**: Test different email copy and timing

---

## Resources

- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [SendGrid Node.js](https://github.com/sendgrid/sendgrid-nodejs)
- [Cloud Scheduler](https://cloud.google.com/scheduler/docs)
- [Firebase Extensions](https://extensions.dev/)
