import { onSchedule } from "firebase-functions/v2/scheduler";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { defineSecret } from "firebase-functions/params";
import * as admin from "firebase-admin";

admin.initializeApp();

const sendgridKey = defineSecret("SENDGRID_KEY");

/**
 * Email Verification Reminder - 24 Hours
 */
export const emailVerificationReminder24h = onSchedule(
    {
        schedule: "every 24 hours",
        timeZone: "Africa/Cairo",
        secrets: [sendgridKey],
    },
    async (event) => {
        const db = admin.firestore();
        const now = admin.firestore.Timestamp.now();
        const yesterday = new admin.firestore.Timestamp(
            now.seconds - 86400,
            now.nanoseconds
        );

        try {
            const unverifiedUsers = await db
                .collection("users")
                .where("createdAt", ">=", yesterday)
                .where("createdAt", "<", now)
                .where("emailVerified", "==", false)
                .get();

            logger.info(
                `Found ${unverifiedUsers.size} users to remind (24h)`
            );

            const promises = unverifiedUsers.docs.map(async (userDoc) => {
                const user = userDoc.data();

                try {
                    await sendVerificationReminder(
                        user.email,
                        user.fullName,
                        user.id,
                        "24h"
                    );

                    await db.collection("email_logs").add({
                        userId: user.id,
                        type: "verification_reminder_24h",
                        sentAt: admin.firestore.FieldValue.serverTimestamp(),
                        status: "sent",
                    });

                    logger.info(`Sent 24h reminder to ${user.email}`);
                } catch (error) {
                    logger.error(
                        `Failed to send 24h reminder to ${user.email}:`,
                        error
                    );
                }
            });

            await Promise.all(promises);
            logger.info("24h email reminders completed");
        } catch (error) {
            logger.error("Error in emailVerificationReminder24h:", error);
        }
    }
);

/**
 * Email Verification Reminder - 48 Hours
 */
export const emailVerificationReminder48h = onSchedule(
    {
        schedule: "every 24 hours",
        timeZone: "Africa/Cairo",
        secrets: [sendgridKey],
    },
    async (event) => {
        const db = admin.firestore();
        const now = admin.firestore.Timestamp.now();
        const twoDaysAgo = new admin.firestore.Timestamp(
            now.seconds - 172800,
            now.nanoseconds
        );
        const threeDaysAgo = new admin.firestore.Timestamp(
            now.seconds - 259200,
            now.nanoseconds
        );

        try {
            const unverifiedUsers = await db
                .collection("users")
                .where("createdAt", ">=", threeDaysAgo)
                .where("createdAt", "<", twoDaysAgo)
                .where("emailVerified", "==", false)
                .get();

            logger.info(
                `Found ${unverifiedUsers.size} users to remind (48h)`
            );

            const promises = unverifiedUsers.docs.map(async (userDoc) => {
                const user = userDoc.data();

                try {
                    await sendVerificationReminder(
                        user.email,
                        user.fullName,
                        user.id,
                        "48h"
                    );

                    await db.collection("email_logs").add({
                        userId: user.id,
                        type: "verification_reminder_48h",
                        sentAt: admin.firestore.FieldValue.serverTimestamp(),
                        status: "sent",
                    });

                    logger.info(`Sent 48h reminder to ${user.email}`);
                } catch (error) {
                    logger.error(
                        `Failed to send 48h reminder to ${user.email}:`,
                        error
                    );
                }
            });

            await Promise.all(promises);
            logger.info("48h email reminders completed");
        } catch (error) {
            logger.error("Error in emailVerificationReminder48h:", error);
        }
    }
);

/**
 * Helper function to send verification reminder email
 */
async function sendVerificationReminder(
    email: string,
    name: string,
    userId: string,
    reminderType: "24h" | "48h"
): Promise<void> {
    const sgMail = require("@sendgrid/mail");
    const apiKey = sendgridKey.value();

    if (!apiKey) {
        logger.error("SendGrid API key not configured");
        throw new Error("SendGrid API key not configured");
    }

    sgMail.setApiKey(apiKey);

    const verificationLink = `https://homerepair.app/verify-email?userId=${userId}`;
    const subject =
        reminderType === "24h"
            ? "⏰ Verify Your Email - Home Repair App"
            : "🔔 Final Reminder: Verify Your Email";

    const htmlContent =
        reminderType === "24h"
            ? get24hEmailTemplate(name, verificationLink)
            : get48hEmailTemplate(name, verificationLink);

    const msg = {
        to: email,
        from: {
            email: "noreply@homerepair.com",
            name: "Home Repair App",
        },
        subject: subject,
        html: htmlContent,
        text: `Hi ${name}, Please verify your email. Visit: ${verificationLink}`,
    };

    try {
        await sgMail.send(msg);
        logger.info(`Successfully sent ${reminderType} email to ${email}`);
    } catch (error: any) {
        logger.error(
            `Failed to send ${reminderType} email to ${email}:`,
            error.response?.body || error
        );
        throw error;
    }
}

/**
 * Email template for 24-hour reminder
 */
function get24hEmailTemplate(name: string, verificationLink: string): string {
    return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f4f4f4;">
  <div style="max-width: 600px; margin: 40px auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px; text-align: center; color: white;">
      <h1 style="margin: 0; font-size: 28px;">✉️ Home Repair App</h1>
    </div>
    <div style="padding: 40px 30px;">
      <h2>Hi ${name},</h2>
      <p>You're almost there! We noticed you haven't verified your email yet.</p>
      <p><strong>Why verify?</strong></p>
      <ul>
        <li>✅ Book services with trusted technicians</li>
        <li>✅ Receive order updates</li>
        <li>✅ Keep your account secure</li>
      </ul>
      <div style="text-align: center;">
        <a href="${verificationLink}" style="display: inline-block; background-color: #667eea; color: white; padding: 15px 40px; text-decoration: none; border-radius: 6px; font-weight: 600; margin: 20px 0;">Verify Email Address</a>
      </div>
      <p style="margin-top: 30px; font-size: 14px; color: #666;">This link will expire in 7 days.</p>
    </div>
    <div style="background: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666;">
      <p>© 2025 Home Repair App</p>
    </div>
  </div>
</body>
</html>`;
}

/**
 * Email template for 48-hour final reminder
 */
function get48hEmailTemplate(name: string, verificationLink: string): string {
    return `<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 0; background-color: #f4f4f4;">
  <div style="max-width: 600px; margin: 40px auto; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
    <div style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); padding: 40px 20px; text-align: center; color: white;">
      <h1 style="margin: 0; font-size: 28px;">🔔 Final Reminder</h1>
    </div>
    <div style="padding: 40px 30px;">
      <h2>Hi ${name},</h2>
      <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; border-radius: 4px;">
        <strong>⚠️ Action Required:</strong> Your email still needs verification.
      </div>
      <p><strong>Without verification, you won't be able to:</strong></p>
      <ul>
        <li>❌ Book any services</li>
        <li>❌ Receive notifications</li>
        <li>❌ Access features</li>
      </ul>
      <div style="text-align: center;">
        <a href="${verificationLink}" style="display: inline-block; background-color: #f5576c; color: white; padding: 15px 40px; text-decoration: none; border-radius: 6px; font-weight: 600; margin: 20px 0;">Verify Now</a>
      </div>
      <p style="margin-top: 30px; font-size: 14px; color: #666;">
        <strong>Note:</strong> If you don't verify, we may deactivate your account.
      </p>
    </div>
    <div style="background: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666;">
      <p>© 2025 Home Repair App</p>
    </div>
  </div>
</body>
</html>`;
}

/**
 * Trigger when a new user is created
 */
export const onUserCreated = onDocumentCreated("users/{userId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        return;
    }
    const user = snapshot.data();
    const userId = event.params.userId;

    if (user && user.emailVerified === false) {
        logger.info(
            `New unverified user created: ${user.email} (${userId})`
        );
    }
});
