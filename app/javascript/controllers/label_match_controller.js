import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["draggable", "dropZone", "placedLabel", "input", "status", "dropzoneContainer", "labelsContainer"];
    static values = {
        actionId: Number,
        experimentId: Number
    };

    connect() {
        this.matchedPairs = [];
        this._updateStatus();
        this._syncInput();
    }

    dragStart(event) {
        const label = event.currentTarget;
        const text = label.dataset.labelText;
        if (label.classList.contains("is-matched")) {
            event.preventDefault();
            return;
        }
        event.dataTransfer.setData("text/plain", text);
        event.dataTransfer.effectAllowed = "move";
        label.classList.add("is-dragging");
    }

    dragEnd(event) {
        event.currentTarget.classList.remove("is-dragging");
        this.dropZoneTargets.forEach((dz) => {
            dz.classList.remove("is-dragover", "is-wrong");
        });
    }

    dragOver(event) {
        event.preventDefault();
        event.dataTransfer.dropEffect = "move";
        const dz = event.currentTarget;
        if (!dz.classList.contains("is-matched")) {
            dz.classList.add("is-dragover");
        }
    }

    drop(event) {
        event.preventDefault();
        const dz = event.currentTarget;
        dz.classList.remove("is-dragover");

        if (dz.classList.contains("is-matched")) return;

        const labelText = event.dataTransfer.getData("text/plain");
        const expected = dz.dataset.expectedLabel;

        if (labelText === expected) {
            this._matchLabel(dz, labelText);
        } else {
            dz.classList.add("is-wrong");
            this._flashError("Incorrect match! Try again.");
            setTimeout(() => dz.classList.remove("is-wrong"), 600);
        }
    }

    _matchLabel(dz, labelText) {
        this.matchedPairs.push(labelText);
        dz.classList.add("is-matched");

        const labelEl = dz.querySelector("[data-label-match-target='placedLabel']");
        if (labelEl) {
            labelEl.textContent = labelText;
        }

        const draggable = this.draggableTargets.find(
            (d) => d.dataset.labelText === labelText
        );
        if (draggable) {
            draggable.classList.add("is-matched");
            draggable.draggable = false;
        }

        this._updateStatus();
        this._syncInput();

        if (this._allMatched()) {
            this._flashSuccess("All equipment identified correctly!");
            this._triggerComplete();
        }
    }

    _allMatched() {
        return this.matchedPairs.length >= this.draggableTargets.length;
    }

    _updateStatus() {
        const total = this.draggableTargets.length;
        const done = this.matchedPairs.length;
        const statusEl = this.hasStatusTarget ? this.statusTarget : null;
        if (statusEl) {
            statusEl.innerHTML = `<span>${done} of ${total} matched</span>`;
        }
    }

    _syncInput() {
        const value = JSON.stringify(this.matchedPairs);
        if (this.hasInputTarget) {
            this.inputTarget.value = value;
            this.inputTarget.dispatchEvent(new Event("change"));
        }
    }

    _triggerComplete() {
        const checkbox = this.element.closest("[data-step-id]")?.querySelector("[data-lab-target='stepCheckbox']");
        if (checkbox && !checkbox.checked) {
            checkbox.checked = true;
            checkbox.dispatchEvent(new Event("change"));
        }

        this.element.dispatchEvent(new CustomEvent("label-match:complete", {
            bubbles: true,
            detail: { matchedPairs: this.matchedPairs }
        }));
    }

    _flashError(message) {
        document.dispatchEvent(new CustomEvent("toast:error", {
            detail: { message }
        }));
    }

    _flashSuccess(message) {
        document.dispatchEvent(new CustomEvent("toast:success", {
            detail: { message }
        }));
    }
}
