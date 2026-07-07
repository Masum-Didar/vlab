import { Controller } from "@hotwired/stimulus";

const WELL_COUNT = 5;
const BAND_SPEED_FACTOR = 1.5;

export default class extends Controller {
    static targets = ["canvas", "progressFill", "progressText", "startBtn", "status", "input"];
    static values = {
        running: { type: Boolean, default: false },
        progress: { type: Number, default: 0 }
    };

    connect() {
        this.animationId = null;
        this.startTime = null;
        this.duration = 15000;
        this.bands = [];
        this._setupBands();
        this._draw();
    }

    disconnect() {
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
        }
    }

    startRun() {
        if (this.runningValue) return;

        this.runningValue = true;
        this.startTime = performance.now();
        this._animate();
    }

    _animate() {
        const elapsed = performance.now() - this.startTime;
        const pct = Math.min(elapsed / this.duration, 1);

        this.progressValue = Math.round(pct * 100);
        this._draw(pct);
        this._updateProgress(pct);

        if (pct < 1) {
            this.animationId = requestAnimationFrame(() => this._animate());
        } else {
            this.runningValue = false;
            this._updateInput();
            if (this.hasStatusTarget) {
                this.statusTarget.textContent = "Run complete!";
                this.statusTarget.classList.remove("text-warning");
                this.statusTarget.classList.add("text-success");
            }
        }
    }

    _setupBands() {
        this.bands = [];
        const bandSets = [
            { size: "large", count: 1 },
            { size: "medium", count: 2 },
            { size: "small", count: 3 }
        ];

        for (let well = 0; well < WELL_COUNT; well++) {
            const bandSet = bandSets[well % bandSets.length];
            for (let i = 0; i < bandSet.count; i++) {
                const speedVariation = 0.5 + Math.random() * 1.0;
                this.bands.push({
                    well,
                    offset: (i / bandSet.count) * 6 + 2,
                    speed: BAND_SPEED_FACTOR * speedVariation
                });
            }
        }
    }

    _draw(pct = 0) {
        const canvas = this.canvasTarget;
        if (!canvas) return;

        const ctx = canvas.getContext("2d");
        const w = canvas.width;
        const h = canvas.height;

        ctx.clearRect(0, 0, w, h);

        this._drawGel(ctx, w, h);
        this._drawProgressOverlay(ctx, w, h, pct);
        this._drawWells(ctx, w, h);
        this._drawMigratingBands(ctx, w, h, pct);
    }

    _drawGel(ctx, w, h) {
        const gradient = ctx.createLinearGradient(0, 0, 0, h);
        gradient.addColorStop(0, "#1a1a2e");
        gradient.addColorStop(1, "#16213e");
        ctx.fillStyle = gradient;

        const margin = 4;
        ctx.fillRect(margin, margin, w - margin * 2, h - margin * 2);
    }

    _drawProgressOverlay(ctx, w, h, pct) {
        if (pct <= 0) return;

        const gradient = ctx.createLinearGradient(0, 0, 0, h);
        gradient.addColorStop(0, "rgba(233, 69, 96, 0.15)");
        gradient.addColorStop(1, "rgba(233, 69, 96, 0)");

        const overlayH = h * pct;
        ctx.fillStyle = gradient;
        const margin = 4;
        ctx.fillRect(margin, h - margin - overlayH, w - margin * 2, overlayH);
    }

    _drawWells(ctx, w, h) {
        const wellWidth = w / WELL_COUNT;
        const wellTop = 10;

        for (let i = 0; i < WELL_COUNT; i++) {
            const cx = i * wellWidth + wellWidth / 2;
            ctx.fillStyle = "#0f3460";
            ctx.fillRect(cx - 3, wellTop, 6, 14);
            ctx.fillStyle = "#e94560";
            ctx.font = "10px sans-serif";
            ctx.textAlign = "center";
            ctx.fillText(`${i + 1}`, cx, h - 4);
        }
    }

    _drawMigratingBands(ctx, w, h, pct) {
        if (pct <= 0) return;

        const wellWidth = w / WELL_COUNT;
        const startY = 20;
        const endY = h - 20;
        const bandRadius = 4;

        ctx.globalAlpha = Math.min(pct * 2, 1);

        this.bands.forEach((band) => {
            const travel = Math.min(pct * band.speed, 0.95);
            const y = startY + (endY - startY) * travel;
            const cx = band.well * wellWidth + wellWidth / 2 + band.offset;

            const bandGradient = ctx.createRadialGradient(cx, y, 0, cx, y, bandRadius + 2);
            bandGradient.addColorStop(0, "#e94560");
            bandGradient.addColorStop(1, "#533483");
            ctx.fillStyle = bandGradient;

            ctx.beginPath();
            ctx.arc(cx, y, bandRadius + 2, 0, Math.PI * 2);
            ctx.fill();
        });

        ctx.globalAlpha = 1;
    }

    _updateProgress(pct) {
        if (this.hasProgressFillTarget) {
            this.progressFillTarget.style.width = `${pct * 100}%`;
        }
        if (this.hasProgressTextTarget) {
            this.progressTextTarget.textContent = `${Math.round(pct * 100)}%`;
        }
        if (this.hasStatusTarget) {
            this.statusTarget.textContent = pct < 1 ? "Running..." : "Complete";
        }
    }

    _updateInput() {
        if (!this.hasInputTarget) return;
        this.inputTarget.value = JSON.stringify({
            progress: this.progressValue,
            complete: this.progressValue >= 100
        });
        this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }));
    }
}
