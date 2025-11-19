export function animate(renderer, scene, camera) {
    function loop() {
        renderer.render(scene, camera);
        requestAnimationFrame(loop);
    }
    loop();
}
