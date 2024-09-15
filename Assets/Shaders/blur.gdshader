shader_type canvas_item;

uniform int strength: hint_range(1, 512) = 2;

vec4 blur_size(sampler2D tex,vec2 fragCoord, vec2 pixelSize) {
    
    vec4 color = vec4(0.,0.,0.,0.);
    float strengthFloat = float(strength);

    vec2 pixel = fragCoord/pixelSize;
    int x_min = max(int(pixel.x-strengthFloat), 0);
    int x_max = min(int(pixel.x+strengthFloat), int(1./pixelSize.x));
    int y_min = max(int(pixel.y-strengthFloat), 0);
    int y_max = min(int(pixel.y+strengthFloat), int(1./pixelSize.y));

    int count =0;

    // Sum the pixels colors
    for(int x=x_min; x <= x_max; x++) {
        for(int y = y_min; y <= y_max; y++) {           
            color += texture(tex, vec2(float(x), float(y)) * pixelSize);
            count++;
        }
    }
    
    // Divide the color by the number of colors you summed up
    color /= float(count);
    
    return color;
}

void fragment() {
    COLOR = blur_size(TEXTURE,UV,TEXTURE_PIXEL_SIZE);
}

/*
shader_type canvas_item;

uniform int iterations = 1;

float average(float a, float b, float c, float d) {
	return sqrt(((a*a)+(b*b)+(c*c)+(d*d))/4.0);
}

void fragment()
{
	vec4 tex_color = texture(TEXTURE, UV);
	
	vec4 up_neighbor_color = texture(TEXTURE, UV - vec2(0, TEXTURE_PIXEL_SIZE.y));
	vec4 down_neighbor_color = texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y));
	vec4 left_neighbor_color = texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0));
	vec4 right_neighbor_color = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0));
	
	float red_average = average(left_neighbor_color.x, right_neighbor_color.x, up_neighbor_color.x, down_neighbor_color.x);
	float green_average = average(left_neighbor_color.y, right_neighbor_color.y, up_neighbor_color.y, down_neighbor_color.y);
	float blue_average = average(left_neighbor_color.z, right_neighbor_color.z, up_neighbor_color.z, down_neighbor_color.z);

	for (int i = 0; i < iterations; i++) {
		vec4 up_neighbor_color = texture(TEXTURE, UV - vec2(0, TEXTURE_PIXEL_SIZE.y));
		vec4 down_neighbor_color = texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y));
		vec4 left_neighbor_color = texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0));
		vec4 right_neighbor_color = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0));
		
		float red_average = average(left_neighbor_color.x, right_neighbor_color.x, up_neighbor_color.x, down_neighbor_color.x);
		float green_average = average(left_neighbor_color.y, right_neighbor_color.y, up_neighbor_color.y, down_neighbor_color.y);
		float blue_average = average(left_neighbor_color.z, right_neighbor_color.z, up_neighbor_color.z, down_neighbor_color.z);
		
		vec4 new_color = vec4(red_average, green_average, blue_average, tex_color.w);
		COLOR = new_color;
	}
}
*/