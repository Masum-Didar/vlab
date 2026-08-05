import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["genotypeSelect", "submitButton", "input"];

    connect() {
        this.answers = {
            sample_a: "",
            sample_b: "",
            sample_c: ""
        };
        this.updateAnswers();
    }

    updateAnswers() {
        this.genotypeSelectTargets.forEach((select) => {
            const sampleKey = `sample_${select.dataset.sample}`;
            this.answers[sampleKey] = select.value;
        });

        const complete = Object.values(this.answers).every((val) => val !== "");
        if (this.hasSubmitButtonTarget) {
            this.submitButtonTarget.disabled = !complete;
        }

        if (this.hasInputTarget) {
            this.inputTarget.value = JSON.stringify(this.answers);
            this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }));
        }
    }

    submit(event) {
        if (event) event.preventDefault();

        // Trigger parent step completion checkbox check
        const checkbox = this.element.closest("[data-step-id]")?.querySelector("[data-lab-target='stepCheckbox']");
        if (checkbox && !checkbox.checked) {
            checkbox.checked = true;
            checkbox.dispatchEvent(new Event("change"));
        }
    }
}
