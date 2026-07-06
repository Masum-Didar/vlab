import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static values = {
        defaultType: { type: String, default: "error" },
        duration: { type: Number, default: 4000 }
    };

    connect() {
        this._bindEvents();
    }

    disconnect() {
        this._unbindEvents();
    }

    show(event) {
        const { message, type } = event.detail || {};
        this._render(message || "", type || this.defaultTypeValue);
    }

    showError(message) {
        this._render(message, "error");
    }

    showSuccess(message) {
        this._render(message, "success");
    }

    showWarning(message) {
        this._render(message, "warning");
    }

    _bindEvents() {
        this._errorHandler = (e) => this.showError(e.detail?.message || e.detail);
        this._successHandler = (e) => this.showSuccess(e.detail?.message || e.detail);
        this._warningHandler = (e) => this.showWarning(e.detail?.message || e.detail);

        document.addEventListener("toast:error", this._errorHandler);
        document.addEventListener("toast:success", this._successHandler);
        document.addEventListener("toast:warning", this._warningHandler);
    }

    _unbindEvents() {
        document.removeEventListener("toast:error", this._errorHandler);
        document.removeEventListener("toast:success", this._successHandler);
        document.removeEventListener("toast:warning", this._warningHandler);
    }

    _render(message, type) {
        const toast = document.createElement("div");
        toast.className = `lab-toast lab-toast--${type}`;
        toast.textContent = message;
        this.element.appendChild(toast);

        setTimeout(() => {
            if (toast.parentNode) toast.remove();
        }, this.durationValue);
    }
}
