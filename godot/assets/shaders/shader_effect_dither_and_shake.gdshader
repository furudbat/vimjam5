shader_type canvas_item;

// --- Uniforms --- //
uniform float dither_intensity: hint_range(0.0, 1.0, 0.05) = 0.0; 
uniform bool enable_shake = false;
uniform float shake_strength: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float shake_bias_x: hint_range(0.0, 0.1, 0.01) = 0.01;
uniform float shake_bias_y: hint_range(0.0, 0.1, 0.01) = 0.01;
uniform vec2 randomness_seed = vec2(12.9898, 78.233);

// --- Constants --- //
const mat4 THRESHOLD_MATRIX = mat4(
    vec4(1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0),
    vec4(13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0),
    vec4(4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0),
    vec4(16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0));

// --- Functions --- //
// Random number generator based on UV coordinates
float random(vec2 seed) {
    return fract(sin(dot(seed.xy, randomness_seed)) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    // Compute the shake offsets
    float dampened_strength = shake_strength * 0.5;
    float offset_x = (random(vec2(TIME, 0.0)) * 2.0 - 1.0) * dampened_strength * shake_bias_x;
    float offset_y = (random(vec2(TIME, 1.0)) * 2.0 - 1.0) * dampened_strength * shake_bias_y;

    vec2 shake_offset = vec2(offset_x, offset_y);

    uv += shake_offset * float(enable_shake);

    // Handle dithering dissolve
    vec2 pixel_uv = uv / TEXTURE_PIXEL_SIZE; // Use modified UV for proper alignment
    float dither_threshold = THRESHOLD_MATRIX[int(pixel_uv.x) % 4][int(pixel_uv.y) % 4];
    float dissolve_factor = step(0.0, dither_threshold - dither_intensity);

    // Create a mask for UVs inside bounds
    vec2 uv_clamped = clamp(uv, 0.0, 1.0);
    float in_bounds = step(uv.x, 1.0) * step(0.0, uv.x) * step(uv.y, 1.0) * step(0.0, uv.y);

    // Sample texture and apply dissolve
    vec4 tex_color = texture(TEXTURE, uv_clamped);
    vec4 dissolved_color = vec4(tex_color.rgb * dissolve_factor, tex_color.a * dissolve_factor);

    COLOR = dissolved_color * in_bounds;     // Blend based on the bounds mask
}
