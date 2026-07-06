Document 2: Backend Technical Documentation
Project Name: Virtual Chemistry Lab (Simulation Engine)
Role: Backend Architecture & API Design
Objective: সিমুলেশন কন্টেন্ট ম্যানেজমেন্ট, ইউজার প্রগ্রেস সেভ করা এবং ডাটা ভ্যালিডেশন নিশ্চিত করা।
১. টেকনোলজি স্ট্যাক (Tech Stack)
Runtime: Node.js (Express.js) - ফ্রন্টএন্ডের সাথে একই ল্যাঙ্গুয়েজ ইকোসিস্টেম রাখার জন্য।
Database: PostgreSQL

Redis: যদি রিয়েল-টাইম সেশন হ্যান্ডল করতে হয়।
Authentication: JWT (JSON Web Token) ইউজার লগইনের জন্য।
২. ডাটাবেস স্কিমা (Database Schema - Collections)
Users: (Name, Email, StudentID, Password)।
Simulations: ল্যাবের ধাপগুলোর কন্টেন্ট, ইনস্ট্রাকশন এবং কুইজ প্রশ্নসমূহ।
LabReports:
userId: রেফারেন্স।
simulationId: রেফারেন্স।
data: { Sample1: 'Genotype A', ... }।
completedPhases: [1, 2, 3, 4]।
Logs: ইউজার ল্যাবে কী কী ভুল করেছে তার রেকর্ড (শিক্ষকদের ইভ্যালুয়েশনের জন্য)।
৩. এপিআই এন্ডপয়েন্ট (API Endpoints)
Auth: POST /api/v1/auth/login
Simulation Content: GET /api/v1/simulation/:id (সব কুইজ এবং ইনস্ট্রাকশন লোড হবে)।
Progress Update: POST /api/v1/simulation/save-progress (ইউজার কোনো ফেজ শেষ করলে সার্ভারে সেভ হবে)।
Lab Data Submission: POST /api/v1/simulation/submit-report (ফাইনাল ডাটা টেবিল সেভ করা)।
Reset Simulation: DELETE /api/v1/simulation/reset/:userId
৪. বিজনেস লজিক ও সিকিউরিটি (Core Logic)
Server-side Validation: ফ্রন্টএন্ড থেকে আসা ল্যাব ডাটা চেক করা। উদাহরণস্বরূপ: ইউজার কি ভোল্টেজ ঠিকমতো সেট করেছে? না করলে সার্ভার এরর রিটার্ন করবে।
Persistence: ইউজার যদি ল্যাব মাঝপথে বন্ধ করে দেয়, পরবর্তীতে ফিরে এসে যেন সে একই জায়গা (Phase) থেকে শুরু করতে পারে।
Export Feature: ল্যাব ডাটাকে PDF হিসেবে জেনারেট করার জন্য সার্ভার সাইড লাইব্রেরি (যেমন: pdfkit বা puppeteer) ব্যবহার করা।
সিনিয়র ডেভেলপারের পরামর্শ:
১. JSON ভিত্তিক কনফিগারেশন: সব ল্যাব ইনস্ট্রাকশন হার্ডকোড না করে একটি JSON ফাইলে রাখুন। এতে ভবিষ্যতে নতুন ল্যাব (যেমন: Titration বা Chromatography) যোগ করা সহজ হবে।
২. Error Handling: প্রতিটি ধাপে ইউজারের ভুল ইনপুটের জন্য বিস্তারিত এরর মেসেজ হ্যান্ডল করুন।
৩. Responsive Design: সিমুলেশনটি যেন ট্যাবলেট এবং ডেস্কটপ—উভয় জায়গাতেই স্মুথলি চলে।



# Backend Technical Documentation: Virtual Lab Simulator

## 1. Overview
The backend acts as the Simulation Engine, handling user authentication, progress persistence, and data validation.

## 2. Tech Stack
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** PostgreSQL
- **Auth:** JWT (JSON Web Tokens)
- **Validation:** Zod or Joi.

## 3. Core API Endpoints
### Auth
- `POST /api/v1/auth/register`: New user signup.
- `POST /api/v1/auth/login`: User login.

### Simulation Progress
- `GET /api/v1/simulation/progress`: Fetch user's current phase.
- `POST /api/v1/simulation/save-phase`: Update phase completion status.
- `POST /api/v1/simulation/reset`: Reset lab progress for the user.

### Lab Results
- `POST /api/v1/simulation/submit-data`: Save final genotype observations.
- `GET /api/v1/simulation/report/:id`: Generate a summary of the lab performance.

## 4. Security & Validation
- **Middleware:** Protect all simulation routes with JWT verification.
- **Logic Validation:** Prevent users from skipping phases via API (e.g., Phase 4 cannot be completed unless Phase 3 is flagged as done in DB).
