#version 430 core
//load lib with field functions
#include hg_sdf.glsl
layout (location = 0) out vec4 fragColor;

//params from .cpp
uniform mat3 CameraDirection;
uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform vec3 ro;
uniform float u_time;
uniform float FOV;
uniform int AA;
uniform sampler2D u_texture1;
uniform sampler2D u_texture2;
uniform sampler2D u_texture3;
uniform sampler2D u_texture4;

//ray marching consts
const int MAX_STEPS = 128;
const float MAX_DIST = 500;
const float EPSILON = 0.01;

//return triplanar projection of texture to 3d object
vec3 triPlanar(sampler2D tex, vec3 p, vec3 normal) {
    normal = abs(normal);
    normal = pow(normal, vec3(5.0));
    normal /= normal.x + normal.y + normal.z;
    return (texture(tex, p.xy * 0.5 + 0.5) * normal.z +
            texture(tex, p.xz * 0.5 + 0.5) * normal.y +
            texture(tex, p.yz * 0.5 + 0.5) * normal.x).rgb;
}

//return true bump mapping (changing distanse and normals) (NOT READY)
float bumpMapping(sampler2D tex, vec3 p, vec3 n, float dist, float factor, float scale) {
    float bump = 0.0;
    if (dist < 0.1) {
        vec3 normal = normalize(n);
        bump += factor * triPlanar(tex, (p * scale), normal).r;
    }
    return bump;
}

//fOpUnion from hg_sdf with ID
vec2 fOpUnionID(vec2 res1, vec2 res2) {
    return (res1.x < res2.x) ? res1 : res2;
}

//fOpUnionStairs from hg_sdf with ID
vec2 fOpUnionStairsID(vec2 res1, vec2 res2, float r, float n) {
    float dist = fOpUnionStairs(res1.x, res2.x, r, n);
    return (res1.x < res2.x) ? vec2(dist, res1.y) : vec2(dist, res2.y);
}


//load map and materials
#include map.glsl
#include material.glsl

//spheres render (ray-marching)
vec2 rayMarch(vec3 ro, vec3 rd) {
    vec2 hit, object;
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + object.x * rd;
        //get distance to closest object
        hit = map(p);
        //move to ray & sphere intersection
        object.x += hit.x;
        object.y = hit.y;
        //check ray collision | going to infinity
        if (abs(hit.x) < EPSILON || object.x > MAX_DIST) break;
    }
    return object;
}

//return normal with the help of closest distanse function
vec3 getNormal(vec3 p) {
    vec2 e = vec2(EPSILON, 0.0);
    vec3 n = vec3(map(p).x) - vec3(map(p - e.xyy).x, map(p - e.yxy).x, map(p - e.yyx).x);
    return normalize(n);
}

//return soft whadows with umpra and penumbra
float getSoftShadow(vec3 p, vec3 lightPos) {
    float res = 1.0;
    float dist = 0.01;
    float lightSize = 0.03;
    for (int i = 0; i < MAX_STEPS; i++) {
        float hit = map(p + lightPos * dist).x;
        res = min(res, hit / (dist * lightSize));
        dist += hit;
        if (hit < 0.0001 || dist > 60.0) break;
    }
    return clamp(res, 0.0, 1.0);
}

//return ambient occlusion (light intensity depending on objets proximity)
float getAmbientOcclusion(vec3 p, vec3 normal) {
    float occ = 0.0;
    float weight = 1.0;
    for (int i = 0; i < 8; i++) {
        float len = 0.01 + 0.02 * float(i * i);
        float dist = map(p + normal * len).x;
        occ += (len - dist) * weight;
        weight *= 0.85;
    }
    return 1.0 - clamp(0.6 * occ, 0.0, 1.0);
}

//return sum lighting
vec3 getLight(vec3 p, vec3 rd, float id) {
    vec3 lightPos = vec3(20.0, 55.0, -25.0);
    vec3 L = normalize(lightPos - p);
    vec3 N = getNormal(p);
    vec3 V = -rd;
    vec3 R = reflect(-L, N);

    vec3 color = getMaterial(p, id, N);

    vec3 specColor = vec3(0.6, 0.5, 0.4);
    vec3 specular = 1.3 * specColor * pow(clamp(dot(R, V), 0.0, 1.0), 10.0);
    vec3 diffuse = 0.9 * color * clamp(dot(L, N), 0.0, 1.0);
    vec3 ambient = 0.05 * color;
    vec3 fresnel = 0.15 * color * pow(1.0 + dot(rd, N), 3.0);

    //get shadows
    float shadow = getSoftShadow(p + N * 0.02, normalize(lightPos));
    //get ambient occlusion
    float occ = getAmbientOcclusion(p, N);
    //get background
    vec3 back = 0.05 * color * clamp(dot(N, -L), 0.0, 1.0);

    return  (back + ambient + fresnel) * occ + (specular * occ + diffuse) * shadow;
}

//return final color
vec3 render(vec2 uv) {
    vec3 col = vec3(0);
    vec3 background = vec3(0.5, 0.8, 0.9);

    vec3 rd = CameraDirection * normalize(vec3(uv, FOV));

    vec2 object = rayMarch(ro, rd);

    if (object.x < MAX_DIST) {
        vec3 p = ro + object.x * rd;
        col += getLight(p, rd, object.y);
        // fog
        col = mix(col, background, 1.0 - exp(-1e-7 * object.x * object.x * object.x));
    } else {
        col += background - max(0.9 * rd.y, 0.0);
    }
    return col;
}

//change coordinate system to easier work with it
vec2 getUV(vec2 offset) {
    return (2.0 * (gl_FragCoord.xy + offset) - u_resolution.xy) / u_resolution.y;
}


//---------------------------------------------------------------------------------------------
//Antialiasing - launching more than 1 ray for 1 pixel and ounting average for smoother picture
//---------------------------------------------------------------------------------------------

//antialiasingx1
vec3 renderAAx1() {
    return render(getUV(vec2(0)));
}

//antialiasingx2
vec3 renderAAx2() {
    float bxy = int(gl_FragCoord.x + gl_FragCoord.y) & 1;
    float nbxy = 1. - bxy;
    vec3 colAA = (render(getUV(vec2(0.33 * nbxy, 0.))) + render(getUV(vec2(0.33 * bxy, 0.66))));
    return colAA / 2.0;
}

//antialiasingx3
vec3 renderAAx3() {
    float bxy = int(gl_FragCoord.x + gl_FragCoord.y) & 1;
    float nbxy = 1. - bxy;
    vec3 colAA = (render(getUV(vec2(0.66 * nbxy, 0.))) +
                  render(getUV(vec2(0.66 * bxy, 0.66))) +
                  render(getUV(vec2(0.33, 0.33))));
    return colAA / 3.0;
}

//antialiasingx4
vec3 renderAAx4() {
    vec4 e = vec4(0.125, -0.125, 0.375, -0.375);
    vec3 colAA = render(getUV(e.xz)) + render(getUV(e.yw)) + render(getUV(e.wx)) + render(getUV(e.zy));
    return colAA /= 4.0;
}

//main calling the rendering
void main() {
    vec3 color = (AA == 1) ? renderAAx1() : (AA == 2) ? renderAAx2() : (AA == 3) ? renderAAx3(): renderAAx4();
    // gamma correction (for realistic )
    color = pow(color, vec3(0.4545));
    fragColor = vec4(color, 1.0);
}