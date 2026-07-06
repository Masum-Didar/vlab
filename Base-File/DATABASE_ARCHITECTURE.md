Database Architecture Documentation
Project: Virtual Lab Simulator (Chemistry/Biology)
Architecture Style: Relational (RDBMS)
১. ডাটাবেস ডায়াগ্রাম ওভারভিউ (Entity Relationship Summary)
আমাদের সিস্টেমে মূলত ৩টি প্রধান অংশ থাকবে:
User Management: ইউজার এবং তাদের সেশন।
Lab Configuration: ল্যাবের ধাপ, ইনস্ট্রাকশন এবং কুইজ প্রশ্ন।
User Performance & Progress: ইউজার কতটুকু কাজ করল এবং তার ল্যাব ডাটা।
২. টেবিল সমূহের বিস্তারিত বর্ণনা
ক. ইউজার ম্যানেজমেন্ট (User Management)
এই অংশটি ইউজারের আইডেন্টিটি নিশ্চিত করবে।
১. users Table
Field Name	Data Type	Constraints	Description
id	UUID/INT	PK, Auto Increment	ইউজারের ইউনিক আইডি।
full_name	VARCHAR(100)	NOT NULL	ইউজারের নাম।
email	VARCHAR(100)	UNIQUE, NOT NULL	লগইন করার জন্য ইমেইল।
password_hash	TEXT	NOT NULL	এনক্রিপ্টেড পাসওয়ার্ড।
role	ENUM	('student', 'teacher')	ইউজারের ধরন।
created_at	TIMESTAMP	DEFAULT CURRENT_TIMESTAMP	অ্যাকাউন্ট তৈরির সময়।
খ. সিমুলেশন কনফিগারেশন (Lab Setup)
ল্যাবের কন্টেন্টগুলো ডাইনামিক রাখার জন্য এই টেবিলগুলো প্রয়োজন।
২. simulations Table
Field Name	Data Type	Constraints	Description
id	INT	PK, Auto Increment	ল্যাবের আইডি (যেমন: ১ = ইলেকট্রোফোরোসিস)।
title	VARCHAR(255)	NOT NULL	ল্যাবের নাম।
description	TEXT		ল্যাবের সংক্ষিপ্ত বিবরণ।
total_phases	INT	DEFAULT 1	ল্যাবে মোট কয়টি ধাপ আছে।
৩. lab_phases Table
Field Name	Data Type	Constraints	Description
id	INT	PK, Auto Increment	ধাপের আইডি।
sim_id	INT	FK -> simulations(id)	কোন ল্যাবের আন্ডারে এই ধাপ।
phase_num	INT	NOT NULL	ধাপের সিরিয়াল (1, 2, 3...)।
title	VARCHAR(255)		ধাপের শিরোনাম (যেমন: Load DNA)।
instructions	JSONB / TEXT		ওই ধাপের জন্য টেকনিক্যাল ইনস্ট্রাকশন।
৪. quiz_questions Table (ভিডিওর সেই কুইজগুলোর জন্য)
Field Name	Data Type	Constraints	Description
id	INT	PK, Auto Increment	প্রশ্নের আইডি।
phase_id	INT	FK -> lab_phases(id)	কোন ধাপে এই প্রশ্নটি আসবে।
question_text	TEXT	NOT NULL	মূল প্রশ্ন।
options	JSONB	NOT NULL	অবজেক্টিভ অপশনসমূহ।
correct_option	INT		সঠিক উত্তরের ইনডেক্স।
গ. ইউজার ডাটা এবং প্রগ্রেস (User Progress & Results)
ইউজার ল্যাবে কী করল তা এখানে সেভ হবে।
৫. user_progress Table
Field Name	Data Type	Constraints	Description
id	UUID	PK	প্রগ্রেস আইডি।
user_id	INT	FK -> users(id)	কোন ইউজার কাজ করছে।
sim_id	INT	FK -> simulations(id)	কোন ল্যাব করছে।
current_phase	INT	DEFAULT 1	ইউজার বর্তমানে কোন ধাপে আছে।
is_completed	BOOLEAN	DEFAULT FALSE	পুরো ল্যাব শেষ হয়েছে কিনা।
last_accessed	TIMESTAMP		শেষ কখন ল্যাবটি ওপেন করেছিল।
৬. lab_data_records Table (ফাইনাল রেজাল্ট টেবিল)
ভিডিওর শেষে আমরা দেখেছি একটি টেবিল (Sample vs Genotype), এটি সেখানে ডাটা সেভ করবে।
Field Name	Data Type	Constraints	Description
id	UUID	PK	রেকর্ড আইডি।
progress_id	UUID	FK -> user_progress(id)	ইউজারের বর্তমান সেশনের সাথে লিঙ্ক।
sample_name	VARCHAR(50)		যেমন: DNA 1, DNA 2.
genotype	VARCHAR(100)		ইউজারের সিলেক্ট করা রেজাল্ট।
conclusion	TEXT		Phase 6-এ ইউজারের লেখা কনক্লুশন।
৩. আর্কিটেকচারাল ডিসিশন (সিনিয়র ডেভেলপার নোট)
১. JSONB কেন?
lab_phases এর instructions বা quiz_questions এর options এর জন্য JSONB ব্যবহার করা হয়েছে। কারণ প্রতিটি ল্যাবের ইনস্ট্রাকশন বা অপশন সংখ্যা ভিন্ন হতে পারে। রিলেশনাল টেবিলে অনেকগুলো কলাম না বাড়িয়ে JSON ফরম্যাটে ডাটা রাখা ফ্লেক্সিবল।
২. UUID বনাম INT:
ইউজার আইডির জন্য INT ঠিক আছে, কিন্তু user_progress বা lab_data এর জন্য UUID ব্যবহার করা নিরাপদ। এতে ইউজারের ডাটা ইউআরএল (URL) থেকে গেস করা কঠিন হয় (Security)।
৩. Index:
আমরা user_id এবং sim_id এর উপর Index ব্যবহার করব যাতে হাজার হাজার স্টুডেন্ট একসাথে ল্যাব করলেও ডাটা দ্রুত লোড হয়।
৪. Audit Logs (Optional but recommended):
ভবিষ্যতে আমরা lab_activity_logs নামে একটি টেবিল রাখতে পারি যেখানে ইউজার প্রতিটি ক্লিকের (যেমন: UV Light ON বা Power Source 70V সেট করা) সময় এবং অ্যাকশন সেভ থাকবে। এতে টিচাররা দেখতে পারবেন স্টুডেন্ট কোথাও ভুল করেছিল কি না।


# Database Architecture Design (PostgreSQL)

## 1. Schema Overview
This project uses a relational schema to ensure data integrity and student progress tracking.

## 2. Tables & Fields

### Table: `users`
- `id`: SERIAL PRIMARY KEY
- `username`: VARCHAR(50) NOT NULL
- `email`: VARCHAR(100) UNIQUE NOT NULL
- `password_hash`: TEXT NOT NULL
- `created_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### Table: `simulations`
- `id`: SERIAL PRIMARY KEY
- `title`: VARCHAR(100) -- e.g., 'DNA Gel Electrophoresis'
- `total_phases`: INT DEFAULT 7

### Table: `user_progress`
- `id`: UUID PRIMARY KEY DEFAULT gen_random_uuid()
- `user_id`: INT REFERENCES users(id)
- `sim_id`: INT REFERENCES simulations(id)
- `current_phase`: INT DEFAULT 1
- `is_completed`: BOOLEAN DEFAULT FALSE
- `updated_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### Table: `lab_data_results`
- `id`: SERIAL PRIMARY KEY
- `progress_id`: UUID REFERENCES user_progress(id)
- `sample_name`: VARCHAR(50) -- DNA 1, DNA 2, etc.
- `genotype_selected`: VARCHAR(100)
- `conclusion`: TEXT
- `submitted_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

### Table: `quiz_logs`
- `id`: SERIAL PRIMARY KEY
- `user_id`: INT REFERENCES users(id)
- `question_id`: INT
- `is_correct`: BOOLEAN
- `attempted_at`: TIMESTAMP DEFAULT CURRENT_TIMESTAMP

## 3. Database Indexes
- Index on `user_id` in `user_progress` for fast loading.
- Index on `progress_id` in `lab_data_results`.
