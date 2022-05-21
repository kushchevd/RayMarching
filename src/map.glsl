float roofBumpFactor = 0.31;
float sphereBumpFactor = 0.21;
float wallBumpFactor = 0.06;

float getColumn(in vec3 p) {
    float Dist;
    
    p.y -= 11.6;
    vec3 pb = p;
    pModPolar(pb.xz, 12);
    pb.x -= 3.;
    float box = fBoxCheap(pb, vec3(0.1, 9., 0.1));
    float cylinder = fCylinder(p, 3., 10.);
    vec3 pr = p;
    pMirror(pr.y, 10.4);
    float roof = fCylinder(pr, 4., 0.2);

    Dist = fOpDifferenceRound(cylinder, box, 0.1);
    Dist = fOpUnionStairs(Dist, roof, 0.7, 3.);
    
    return Dist;
}

float getTempleFloor(in vec3 p) {
    float Dist;

    p.xz -= vec2(110., 60.);
    Dist = fBoxCheap(p, vec3(140., 1., 80.));

    return Dist;
}

float getTempleRoofCorners(in vec3 p) {
    float Dist;

    p -= vec3(105., 23.7, 50.);
    pMirrorOctant(p.xz, vec2(110., 60.));
    p.x -= 0.1;
    Dist = fBox2Cheap(p.xy, vec2(0.3, 1.5));

    return Dist;
}

float getTempleRoof(in vec3 p) {
    float Dist;

    float corners = getTempleRoofCorners(p);
    p -= vec3(105., 23.2, 50.);
    Dist = fBoxCheap(p, vec3(110., 1., 60.));
    Dist = fOpUnionRound(Dist, corners, 0.2);

    return Dist;
}

float getColumns(in vec3 p) {
    pModInterval1(p.x, 30., 0., 7.);
    pModInterval1(p.z, 20., 0., 5.);
    
    return getColumn(p);
}

vec2 getTemple(in vec3 p) {
    float Dist;
    float ID = 3.;

    float columns = getColumns(p);
    float floor = getTempleFloor(p);
    float roof = getTempleRoof(p);

    Dist = min(columns, floor);
    Dist = min(Dist, roof);

    return vec2(Dist, ID);
}

vec2 getShinglesRoof(in vec3 p) {
    float Dist;
    float ID = 2.;

    p -= vec3(105., 36.8, 50.);
    pMirrorOctant(p.xz, vec2(50, 0));
    pR(p.xy, -0.2);
    p.x -= 18.0;
    Dist = fBox2Cheap(p.xy, vec2(43.3, 0.5));

    return vec2(Dist, ID);
}

vec2 getPlane(in vec3 p) {
    float Dist;
    float ID = 1.;

    Dist = fPlane(p, vec3(0., 1., 0.), 0.);

    return vec2(Dist, ID);
}

float fSphereDisplace(in vec3 p) {
    pR(p.yz, sin(2.0 * u_time));
    pR(p.zx, sin(0.5 * u_time));

    return (sin(p.x + 4.2 * u_time) * sin(p.y + sin(6.0 * u_time)) * sin(p.z + u_time * sin(u_time)));
}

vec3 fCubeDisplace(in vec3 p) {
    return vec3(sin(1.5 * u_time), 0.7 * sin(u_time), 0.9 * sin(2.2 * u_time));
}

void rotateCube(inout vec3 p) {
    pR(p.yz, PI / 4 * u_time);
    pR(p.xz, u_time);
}

vec2 getUnknownObject(in vec3 p) {
    float Dist;
    float ID = 1.;
    float uoScale = 1.2;

    p -= vec3(-40., 15., 50.);
    vec3 pc = p;
    rotateCube(pc);
    float cube = fBoxCheap(pc, (vec3(9., 8., 8.5) + fCubeDisplace(p)) * uoScale);

    Dist = fSphere(p, (10. + fSphereDisplace(p)) * uoScale);
    Dist = max(Dist, cube);

    return vec2(Dist, ID);
}

vec2 map(vec3 p) {
    vec2 res;

    vec2 plane = getPlane(p);
    vec2 temple = getTemple(p);
    vec2 object = getUnknownObject(p);
    vec2 shingles = getShinglesRoof(p);

    res = fOpUnionStairsID(plane, temple, 1., 5.);
    res = fOpUnionID(res, object);
    res = fOpUnionID(res, shingles);

    return res;
}
