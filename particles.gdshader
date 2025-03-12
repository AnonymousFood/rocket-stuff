// Shader to add glow effect to rocket particles
shader_type spatial;
render_mode blend_add, unshaded;

uniform float max_emission_strength = 0.5;

void fragment() {
    float life_time = COLOR.a;
    float current_emission = max_emission_strength * (1.0 - life_time);

    ALBEDO = COLOR.rgb;
    EMISSION = COLOR.rgb * current_emission;
    ALPHA = 1.0;
}