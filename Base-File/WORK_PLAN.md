# Work Plan — Virtual Lab Simulator (Gel Electrophoresis)

**Goal:** Complete the project to 100% functional state based on the Gap Analysis Report.

---

## Phase 1: Foundation (Priority P0)

### Task 1.1: Phase State Machine
- [ ] Implement State Machine pattern (frontend + backend)
- [ ] Track `completedPhases` in Zustand/Redux store
- [ ] Prevent skipping phases (server-side validation in `LabSession`)
- [ ] Auto-unlock next phase when current phase is complete

### Task 1.2: Voltage Validation
- [ ] Build arrow-key UI component for voltage setting
- [ ] Add server-side validation (`voltage_used == 70`)
- [ ] Fail experiment if voltage is incorrect

### Task 1.3: Error Alert System
- [ ] Build global Toast/Alert Stimulus controller
- [ ] `showError(message)` and `showSuccess(message)` methods
- [ ] Integrate with all step interactions

### Task 1.4: Assignments & Classrooms System
- [ ] Create `classrooms` table and model
- [ ] Create `assignments` table and model
- [ ] Faculty "Assign Lab" workflow UI
- [ ] Student "My Assignments" dashboard
- [ ] Due date enforcement

---

## Phase 2: Core Simulation Logic (Priority P1)

### Task 2.1: Micropipette Tip Logic
- [ ] Add `pipette_tip_attach`, `pipette_eject`, `pipette_transfer` action types
- [ ] Build tip attach/eject UI interactions
- [ ] Implement Autoclave Bag waste management
- [ ] Contamination warning (tip not changed between samples)

### Task 2.2: DNA Band Configuration & Matching
- [ ] Store band positions in `experiments.config` JSONB
- [ ] Implement genotype matching algorithm
- [ ] Server-side validation of genotype selection

### Task 2.3: Progress Bar & Band Migration
- [ ] Build timer component for Phase 4 (1hr 30min simulation)
- [ ] Create band migration animation (Three.js/Canvas)
- [ ] Sync progress bar with band positions

### Task 2.4: Phase 2 Gel Preparation Flow
- [ ] Implement all 8 sub-steps with proper validation
- [ ] Masking tape, comb, EtBr, pouring, timer, etc.
- [ ] Air bubble prevention logic

---

## Phase 3: Interaction Fidelity (Priority P2)

### Task 3.1: Micropipette 3D Animation
- [ ] Three.js plunger press animation
- [ ] Liquid uptake visualization
- [ ] Dispense into well animation

### Task 3.2: Drag-and-Drop Label Matching
- [ ] Phase 1: Implement dnd-kit label matching
- [ ] Green highlight on correct match
- [ ] Auto-proceed when all matched

### Task 3.3: Quiz & Activity Logs
- [ ] Create `quiz_logs` table
- [ ] Create `lab_activity_logs` table
- [ ] Log all student actions

### Task 3.4: Student Progress Dashboard
- [ ] Faculty progress monitoring view
- [ ] Per-student, per-phase status
- [ ] Mistake tracking display

---

## Phase 4: Visual Polish (Priority P3)

### Task 4.1: UV Light Effect
- [ ] Dark mode scene transition
- [ ] Glowing band effect (emissive materials)

### Task 4.2: Well Loading Visualization
- [ ] Color change on sample load
- [ ] Sample name label on well

### Task 4.3: Quiz Bank & Faculty Selection
- [ ] `master_quizzes` table
- [ ] Faculty quiz selection UI in assignment flow

### Task 4.4: Due Date & Student Detail
- [ ] Block late submissions
- [ ] Faculty student detail view (activity log, quiz answers)

---

## Phase 5: Admin & Export (Priority P4)

### Task 5.1: Schema Documentation & Admin Role
- [ ] Document `experiment_results.data` JSONB structure
- [ ] Add `admin` role to users

### Task 5.2: CSV/PDF Export
- [ ] Faculty class result export (CSV)
- [ ] Student lab report export (PDF)

---

## Milestone Timeline

| Milestone | Tasks | Estimated Effort |
|-----------|-------|-----------------|
| M1: Core Infrastructure | 1.1, 1.2, 1.3, 1.4 | 2 weeks |
| M2: Simulation Engine | 2.1, 2.2, 2.3, 2.4 | 2 weeks |
| M3: Interaction & Analytics | 3.1, 3.2, 3.3, 3.4 | 2 weeks |
| M4: Visual & Faculty Tools | 4.1, 4.2, 4.3, 4.4 | 1.5 weeks |
| M5: Admin & Final Polish | 5.1, 5.2 | 0.5 week |
| **Total** | **22 tasks** | **~8 weeks** |
