//migration information from json to firebase
const admin = require('firebase-admin');
const fs = require('fs');
const serviceAccount = require('./serviceAccountKey.json');

// 1. Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function migrateData() {
  try {
    // 2. Read your local data.json
    const rawData = fs.readFileSync('./data.json', 'utf8');
    const data = JSON.parse(rawData);

    console.log("🚀 Starting migration...");

    // 3. Upload to Firestore
    // We create a document called 'landing_page' inside 'site_content'
    await db.collection('site_content').doc('landing_page').set(data);

    console.log("✅ Migration successful! Your data is now in the cloud.");
    process.exit();
  } catch (error) {
    console.error("❌ Migration failed:", error);
    process.exit(1);
  }
}

migrateData();