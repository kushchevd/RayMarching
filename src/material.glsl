//return material params with ID
vec3 getMaterial(vec3 p, float id, vec3 normal) {
    vec3 m;
    switch (int(id)) {
        case 1:
        m = vec3(0.9, 0.0, 0.0); break;

        //floor
        case 2:
        m = triPlanar(u_texture1, p * floorScale, normal); break;

        //temple
        case 3:
        m = triPlanar(u_texture2, p * TempleScale, normal); break;

        //roof
        case 4:
        m = triPlanar(u_texture3, p * roofScale, normal); break;

        default:
        m = vec3(0.4); break;
    }
    return m;
}
