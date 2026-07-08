# VLab Completion Work Plan

**Based on:** Gap Analysis Report + Project Status Review  
**Target:** 100% feature parity with Base-File specifications  
**Estimated Timeline:** 6-8 weeks (1 developer) / 3-4 weeks (2 developers)  
**Current Status:** ~55-60% complete (see PROJECT_STATUS_REVIEW.md)

---

## ✅ Already Implemented (Partial/Full)

| Feature | Status | Notes |
|---------|--------|-------|
| Phase State Machine (LG-03) | ✅ **Done** | `LabSession#can_access_phase?` + `lab_controller.js` |
| Error Alert System (UX-01) | ✅ **Done** | `alert_controller.js` + toast events |
| Assignments & Classrooms (DB-01) | ✅ **Done** | Tables + Faculty CRUD exist |
| Admin/Super Admin Roles (DB-05) | ✅ **Done** | `administrator`, `super_admin` roles |
| DNA Band Matching Logic (LG-02) | ✅ **Done** | `dna_band_configs` + validation |
| Tip Contamination Logic (LG-04) | ✅ **Done** | Server validates `tip_changed` on transfer |
| Pipette Tip Attach/Eject (FN-01) | ✅ **Done** | Session-backed tip state, attach/eject, transfer validation, contamination warning, and visual tip/draw/dispense feedback |
| Voltage Validation Server-side (LG-01) | ⚠️ **Partial** | Check exists; UI not arrow-key spec |
| Gel Prep Sub-steps (FN-02) | ⚠️ **Partial** | 6 of 8 steps seeded; missing tape, EtBr, timer, buffer |
| Voltage Set Action (FN-03) | ⚠️ **Partial** | `voltage_set` action exists; no power ON/OFF/pause |
| Band Migration Animation (FN-04) | ⚠️ **Partial** | Timer + gel_run; not Canvas/Three.js |
| Progress Bar (UX-02) | ⚠️ **Partial** | Short 15s run; not 1hr30min simulation |
| Faculty Progress Dashboard (FC-02) | ⚠️ **Partial** | Basic index/show; no timeline/detail |
| Faculty Assignment Workflow (FC-01) | ⚠️ **Partial** | Create assignment works; no quiz selection, no custom instructions |

---

## ⚠️ Major Partial Gaps (Need Significant Work)

| Gap ID | Feature | Current State | Missing |
|--------|---------|---------------|---------|
| **FN-01** | Pipette Tip Management | ✅ Complete | Session-backed tip lifecycle, contamination validation, visible tip, plunger draw/dispense, and eject animation |
| **FN-02** | Gel Prep 8 Sub-steps | 6/8 seeded (tray, comb, mix, heat, pour, comb remove, chamber) | Masking tape, EtBr add, 10-min timer, buffer fill |
| **FN-03** | Voltage/Power Sequence | `voltage_set` (70V validation) | Power ON/OFF buttons, pause/stop, arrow-key UI, lid placement check |
| **FN-04** | Band Migration Animation | Timer + `gel_run` action (15s) | Canvas/Three.js band movement by fragment size, synced progress bar |
| **UX-02** | Electrophoresis Progress Bar | Short timer exists | 1hr30min simulated progress bar (fast-forwarded) |
| **UX-03** | Micropipette 3D Animation | None | Three.js: plunger press → liquid up → dispense into well |
| **UX-04** | UV Dark Mode + Glow | Instruction step only | Black background, emissive bands, "Turn on UV" transition |
| **UX-05** | Phase 1 Drag-and-Drop | `label_match` action_type exists | No dnd-kit UI, no drop zones, no green highlight/lock |
| **UX-06** | Well Loading Visual | None | Well color change per sample, sample name label |
| **FC-01** | Faculty Assign Lab | Assignment CRUD works | No quiz selection, no custom instructions, no due-date block |
| **FC-02** | Progress Monitoring | Basic stats table | Per-student timeline, mistakes, quiz answers, tip compliance |
| **FC-03** | Quiz Bank & Selection | `step_actions.quiz_input` only | No `master_quizzes`, no `assignment_quizzes`, no faculty picker |
| **FC-05** | Student Detail View | `progress#show` exists | No activity log, no phase/step drill-down, no voltage/tip audit |
| **DB-02/03** | `quiz_logs`, `lab_activity_logs` | Tables missing | Need migrations + logging in `run_step` + faculty UI |

---

## Phase 0: Critical Blockers (P0) — Week 1

### 0.1 Admin UI: Approve Faculty Registrations
**Files:** `app/controllers/admin/users_controller.rb`, `app/views/admin/users/index.html.erb`
- Add "Pending Faculty" tab to admin users index
- Add approve/reject actions (update `is_approved` + send email)
- **Effort:** 1 day

### 0.2 Due Date Enforcement on Lab Start
**Files:** `app/controllers/experiments_controller.rb#set_lab_session`
- Check `assignment.due_date` before creating LabSession
- Block if `Time.current > due_date`, show "Assignment past due" message
- **Effort:** 0.5 day

---

## Phase 1: Core Simulation Completion (P1) — Weeks 2-4

### 1.1 Phase 1: Lab Orientation — Drag-and-Drop Label Matching
**Files:** 
- `app/views/experiments/_label_match.html.erb` (new)
- `app/javascript/controllers/label_match_controller.js` (new)
- `db/seeds/gel_electrophoresis.rb` (add Phase 1)
**Tasks:**
- Add Phase 1 to seed with `label_match` action_type
- Build dnd-kit UI: draggable labels → drop zones on equipment images
- Green highlight on correct match, lock position
- Auto-unlock Phase 2 when all matched
- **Effort:** 3-4 days

### 1.2 Complete Gel Prep Sub-steps (FN-02) — Add Missing 4 Steps
**Current (seeded):** 6 steps (tray, comb, mix, heat, pour, remove comb, chamber)
**Missing from PDF:**
1. **Masking tape** — apply to both ends of tray
2. **Ethidium Bromide** — add to hot agarose (safety warning)
3. **10-min solidification timer** — use `phase_step.timer_duration = 600`
4. **Buffer fill** — cover gel with TAE in chamber
**Files:** `db/seeds/gel_electrophoresis.rb`, `gel_prep_controller.js`
- Add 4 new `phase_steps` with `gel_prep` action_type + new `config.substep` values
- UI: timer countdown, click-to-pop bubbles animation, tape visual
- **Effort:** 3-4 days

### 1.3 UV Examination Phase (Phase 5)
**Files:** `app/views/experiments/_uv_exam.html.erb` (new), `uv_controller.js` (new)
- Dark background (black Three.js scene)
- Glowing bands (emissive materials: blue/pink)
- "Turn on UV" button → transition effect
- Band positions from `dna_band_configs`
- **Effort:** 2-3 days

### 1.4 Conclusion Phase + Lab Data Table + PDF Export (Phases 6-7)
**Files:** 
- `app/views/experiments/_conclusion.html.erb` (new)
- `app/controllers/experiment_results_controller.rb`
- `app/services/pdf_generator.rb` (new, use `prawn`)
**Tasks:**
- Genotype table UI: Sample | Well | Bands | Genotype (dropdown) | Correct?
- Calculate score, show pass/fail
- "Save & Download PDF" → generate lab report
- PDF: Student info, experiment, phase timestamps, band image, genotype table, score
- **Effort:** 3-4 days

---

## Phase 2: Faculty Visibility & Audit (P2) — Weeks 5-6

### 2.1 `lab_activity_logs` Table + Migration
```ruby
# Migration
create_table :lab_activity_logs do |t|
  t.references :user, null: false
  t.references :lab_session, null: false
  t.references :experiment_phase
  t.references :phase_step
  t.string :action_type
  t.jsonb :metadata
  t.boolean :is_error, default: false
  t.timestamps
end
```
**Effort:** 0.5 day

### 2.2 Log Key Events
**Files:** `app/controllers/experiments_controller.rb#run_step`
- Log: phase/step enter, action submit, validation pass/fail, voltage set, tip change, band selection
- **Effort:** 1 day

### 2.3 Faculty Student Detail View
**Files:** `app/controllers/faculty/progress_controller.rb#show`, `app/views/faculty/progress/show.html.erb`
- Timeline: phase → step → action → timestamp → success/error
- Quiz answers with correct/incorrect
- Tip change compliance
- Voltage accuracy
- **Effort:** 2-3 days

### 2.4 `quiz_logs` Table + Master Quiz Bank
**Migration:**
```ruby
create_table :master_quizzes do |t|
  t.references :experiment, null: false
  t.references :phase_step, null: false
  t.text :question
  t.string :question_type # mcq, text, genotype_select
  t.jsonb :options
  t.string :correct_answer
  t.integer :points
  t.timestamps
end

create_table :assignment_quizzes do |t|
  t.references :assignment, null: false
  t.references :master_quiz, null: false
  t.timestamps
end

create_table :quiz_logs do |t|
  t.references :user, null: false
  t.references :assignment, null: false
  t.references :master_quiz, null: false
  t.text :student_answer
  t.boolean :is_correct
  t.integer :attempt_number, default: 1
  t.timestamps
end
```
**Effort:** 1 day (migrations) + 2 days (UI)

### 2.5 Faculty Quiz Selection UI
**Files:** `app/views/faculty/assignments/_form.html.erb`, `app/controllers/faculty/assignments_controller.rb`
- Checkbox list of master quizzes for selected experiment
- Store in `assignment_quizzes`
- **Effort:** 2 days

---

## Phase 3: Export & Cleanup (P3-P4) — Week 7

### 3.1 CSV/PDF Export for Faculty
**Files:** `app/controllers/faculty/progress_controller.rb`, `app/services/csv_exporter.rb`
- CSV: All students × assignment with phases, scores, mistakes
- PDF: Class summary report
- **Effort:** 2 days

### 3.2 Cleanup Legacy Tables
**Migration:** Drop `experiment_steps`, `phase_items`, `step_options`
- Verify no code references first (`grep -r`)
- **Effort:** 0.5 day

### 3.3 Document `experiment_results.data` JSONB Schema
**File:** `db/docs/experiment_results_schema.md`
```json
{
  "genotype_data": [{"sample_name", "well_number", "genotype", "correct"}],
  "voltage_used": 70,
  "total_time_seconds": 5400,
  "conclusion": "...",
  "mistakes_made": ["tip_not_changed_between_well_3_and_4"]
}
```
**Effort:** 0.5 day

### 3.4 Update Base-File Docs
**Files:** All `.md` in `Base-File/`
- Replace Node/React references with Rails/Hotwire/Stimulus
- Update architecture diagrams
- **Effort:** 1 day

---

## Dependency Graph

```
P0.1 (Admin approve faculty) ──────────────────────┐
                                                   ▼
P0.2 (Due date) ──► P1.1 (Phase 1 DnD) ──► P1.2 (Gel prep) ──► P1.3 (UV) ──► P1.4 (Conclusion/PDF)
                                                   │
                                                   ▼
                                          P2.1 (Activity logs) ──► P2.3 (Student detail)
                                                   │
                                                   ▼
                                          P2.4 (Quiz logs + bank) ──► P2.5 (Quiz selection)
                                                   │
                                                   ▼
                                          P3.1 (Export) ──► P3.2 (Cleanup) ──► P3.3 (Schema doc) ──► P3.4 (Update docs)
```

---

## Resource Allocation

| Role | Weeks 1-2 | Weeks 3-4 | Weeks 5-6 | Week 7 |
|------|-----------|-----------|-----------|--------|
| Backend | P0.1, P0.2, P1.2 seed | P1.3, P1.4, P2.1 | P2.2, P2.4 | P3.1, P3.2 |
| Frontend | P1.1 (DnD) | P1.2 UI, P1.3 UI, P1.4 UI | P2.3, P2.5 | P3.4 |

---

## Definition of Done (Per Task)

- [ ] Migration runs & rolls back
- [ ] Model specs pass
- [ ] Controller specs pass (JSON + HTML)
- [ ] System test covers happy path + 1 error case
- [ ] Manual QA on seeded Gel Electrophoresis
- [ ] No console errors in browser
- [ ] Mobile-responsive (Tailwind)

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Three.js/Canvas complexity (UV, bands) | Start with CSS-only glow; upgrade to Three.js later |
| dnd-kit integration with Stimulus | Use `stimulus-dnd` wrapper or vanilla dnd-kit in controller |
| PDF generation performance | Use `prawn` with background job (ActiveJob) for large exports |
| Faculty quiz bank UX | Ship minimal v1 (checkbox list); enhance v2 with search/filter |

---

## Quick Wins (Can Start Immediately)

1. **P0.1** — Admin approve faculty (pure CRUD, no deps)
2. **P0.2** — Due date check (5 lines in controller)
3. **P3.2** — Drop legacy tables (verify no refs first)
4. **P3.3** — Document JSONB schema (documentation only)

---

## Success Metrics

- Student completes full 7-phase Gel Electrophoresis without errors
- Faculty sees per-student timeline with mistakes
- PDF lab report downloads with correct data
- All 26 GAP items marked ✅ or ⚠️ (partial with documented follow-up)
