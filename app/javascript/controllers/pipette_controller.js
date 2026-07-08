import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["tip", "pipetteBody", "plunger", "statusText", "autoclaveBag", "ejectedTipsCount", "input"];
    static values = {
        hasTip: { type: Boolean, default: false },
        ejectedCount: { type: Number, default: 0 },
        liquid: { type: Boolean, default: false }
    };

    connect() {
        this._syncFromSession();
        this._render();
    }

    _syncFromSession() {
        const stored = sessionStorage.getItem("vlab_pipette_state");
        if (stored) {
            try {
                const state = JSON.parse(stored);
                this.hasTipValue = state.hasTip || false;
                this.ejectedCountValue = state.ejectedCount || 0;
                this.liquidValue = state.liquid || false;
            } catch (e) {
                console.warn("Failed to parse pipette state", e);
            }
        }
    }

    _saveToSession() {
        sessionStorage.setItem("vlab_pipette_state", JSON.stringify({
            hasTip: this.hasTipValue,
            ejectedCount: this.ejectedCountValue,
            liquid: this.liquidValue
        }));
    }

    attach() {
        if (this.hasTipValue) return;
        this.hasTipValue = true;
        this._saveToSession();
        this._render();
        this._dispatch("tip_attached", true);
        this._animateAttach();
    }

    eject() {
        if (!this.hasTipValue) return;
        this.hasTipValue = false;
        this.liquidValue = false;
        this.ejectedCountValue += 1;
        this._saveToSession();
        this._render();
        this._dispatch("tip_ejected", true);
        this._animateEject();
    }

    draw() {
        if (!this.checkContamination()) return;
        this.liquidValue = true;
        this._saveToSession();
        this._render();
        this._animatePlunger("pipette--drawing");
    }

    dispense() {
        if (!this.checkContamination()) return;
        this.liquidValue = false;
        this._saveToSession();
        this._render();
        this._animatePlunger("pipette--dispensing");
    }

    _animateAttach() {
        if (!this.hasTipTarget) return;
        this.tipTarget.classList.add("pipette-tip--attaching");
        this.tipTarget.addEventListener("animationend", () => {
            this.tipTarget.classList.remove("pipette-tip--attaching");
        }, { once: true });
    }

    _animateEject() {
        if (!this.hasTipTarget || !this.hasAutoclaveBagTarget) return;
        this.tipTarget.classList.add("pipette-tip--ejecting");
        this.autoclaveBagTarget.classList.add("autoclave-bag--receiving");
        this.tipTarget.addEventListener("animationend", () => {
            this.tipTarget.classList.remove("pipette-tip--ejecting");
            this.autoclaveBagTarget.classList.remove("autoclave-bag--receiving");
        }, { once: true });
    }

    _animatePlunger(className) {
        if (!this.hasPipetteBodyTarget) return;
        this.pipetteBodyTarget.classList.add(className);
        this.pipetteBodyTarget.addEventListener("animationend", () => {
            this.pipetteBodyTarget.classList.remove(className);
        }, { once: true });
    }

    checkContamination() {
        if (!this.hasTipValue) {
            this._showError("Attach a fresh tip first");
            return false;
        }
        return true;
    }

    _dispatch(name, value) {
        this.element.dispatchEvent(new CustomEvent(`pipette:${name}`, {
            detail: { value, hasTip: this.hasTipValue, ejectedCount: this.ejectedCountValue },
            bubbles: true
        }));
    }

    _render() {
        if (this.hasTipTarget) {
            this.tipTarget.style.display = this.hasTipValue ? "block" : "none";
            this.tipTarget.classList.toggle("pipette__tip--filled", this.liquidValue);
        }
        if (this.hasPipetteBodyTarget) {
            this.pipetteBodyTarget.classList.toggle("pipette--has-tip", this.hasTipValue);
        }
        if (this.hasStatusTextTarget) {
            this.statusTextTarget.textContent = this.hasTipValue ? "Tip attached" : "No tip";
            this.statusTextTarget.className = this.hasTipValue
                ? "badge text-bg-success pipette__status"
                : "badge text-bg-secondary pipette__status";
        }
        if (this.hasEjectedTipsCountTarget) {
            this.ejectedTipsCountTarget.textContent = this.ejectedCountValue;
        }
        if (this.hasInputTarget) {
            this.inputTarget.value = JSON.stringify({
                has_tip: this.hasTipValue,
                liquid: this.liquidValue,
                ejected_count: this.ejectedCountValue
            });
            this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
        }
    }

    _showError(message) {
        document.dispatchEvent(new CustomEvent("toast:error", { detail: { message } }));
    }

    reset() {
        this.hasTipValue = false;
        this.ejectedCountValue = 0;
        this.liquidValue = false;
        this._saveToSession();
        this._render();
    }
}
