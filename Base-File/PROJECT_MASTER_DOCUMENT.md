Project Master Document: Virtual Lab Simulator (DNA Gel Electrophoresis)
1. Project Overview
এই প্রজেক্টটি একটি ইন্টারঅ্যাক্টিভ ওয়েব অ্যাপ্লিকেশন যা বায়োলজি/কেমিস্ট্রি ল্যাবের "Gel Electrophoresis" প্রক্রিয়াকে ভার্চুয়ালি সিমুলেট করে। ইউজার ল্যাবের যন্ত্রপাতি ব্যবহার করে DNA স্যাম্পল আলাদা করা এবং জিনোটাইপ বিশ্লেষণ শিখবে।
2. Core Simulation Logic (Phase-by-Phase)
সিমুলেশনটি ৭টি ধারাবাহিক ধাপে চলবে। প্রতিটি ধাপ সফলভাবে সম্পন্ন না হলে পরের ধাপে যাওয়া যাবে না।
Phase 1: Lab Orientation
Task: স্ক্রিনের বাম পাশের লেবেলগুলোকে ডান পাশের যন্ত্রপাতির সঠিক স্থানে ড্র্যাগ করে বসানো।
Success Condition: সব আইটেম (Chamber, Micropipette, Agarose, etc.) সঠিক স্থানে লেবেল করা।
Phase 2: Prepare an Agarose Gel
Sequence:
কাস্টিং ট্রেতে মাস্কিং টেপ লাগানো।
জেল কম্ব (Comb) ট্রেতে বসানো (উদ্দেশ্য: স্যাম্পল ওয়েল তৈরি করা)।
লিকুইড আগারোজে ইথিডিয়াম ব্রোমাইড (Ethidium Bromide) যোগ করা।
সাবধানে লিকুইডটি ট্রেতে ঢালা (এয়ার বাবল এড়িয়ে)।
১০ মিনিট অপেক্ষা করা (সলিড হওয়ার জন্য)।
কম্ব এবং টেপ খুলে ফেলা।
ইলেকট্রোফোরোসিস চেম্বারে ট্রে রাখা এবং বাফার সলিউশন দিয়ে চেম্বার পূর্ণ করা।
Phase 3: Load DNA Samples
Mechanism: মাইক্রোপিপেট ড্র্যাগ করে স্যাম্পল বোটল থেকে লিকুইড নেওয়া এবং ট্রের নির্দিষ্ট ওয়েল-এ (Well) রাখা।
Order:
Well 1: TNF1 (Control)
Well 2: TNF2 (Control)
Well 3: DNA Sample 1
Well 4: DNA Sample 2
Well 5: DNA Sample 3
Rule: প্রতিবার নতুন স্যাম্পল নেওয়ার আগে মাইক্রোপিপেট টিপ (Tip) বদলাতে হবে এবং পুরনো টিপ অটোক্লেভ ব্যাগে ফেলতে হবে।
Phase 4: Separate DNA Fragments
Sequence: চেম্বারের ঢাকনা লাগানো -> পাওয়ার সোর্স অন করা -> ভোল্টেজ ৭০ ভোল্টে সেট করা -> 'Play' ক্লিক করা।
Simulation Time: ১ ঘণ্টা ৩০ মিনিট (এটি ১-২ সেকেন্ডে ফাস্ট-ফরওয়ার্ড হবে)।
Result: DNA ব্যান্ডগুলো তাদের সাইজ অনুযায়ী আলাদা হয়ে যাবে।
Phase 5: Examine the Results
Action: জেল ট্রেটি UV-টেবিলে রাখা এবং UV লাইট অন করা।
Visual: ডার্ক ব্যাকগ্রাউন্ডে উজ্জ্বল নীল/পিঙ্ক ব্যান্ড দেখা যাবে।
Phase 6 & 7: Conclusion and Data Save
Task: স্যাম্পলের ব্যান্ডের সাথে কন্ট্রোল (TNF1/TNF2) ব্যান্ড মিলিয়ে ডাটা টেবিলে জিনোটাইপ সিলেক্ট করা। শেষে প্রজেক্টটি পিডিএফ আকারে সেভ করা।
3. Technical Stack
Frontend: React.js (Next.js), Tailwind CSS, Framer Motion (Animations), Lucide Icons.
Backend: Node.js (Express.js).
Database: PostgreSQL (Relational data storage).
State Management: Zustand or Redux.
4. PostgreSQL Database Schema
এই প্রজেক্টের জন্য ডাটাবেস ডিজাইনটি হবে নিম্নরূপ:
Table 1: users
id: SERIAL PRIMARY KEY
username: VARCHAR(50)
email: VARCHAR(100) UNIQUE
password: TEXT (Hashed)
Table 2: simulations
id: SERIAL PRIMARY KEY
name: VARCHAR(100) (e.g., 'Gel Electrophoresis')
total_phases: INT (default 7)
Table 3: user_progress
id: SERIAL PRIMARY KEY
user_id: INT (References users)
sim_id: INT (References simulations)
current_phase: INT (1-7)
completed_at: TIMESTAMP
Table 4: lab_data_results
id: SERIAL PRIMARY KEY
user_id: INT (References users)
sample_id: VARCHAR(20) (DNA 1, DNA 2, etc.)
genotype_selected: VARCHAR(50)
conclusion_text: TEXT
5. Visual & UI Requirements
Interactivity: সব ড্র্যাগ-এন্ড-ড্রপ ইভেন্টের জন্য স্মুথ অ্যানিমেশন থাকতে হবে।
Feedback: ভুল ধাপে ক্লিক করলে একটি রেড অ্যালার্ট মেসেজ আসবে (যেমন: "You must add Ethidium Bromide first!")।
DNA Bands Logic:
TNF1 = Single band at high position.
TNF2 = Single band at low position.
DNA Samples = এই দুইটির কম্বিনেশন।
6. Logic Gaps & Extra Features (Video Gaps Filled)
Reset Button: যেকোনো সময় ওই ফেজটি পুনরায় শুরু করার ব্যবস্থা।
Timer Simulation: ১ ঘণ্টা ৩০ মিনিটের ইলেকট্রোফোরোসিস প্রসেসটি একটি গ্রাফিক্যাল প্রগ্রেস বারের মাধ্যমে দেখানো হবে।
Genotype Key: স্যাম্পলের ব্যান্ড যদি TNF1 এর সমান উচ্চতায় হয় তবে সেটি Genotype-1, আর TNF2 এর সাথে মিললে Genotype-2।

# Project Master Document: Gel Electrophoresis Virtual Lab

## 1. Functional Requirements
This application must replicate the exact steps of a DNA Gel Electrophoresis experiment as shown in the simulation video.

## 2. Detailed Phase Logic (The Workflow)

### Phase 1: Lab Orientation
- User must match labels (Chamber Lid, DNA Samples, Buffer, etc.) to the correct lab items.
- Items stay highlighted until all are correctly labeled.

### Phase 2: Agarose Gel Preparation
1. Attach **Masking Tape** to both ends of the tray.
2. Insert **Gel Comb** into the tray.
3. Add **Ethidium Bromide** to the liquid agarose bottle.
4. Pour the agarose into the tray (Trigger pouring animation).
5. Wait for **10 minutes** (Simulated time skip).
6. Remove Comb and Tape.
7. Place tray in the **Electrophoresis Chamber**.
8. Pour **Buffer** into the chamber until full.

### Phase 3: Sample Loading (The Micropipette Logic)
- **Sequence:**
    1. Attach **Tip** to Pipette.
    2. Extract **TNF1** -> Load into **Well 1**.
    3. Eject Tip into **Autoclave Bag**.
    4. Repeat for: **TNF2 (Well 2)**, **Sample 1 (Well 3)**, **Sample 2 (Well 4)**, **Sample 3 (Well 5)**.
- **Rule:** Failure to change the tip between samples should trigger a "Contamination" warning.

### Phase 4: Separation
- Close Lid -> Power ON -> Set Voltage to **70V** -> Click Play.
- Display a progress bar for **1 hour 30 minutes**.
- UI updates to show DNA bands migrating downward.

### Phase 5: UV Examination
- Move Tray to **UV Table**.
- Switch on UV light.
- **Visuals:** DNA bands glow pink/blue. TNF1 (Control) is the top band, TNF2 (Control) is the bottom band.

### Phase 6 & 7: Lab Report
- User compares Sample 1, 2, 3 with TNF1 and TNF2.
- User selects genotypes from a dropdown in a Table UI.
- Final Step: Save and Export data.

## 3. Success Metrics
- Simulation logic must prevent skipping steps.
- Real-time feedback for errors (e.g., "Wait for the gel to solidify!").
- Final Data Table must persist in the PostgreSQL database.
