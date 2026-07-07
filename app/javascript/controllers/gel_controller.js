import { Controller } from "@hotwired/stimulus";

const WELL_COUNT = 5;
const BAND_RADIUS = 6;

export default class extends Controller {
    static targets = ["canvas", "input"];
    static values = {
        wells: { type: Number, default: WELL_COUNT },
        editing: { type: Boolean, default: true }
    };

    connect() {
        this.selections = {};
        this._render();
    }

    canvasTargetConnected() {
        this._render();
    }

    clickCanvas(event) {
        if (!this.editingValue) return;

        const rect = this.canvasTarget.getBoundingClientRect();
        const x = event.clientX - rect.left;
        const y = event.clientY - rect.top;

        const wellWidth = rect.width / this.wellsValue;
        const wellIndex = Math.floor(x / wellWidth);

        if (wellIndex < 0 || wellIndex >= this.wellsValue) return;

        const well = this.selections[wellIndex] || [];
        const wellCenterX = wellIndex * wellWidth + wellWidth / 2;

        const laneX = Math.abs(x - wellCenterX);
        if (laneX > wellWidth * 0.25) return;

        const clickedBand = well.findIndex((pos) => Math.abs(pos - y) < BAND_RADIUS * 2);

        if (clickedBand >= 0) {
            well.splice(clickedBand, 1);
        } else {
            well.push(Math.round(y));
        }

        this.selections[wellIndex] = well;
        this._render();
        this._updateInput();
    }

    clearWell(event) {
        const wellIndex = Number(event.currentTarget.dataset.wellIndex);
        delete this.selections[wellIndex];
        this._render();
        this._updateInput();
    }

    _render() {
        const canvas = this.canvasTarget;
        if (!canvas) return;

        const ctx = canvas.getContext("2d");
        const w = canvas.width;
        const h = canvas.height;

        ctx.clearRect(0, 0, w, h);

        this._drawGel(ctx, w, h);
        this._drawWells(ctx, w, h);
        this._drawBands(ctx, w, h);
    }

    _drawGel(ctx, w, h) {
        const gradient = ctx.createLinearGradient(0, 0, 0, h);
        gradient.addColorStop(0, "#1a1a2e");
        gradient.addColorStop(1, "#16213e");
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, w, h);
    }

    _drawWells(ctx, w, h) {
        const wellWidth = w / this.wellsValue;
        const wellTop = 8;

        for (let i = 0; i < this.wellsValue; i++) {
            const cx = i * wellWidth + wellWidth / 2;
            ctx.fillStyle = "#0f3460";
            ctx.fillRect(cx - 4, wellTop, 8, 16);
            ctx.fillStyle = "#e94560";
            ctx.font = "11px sans-serif";
            ctx.textAlign = "center";
            ctx.fillText(`${i + 1}`, cx, h - 6);
        }
    }

    _drawBands(ctx, w, h) {
        const wellWidth = w / this.wellsValue;

        for (const [wellIdxStr, positions] of Object.entries(this.selections)) {
            const wellIdx = Number(wellIdxStr);
            const cx = wellIdx * wellWidth + wellWidth / 2;

            positions.forEach((y) => {
                ctx.beginPath();
                ctx.arc(cx, y, BAND_RADIUS, 0, Math.PI * 2);
                ctx.fillStyle = "#533483";
                ctx.fill();
                ctx.strokeStyle = "#e94560";
                ctx.lineWidth = 2;
                ctx.stroke();
            });
        }
    }

    _updateInput() {
        if (!this.hasInputTarget) return;
        this.inputTarget.value = JSON.stringify(this.selections);
        this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
    }
}
