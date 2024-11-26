shader_type canvas_item;

// Shake effect settings
uniform bool enable_shake = false;                              // Enable or disable the shake
uniform float shake_strength: hint_range(0.0, 1.0, 0.01) = 0.5; // Overall shake strength
uniform float shake_bias_x: hint_range(0.0, 0.1, 0.01) = 0.01;   // Horizontal shake bias
uniform float shake_bias_y: hint_range(0.0, 0.1, 0.01) = 0.01;   // Vertical shake bias
uniform vec2 randomness_seed = vec2(12.9898, 78.233);           // Randomness seed

// Random number generator based on UV coordinates
float random(vec2 seed) {
    return fract(sin(dot(seed.xy, randomness_seed)) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    if (enable_shake) {
        // Apply a damping factor to reduce shake strength
        float dampened_strength = shake_strength * 0.5; // Halve the strength for a more subtle effect

        // Generate random shake offsets with separate bias
        float offset_x = (random(vec2(TIME, 0.0)) * 2.0 - 1.0) * dampened_strength * shake_bias_x;
        float offset_y = (random(vec2(TIME, 1.0)) * 2.0 - 1.0) * dampened_strength * shake_bias_y;

        vec2 shake_offset = vec2(offset_x, offset_y);
        uv += shake_offset;
    }

    // Sample the texture, handling UV out-of-bounds gracefully
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        // Transparent outside bounds
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        // Regular texture sampling
        COLOR = texture(TEXTURE, uv);
    }
}
