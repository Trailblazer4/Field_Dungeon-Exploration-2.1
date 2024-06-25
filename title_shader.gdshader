shader_type canvas_item;
uniform float offset_x: hint_range(0.0, 1.0, 0.01) = 0.12;
uniform float offset_y: hint_range(0.0, 1.0, 0.01) = 0.04;
uniform float stretch_x: hint_range(0.0, 2.0, 0.01) = 0.13;
uniform float stretch_y: hint_range(0.0, 2.0, 0.01) = 0.5; // 0.31
uniform float brightness: hint_range(0.1, 10.0, 0.01) = 1.77;
uniform float redness: hint_range(0.1, 1.0, 0.01) = 1.0;
uniform float whiteness: hint_range(0.1, 3.0, 0.01) = 0.46;

void fragment() {
	COLOR = vec4(0.3, 0.0, 0.5, COLOR.a);
	float center_x = abs(UV.x - offset_x) * abs(UV.x - offset_x);
	float center_y = abs(UV.y - offset_y) * abs(UV.y - offset_y);
	float color_vector = sqrt((stretch_x * center_x) + (stretch_y * center_y)) * brightness;

	COLOR.b -= color_vector / 3.5;
	COLOR.r -= color_vector * whiteness;
}
