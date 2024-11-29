shader_type canvas_item;

// --- Uniforms --- //
uniform bool enable_destortion = false;
uniform float destortion_strength: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec2 direction = vec2(1.0, 1.0);

// --- Functions --- //
// Random noise function for chaotic motion
float random(vec2 seed) {
	return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	vec2 normalized_direction = normalize(direction);   // Normalize the direction to ensure it's unit-length

        // Randomized shake offsets
	vec2 random_offset = vec2(
		random(vec2(TIME * destortion_strength, uv.x)) - 0.5,
		random(vec2(TIME * destortion_strength, uv.y)) - 0.5
		);

	vec2 shake_offset = random_offset * destortion_strength * normalized_direction * 0.1; // * 0.1 to dampen the effect

	uv += shake_offset * float(enable_destortion);
	uv = clamp(uv, 0.0, 1.0);      // Clamp UVs to prevent edge artifacts
	COLOR = texture(TEXTURE, uv);     // Sample the sprite's texture using the modified UV coordinates
}
