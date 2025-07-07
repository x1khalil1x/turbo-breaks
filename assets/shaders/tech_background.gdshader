shader_type canvas_item;

// Tech Background Shader
// Creates animated grid patterns with subtle tech aesthetics
// Designed for modern UI backgrounds with configurable parameters

uniform float grid_scale : hint_range(0.1, 2.0) = 0.5;
uniform float line_width : hint_range(0.001, 0.1) = 0.02;
uniform float scroll_speed : hint_range(0.0, 2.0) = 0.3;
uniform float grid_opacity : hint_range(0.0, 1.0) = 0.2;
uniform vec4 grid_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform vec4 background_color : source_color = vec4(0.05, 0.1, 0.15, 1.0);

// Animated elements
uniform float pulse_speed : hint_range(0.0, 3.0) = 1.0;
uniform float scan_line_speed : hint_range(0.0, 2.0) = 0.8;
uniform float glow_intensity : hint_range(0.0, 3.0) = 1.5;

varying vec2 world_position;

// Generate grid pattern
float grid_pattern(vec2 uv, float scale, float line_w) {
    vec2 grid = abs(fract(uv * scale) - 0.5) / fwidth(uv * scale);
    float line = min(grid.x, grid.y);
    return 1.0 - min(line, 1.0);
}

// Create animated scan lines
float scan_lines(vec2 uv, float time) {
    float scan_y = mod(uv.y + time * scan_line_speed, 1.0);
    float scan_intensity = smoothstep(0.95, 1.0, scan_y) * 0.5;
    return scan_intensity;
}

// Generate subtle noise for texture
float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// Pulse effect for dynamic lighting
float pulse_effect(float time) {
    return 0.5 + 0.5 * sin(time * pulse_speed * 6.28318);
}

void vertex() {
    world_position = VERTEX;
}

void fragment() {
    vec2 uv = UV;
    float time = TIME;
    
    // Animate UV coordinates for scrolling effect
    vec2 animated_uv = uv + vec2(time * scroll_speed * 0.1, time * scroll_speed * 0.05);
    
    // Create main grid
    float main_grid = grid_pattern(animated_uv, grid_scale * 10.0, line_width);
    
    // Create secondary fine grid
    float fine_grid = grid_pattern(animated_uv, grid_scale * 50.0, line_width * 0.5) * 0.3;
    
    // Combine grids
    float combined_grid = max(main_grid, fine_grid);
    
    // Add scan lines
    float scan = scan_lines(uv, time);
    
    // Add subtle noise texture
    float noise_val = noise(animated_uv * 100.0) * 0.05;
    
    // Pulse animation
    float pulse = pulse_effect(time);
    
    // Calculate final grid intensity
    float grid_intensity = combined_grid * grid_opacity * (1.0 + pulse * 0.3);
    
    // Add glow effect
    float glow = smoothstep(0.0, line_width * 2.0, combined_grid) * glow_intensity;
    
    // Combine all effects
    vec3 final_color = background_color.rgb;
    final_color = mix(final_color, grid_color.rgb, grid_intensity);
    final_color += grid_color.rgb * glow * 0.2;
    final_color += vec3(scan * 0.5);
    final_color += vec3(noise_val);
    
    // Output with background alpha
    COLOR = vec4(final_color, background_color.a);
} 