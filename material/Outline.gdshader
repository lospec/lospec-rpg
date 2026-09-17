shader_type canvas_item;

uniform vec4 outline_color: source_color;
uniform bool enable;

void fragment() {
	float size_x = 1.0/ float(textureSize(TEXTURE, 0).x);
	float size_y = 1.0/ float(textureSize(TEXTURE, 0).y);

	float alpha = -4.0 * COLOR.a;
	alpha += texture(TEXTURE, UV + vec2(size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(-size_x, 0)).a;
	alpha += texture(TEXTURE, UV + vec2(0, size_y)).a;
	alpha += texture(TEXTURE, UV + vec2(0, -size_y)).a;

	vec4 outline_effect = mix(COLOR, outline_color, clamp(alpha, 0.0, 1.0));
	vec4 final_color = vec4(outline_effect.rgb, clamp(abs(alpha) + COLOR.a, 0.0, 1.0));
	COLOR = enable ? final_color : COLOR;
}
