shader_type canvas_item;
uniform vec3 color: source_color = vec3(0.8, 0.81, 0.02); // 204, 208, 7
uniform float speed: hint_range(1.0, 5.0, 0.1) = 4.1;
uniform float max_color: hint_range(0.0, 1.0, 0.01) = 0.4;

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, color, max_color * (sin(TIME * speed) + 1.0)); // fluctuates mix with white between 0% and 40%
}