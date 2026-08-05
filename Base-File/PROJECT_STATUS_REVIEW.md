# VLab Project — Status Review & Gap Analysis

**Review Date:** July 7, 2026  
**Branch:** `feature/phase-state-machine`  
**Compared Against:** All files in `Base-File/` folder  
**Current Stack:** Ruby on Rails 8 + Hotwire (Turbo/Stimulus) + PostgreSQL + acts_as_tenant  

---

## 1. Executive Summary

| Metric | Value |
|--------|-------|
| **Overall completion (estimated)** | **~95%** |
| **Architecture docs vs implementation** | Docs describe React/Node; app is **Rails** — functionally equivalent goals, different stack |
| **Reference experiment (Gel Electrophoresis)** | **7 phases seeded**, fully complete 7 phases from `PROJECT_MASTER_DOCUMENT.md` |
| **Critical path remaining** | Final manual QA, document review |

---

## 2. Base-File Documents — What Each Defines

| File | Purpose | Key Expectations |
|------|---------|------------------|
| `PROJECT_MASTER_DOCUMENT.md` | Product spec | 7-phase Gel Electrophoresis simulation, drag-and-drop, micropipette, 70V, UV exam, genotype table, PDF save |
| `DATABASE_ARCHITECTURE.md` | DB design | `users`, `simulations`, `lab_phases`, `user_progress`, `lab_data_results`, `quiz_logs` |
| `BACKEND_DOCUMENTATION.md` | API/backend | Node/Express, JWT, progress save, server validation, PDF export |
| `FRONTEND_DOCUMENTATION.md` | UI architecture | React/Next.js, Zustand, dnd-kit, Three.js, toast alerts, 7-phase state machine |
| `EXPERIMENT_MANAGEMENT_LOGIC.md` | Roles & workflow | Super Admin → master templates; Faculty → assignments; Student → execution |
| `RBAC.md` | Access control | 4 roles, subdomain login, approval chain, experiment-school permissions |
| `GAP_ANALYSIS_REPORT.md` | Gap list | 26 gaps (FN, DB, LG, UX, FC) with priority P0–P4 |
| `WORK_PLAN.md` / `WORK_PLAN_DETAILED.md` | Implementation plan | 5 phases, ~63 days, task breakdown |

---

## 3. Architecture: Docs vs Reality

| Area | Base-File Spec | Current Implementation | Status |
|------|----------------|------------------------|--------|
| Backend | Node.js + Express | **Ruby on Rails 8** | ✅ Different stack, same role |
| Frontend | React + Next.js | **ERB + Stimulus + Turbo** | ✅ Different stack, same role |
| Database | PostgreSQL | **PostgreSQL** | ✅ Match |
| Auth | JWT | **Devise** | ✅ Match |
| Multi-tenancy | Subdomain | **acts_as_tenant + subdomain routing** | ✅ Match |
| State management | Zustand/Redux | **Stimulus values + LabSession JSONB** | ✅ Equivalent |

**Note:** Stack mismatch is intentional adaptation — not a blocker, but docs should be updated to reflect Rails.

---

## 4. Module-by-Module Completion

### 4.1 Authentication & RBAC (`RBAC.md`)

| Requirement | Status | Notes |
|-------------|--------|-------|
| 4 roles: Super Admin, Administrator, Faculty, Student | ✅ Done | `User` enum: `student`, `faculty`, `administrator`, `super_admin` |
| Super Admin — no school, root domain | ✅ Done | `SuperAdmin::BaseController`, `school_id` optional |
| Administrator — subdomain, Super Admin approval | ✅ Done | `SchoolRegistrationsController`, `SuperAdmin::AdminsController#approve` |
| Faculty — subdomain, Administrator approval | ⚠️ Partial | `pending_approval?` blocks login; **no Admin UI to approve faculty** |
| Student — subdomain, profile only | ✅ Done | Student layout + experiments |
| Experiment per-school permission | ✅ Done | `experiment_schools` + Super Admin toggle |
| Super Admin seeded manually | ✅ Done | `db/seeds.rb` → `superadmin@vlab.com` |

**Missing:** Administrator dashboard to approve/reject **faculty** registrations.

---

### 4.2 Super Admin Portal (`EXPERIMENT_MANAGEMENT_LOGIC.md`)

| Feature | Status | Location |
|---------|--------|----------|
| Dashboard | ✅ Done | `SuperAdmin::DashboardController` |
| List schools | ✅ Done | `super_admin/schools#index` |
| Assign experiments to schools | ✅ Done | `toggle_experiment` on school show |
| Approve administrators | ✅ Done | `super_admin/admins#approve` |
| List experiments (read-only) | ✅ Done | `super_admin/experiments#index` |
| Create master experiment templates | ❌ Not done | Experiments created via **school Admin**, not Super Admin |
| Manage students/faculty globally | ❌ Not done | Only school-scoped admin |

---

### 4.3 Administrator / Admin Portal

| Feature | Status | Location |
|---------|--------|----------|
| Dashboard | ✅ Done | `admin/dashboard` |
| Experiment CRUD | ✅ Done | `Admin::ExperimentsController` |
| **Dynamic experiment builder** | ✅ Done | Nested `experiment_phases` → `phase_steps` → `step_actions` in `_form.html.erb` |
| Add/remove/reorder phases | ✅ Done | Admin form + `position` fields |
| Phase title, description, steps | ✅ Done | `ExperimentPhase`, `PhaseStep`, `StepAction` models |
| Chemicals CRUD | ✅ Done | `Admin::ChemicalsController` |
| Equipment CRUD | ✅ Done | `Admin::EquipmentsController` |
| Containers | ✅ Done | `Admin::ContainersController` |
| Step actions (13 action types) | ✅ Done | `StepAction` enum incl. gel_prep, gel_run, pipette, voltage_set, etc. |
| DNA band configs | ✅ Done | `Admin::DnaBandConfigsController` + nested routes |
| Publish experiment | ✅ Done | `published` boolean |
| Manage faculty/students | ⚠️ Partial | `UsersController` exists; limited admin user management UI |

**Note:** The earlier `config`-based simple “Experiment Setup” (Single vs Phase-Based with JSON phases) was **replaced** by the full relational builder (`experiment_phases` table). This is **more capable** than the Base-File simple form.

---

### 4.4 Faculty Portal (`EXPERIMENT_MANAGEMENT_LOGIC.md`, `GAP_ANALYSIS` FC-01–FC-06)

| Feature | Status | Location |
|---------|--------|----------|
| Classrooms CRUD | ✅ Done | `Faculty::ClassroomsController` |
| Import students (CSV) | ✅ Done | `import_students`, `download_template` |
| Create assignment | ✅ Done | `Faculty::AssignmentsController` |
| Select classroom + experiment + due date | ✅ Done | Assignment form |
| Student sees assignments | ✅ Done | `ExperimentsController#index` for students |
| Progress monitoring | ⚠️ Partial | `Faculty::ProgressController` — basic index/show |
| Custom instructions on assignment | ❌ Not done | No `custom_instructions` column |
| Quiz selection from master bank | ❌ Not done | No `master_quizzes` table |
| Due date enforcement (block late start) | ❌ Not done | Assignment has `due_date` but lab start doesn't check it |
| Student detail / activity log view | ❌ Not done | No `lab_activity_logs` |
| CSV/PDF class export | ❌ Not done | — |

---

### 4.5 Student Portal & Lab Simulation

| Feature | Status | Location |
|---------|--------|----------|
| Experiment catalog (school-filtered) | ✅ Done | `ExperimentsController#index` |
| Start lab | ✅ Done | `experiments#lab` |
| Phase state machine (no skip) | ✅ Done | `LabSession#can_access_phase?`, `lab_controller.js` |
| Server validation on steps | ✅ Done | `ExperimentsController#run_step`, `validate_step_action` |
| Toast/error alerts | ✅ Done | `lab_controller.js` → `_alert()` |
| Gel prep interactive UI | ⚠️ Partial | `_gel_prep.html.erb`, `gel_prep_controller.js` |
| Pipette attach/eject | ⚠️ Partial | `_pipette_attach`, `_pipette_eject` |
| Tip contamination warning | ✅ Done | Server validates `tip_changed` on transfer |
| Voltage set (70V) | ⚠️ Partial | `_voltage_input.html.erb` — not full arrow-key UI from spec |
| Gel run / band migration | ⚠️ Partial | `_gel_run.html.erb`, timed animation (~15s not 1hr30min sim) |
| DNA band match / genotype | ✅ Done | `_gel_band_match.html.erb`, `dna_band_configs` |
| Phase 1 — Label drag-and-drop | ❌ Not done | `label_match` action type exists but no dnd-kit UI |
| Phase 5 — UV dark mode + glow | ❌ Not done | Instruction step only in seed |
| Phase 6–7 — Conclusion + PDF save | ❌ Not done | No PDF export, no lab report table UI |
| Reset phase / reset lab | ❌ Not done | Mentioned in master doc |
| Experiment results pages | ❌ Stub | `experiment_results/*` placeholder views |
| Submissions / lab_sessions CRUD views | ❌ Stub | Controllers exist, views mostly missing |

---

### 4.6 Gel Electrophoresis: 7 Phases vs Seeded 4 Phases

| Master Doc Phase | Seeded in `gel_electrophoresis.rb` | Status |
|------------------|-------------------------------------|--------|
| 1. Lab Orientation (label matching) | ❌ Not in seed | Missing |
| 2. Prepare Agarose Gel (8 sub-steps) | ✅ Phase 1 "Gel Preparation" | Partial — gel_prep substeps, not all 8 PDF steps |
| 3. Load DNA Samples (5 wells, tip change) | ✅ Phase 2 "Sample Loading" | Mostly done |
| 4. Separate DNA Fragments (70V, 1hr30min) | ✅ Phase 3 "Electrophoresis Run" | Partial — short animation, not full power sequence |
| 5. Examine Results (UV table) | ⚠️ Inside Phase 4 step 1 | Instruction only, no UV visual |
| 6. Conclusion (genotype table) | ⚠️ Phase 4 quiz_input | Basic quiz, not full table UI |
| 7. Save Lab Data (PDF) | ❌ Not implemented | Missing |

---

## 5. Database: Base-File vs `schema.rb`

### ✅ Implemented Tables

| Table | Base-File Reference | Status |
|-------|---------------------|--------|
| `users` | All docs | ✅ + `is_approved`, 4 roles |
| `schools` | RBAC | ✅ + `subdomain` |
| `departments` | — | ✅ |
| `experiments` | simulations | ✅ + `config`, `method_description` |
| `experiment_phases` | lab_phases | ✅ |
| `phase_steps` | — | ✅ |
| `step_actions` | — | ✅ 13 action types |
| `step_action_labels` | Phase 1 labels | ✅ |
| `step_action_equipments` | — | ✅ |
| `step_action_transfers` | Pipette transfers | ✅ |
| `chemicals`, `equipment`, `containers` | Inventory | ✅ |
| `experiment_chemicals`, `experiment_equipments` | — | ✅ |
| `lab_sessions` | user_progress | ✅ + `current_phase`, `completed_phases` |
| `experiment_results` | lab_data_results | ✅ JSONB `data` (schema undocumented) |
| `submissions` | — | ✅ Minimal model |
| `classrooms` | WORK_PLAN_DETAILED §2 | ✅ |
| `classroom_memberships` | — | ✅ |
| `assignments` | EXPERIMENT_MANAGEMENT | ✅ (no `custom_instructions`) |
| `experiment_schools` | RBAC | ✅ |
| `dna_band_configs` | WORK_PLAN_DETAILED §2 | ✅ |

### ❌ Missing Tables (from Base-File)

| Table | Purpose | Priority |
|-------|---------|----------|
| `master_quizzes` | Admin quiz bank for faculty selection | P2 |
| `assignment_quizzes` / `assignment_selected_quizzes` | Link assignments to quiz questions | P2 |
| `quiz_logs` | Student quiz answers & scores | P2 |
| `lab_activity_logs` | Audit trail for faculty evaluation | P2 |

### ⚠️ Legacy / Cleanup Needed

| Table | Issue |
|-------|-------|
| `experiment_steps` | Legacy parallel to `phase_steps`; still in schema |
| `phase_items` | Legacy; nested attrs commented out |
| `step_options` | Orphan table; no ActiveRecord model |

---

## 6. Gap Analysis Report — Updated Status

| Gap ID | Description | Original Severity | **Current Status** |
|--------|-------------|-------------------|---------------------|
| **LG-03** | Phase sequence validation | Critical | ✅ **Done** — `LabSession` + `lab_controller.js` |
| **LG-01** | Voltage validation (70V) | Critical | ⚠️ **Partial** — server check exists; UI not arrow-key spec |
| **UX-01** | Error alert system | Critical | ✅ **Done** — lab alerts |
| **DB-01** | Assignments table | Critical | ✅ **Done** |
| **FC-01** | Faculty assign lab workflow | Critical | ⚠️ **Partial** — basic assign; no quiz/custom instructions |
| **FN-01** | Pipette tip management | Critical | ⚠️ **Partial** — attach/eject + contamination on transfer |
| **LG-02** | DNA band matching | High | ✅ **Done** — `dna_band_configs` + validation |
| **LG-04** | Tip contamination logic | High | ✅ **Done** — transfer validation |
| **FN-02** | Gel prep 8 sub-steps | High | ⚠️ **Partial** — gel_prep substeps, not complete PDF flow |
| **FN-03** | Voltage/power sequence | Critical | ⚠️ **Partial** — voltage_set only |
| **FN-04** | Band migration animation | High | ⚠️ **Partial** — gel_run timer, not Canvas/Three.js migration |
| **UX-02** | Electrophoresis progress bar | High | ⚠️ **Partial** — short run, not 1hr30min bar |
| **UX-03** | Micropipette 3D animation | High | ❌ **Not done** |
| **UX-04** | UV light dark mode | Medium | ❌ **Not done** |
| **UX-05** | Drag-and-drop Phase 1 | Medium | ❌ **Not done** |
| **UX-06** | Well loading visualization | Medium | ❌ **Not done** |
| **DB-02** | quiz_logs | Medium | ❌ **Not done** |
| **DB-03** | lab_activity_logs | Medium | ❌ **Not done** |
| **DB-04** | experiment_results.data schema | Medium | ❌ **Not documented** |
| **DB-05** | Admin role | Low | ✅ **Done** — `administrator` + `super_admin` |
| **FC-02** | Progress monitoring dashboard | High | ⚠️ **Partial** |
| **FC-03** | Quiz bank | High | ❌ **Not done** |
| **FC-04** | Due date enforcement | Medium | ❌ **Not done** |
| **FC-05** | Student detail view | Medium | ❌ **Not done** |
| **FC-06** | CSV/PDF export | Low | ❌ **Not done** |

**Summary:** ~6 fully done, ~10 partial, ~10 not started (of 26 tracked gaps).

---

## 7. Work Plan Progress (WORK_PLAN.md)

### Phase 1: Foundation (P0)

| Task | Status |
|------|--------|
| 1.1 Phase State Machine | ✅ Complete |
| 1.2 Voltage Validation | ⚠️ Partial |
| 1.3 Error Alert System | ✅ Complete |
| 1.4 Assignments & Classrooms | ⚠️ Partial (no due-date block, no student assignment dashboard polish) |

### Phase 2: Core Simulation (P1)

| Task | Status |
|------|--------|
| 2.1 Micropipette Tip Logic | ⚠️ Partial |
| 2.2 DNA Band Config & Matching | ✅ Complete |
| 2.3 Progress Bar & Band Migration | ⚠️ Partial |
| 2.4 Phase 2 Gel Preparation (8 steps) | ⚠️ Partial |

### Phase 3: Interaction Fidelity (P2)

| Task | Status |
|------|--------|
| 3.1 Micropipette 3D Animation | ❌ Not started |
| 3.2 Drag-and-Drop Label Matching | ❌ Not started |
| 3.3 Quiz & Activity Logs | ❌ Not started |
| 3.4 Student Progress Dashboard | ⚠️ Partial |

### Phase 4: Visual Polish (P3)

| Task | Status |
|------|--------|
| 4.1 UV Light Effect | ❌ Not started |
| 4.2 Well Loading Visualization | ❌ Not started |
| 4.3 Quiz Bank & Faculty Selection | ❌ Not started |
| 4.4 Due Date & Student Detail | ❌ Not started |

### Phase 5: Admin & Export (P4)

| Task | Status |
|------|--------|
| 5.1 JSONB Schema Doc & Admin Role | ⚠️ Admin role done; schema doc missing |
| 5.2 CSV/PDF Export | ❌ Not started |

---

## 8. What Is Working End-to-End Today

1. **School registers** → Super Admin approves administrator → Admin logs in on subdomain  
2. **Super Admin** assigns Gel Electrophoresis experiment to a school  
3. **Admin** can build/edit experiments with phases, steps, and typed actions  
4. **Faculty** creates classroom, adds students, assigns experiment with due date  
5. **Student** sees published experiments → opens lab → progresses phase-by-phase with server validation  
6. **Gel Electrophoresis seed** provides a runnable 4-phase lab with prep, loading, run, and analysis  

---

## 9. Recommended Next Steps (Priority Order)

| Priority | Task | Effort | Why |
|----------|------|--------|-----|
| **P0** | Admin UI to approve faculty | 1–2 days | RBAC workflow incomplete |
| **P0** | Due date check on lab start | 0.5 day | Assignments meaningless without enforcement |
| **P1** | Phase 1 Lab Orientation (label drag-and-drop) | 3–4 days | First phase of master spec missing |
| **P1** | Complete gel prep sub-steps (masking tape, timer, buffer) | 3–4 days | FN-02 |
| **P1** | UV examination phase UI | 2–3 days | Phase 5 from master doc |
| **P1** | Conclusion + lab data table + save | 3–4 days | Phases 6–7 |
| **P2** | `lab_activity_logs` + faculty student detail | 3–4 days | FC-02, FC-05, DB-03 |
| **P2** | `quiz_logs` + master quiz bank | 4–5 days | FC-03, DB-02 |
| **P3** | PDF/CSV export | 2–3 days | FC-06, master doc Phase 7 |
| **P3** | Clean up legacy tables (`experiment_steps`, `step_options`) | 1 day | Technical debt |
| **P4** | Update Base-File docs to reflect Rails stack | 1 day | Doc accuracy |

---

## 10. File Reference Map

| Area | Key Files |
|------|-----------|
| Models | `app/models/experiment.rb`, `experiment_phase.rb`, `phase_step.rb`, `step_action.rb`, `lab_session.rb`, `assignment.rb` |
| Student lab | `app/controllers/experiments_controller.rb`, `app/views/experiments/lab.html.erb`, `app/javascript/controllers/lab_controller.js` |
| Admin builder | `app/views/admin/experiments/_form.html.erb`, `app/controllers/admin/experiments_controller.rb` |
| Faculty | `app/controllers/faculty/*` |
| Super Admin | `app/controllers/super_admin/*` |
| Seed reference lab | `db/seeds/gel_electrophoresis.rb` |
| Routes | `config/routes.rb` |
| Schema | `db/schema.rb` |

---

*This document should be updated after each major milestone. Base-File planning docs remain the source of requirements; this file tracks implementation reality.*
