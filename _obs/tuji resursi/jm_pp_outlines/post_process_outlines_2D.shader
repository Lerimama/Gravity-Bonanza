shader_type canvas_item;
render_mode blend_mix;

uniform float color_outline_scale = 50.0; // Size of color outlines
uniform float edge_threshold : hint_range(0,1) = 0.04; // General threshold for values to be considered as edges
uniform float max_edge_alpha : hint_range(0,1) = 0.8; // Max edge alpha, lower values means edges blend more with background
uniform float edge_alpha_multiplier = 3.0; // General multiplier for edge alpha value, higher values mean harder edges

uniform vec4 edge_color : hint_color = vec4(0,0,0,1); // Outlines color
uniform sampler2D bgTex : hint_albedo; // BG texture

uniform bool color_use_laplace = false; // Sets color edges to use the laplace operator instead of sobel
uniform bool use_bg_texture = false; // Sets shader to use render the BG behind the edges

void fragment() {
	float halfScaleFloor_c = floor(color_outline_scale * 0.5);
	float halfScaleCeil_c = ceil(color_outline_scale * 0.5);
	vec2 texelSize = SCREEN_PIXEL_SIZE;
	


	vec2 topUV_c = SCREEN_UV + vec2(0.0, texelSize.y * halfScaleCeil_c);
	vec2 bottomUV_c = SCREEN_UV + vec2(0.0, -texelSize.y * halfScaleFloor_c);
	vec2 centerUV_c = SCREEN_UV;
//	vec2 bottomLeftUV_c = SCREEN_UV - vec2(texelSize.x, texelSize.y) * halfScaleFloor_c;
//	vec2 topRightUV_c = SCREEN_UV + vec2(texelSize.x, texelSize.y) * halfScaleCeil_c;
//	vec2 rightUV_c = SCREEN_UV + vec2(texelSize.x * halfScaleCeil_c, 0.0);
//	vec2 leftUV_c = SCREEN_UV + vec2(-texelSize.x * halfScaleFloor_c, 0.0);
//	vec2 bottomRightUV_c = SCREEN_UV + vec2(texelSize.x * halfScaleCeil_c, -texelSize.y * halfScaleFloor_c);
//	vec2 topLeftUV_c = SCREEN_UV + vec2(-texelSize.x * halfScaleFloor_c, texelSize.y * halfScaleCeil_c);
	
	vec4 top_tex = texture(TEXTURE, topUV_c);
	vec4 center_tex = texture(TEXTURE, centerUV_c);
	vec4 bottom_tex = texture(TEXTURE, bottomUV_c);
	
//	vec4 n4 = texture(TEXTURE, centerUV_c);
//	vec4 n1 = texture(TEXTURE, topUV_c);
//	vec4 n7 = texture(TEXTURE, bottomUV_c);
	
//	vec4 n0 = texture(TEXTURE, topLeftUV_c);
//	vec4 n2 = texture(TEXTURE, topRightUV_c);
//	vec4 n3 = texture(TEXTURE, leftUV_c);
//	vec4 n5 = texture(TEXTURE, rightUV_c);
//	vec4 n6 = texture(TEXTURE, bottomLeftUV_c);
//	vec4 n8 = texture(TEXTURE, bottomRightUV_c);
	
//	vec4 n0 = vec4(0.0);
//	vec4 n2 = vec4(0.0);
//	vec4 n3 = vec4(0.0);
//	vec4 n5 = vec4(0.0);
//	vec4 n6 = vec4(0.0);
//	vec4 n8 = vec4(0.0);
	
	float color_edge;
	
	
//	vec4 sobel_edge_h = (n2 + (2.0*n5) + n8 - (n0 + (2.0*n3) + n6)) / 4.0; // new
	
	
//	vec4 sobel_edge_h = (n2 + (2.0*n5) + n8 - (n0 + (2.0*n3) + n6)) / 4.0;
//	vec4 sobel_edge_h = (n0 + (2.0*n1) + n2 - (n6 + (2.0*n7) + n8)) / 4.0;
	vec4 sobel = top_tex - center_tex;
//	vec4 sobel = sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));
	color_edge = sobel.r;
	color_edge = sobel.g;
	color_edge = sobel.b;
	color_edge -= sobel.a;// 0.01; // transparenca ... 0.1 pomeni polno barvo

	
	float edgeVal = color_edge;
	
	// preverimo kje je sprite transparenten
	float edge_alpha = min(max_edge_alpha, edgeVal * edge_alpha_multiplier); 
	
	
	COLOR = (color_edge * edge_color.rgba) + texture(TEXTURE, SCREEN_UV).rgba;
}