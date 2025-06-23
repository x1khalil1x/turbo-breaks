shader_type canvas_item;

// Uniforms for customization
uniform float speed: hint_range(0.0, 2.0) = 0.5;
uniform float wave_strength: hint_range(0.0, 0.1) = 0.02;
uniform vec2 direction = vec2(1.0, 0.0);
uniform sampler2D background_texture : source_color;
uniform float fade_alpha: hint_range(0.0, 1.0) = 1.0;

// FIXED: Much higher resolution for fine pixels
uniform float pixel_size: hint_range(0.001, 0.01) = 0.003;  // Smaller = finer pixels
uniform int palette_size: hint_range(2, 8) = 6;

// Monochrome blue palette
const vec4 PALETTE[8] = {
    vec4(0.05, 0.05, 0.15, 1.0),  // Very dark blue
    vec4(0.15, 0.15, 0.3, 1.0),   // Dark blue
    vec4(0.25, 0.3, 0.45, 1.0),   // Medium dark blue
    vec4(0.35, 0.4, 0.6, 1.0),    // Medium blue
    vec4(0.45, 0.5, 0.75, 1.0),   // Light blue
    vec4(0.6, 0.65, 0.85, 1.0),   // Very light blue
    vec4(0.75, 0.8, 0.95, 1.0),   // Almost white blue
    vec4(0.9, 0.9, 0.95, 1.0)     // Off-white
};

void fragment() {
    // CORRECTED pixelation math - this creates fine pixel grid
    vec2 pixelated_uv = floor(UV / pixel_size) * pixel_size;

    float time = TIME * speed;
    vec2 uv = pixelated_uv + direction * time * 0.05;

    // Subtle distortion
    uv.x += sin(uv.y * 20.0 + time) * wave_strength * 0.5;
    uv.y += cos(uv.x * 15.0 + time) * wave_strength * 0.3;

    vec4 tex_color = texture(background_texture, uv);

    // Find closest palette color
    vec4 final_color = PALETTE[0];
    float min_distance = distance(tex_color.rgb, PALETTE[0].rgb);

    for (int i = 1; i < palette_size && i < 8; i++) {
        float dist = distance(tex_color.rgb, PALETTE[i].rgb);
        if (dist < min_distance) {
            min_distance = dist;
            final_color = PALETTE[i];
        }
    }

    final_color.a *= fade_alpha;
    COLOR = final_color;
}