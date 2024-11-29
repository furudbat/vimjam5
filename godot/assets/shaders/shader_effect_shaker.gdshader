shader_type canvas_item;

// --- Uniforms --- //
uniform bool enable_shake = false;
uniform float shake_strength: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float shake_bias_x: hint_range(0.0, 0.1, 0.01) = 0.01;
uniform float shake_bias_y: hint_range(0.0, 0.1, 0.01) = 0.01;
uniform float shake_speed: hint_range(10.0, 1000.0, 10.0) = 10.0;
uniform vec2 randomness_seed = vec2(62.9898, 78.233);

// --- Functions --- //
float random(vec2 seed) {
    return fract(sin(dot(seed.xy, randomness_seed)) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    // Compute the shake offsets
    float dampened_strength = shake_strength * 0.5; // Halve the strength for a more subtle shake effect
	float adjusted_time = TIME * 1.0/(shake_speed*500.0); // we need a very low number to influence the aktual speed: 1.0/(1000*500)=0.000002
	float offset_x = (random(vec2(adjusted_time, 0.0)) * 2.0 - 1.0) * dampened_strength * shake_bias_x;
    float offset_y = (random(vec2(adjusted_time, 1.0)) * 2.0 - 1.0) * dampened_strength * shake_bias_y;
    vec2 shake_offset = vec2(offset_x, offset_y);
    uv += shake_offset * float(enable_shake);
	
	//transpacency handling
    vec2 uv_clamped = clamp(uv, 0.0, 1.0);     // Clamp UVs to prevent stretching of the pixeln at the edge
    float in_bounds = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);     // Generate a mask for in-bounds UVs
    vec4 tex_color = texture(TEXTURE, uv_clamped);

    COLOR = tex_color * in_bounds;     // Blend between transparent and the texture based on the in-bounds mask
}