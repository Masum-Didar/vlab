import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "tray", "tapeLeft", "tapeRight", "comb", "gel", "wells", 
        "actionButton", "timerDisplay", "input"
    ];
    
    static values = {
        substep: String,
        timerDuration: { type: Number, default: 600 } // Default 10 minutes in seconds
    };

    connect() {
        this.isTimerRunning = false;
        this.secondsRemaining = this.timerDurationValue;
        this._updateTimerDisplay();
    }

    performAction(event) {
        if (event) event.preventDefault();
        
        // Apply visual updates based on the substep
        this._applyVisualChanges();
        
        // Mark as completed
        this._markCompleted();
    }

    startSolidification(event) {
        if (event) event.preventDefault();
        if (this.isTimerRunning) return;

        this.isTimerRunning = true;
        this.actionButtonTarget.disabled = true;
        this.actionButtonTarget.textContent = "Solidifying...";

        // Fast-forward solidification timer: 10 minutes (600s) completes in 6 seconds (100x speed)
        const tickRateMs = 10; // Tick every 10ms
        const secondsPerTick = 1; // Decrement 1 second per tick
        
        this.timerInterval = setInterval(() => {
            this.secondsRemaining -= secondsPerTick;
            
            if (this.secondsRemaining <= 0) {
                this.secondsRemaining = 0;
                clearInterval(this.timerInterval);
                this.isTimerRunning = false;
                
                // Add solidified visual class
                if (this.hasGelTarget) {
                    this.gelTarget.classList.add("is-solidified");
                }
                
                this.actionButtonTarget.textContent = "Gel Solidified!";
                this._markCompleted();
                this._flashSuccess("Gel has solidified successfully!");
            }
            
            this._updateTimerDisplay();
        }, tickRateMs);
    }

    disconnect() {
        if (this.timerInterval) {
            clearInterval(this.timerInterval);
        }
    }

    _applyVisualChanges() {
        const step = this.substepValue;

        if (step === "tray" && this.hasTrayTarget) {
            this.trayTarget.classList.add("is-placed");
        } else if (step === "tape") {
            if (this.hasTapeLeftTarget) this.tapeLeftTarget.classList.add("is-applied");
            if (this.hasTapeRightTarget) this.tapeRightTarget.classList.add("is-applied");
        } else if (step === "comb" && this.hasCombTarget) {
            this.combTarget.classList.add("is-inserted");
        } else if (step === "pour" && this.hasGelTarget) {
            this.gelTarget.classList.add("is-poured");
        } else if (step === "remove_comb") {
            if (this.hasCombTarget) this.combTarget.classList.remove("is-inserted");
            if (this.hasTapeLeftTarget) this.tapeLeftTarget.classList.remove("is-applied");
            if (this.hasTapeRightTarget) this.tapeRightTarget.classList.remove("is-applied");
            if (this.hasWellsTarget) this.wellsTarget.classList.add("is-visible");
        }
    }

    _updateTimerDisplay() {
        if (!this.hasTimerDisplayTarget) return;
        
        const minutes = Math.floor(this.secondsRemaining / 60);
        const seconds = this.secondsRemaining % 60;
        
        const minutesStr = String(minutes).padStart(2, "0");
        const secondsStr = String(seconds).padStart(2, "0");
        
        this.timerDisplayTarget.textContent = `${minutesStr}:${secondsStr}`;
    }

    _markCompleted() {
        // Set the hidden input value
        if (this.hasInputTarget) {
            this.inputTarget.value = JSON.stringify({ all_done: true });
            this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }));
        }

        // Auto-check parent step checkbox
        const checkbox = this.element.closest("[data-step-id]")?.querySelector("[data-lab-target='stepCheckbox']");
        if (checkbox && !checkbox.checked) {
            checkbox.checked = true;
            checkbox.dispatchEvent(new Event("change"));
        }
    }

    _flashSuccess(message) {
        document.dispatchEvent(new CustomEvent("toast:success", {
            detail: { message }
        }));
    }
}
