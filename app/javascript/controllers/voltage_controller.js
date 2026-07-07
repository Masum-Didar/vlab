import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["display", "input"];
    static values = {
        target: { type: Number, default: 70 },
        min: { type: Number, default: 0 },
        max: { type: Number, default: 120 },
        step: { type: Number, default: 1 }
    };

    connect() {
        this.currentValue = 0;
        this._updateDisplay();
    }

    up() {
        const next = Math.min(this.currentValue + this.stepValue, this.maxValue);
        if (next !== this.currentValue) {
            this.currentValue = next;
            this._updateDisplay();
        }
    }

    down() {
        const next = Math.max(this.currentValue - this.stepValue, this.minValue);
        if (next !== this.currentValue) {
            this.currentValue = next;
            this._updateDisplay();
        }
    }

    _updateDisplay() {
        if (this.hasDisplayTarget) {
            this.displayTarget.textContent = `${this.currentValue} V`;
        }
        if (this.hasInputTarget) {
            this.inputTarget.value = this.currentValue;
            this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
        }
    }
}
