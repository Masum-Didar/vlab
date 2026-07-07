import { Controller } from "@hotwired/stimulus";

const PREP_STEPS = ["tray", "comb", "pour", "solidify", "remove_comb"];

export default class extends Controller {
    static targets = ["step", "tray", "comb", "gel", "wells", "progress", "input"];
    static values = {
        completedSteps: { type: Array, default: [] },
        currentStep: { type: Number, default: 0 }
    };

    connect() {
        this._render();
    }

    nextStep(event) {
        const stepIndex = Number(event.currentTarget.dataset.prepStep);
        if (stepIndex < 0 || stepIndex >= PREP_STEPS.length) return;
        if (stepIndex > this.currentStepValue) return;

        const completed = [...this.completedStepsValue];
        if (!completed.includes(stepIndex)) {
            completed.push(stepIndex);
        }
        this.completedStepsValue = completed;

        if (stepIndex + 1 < PREP_STEPS.length) {
            this.currentStepValue = stepIndex + 1;
        }

        this._render();
        this._updateInput();
    }

    _render() {
        this.stepTargets.forEach((el, i) => {
            const isDone = this.completedStepsValue.includes(i);
            const isCurrent = i === this.currentStepValue;
            const isNext = i === this.currentStepValue + 1;

            el.classList.toggle("is-done", isDone);
            el.classList.toggle("is-current", isCurrent);
            el.classList.toggle("is-pending", !isDone && !isCurrent);
        });

        const pct = Math.round((this.completedStepsValue.length / PREP_STEPS.length) * 100);
        if (this.hasProgressTarget) {
            this.progressTarget.style.width = `${pct}%`;
            this.progressTarget.textContent = `${pct}%`;
        }

        const doneSet = new Set(this.completedStepsValue);

        if (this.hasTrayTarget) {
            this.trayTarget.classList.toggle("is-placed", doneSet.has(0));
        }
        if (this.hasCombTarget) {
            this.combTarget.classList.toggle("is-inserted", doneSet.has(1));
        }
        if (this.hasGelTarget) {
            this.gelTarget.classList.toggle("is-poured", doneSet.has(2));
            this.gelTarget.classList.toggle("is-solidified", doneSet.has(3));
        }
        if (this.hasWellsTarget) {
            this.wellsTarget.classList.toggle("is-visible", doneSet.has(4));
        }
    }

    _updateInput() {
        if (!this.hasInputTarget) return;
        this.inputTarget.value = JSON.stringify({
            completed_steps: this.completedStepsValue,
            current_step: this.currentStepValue,
            all_done: this.completedStepsValue.length >= PREP_STEPS.length
        });
        this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
    }
}
