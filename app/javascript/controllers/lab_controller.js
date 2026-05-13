import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["phasePanel", "phaseTab", "dropZone"];

    connect() {
        this.currentPhase = 0;
        this.draggedLabel = null;
        this.updateProgress();
    }

    dragLabel(event) {
        this.draggedLabel = event.currentTarget.dataset.labLabel;
        event.dataTransfer.effectAllowed = "move";
        event.dataTransfer.setData("text/plain", this.draggedLabel);
    }

    allowDrop(event) {
        event.preventDefault();
    }

    dropLabel(event) {
        event.preventDefault();
        const droppedLabel = event.dataTransfer.getData("text/plain") || this.draggedLabel;
        const expectedLabel = event.currentTarget.dataset.label;

        event.currentTarget.classList.toggle("is-correct", droppedLabel === expectedLabel);
        event.currentTarget.classList.toggle("is-wrong", droppedLabel !== expectedLabel);
        event.currentTarget.querySelector("span").textContent = droppedLabel === expectedLabel ? droppedLabel : "Try again";

        this.updateProgress();
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
        this.phasePanelTargets.forEach((panel) => panel.classList.toggle("is-active", Number(panel.dataset.phaseIndex) === index));
        this.phaseTabTargets.forEach((tab) => tab.classList.toggle("is-active", Number(tab.dataset.phaseIndex) === index));
    }

    updateProgress() {
        const correctLabels = this.dropZoneTargets.filter((zone) => zone.classList.contains("is-correct")).length;
        this.dropZoneTargets.forEach((zone) => {
            zone.title = `${zone.dataset.label}${zone.classList.contains("is-correct") ? " matched" : ""}`;
        });

        this.element.style.setProperty("--label-progress", `${correctLabels}/${this.dropZoneTargets.length}`);
    }
}
