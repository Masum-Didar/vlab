# Experiment Results JSONB Schema Document

This document defines the schema structure used in the `experiment_results` table for the `data` (JSONB) field, as well as the `metadata` JSONB schema inside `lab_activity_logs`.

---

## 1. `experiment_results.data` (JSONB)
Stores student results and final genotype answers upon completing an experiment.

### Schema Fields
* `genotype_data` (Array of objects):
  * `sample_name` (String): e.g., `"Wild Type"`, `"Mutant"`, `"Heterozygous"`
  * `well_number` (Integer): The well index (1-indexed) e.g., `2`
  * `genotype` (String): The student selected genotype classification e.g., `"Wild Type"`
  * `correct` (Boolean): Whether the student answered correctly.
* `voltage_used` (Integer): Voltage value set during the run e.g., `70`.
* `total_time_seconds` (Integer): Total simulated or actual elapsed time in seconds.
* `mistakes_made` (Array of strings): Audit warnings triggered (e.g. `["tip_not_changed_between_well_3_and_4"]`).

### Example Payload
```json
{
  "genotype_data": [
    { "sample_name": "Wild Type", "well_number": 2, "genotype": "Wild Type", "correct": true },
    { "sample_name": "Mutant", "well_number": 3, "genotype": "Mutant", "correct": true },
    { "sample_name": "Heterozygous", "well_number": 4, "genotype": "Heterozygous", "correct": true }
  ],
  "voltage_used": 70,
  "total_time_seconds": 600,
  "mistakes_made": []
}
```

---

## 2. `lab_activity_logs.metadata` (JSONB)
Stores step action parameters, input selections, or error messages for audits.

### Schema Structure per Action Type

#### A. Pipette Transfer (`action_type: "transfer"`)
```json
{
  "action_data": {
    "sample": "DNA Ladder",
    "source": "DNA Ladder Tube",
    "target": "Gel Well 1",
    "well": 1
  }
}
```

#### B. Voltage Set (`action_type: "voltage_set"`)
```json
{
  "action_data": {
    "voltage": 70
  }
}
```

#### C. Validation Failures (`is_error: true`)
```json
{
  "error_message": "Contamination warning: Eject the used pipette tip and attach a fresh one before loading a new sample.",
  "action_data": {
    "sample": "Sample A",
    "source": "Sample A Tube",
    "target": "Gel Well 2",
    "well": 2
  }
}
```

#### D. Quiz Submission (`action_type: "quiz_submit"`)
```json
{
  "quiz_question": "What is the net electrical charge of DNA molecules?",
  "student_answer": "Negative charge, migrating to the positive anode",
  "attempt": 1,
  "is_correct": true
}
```
