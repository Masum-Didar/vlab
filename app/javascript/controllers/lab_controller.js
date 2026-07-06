import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["phasePanel", "phaseTab", "stepCheckbox", "phaseNavNext", "completionScreen"];
    static values = {
        currentPhase: { type: Number, default: 1 },
        completedPhases: { type: Array, default: [] },
        experimentId: Number,
        totalPhases: { type: Number, default: 1 }
    };

    connect() {
        this._render();
    }

    currentPhaseValueChanged() {
        this._render();
    }

    completedPhasesValueChanged() {
        this._render();
    }

    selectPhase(event) {
        const index = Number(event.currentTarget.dataset.phaseIndex);
        const phaseNumber = index + 1;

        if (this._canAccess(phaseNumber)) {
            this.showPhase(index);
        } else {
            this._alert("Complete the previous phase first.", "error");
        }
    }

    nextPhase() {
        const allDone = (this.completedPhasesValue?.length || 0) >= this.totalPhasesValue;
        if (allDone) return;

        const next = this.currentPhaseValue;
        if (this._canAccess(next + 1)) {
            this.showPhase(next);
        } else {
            this._alert("Complete all steps in this phase first.", "error");
        }
    }

    previousPhase() {
        this.showPhase(Math.max(this.currentPhaseValue - 2, 0));
    }

    showPhase(index) {
        const phaseNumber = index + 1;
        if (!this._canAccess(phaseNumber)) return;

        this.currentPhaseValue = phaseNumber;
        this.phasePanelTargets.forEach((panel) => {
            panel.classList.toggle("is-active", Number(panel.dataset.phaseIndex) === index);
        });
        this.phaseTabTargets.forEach((tab) => {
            const tabIndex = Number(tab.dataset.phaseIndex);
            const tabPhaseNumber = tabIndex + 1;
            tab.classList.toggle("is-active", tabIndex === index);
            tab.disabled = !this._canAccess(tabPhaseNumber);
        });

        if (this.hasPhaseNavNextTarget) {
            const isLast = index >= this.phasePanelTargets.length - 1;
            this.phaseNavNextTarget.textContent = isLast ? "Complete" : "Next";
        }
    }

    async completeStep(event) {
        const checkbox = event.currentTarget;
        const stepCard = checkbox.closest("[data-step-id]");
        if (!stepCard) return;

        const stepId = stepCard.dataset.stepId;
        const phaseIndex = Number(stepCard.dataset.phaseIndex);
        const phaseNumber = phaseIndex + 1;
        const actionType = stepCard.dataset.actionType;
        const actionData = this._collectActionData(stepCard);

        checkbox.disabled = true;

        try {
            const response = await fetch(`/experiments/${this.experimentIdValue}/run_step`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
                },
                body: JSON.stringify({
                    phase_number: phaseNumber,
                    step_number: parseInt(stepCard.dataset.stepNumber),
                    action_type: actionType,
                    action_data: actionData,
                    completed_step_ids: this._completedStepIds()
                })
            });

            const data = await response.json();

            if (data.error) {
                this._alert(data.error, "error");
                checkbox.checked = false;
                checkbox.disabled = false;
                return;
            }

            checkbox.checked = true;
            this.completedPhasesValue = data.completed_phases || [];
            this.currentPhaseValue = data.current_phase || phaseNumber;

            if (data.phase_completed) {
                this._alert(`Phase ${phaseNumber} complete!`, "success");
            }
        } catch (error) {
            this._alert("Failed to save step. Please try again.", "error");
            checkbox.checked = false;
            checkbox.disabled = false;
        }
    }

    _canAccess(phaseNumber) {
        if (phaseNumber <= 1) return true;
        return (this.completedPhasesValue || []).includes(phaseNumber - 1);
    }

    _collectActionData(stepCard) {
        const data = {};
        const inputs = stepCard.querySelectorAll("[data-action-input]");
        inputs.forEach((input) => {
            data[input.name] = input.value;
        });
        return data;
    }

    _completedStepIds() {
        const ids = [];
        this.stepCheckboxTargets.forEach((cb) => {
            if (cb.checked) {
                const card = cb.closest("[data-step-id]");
                if (card) ids.push(card.dataset.stepId);
            }
        });
        return ids;
    }

    _alert(message, type) {
        document.dispatchEvent(new CustomEvent(`toast:${type}`, {
            detail: { message }
        }));
    }

    _render() {
        const allDone = (this.completedPhasesValue?.length || 0) >= this.totalPhasesValue;

        this.phaseTabTargets.forEach((tab) => {
            const tabIndex = Number(tab.dataset.phaseIndex);
            const tabPhaseNumber = tabIndex + 1;
            const isAccessible = this._canAccess(tabPhaseNumber);
            const isCurrent = tabPhaseNumber === this.currentPhaseValue;

            tab.classList.toggle("is-active", isCurrent);
            tab.classList.toggle("is-locked", !isAccessible && !isCurrent);
            tab.disabled = !isAccessible;
        });

        this.phasePanelTargets.forEach((panel) => {
            const panelIndex = Number(panel.dataset.phaseIndex);
            const panelPhaseNumber = panelIndex + 1;
            const isAccessible = this._canAccess(panelPhaseNumber);
            const isCurrent = panelPhaseNumber === this.currentPhaseValue;

            panel.classList.toggle("is-active", isCurrent && !allDone);
            panel.classList.toggle("is-locked", !isAccessible);
        });

        if (this.hasPhaseNavNextTarget) {
            const isLast = this.currentPhaseValue >= this.phasePanelTargets.length;
            this.phaseNavNextTarget.textContent = isLast ? "Complete" : "Next";
            this.phaseNavNextTarget.disabled = allDone || false;
        }

        if (this.hasCompletionScreenTarget) {
            this.completionScreenTarget.classList.toggle("is-visible", allDone);
        }
    }
}
