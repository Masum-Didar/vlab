import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["experimentSelect", "quizzesContainer", "quizRow"];

    connect() {
        this.toggleQuizzes();
    }

    toggleQuizzes() {
        if (!this.hasExperimentSelectTarget) return;

        const selectedExpId = this.experimentSelectTarget.value;

        if (!selectedExpId) {
            if (this.hasQuizzesContainerTarget) {
                this.quizzesContainerTarget.classList.add("d-none");
            }
            return;
        }

        let hasQuizzes = false;
        this.quizRowTargets.forEach((row) => {
            const expId = row.dataset.experimentId;
            if (expId === selectedExpId) {
                row.classList.remove("d-none");
                hasQuizzes = true;
            } else {
                row.classList.add("d-none");
                // Uncheck checkbox if the experiment changes
                const checkbox = row.querySelector("input[type='checkbox']");
                if (checkbox) checkbox.checked = false;
            }
        });

        if (this.hasQuizzesContainerTarget) {
            if (hasQuizzes) {
                this.quizzesContainerTarget.classList.remove("d-none");
            } else {
                this.quizzesContainerTarget.classList.add("d-none");
            }
        }
    }
}
