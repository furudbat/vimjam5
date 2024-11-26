shader_type canvas_item;

// Shake effect settings
// @TODO code clean up, factor and strength basically do the same thing, remove one
uniform bool shake_enabled = false;                              // Enable/Disable the shake
uniform float shake_strength: hint_range(0.0, 1.0, 0.01) = 0.1;  // Overall shake strength
uniform float factor: hint_range(0.0, 1.0, 0.01) = 0.0;          // Control the shake intensity (animate via AnimationPlayer)
uniform vec2 direction = vec2(1.0, 1.0);                         // Base shake direction

// Random noise function for chaotic motion
float random(vec2 seed) {
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    if (shake_enabled) {
        // Normalize the direction to ensure it's unit-length
        vec2 normalized_direction = normalize(direction);

        // Randomized shake offsets
        vec2 random_offset = vec2(
            random(vec2(TIME * factor, uv.x)) - 0.5,
            random(vec2(TIME * factor, uv.y)) - 0.5
        );

        vec2 shake_offset = random_offset * shake_strength * factor * normalized_direction;

        // Apply the shake effect to the UV coordinates
        uv += shake_offset;

        // Clamp UVs to prevent edge artifacts
        uv = clamp(uv, 0.0, 1.0);
    }

    // Sample the sprite's texture using the modified UV coordinates
    COLOR = texture(TEXTURE, uv);
}
