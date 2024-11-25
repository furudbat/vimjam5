shader_type canvas_item;

uniform vec3 color: source_color;
uniform bool enable_outline = true;
uniform float num_cells: hint_range(2.0, 20.0, 1.0) = 10.0;
uniform float factor: hint_range(0.0, 2.0, 0.01) = 0.0;
uniform float angle: hint_range(0.0, 360.0) = 45.0;

float rectanglef(vec2 uv, float width, float height, float feather) {
    vec2 uv_cartesian = uv * 2.0 - 1.0;
    vec2 uv_reflected = abs(uv_cartesian);
    float dfx = smoothstep(width - feather, width + feather, uv_reflected.x);
    float dfy = smoothstep(height - feather, height + feather, uv_reflected.y);

    return max(dfx, dfy);
}

vec2 rotation(vec2 uv, vec2 center, float ang) {
    mat2 rotation = mat2(
        vec2(cos(ang), -sin(ang)),
        vec2(sin(ang), cos(ang))
    );
    uv -= center;
    uv *= rotation;
    uv += center;
    return uv;
}

void fragment() {
    // Divide the UV space into cells
    vec2 igrid = floor(UV * num_cells) / num_cells;

    // Rotate the grid based on the angle
    igrid = rotation(igrid, vec2(0.5), angle * PI / 180.0);

    // Shrink the rectangles progressively as factor increases
    float rect_size = mix(-0.5, 1.3, factor); // Start large, shrink to small as factor increases
    vec2 fgrid = fract(UV * num_cells);

    // Calculate the rectangle mask for shrinking rectangles
    float rect_mask = rectanglef(igrid, rect_size, rect_size, factor);

    // Calculate the grid mask (for the inner grid area)
    float grid_mask = 1.0 - rectanglef(fgrid, rect_mask, rect_mask, 0.0);

    // Outline size based on the shrinking factor (this controls the outline expansion)
	float outline_size = mix(0.1 * (1.0 - factor), 0.1 * (1.5 - factor), step(0.5, factor));
    float outline_mask = 1.0 - rectanglef(fgrid, rect_mask + outline_size, rect_mask + outline_size, 0.0) - grid_mask;
	outline_mask *= float(enable_outline); // outline disable | enable    
    vec4 tex = texture(TEXTURE, UV); // Original texture color and alpha

    // Mix the outline color only where the outline mask is active
    vec3 outline = outline_mask * color;
    vec3 output = mix(tex.rgb, outline, outline_mask * step(0.01, tex.a)); // Only mix where tex alpha > 0
    float final_alpha = tex.a * (outline_mask + grid_mask);

    COLOR = vec4(output, final_alpha);
}
