shader_type spatial;
render_mode blend_mix, cull_back, unshaded, depth_prepass_alpha;

// Colores
uniform vec4 bubble_color : source_color = vec4(0.6, 0.85, 1.0, 0.25);
uniform vec3 rim_color    : source_color = vec3(1.0, 1.0, 1.0);

// Toon lighting
uniform vec3 light_color  : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 shadow_color : source_color = vec3(0.5, 0.6, 0.8);
uniform float toon_threshold : hint_range(0.0, 1.0) = 0.5;

// Fresnel rim
uniform float rim_intensity : hint_range(0.0, 3.0) = 1.0;
uniform float rim_power : hint_range(0.5, 8.0) = 2.0;

uniform float wobble_speed : hint_range(0.0, 10.0) = 0.0;
uniform float wobble_amp   : hint_range(0.0, 0.1) = 0.02;

void vertex() {
    if (wobble_speed > 0.0 && wobble_amp > 0.0) {
        float w = sin(TIME * wobble_speed + VERTEX.x * 3.1 + VERTEX.y * 2.7 + VERTEX.z * 1.9) * wobble_amp;
        VERTEX += NORMAL * w;
    }
}

void fragment() {
    // Dirección de la luz principal (Godot 4 te da LIGHT y LIGHT_COLOR)
    vec3 light_dir = normalize(light_color);
    float ndotl = max(dot(NORMAL, light_dir), 0.0);

    // Toon shading
    vec3 toon_col = ndotl > toon_threshold ? light_color : shadow_color;

    // Fresnel
    vec3 view_n = normalize(NORMAL);
    vec3 view_dir = normalize(-VIEW);
    float fres = pow(1.0 - clamp(dot(view_n, view_dir), 0.0, 1.0), rim_power);

    // Resultado final
    ALBEDO = mix(bubble_color.rgb * toon_col, rim_color, fres * rim_intensity);
    ALPHA  = bubble_color.a + fres * 0.3;
}
