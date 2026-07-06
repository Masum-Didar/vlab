Document 1: Frontend Technical Documentation
Project Name: Virtual Chemistry Lab (Gel Electrophoresis Simulation)
Role: Frontend Architecture
Objective: একটি হাইলি ইন্টারঅ্যাক্টিভ এবং রিঅ্যাক্টিভ ইউজার ইন্টারফেস তৈরি করা যা ল্যাব এনভায়রনমেন্টকে সিমুলেট করবে।
১. টেকনোলজি স্ট্যাক (Tech Stack)
Framework: React.js অথবা Next.js (কম্পোনেন্ট ভিত্তিক আর্কিটেকচারের জন্য)।
State Management: Redux Toolkit অথবা Zustand (পুরো ল্যাবের স্টেট যেমন: কোন স্যাম্পল লোড হয়েছে, কারেন্ট ফেজ কত—এসব ট্র্যাক করার জন্য)।
Graphics & Interaction:
Three.js / React Three Fiber: যদি ৩ডি ইন্টারফেস তৈরি করতে চান।
Konva.js / HTML5 Canvas: ২ডি ড্র্যাগ-এন্ড-ড্রপ এবং স্যাম্পল অ্যানিমেশনের জন্য।
Styling: Tailwind CSS (দ্রুত ইউআই ডিজাইনের জন্য)।
Animation: Framer Motion (স্মুথ ট্রানজিশন এবং পপ-আপের জন্য)।
২. কম্পোনেন্ট আর্কিটেকচার (Component Architecture)
Layout: মেইন কন্টেইনার যা পুরো স্ক্রিনকে ৩টি অংশে ভাগ করবে (Sidebar, Stage, InfoPanel)।
InventorySidebar: ড্র্যাগযোগ্য লেবেল এবং ইকুইপমেন্টের লিস্ট।
LabStage: মূল অংশ যেখানে স্যাম্পল লোড করা বা বাফার ঢালার অ্যানিমেশন ঘটবে।
InstructionPanel: বর্তমান ধাপের জন্য স্টেপ-বাই-স্টেপ গাইড।
ControlBar: নিচের মেনু (Methods, Lab Data, Reset, Phase Navigation)।
QuizModal: পপ-আপ উইন্ডো যা ভিডিওর মতো প্রশ্ন জিজ্ঞাসা করবে।
৩. স্টেট লজিক (Simulation State)
সিমুলেশনটি একটি 'State Machine' হিসেবে কাজ করবে:
currentPhase: (1 to 7)
inventoryStatus: কোন আইটেমটি ব্যবহার করা হয়েছে বা হয়নি।
labData: ইউজার যে ডাটা ইনপুট দিচ্ছে (Genotype table)।
timer: ইলেকট্রোফোরোসিস প্রসেসের জন্য কাউন্টডাউন।
৪. ইন্টারঅ্যাকশন ডিজাইন (Key Interactions)
Drag-and-Drop: লেবেলটি সঠিক ইকুইপমেন্টের উপর পড়লে স্টেট আপডেট হবে।
Validation: ইউজার যদি ভুল কিছু করে (যেমন: জেল তৈরি না করে স্যাম্পল লোড করা), তবে একটি গ্লোবাল Toast বা Alert সিস্টেম নোটিফিকেশন দেবে।




# Frontend Technical Documentation: Virtual Lab Simulator

## 1. Overview
This document outlines the frontend architecture for a web-based "Gel Electrophoresis" virtual lab. The goal is to provide a highly interactive, responsive, and state-driven UI.

## 2. Tech Stack
- **Framework:** React.js / Next.js
- **Styling:** Tailwind CSS
- **State Management:** Zustand or Redux Toolkit (To track current phase, lab equipment status, and user data).
- **Animations/Interactions:** 
    - **Framer Motion:** For smooth transitions and UI feedback.
    - **React-DnD / dnd-kit:** For drag-and-drop equipment labeling and sample loading.
- **Icons:** Lucide-React.

## 3. Component Hierarchy
- **Layout:** Main wrapper with a 3-column layout (Left: Sidebar, Center: Lab Stage, Right: Instructions).
- **InventorySidebar:** Contains draggable items (labels, micropipettes, tips).
- **LabStage:** The interactive area where animations happen (Chamber, Tray, UV Table).
- **ControlBar:** Bottom menu for Phase navigation, Methods, Lab Data, and Reset.
- **QuizModal:** Pop-up UI for in-phase assessment questions.

## 4. Simulation State Logic
The frontend must manage a "State Machine":
- `currentPhase`: (1 - 7).
- `inventoryStatus`: Tracks which items have been interacted with.
- `labData`: Stores user-input genotypes (DNA 1, 2, 3).
- `timerActive`: Simulates the 1 hour 30 mins electrophoresis runtime.

## 5. UI Requirements
- **Responsive Design:** Must work on Desktop and Tablets.
- **Visual Cues:** Glowing effects for items that need to be clicked next.
- **Alert System:** Red toasts for wrong actions (e.g., trying to run the gel without buffer).

