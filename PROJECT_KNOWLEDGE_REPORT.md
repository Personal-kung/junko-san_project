# Final Project Knowledge Report: Luxury Touch Massage

## 1. Executive Summary
The project is a booking management system for a massage business called "Luxury Touch Massage". It provides a customer-facing website for users to view services and book appointments, and a cross-platform admin application for the business owner to manage those bookings and update the website's content in real-time.

## 2. Project Purpose
It exists to streamline the booking process for a massage business, eliminating the need for manual appointment tracking. It allows customers to self-serve their bookings and gives administrators an easy-to-use dashboard to approve or reschedule appointments and update service offerings.

## 3. Architecture Overview
The system follows a Serverless Backend-as-a-Service (BaaS) architecture powered by Firebase.
- **Database Layer**: Firebase Firestore serves as the single source of truth.
- **Client Layer (Customer)**: A Vanilla HTML/CSS/JS frontend that reads site configuration and writes booking requests directly to Firestore.
- **Admin Layer**: A Flutter application that reads/writes both bookings and site configuration directly from/to Firestore.
- **Legacy Layer**: An obsolete Node.js Express server (`server.js`) and JSON files that have been replaced by the direct Firebase integration.

## 4. Technology Stack
- **Frontend (Client)**: HTML5, CSS3, Vanilla JavaScript, Firebase Web SDK (v10.8.0, compat). Used for the public-facing booking site due to its simplicity.
- **Admin App**: Flutter (Dart) targeting Web, Android, and iOS. Used to provide a cross-platform native experience for business management.
- **Database**: Firebase Firestore. Used for real-time data synchronization between the client and admin apps without a custom backend.
- **Legacy Backend**: Node.js, Express. Currently deprecated.

## 5. Repository Structure
- `massage_admin_app/`: Contains the active Flutter admin application.
  - `lib/`: Flutter Dart source code.
  - `client_site/`: The active vanilla web frontend for customers.
- `server.js`: Legacy Node.js backend (deprecated).
- `data.json`, `bookings.json`: Legacy local database files (deprecated).
- `migrate.js`: Script used to migrate local JSON data to Firestore.
- `DEVELOPER_GUIDE.md` / `USER_MANUAL.md`: Project documentation.

## 6. Application Entry Points
- **Customer Site**: `massage_admin_app/client_site/index.html`. Execution starts here, loads `script.js`, initializes Firebase, and establishes a real-time listener on the `site_content` collection.
- **Admin App**: `massage_admin_app/lib/main.dart`. Execution begins at `main()`, initializes Firebase, and launches the Flutter `MassageAdminApp` which connects to Firestore.

## 7. Core Domain & Business Logic
The core entities are `Services` and `Bookings`.
- **Booking Workflow**:
  Customer fills form -> JS captures data -> Writes to `bookings` Firestore collection with status "new".
- **Admin Workflow**:
  Admin opens app -> Reads `bookings` where status is "new" -> Admin approves (changes status to "approved" and adds "location") or reschedules (changes date/time, status to "rescheduled", adds "reschedule_note") -> Updates Firestore.
- **Content Management**:
  Admin edits service/branding in Flutter app -> Updates `site_content/landing_page` document -> Customer site updates in real-time via `onSnapshot` listener.

## 8. Data Model
Database: Firebase Firestore.
- **Collection `site_content` / Document `landing_page`**: Contains nested maps/arrays for `site` (branding), `contact`, and `services` (including `addons`).
- **Collection `bookings`**: Each document represents a booking request. Fields include `service`, `duration`, `addon`, `customerName`, `customerEmail`, `customerPhone`, `scheduledDateTime`, `date`, `time`, `notes`, `status` (new/approved/rescheduled), and `timestamp`.
Data flows directly from client to Firestore to admin, and vice-versa.

## 9. API & Integrations
The project relies entirely on the Firebase Firestore SDK for its API. There are no custom REST or GraphQL endpoints in the active architecture. 
- External Integration: Firebase (Cloud Firestore) is the sole critical external dependency.

## 10. Frontend / UI Architecture
- **Customer UI (`client_site`)**: A single-page static HTML layout. State is minimal; the UI simply reflects the latest snapshot from Firestore and provides a form to write to Firestore.
- **Admin UI (`massage_admin_app/lib`)**: A Flutter app using a `DefaultTabController` with three tabs: Requests (new bookings), Approved (approved bookings with CSV export), and Settings (managing site content). It uses `StreamBuilder` widgets to reactively rebuild the UI when Firestore data changes.

## 11. Authentication & Authorization
**CRITICAL FLAW**: There is currently NO authentication or authorization implemented.
- The Flutter app does not require a login.
- `firestore.rules` is configured to allow universal read/write access until April 9, 2026.
- Anyone with the Firebase config keys (which are exposed in the HTML) can read all bookings (including PII) and modify the site's content.

## 12. Configuration & Environment
- **Customer Site**: Firebase config is hardcoded in `massage_admin_app/client_site/index.html`.
- **Admin App**: Firebase config is managed via `firebase_options.dart` generated by the FlutterFire CLI.
There is no strict environment separation (e.g., dev vs. prod).

## 13. Testing
There are no automated tests (unit, integration, or E2E) present in the repository. The Flutter `test` directory likely only contains the default counter app tests, which would be broken or irrelevant.

## 14. Build / Run / Test / Deploy
- **Run Web Client**: `cd massage_admin_app/client_site/ && python -m http.server 8000`
- **Run Admin App**: `cd massage_admin_app && flutter run`
- **Deploy Web Client**: `firebase deploy --only hosting` (from `client_site`)
- **Build Admin App**: `flutter build apk` (Android), `flutter build web` (Web), `flutter build ipa` (iOS).

## 15. Feature Map
- **Customer Booking Flow**: `client_site/index.html` -> `client_site/script.js` -> Firestore `bookings` collection.
- **Admin Booking Management**: `lib/main.dart` (`RequestsTab`, `ApprovedTab`) -> Firestore `bookings` collection.
- **Admin Content Management**: `lib/main.dart` (`SettingsTab`) -> Firestore `site_content/landing_page`.
- **CSV Export**: `lib/main.dart` (`_downloadCSV`) -> `lib/web_download_helper.dart` (for Web) or local file system (for Android).

## 16. Important Files
- **CRITICAL**: `massage_admin_app/client_site/script.js` -> Contains the customer booking logic and Firebase integration.
- **CRITICAL**: `massage_admin_app/lib/main.dart` -> Contains the entire Admin application logic.
- **CRITICAL**: `massage_admin_app/firestore.rules` -> Dictates database security (currently insecure).
- **IMPORTANT**: `massage_admin_app/client_site/index.html` -> Customer UI and Firebase config.
- **REFERENCE**: `DEVELOPER_GUIDE.md` -> Explains the architectural shift from Node.js to Firebase.

## 17. Technical Debt
- **High**: No authentication system for the Admin app.
- **High**: Hardcoded Firebase configurations without environment variables.
- **High**: Entire Admin app logic, state management, and UI are stuffed into a single massive `main.dart` file (800+ lines).
- **Medium**: Legacy Node.js files (`server.js`, `data.json`, etc.) are still in the repo root, causing clutter and confusion.
- **Medium**: Lack of any automated testing.

## 18. Security Findings
- **Critical**: `firestore.rules` allows global read/write access. This is a severe data breach risk, as anyone can access customer names, emails, and phone numbers.
- **Critical**: Missing Firebase Authentication. Anyone who opens the Admin app has full control over the business operations.

## 19. Performance Findings
- **Potential Risk**: The `StreamBuilder` in Flutter rebuilds the UI on every database change. While fine for a small scale, it could become sluggish if the `bookings` collection grows very large, as it fetches all documents and filters them on the client side (`.where` is used for approved, but `RequestsTab` fetches all and filters locally in Dart).
- **Potential Risk**: CSV download loops through all approved bookings in memory, which could cause OOM errors on low-end devices if the list is massive.

## 20. Documentation Gaps
- The `DEVELOPER_GUIDE.md` accurately describes the architectural shift, but it incorrectly assumes that `firestore.rules` are configured properly for production ("Ensure your firestore.rules are configured properly..."). In reality, they are completely open.
- The repository structure is confusing because the `client_site` is nested *inside* the Flutter app directory (`massage_admin_app/`), which is an anti-pattern.

## 21. Architectural Risks
- **Tight Coupling**: The frontend and admin apps are tightly coupled directly to the database schema. Any change to the Firestore document structure requires updating both codebases simultaneously.
- **Monolithic File**: The Flutter app's `main.dart` handles UI, Firebase reads/writes, CSV generation, and platform-specific logic, making it very difficult to maintain or test.

## 22. Unknowns & Questions
- Is there a production Firebase project, or is `junko-san-05zvr7` the actual production instance?
- What are the business requirements for retaining old bookings? Should they be archived or deleted after a certain time to save Firestore costs and improve performance?

## 23. Development Guidelines
- Do not modify or rely on `server.js`, `data.json`, or `bookings.json`. They are obsolete.
- For frontend changes, only modify files within `massage_admin_app/client_site/`.
- For admin app changes, refactoring `main.dart` into smaller widgets/services should be a priority before adding new features.
- **CRITICAL**: Securing the Firestore rules and implementing Firebase Auth must be the highest priority before pushing any further updates.

## 24. Mental Model
The system is a two-sided Serverless application relying entirely on Firebase Firestore as the central communication hub. The Customer Site (HTML/JS) is a thin client that reads display settings from Firestore and writes new booking requests to it. The Admin App (Flutter) is a heavy client that reads those requests, allows the owner to approve/reschedule them, and allows the owner to edit the display settings which instantly reflect on the Customer Site. There is no intermediate backend server; business logic and security are supposed to be handled by `firestore.rules`, though currently, the system is operating without any security barriers.
