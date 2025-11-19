import { Controller } from "@hotwired/stimulus";
import { createLabScene } from "../three/scene";
import { createBeaker, createChemical } from "../three/lab_objects";
import { animate } from "../three/interactions";

export default class extends Controller {
    connect() {
        const canvas = this.element.querySelector("canvas");
        const { scene, camera, renderer } = createLabScene(canvas);

        scene.add(createBeaker());
        scene.add(createChemical(0xff3333));

        animate(renderer, scene, camera);
    }
}
