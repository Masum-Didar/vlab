import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["status", "input"];
    static values = {
        mode: { type: String, default: "attach" }
    };

    connect() {
        this._updateStatus();
    }

    attach() {
        if (this.modeValue !== "attach") return;
        this.element.dataset.tipAttached = "true";
        this._updateStatus();
        this._dispatchInput("tip_attached", true);
    }

    eject() {
        if (this.modeValue !== "eject") return;
        this.element.dataset.tipAttached = "false";
        this._updateStatus();
        this._dispatchInput("tip_ejected", true);
    }

    _updateStatus() {
        if (!this.hasStatusTarget) return;
        const attached = this.element.dataset.tipAttached === "true";
        this.statusTarget.textContent = attached ? "Tip attached" : "No tip";
        this.statusTarget.className = attached
            ? "badge text-bg-success"
            : "badge text-bg-secondary";
    }

    _dispatchInput(name, value) {
        if (this.hasInputTarget) {
            this.inputTarget.name = name;
            this.inputTarget.value = value;
            this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
        }
    }
}
