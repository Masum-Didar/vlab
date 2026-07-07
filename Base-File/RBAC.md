Updated Project Requirements: Role-Based Multi-Tenant System
১. রোলস (Roles):
সিস্টেমে মোট ৪টি রোল থাকবে:
Super Admin (সুপার এডমিন)
Administrator (স্কুল এডমিন)
Faculty (শিক্ষক)
Student (ছাত্র)
২. রোলের ক্ষমতা ও অ্যাক্সেস লেভেল (Access Control):
Super Admin:
তার কোনো নির্দিষ্ট school_id থাকবে না (Global Access)।
পুরো সিস্টেমের ফুল কন্ট্রোল থাকবে।
সে নির্ধারণ করবে কোন স্কুল কোন কোন Experiment অ্যাক্সেস করতে পারবে।
সুপার এডমিনকে কোনো সাব-ডোমেইনে যেতে হবে না, সে মেইন ডোমেইন থেকে সরাসরি লগইন করবে।
সুপার এডমিন অ্যাকাউন্টটি সিস্টেমের Database Seed করার মাধ্যমে ম্যানুয়ালি তৈরি করা হবে।
সে নতুন স্কুলের এডমিনিস্ট্রেটরদের রেজিস্ট্রেশন এপ্রুভ (Approve) করবে।
Administrator:
একটি নির্দিষ্ট স্কুলের আন্ডারে থাকবে এবং লগইন করার জন্য অবশ্যই ওই স্কুলের Sub-domain ব্যবহার করতে হবে।
সে তার স্কুলের Faculty এবং Student ম্যানেজ (Create/Edit/Delete) করতে পারবে।
রেজিস্ট্রেশন করার পর সে সরাসরি কাজ করতে পারবে না; Super Admin এপ্রুভ করলেই কেবল সে ড্যাশবোর্ড অ্যাক্সেস করতে পারবে।
Faculty:
নির্দিষ্ট স্কুলের সাব-ডোমেইনে লগইন করবে।
সে শুধুমাত্র Student ম্যানেজ করতে পারবে।
রেজিস্ট্রেশন করার পর তাকে ওই স্কুলের Administrator এপ্রুভ করতে হবে, তারপর সে কাজ শুরু করতে পারবে।
Student:
নির্দিষ্ট স্কুলের সাব-ডোমেইনে লগইন করবে।
সে শুধুমাত্র নিজের প্রোফাইল ম্যানেজ/আপডেট করতে পারবে।
৩. লগইন ও সাব-ডোমেইন লজিক:
Super Admin: No subdomain required (Root domain login).
Admin, Faculty, Student: Must login through schoolname.yourdomain.com.
৪. স্পেশাল ফিচার (Experiment Management):
সুপার এডমিন প্রতিটি স্কুলের জন্য আলাদা আলাদা এক্সপেরিমেন্ট পারমিশন সেট করবে। একটি স্কুল কেবল ওই এক্সপেরিমেন্টগুলোই দেখতে পাবে যা সুপার এডমিন তাদের জন্য এলাউ (Allow) করেছে।
Technical Summary for Developer:
Authentication: Use Laravel Breeze/Jetstream or custom Auth with multi-guard.
Middleware:
SubdomainMiddleware to restrict school users to their respective subdomains.
ApprovalMiddleware to check if the Admin/Faculty is approved.
Database:
users table with role and is_approved status.
schools table linked to school_id in users.
experiment_school pivot table to manage experiment access per school.
Seeder: Create a SuperAdminSeeder for the initial master account.



======================================================================================


System Architecture & Role-Based Access Control (RBAC)
1. User Roles & Descriptions
Role	Scope	Login Requirement	Approval Required By
Super Admin	Global (All Schools)	Main Domain	N/A (Created via Seed)
Administrator	School Specific	Sub-domain	Super Admin
Faculty	School Specific	Sub-domain	Administrator
Student	School Specific	Sub-domain	N/A
2. Detailed Role Permissions
A. Super Admin
School Association: Does not belong to any specific school (school_id is null).
Access Level: Full access to the entire system.
Key Responsibilities:
Manage all schools and their administrators.
Approve Administrator registration requests.
Experiment Management: Assign specific experiments to specific schools (Permission-based access).
Can modify/manage Students, Faculty, and Administrators across all schools.
Creation: Manually created using a database seeder (php artisan db:seed).
B. Administrator (School Admin)
School Association: Tied to a specific school.
Access Level: Manage their own school's data.
Key Responsibilities:
Manage (Create, Update, Delete) Faculty and Students within their school.
Must login through a Sub-domain (e.g., school1.domain.com).
Activation: Can only access the dashboard after Super Admin approves their account.
C. Faculty
School Association: Tied to a specific school.
Access Level: Manage student-related activities.
Key Responsibilities:
Manage (Create, Update, Delete) Students within their school.
Must login through the school's Sub-domain.
Activation: Can only access the dashboard after the school's Administrator approves their account.
D. Student
School Association: Tied to a specific school.
Access Level: Limited/Personal access.
Key Responsibilities:
Manage/Update only their own profile.
Must login through the school's Sub-domain.
3. System Logic & Workflow
Sub-domain Routing
Super Admin: Accesses the system via the root domain (e.g., admin.domain.com or domain.com/login).
School Users: Administrators, Faculty, and Students must visit their specific sub-domain (e.g., xyz-school.domain.com) to log in.
Approval Workflow
Admin Registration: Admin registers -> Status: Pending -> Super Admin Approves -> Admin can Login.
Faculty Registration: Faculty registers -> Status: Pending -> Administrator Approves -> Faculty can Login.
Experiment Allocation
Not all schools have access to all experiments.
The Super Admin holds the master list of experiments and maps them to schools.
Users within a school (Admin/Faculty/Student) can only see and perform experiments that have been allocated to their school by the Super Admin.
4. Technical Requirements for Developers
Multi-Tenancy: Implement sub-domain based multi-tenancy.
Middleware:
CheckApproval: To restrict users who are not yet approved.
SubdomainAccess: To ensure school users are on the correct sub-domain.
Database Seeder: Create a SuperAdminSeeder to generate the initial Super Admin account.
Database Tables:
users (id, name, email, password, role, school_id, is_approved, etc.)
schools (id, school_name, subdomain, etc.)
experiments (id, name, description, etc.)
experiment_school (Pivot table: school_id, experiment_id)

