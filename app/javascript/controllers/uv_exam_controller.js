import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["chamber", "band", "powerButton", "indicator", "input"];
    static values = {
        uvOn: { type: Boolean, default: false }
    };

    connect() {
        this._updateUI();
    }

    toggleUV(event) {
        if (event) event.preventDefault();
        this.uvOnValue = !this.uvOnValue;
    }

    uvOnValueChanged() {
        this._updateUI();
    }

    _updateUI() {
        const active = this.uvOnValue;

        // Toggle chamber dark-room state
        if (this.hasChamberTarget) {
            this.chamberTarget.classList.toggle("is-active", active);
        }

        // Toggle power button state indicator
        if (this.hasIndicatorTarget) {
            this.indicatorTarget.classList.toggle("is-active", active);
        }

        // Toggle power button label and class
        if (this.hasPowerButtonTarget) {
            if (active) {
                this.powerButtonTarget.innerHTML = `<span class="uv-exam__indicator-dot is-active" data-uv-exam-target="indicator"></span> Turn OFF UV Light`;
                this.powerButtonTarget.className = "btn btn-danger btn-sm px-4 fw-bold d-flex align-items-center gap-2";
            } else {
                this.powerButtonTarget.innerHTML = `<span class="uv-exam__indicator-dot" data-uv-exam-target="indicator"></span> Turn ON UV Light`;
                this.powerButtonTarget.className = "btn btn-dark btn-sm px-4 fw-bold d-flex align-items-center gap-2";
            }
        }

        // Toggle glowing DNA bands
        this.bandTargets.forEach((band) => {
            band.classList.toggle("is-glowing", active);
        });

        // Set hidden input value
        if (this.hasInputTarget) {
            this.inputTarget.value = JSON.stringify({ uv_on: active });
            this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }));
        }

        // Auto-check parent step checkbox when UV light is turned ON
        if (active) {
            const checkbox = this.element.closest("[data-step-id]")?.querySelector("[data-lab-target='stepCheckbox']");
            if (checkbox && !checkbox.checked) {
                checkbox.checked = true;
                checkbox.dispatchEvent(new Event("change"));
            }
            this._flashSuccess("UV transilluminator turned on. DNA fragments fluorescing!");
        }
    }

    _flashSuccess(message) {
        document.dispatchEvent(new CustomEvent("toast:success", {
            detail: { message }
        }));
    }
}
