import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["phasePanel", "phaseTab"];

    connect() {
        this.currentPhase = 0;
    }

    selectPhase(event) {
        this.showPhase(Number(event.currentTarget.dataset.phaseIndex));
    }

    nextPhase() {
        this.showPhase(Math.min(this.currentPhase + 1, this.phasePanelTargets.length - 1));
    }

    previousPhase() {
        this.showPhase(Math.max(this.currentPhase - 1, 0));
    }

    showPhase(index) {
        this.currentPhase = index;
        this.phasePanelTargets.forEach((panel) => {
            panel.classList.toggle("is-active", Number(panel.dataset.phaseIndex) === index);
        });
        this.phaseTabTargets.forEach((tab) => {
            tab.classList.toggle("is-active", Number(tab.dataset.phaseIndex) === index);
        });
    }
}
