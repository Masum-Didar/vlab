import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["phasePanel", "phaseTab", "stepCheckbox", "phaseNavNext"];
    static values = {
        currentPhase: { type: Number, default: 1 },
        completedPhases: { type: Array, default: [] },
        experimentId: Number,
        sessionId: Number
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
            this._showError("Complete the previous phase first.");
        }
    }

    nextPhase() {
        const next = this.currentPhaseValue;
        if (this._canAccess(next + 1)) {
            this.showPhase(next);
        } else {
            this._showError("Complete all steps in this phase first.");
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
                    completed_action_ids: this._completedActionIds()
                })
            });

            const data = await response.json();

            if (data.error) {
                this._showError(data.error);
                checkbox.checked = false;
                checkbox.disabled = false;
                return;
            }

            checkbox.checked = true;
            this.completedPhasesValue = data.completed_phases || [];
            this.currentPhaseValue = data.current_phase || phaseNumber;

            if (data.phase_completed) {
                this._showSuccess(`Phase ${phaseNumber} complete!`);
            }
        } catch (error) {
            this._showError("Failed to save step. Please try again.");
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

    _completedActionIds() {
        const ids = [];
        this.stepCheckboxTargets.forEach((cb) => {
            if (cb.checked) {
                const card = cb.closest("[data-action-id]");
                if (card) ids.push(card.dataset.actionId);
            }
        });
        return ids;
    }

    _showError(message) {
        this._showToast(message, "error");
    }

    _showSuccess(message) {
        this._showToast(message, "success");
    }

    _showToast(message, type) {
        const container = this.element.querySelector("[data-toast-container]");
        if (!container) return;

        const toast = document.createElement("div");
        toast.className = `lab-toast lab-toast--${type}`;
        toast.textContent = message;
        container.appendChild(toast);

        setTimeout(() => {
            toast.remove();
        }, 4000);
    }

    _render() {
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

            panel.classList.toggle("is-active", isCurrent);
            panel.classList.toggle("is-locked", !isAccessible);
        });

        if (this.hasPhaseNavNextTarget) {
            const isLast = this.currentPhaseValue >= this.phasePanelTargets.length;
            this.phaseNavNextTarget.textContent = isLast ? "Complete" : "Next";
            this.phaseNavNextTarget.disabled = false;
        }
    }
}
