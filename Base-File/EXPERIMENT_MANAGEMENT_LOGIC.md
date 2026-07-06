# Experiment Configuration & Management Logic

## 1. Overview
এই ডকুমেন্টটি বর্ণনা করে কীভাবে ভার্চুয়াল ল্যাবের এক্সপেরিমেন্টগুলো (Experiments), ধাপগুলো (Phases), এবং কুইজগুলো (Quizzes) সিস্টেমে সেটআপ এবং ম্যানেজ করা হবে। এটি একটি Role-Based আর্কিটেকচার অনুসরণ করে।

## 2. Roles & Responsibilities

### A. Super Admin (The Developer/Content Creator)
সুপার অ্যাডমিন সিস্টেমের "Master Templates" তৈরি করবেন। 
- **Tasks:**
    - নতুন এক্সপেরিমেন্ট তৈরি করা (e.g., DNA Gel Electrophoresis)।
    - প্রতিটি ল্যাবের জন্য নির্দিষ্ট ধাপ (Phases 1-7) তৈরি করা।
    - প্রতিটি ধাপের জন্য ডিফল্ট ইনস্ট্রাকশন এবং মাস্টার কুইজ ব্যাংক তৈরি করা।
    - অ্যানিমেশন এবং লজিক প্যারামিটার সেট করা।

### B. Faculty (The Instructor)
ফ্যাকাল্টি সুপার অ্যাডমিনের তৈরি করা মাস্টার টেমপ্লেট ব্যবহার করে নিজের ক্লাসের জন্য ল্যাব সেটআপ করবেন।
- **Tasks:**
    - মাস্টার টেমপ্লেট থেকে একটি ল্যাব সিলেক্ট করা।
    - ক্লাসের জন্য ডেডলাইন (Due Date) সেট করা।
    - মাস্টার কুইজ ব্যাংক থেকে নির্দিষ্ট প্রশ্ন সিলেক্ট করা।
    - ল্যাবের নির্দিষ্ট প্যারামিটার (যেমন: DNA স্যাম্পল রেজাল্ট) কাস্টমাইজ করা।

### C. Student (The Learner)
স্টুডেন্ট ফ্যাকাল্টির দেওয়া অ্যাসাইনমেন্ট অনুযায়ী ল্যাবটি সম্পন্ন করবে।

---

## 3. Data Hierarchy & Flow

সিস্টেমটি নিচের ধারাবাহিকতায় কাজ করবে:

1. **Master Simulation (Template):** 
   - `simulations` টেবিলে মূল ল্যাবের নাম থাকে।
   - `lab_phases` টেবিলে ধাপগুলো (1-7) এবং মাস্টার ইনস্ট্রাকশন থাকে।
   - `master_quizzes` টেবিলে সব সম্ভাব্য প্রশ্ন থাকে।

2. **Class Assignment (Customization):**
   - ফ্যাকাল্টি যখন ল্যাব অ্যাসাইন করেন, তখন `assignments` টেবিলে একটি এন্ট্রি তৈরি হয়।
   - এটি একটি নির্দিষ্ট `simulation_id` এবং `classroom_id` কে যুক্ত করে।

3. **Student Attempt (Execution):**
   - স্টুডেন্ট যখন ল্যাব শুরু করে, সিস্টেম `assignments` থেকে ডাটা লোড করে স্টুডেন্টের জন্য একটি `user_progress` রেকর্ড তৈরি করে।

---

## 4. Database Schema for Management (PostgreSQL)

এই লজিকটি বাস্তবায়নের জন্য নিচের টেবিলগুলো ব্যবহার করা হবে:

### ক. মাস্টার টেমপ্লেট টেবিল (Admin Controlled)
```sql
-- মূল এক্সপেরিমেন্ট
CREATE TABLE simulations (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_by INT -- Admin ID
);

-- ল্যাবের প্রতিটি ধাপের মাস্টার ডাটা
CREATE TABLE lab_phases (
    id SERIAL PRIMARY KEY,
    sim_id INT REFERENCES simulations(id),
    phase_num INT NOT NULL,
    title VARCHAR(255),
    default_instructions JSONB, -- ডিফল্ট নির্দেশিকা
    animation_trigger VARCHAR(100) -- কোন অ্যানিমেশনটি চলবে
);

-- মাস্টার কুইজ ব্যাংক
CREATE TABLE master_quizzes (
    id SERIAL PRIMARY KEY,
    phase_id INT REFERENCES lab_phases(id),
    question_text TEXT NOT NULL,
    options JSONB NOT NULL, -- ["Opt 1", "Opt 2", ...]
    correct_option INT
);


খ. ফ্যাকাল্টি অ্যাসাইনমেন্ট টেবিল (Faculty Controlled)
CREATE TABLE assignments (
    id SERIAL PRIMARY KEY,
    classroom_id INT REFERENCES classrooms(id),
    sim_id INT REFERENCES simulations(id),
    faculty_id INT REFERENCES users(id),
    custom_instructions TEXT, -- শিক্ষক চাইলে অতিরিক্ত নোট দিতে পারেন
    selected_quizzes INT[], -- মাস্টার কুইজ আইডিগুলোর অ্যারে
    due_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


5. Setup Workflow (Step-by-Step)
Step 1: Master Setup (Admin)
অ্যাডমিন ডাটাবেসে "Gel Electrophoresis" এর জন্য ৭টি ধাপ ইনসার্ট করবেন। প্রতিটি ধাপের জন্য default_instructions এবং কুইজ সেট করে দেবেন।
Step 2: Class Assignment (Faculty)
ফ্যাকাল্টি ড্যাশবোর্ডে গিয়ে তার ক্লাসের জন্য "Gel Electrophoresis" ল্যাবটি সিলেক্ট করবেন। তিনি কুইজগুলো রিভিউ করবেন এবং একটি ডেডলাইন সেট করবেন। এটি assignments টেবিলে সেভ হবে।
Step 3: Lab Execution (Student)
স্টুডেন্ট যখন তার ড্যাশবোর্ডে "Start Lab" ক্লিক করবে, ফ্রন্টএন্ড assignments টেবিল থেকে ওই ক্লাসের জন্য নির্ধারিত কুইজ এবং ইনস্ট্রাকশনগুলো ফেচ (Fetch) করবে।
6. Key Advantages
Scalability: ভবিষ্যতে নতুন কোনো ল্যাব (যেমন: Titration) যোগ করতে হলে কোড চেঞ্জ না করে শুধু ডাটাবেসে নতুন টেমপ্লেট যোগ করলেই হবে।
Flexibility: শিক্ষকরা তাদের ক্লাসের মান অনুযায়ী কুইজ বা ইনস্ট্রাকশন পরিবর্তন করতে পারবেন।
Consistency: মূল ল্যাবের নিয়ম বা অ্যানিমেশন সব ক্লাসের জন্য একই থাকবে, যা ভুলের সম্ভাবনা কমায়।

