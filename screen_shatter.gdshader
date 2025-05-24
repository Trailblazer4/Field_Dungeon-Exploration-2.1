shader_type canvas_item;

uniform float time; // Set this over time from script
uniform float intensity = 1.0; // How violent the shatter is

// Simple hash function
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;
    vec2 grid = floor(uv * vec2(20.0, 12.0)); // Controls number of shards
    float seed = rand(grid);

    // Each shard gets a direction
    float angle = seed * 6.2831;
    vec2 dir = vec2(cos(angle), sin(angle));

    // Animate shard offset
    uv += dir * time * intensity * (seed * 0.5 + 0.5);

    // Optional: add cracks or transparency between shards
    float border = smoothstep(0.02, 0.03, abs(fract(uv.x * 20.0) - 0.5) + abs(fract(uv.y * 12.0) - 0.5));

    if (border > 0.98) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // simulate cracks
    } else {
        COLOR = texture(TEXTURE, uv);
    }
}
