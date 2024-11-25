shader_type canvas_item;
render_mode skip_vertex_transform;

uniform vec2  direction = vec2(0, 0.5);
uniform float offset : hint_range(0, 1);
uniform float strip_size_pixel = 4;
uniform float progress: hint_range(0, 1) = 0;

varying float max_offset;

void vertex(){
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 norm = normalize(direction);
	
	vec2 compare = norm * vec2(texture_size.y, texture_size.x);
	if(compare.x > compare.y){
		max_offset = length(vec2(texture_size.x, texture_size.x/norm.x*norm.y));
		
	}else{
		max_offset = length(vec2(texture_size.y/norm.y*norm.x, texture_size.y));
	}
	vec2 amount = max_offset * progress * norm;
	VERTEX += sign(VERTEX)*amount;
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}
void fragment() {
	vec2 norm = normalize(direction);
	vec2 amount = max_offset * progress * norm;
	vec2 pixels = UV*(1.0/TEXTURE_PIXEL_SIZE+2.0*amount);
	vec2 pdir = vec2(norm.y, -norm.x);
	
	float sw = (float(int(dot(pdir, pixels) / strip_size_pixel) & 0x1) * 2.0) - 1.;
	vec2 corrected_uv = (UV-(sw+1.0)*amount/((1.0/TEXTURE_PIXEL_SIZE+2.0*amount)))*((1.0/TEXTURE_PIXEL_SIZE+2.0*amount)/(1.0/TEXTURE_PIXEL_SIZE));
	
	vec4 color = texture(TEXTURE, corrected_uv);
	
	//color.a *= clamp(1. - factor, 0, 1);
	COLOR = color;
	
	if(corrected_uv.x>1.0 ||corrected_uv.x<0.0||corrected_uv.y>1.0||corrected_uv.y<0.0){
		COLOR.a = 0.0;
	}
}
