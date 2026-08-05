import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["option", "submitBtn", "feedback", "optionsBlock"];
    static values = {
        id: Number,
        submitUrl: String
    };

    submit(event) {
        if (event) event.preventDefault();

        // Find selected option value
        const selectedOption = this.optionTargets.find((opt) => opt.checked);
        if (!selectedOption) {
            this._showFeedback("Please select an answer first.");
            return;
        }

        const selectedAnswer = selectedOption.value;
        this.submitBtnTarget.disabled = true;
        this.submitBtnTarget.textContent = "Submitting...";

        // Fetch CSRF Token
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute("content");

        fetch(this.submitUrlValue, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "X-CSRF-Token": csrfToken
            },
            body: JSON.stringify({
                quiz_id: this.idValue,
                answer: selectedAnswer
            })
        })
        .then((res) => {
            if (!res.ok) throw new Error("Server error");
            return res.json();
        })
        .then((data) => {
            if (data.correct) {
                // Answer was correct, lock the card with green banner
                this.element.innerHTML = `
                    <div class="d-flex align-items-center gap-2 mb-2">
                        <span class="badge bg-info text-white">Quiz Question</span>
                    </div>
                    <p class="fw-semibold mb-2 text-dark">${this.element.querySelector("p").textContent}</p>
                    <div class="alert alert-success py-2 px-3 mb-0 small d-flex align-items-center gap-2">
                        <svg width="18" height="18" fill="currentColor" class="text-success flex-shrink-0" viewBox="0 0 16 16">
                            <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>
                        </svg>
                        <span>Correct! You selected: <strong>${selectedAnswer}</strong></span>
                    </div>
                `;
                this._flashSuccess("Quiz question answered correctly!");
            } else {
                // Incorrect, reset button and show feedback message
                this.submitBtnTarget.disabled = false;
                this.submitBtnTarget.textContent = "Submit Quiz Answer";
                this._showFeedback(data.message || "Incorrect answer. Try again.");
            }
        })
        .catch((err) => {
            console.error(err);
            this.submitBtnTarget.disabled = false;
            this.submitBtnTarget.textContent = "Submit Quiz Answer";
            this._showFeedback("A network error occurred. Please try again.");
        });
    }

    _showFeedback(msg) {
        if (this.hasFeedbackTarget) {
            this.feedbackTarget.textContent = msg;
            this.feedbackTarget.classList.remove("d-none");
        }
    }

    _flashSuccess(message) {
        document.dispatchEvent(new CustomEvent("toast:success", {
            detail: { message }
        }));
    }
}
