# Privacy Policy — PreFlight W&B

**Effective Date:** February 10, 2026
**Last Updated:** February 10, 2026

PreFlight W&B ("the App") is developed and operated by Valderis ("we," "us," or "our"). This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application.

## 1. Information We Collect

### 1.1 Account Information
When you create an account, we collect:
- **Email address** — used for authentication (email verification codes) and account identification
- **Name** — provided by Google Sign-In if you choose that method, or omitted for email-only accounts
- **Profile photo URL** — provided by Google Sign-In only; we do not collect photos directly

### 1.2 User-Generated Content
- **Weight and balance scenarios** — aircraft configurations you save, including station loads, fuel loads, aircraft selection, and scenario names
- These are stored locally on your device and optionally synced to our servers if you sign in

### 1.3 Technical Data
- **Authentication tokens** — JSON Web Tokens stored locally on your device for session management
- **Sync timestamps** — used to coordinate data synchronization between your device and our servers

### 1.4 Information We Do NOT Collect
- Location data
- Device identifiers or advertising IDs
- Usage analytics or telemetry
- Photos, contacts, or calendar data
- Health or fitness data
- Financial or payment information
- Browsing history
- Crash reports (no crash reporting SDK is integrated)

## 2. How We Use Your Information

We use your information solely to:
- **Authenticate your identity** when you sign in
- **Store and sync your saved scenarios** across sessions and devices
- **Send verification codes** to your email address during sign-in (via Resend email service)

We do NOT use your information for:
- Advertising or marketing
- Profiling or behavioral analysis
- Sale to third parties
- Any purpose unrelated to the core functionality of the App

## 3. Data Storage and Security

### 3.1 Local Storage
- All calculation data and saved scenarios are stored locally on your device using IndexedDB
- The App works fully offline without any data leaving your device
- Local data persists until you delete the app or clear app data

### 3.2 Cloud Storage (optional, requires sign-in)
- If you sign in, your scenarios are synced to our PostgreSQL database hosted on a private Virtual Private Server
- Data is transmitted over HTTPS (TLS 1.2+)
- Authentication uses signed JSON Web Tokens with 90-day expiry
- Database access is restricted to our application server only

### 3.3 Third-Party Services
We use the following third-party services:
| Service | Purpose | Data Shared |
|---------|---------|-------------|
| Google Identity Services | Google Sign-In authentication | Email, name, profile photo (from Google) |
| Resend | Sending verification code emails | Email address |

We do not use any analytics, advertising, or tracking services.

## 4. Data Retention

- **Account data** is retained as long as your account exists
- **Saved scenarios** are retained until you delete them or delete your account
- **Deleted scenarios** are soft-deleted (marked as deleted) and may be permanently purged after 90 days
- **Verification codes** expire after 10 minutes and are marked as used upon verification

## 5. Your Rights

You have the right to:
- **Access** your data — all your scenarios are visible in the App
- **Delete** your scenarios — swipe to delete in the Scenarios page
- **Delete your account** — contact us at the email below and we will delete all your data within 30 days
- **Use the App without an account** — Guest mode provides full calculator functionality with local-only storage

## 6. Children's Privacy

The App is not directed at children under 13. We do not knowingly collect personal information from children. The App is a technical aviation tool intended for licensed pilots and student pilots.

## 7. Changes to This Policy

We may update this Privacy Policy from time to time. We will notify you of significant changes by updating the "Last Updated" date at the top of this policy. Continued use of the App after changes constitutes acceptance.

## 8. Contact

For privacy-related questions or data deletion requests:

**Email:** privacy@valderis.com
**Website:** https://preflight.valderis.com

---

*This privacy policy is required for App Store submission and complies with Apple's App Store Review Guidelines Section 5.1 (Privacy).*
