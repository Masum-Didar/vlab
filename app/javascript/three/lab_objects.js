import * as THREE from "three";

export function createBeaker() {
    const geometry = new THREE.CylinderGeometry(1, 1, 2, 32);
    const material = new THREE.MeshStandardMaterial({
        color: 0x66a6ff,
        transparent: true,
        opacity: 0.4
    });
    return new THREE.Mesh(geometry, material);
}

export function createChemical(color) {
    const geometry = new THREE.SphereGeometry(0.3, 32, 32);
    const material = new THREE.MeshStandardMaterial({ color });
    return new THREE.Mesh(geometry, material);
}
