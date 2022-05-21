float cubeScale = 1.0;
float roofScale = 0.15;
float pedestalScale = 0.3;
float floorScale = 0.15;
float sphereScale = 0.2;
float wallScale = 0.12;

vec3 getMaterial(vec3 p, float id, vec3 normal) {
    vec3 m;
    switch (int(id)) {
        case 1:
        m = vec3(0.9, 0.0, 0.0); break;

        case 2:
        m = vec3(0.2 + 0.4 * mod(floor(p.x) + floor(p.z), 2.0)); break;

        case 3:
        m = vec3(0.7, 0.8, 0.9); break;

        case 4:
        vec2 i = step(fract(0.5 * p.xz), vec2(1.0 / 10.0));
        m = ((1.0 - i.x) * (1.0 - i.y)) * vec3(0.37, 0.12, 0.0); break;

        // cube
        case 5:
        m = triPlanar(u_texture1, p * cubeScale, normal); break;

        // floor
        case 6:
        m = triPlanar(u_texture2, p * floorScale, normal); break;

        // walls
        case 7:
        m = triPlanar(u_texture3, p * wallScale, normal); break;

        // roof
        case 8:
        m = triPlanar(u_texture4, p * roofScale, normal); break;

        // pedestal
        case 9:
        m = triPlanar(u_texture5, p * pedestalScale, normal); break;

        // sphere
        case 10:
        m = triPlanar(u_texture6, p * sphereScale, normal); break;

        // roof bump
        case 11:
        m = triPlanar(u_texture7, p * roofScale, normal); break;

        default:
        m = vec3(0.4); break;
    }
    return m;
}
