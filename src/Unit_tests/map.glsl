//bump mapping coeffs
float roofBumpFactor = 0.31;
float TempleBumpFactor = 0.06;

//textures scales
float roofScale = 0.15;
float floorScale = 0.15;
float TempleScale = 0.12;

//return column sdf
float getColumn(in vec3 p) {
    float Dist;
    
    p.y -= 11.6;

    //polar copy of boxes (with copied vector)
    vec3 pb = p;
    pModPolar(pb.xz, 12);
    pb.x -= 3.;
    float box = fBoxCheap(pb, vec3(0.1, 9., 0.1));

    //create main column cylinder
    float cylinder = fCylinder(p, 3., 10.);

    //create top and bottom cylinders
    vec3 pr = p;
    pMirror(pr.y, 10.4);
    float roof = fCylinder(pr, 4., 0.2);

    //cut boxes from column
    Dist = fOpDifferenceRound(cylinder, box, 0.1);
    //union column with top and bottom parts
    Dist = fOpUnionStairs(Dist, roof, 0.7, 3.);
    
    return Dist;
}

//return temple floor sdf
float getTempleFloor(in vec3 p) {
    float Dist;

    p.xz -= vec2(110., 60.);
    Dist = fBoxCheap(p, vec3(140., 1., 80.));

    return Dist;
}

//return temple roof corners sdf
float getTempleRoofCorners(in vec3 p) {
    float Dist;

    p -= vec3(105., 23.7, 50.);
    pMirrorOctant(p.xz, vec2(110., 60.));
    p.x -= 0.1;
    Dist = fBox2Cheap(p.xy, vec2(0.3, 1.5));

    return Dist;
}


//return temple roof sdf
float getTempleRoof(in vec3 p) {
    float Dist;

    //get roof corners
    float corners = getTempleRoofCorners(p);

    //create box roof
    p -= vec3(105., 23.2, 50.);
    Dist = fBoxCheap(p, vec3(110., 1., 60.));
    Dist = fOpUnionRound(Dist, corners, 0.2);

    return Dist;
}

//return 6x8 columns sdf
float getColumns(in vec3 p) {
    //copy columns
    pModInterval1(p.x, 30., 0., 7.);
    pModInterval1(p.z, 20., 0., 5.);
    
    return getColumn(p);
}

//return full temple sdf
vec2 getTemple(in vec3 p) {
    float Dist;
    float ID = 3.;

    //get parts
    float columns = getColumns(p);
    float floor = getTempleFloor(p);
    float roof = getTempleRoof(p);

    //union parts
    Dist = min(columns, floor);
    Dist = min(Dist, roof);

    //bump mapping
    Dist -= bumpMapping(u_texture2, p, vec3(TempleBumpFactor), Dist, TempleBumpFactor, TempleScale);
    Dist += TempleBumpFactor;

    return vec2(Dist, ID);
}

//return shingles sdf
vec2 getShinglesRoof(in vec3 p) {
    float Dist;
    float ID = 4.;

    //mirror space relative to the two axes and draw infinity box-roof
    p -= vec3(105., 36.8, 50.);
    pMirrorOctant(p.xz, vec2(50, 0));
    pR(p.xy, -0.2);
    p.x -= 18.0;
    Dist = fBox2Cheap(p.xy, vec2(43.3, 0.5));

    //bump mapping with height map
    Dist -= bumpMapping(u_texture4, p, p - roofBumpFactor, Dist, roofBumpFactor, roofScale);
    Dist += roofBumpFactor;

    return vec2(Dist, ID);
}

//ruturn ground plane sdf
vec2 getPlane(in vec3 p) {
    float Dist;
    float ID = 2.;

    Dist = fPlane(p, vec3(0., 1., 0.), 0.);

    return vec2(Dist, ID);
}

//sphere trigonometric displace
float fSphereDisplace(in vec3 p) {
    //rotate sphere
    pR(p.yz, sin(2.0 * u_time));
    pR(p.zx, sin(0.5 * u_time));

    //add trigonometric displace
    return (sin(p.x + 4.2 * u_time) * sin(p.y + sin(6.0 * u_time)) * sin(p.z + u_time * sin(u_time)));
}

//box sizes displace
vec3 fCubeDisplace(in vec3 p) {
    //box rotation
    pR(p.yz, PI / 4 * u_time);
    pR(p.xz, u_time);

    //add sizes displace
    return vec3(sin(1.5 * u_time), 0.7 * sin(u_time), 0.9 * sin(2.2 * u_time));
}

//return unknown flying object
vec2 getUnknownObject(in vec3 p) {
    float Dist;
    float ID = 1.;
    float uoScale = 1.2;

    //create cube
    p -= vec3(-40., 15., 50.);
    vec3 pc = p;
    float cube = fBoxCheap(pc, (vec3(9., 8., 8.5) + fCubeDisplace(p)) * uoScale);

    //create sphere
    Dist = fSphere(p, (10. + fSphereDisplace(p)) * uoScale);

    //intersiction
    Dist = max(Dist, cube);

    return vec2(Dist, ID);
}

//return full map sdf
vec2 map(vec3 p) {
    vec2 res;

    //get all objets
    vec2 plane = getPlane(p);
    vec2 temple = getTemple(p);
    vec2 object = getUnknownObject(p);
    vec2 shingles = getShinglesRoof(p);

    //union all objects
    res = fOpUnionStairsID(plane, temple, 1., 5.);
    res = fOpUnionID(res, object);
    res = fOpUnionID(res, shingles);

    return res;
}
