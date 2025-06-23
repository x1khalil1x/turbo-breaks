shader_type canvas_item;

// Character Select Enhanced Background Shader
// Multi-zone color system with technical patterns

uniform float time_speed: hint_range(0.0, 2.0) = 0.4;
uniform float scan_line_intensity: hint_range(0.0, 1.0) = 0.3;
uniform float grid_size: hint_range(10.0, 100.0) = 40.0;
uniform float zone_transition: hint_range(0.0, 1.0) = 0.6;

// Color zones inspired by Anno Mutationem
uniform vec4 portrait_zone_color: source_color = vec4(0.1, 0.15, 0.3, 1.0);
uniform vec4 equipment_zone_color: source_color = vec4(0.2, 0.1, 0.1, 1.0);
uniform vec4 module_zone_color: source_color = vec4(0.1, 0.2, 0.15, 1.0);
uniform vec4 accent_color: source_color = vec4(0.4, 0.8, 1.0, 1.0);

// Technical overlay patterns
uniform float circuit_intensity: hint_range(0.0, 1.0) = 0.2;
uniform float data_stream_speed: hint_range(0.0, 3.0) = 1.0;

// Noise for variation
float noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// Technical grid pattern
float grid_pattern(vec2 uv, float size) {
    vec2 grid = abs(fract(uv * size) - 0.5);
    return min(grid.x, grid.y);
}

// Scanning line effect
float scan_lines(vec2 uv, float time) {
    float line = sin(uv.y * 200.0 + time * 10.0) * 0.04;
    return line;
}

// Data stream effect
float data_streams(vec2 uv, float time) {
    vec2 stream_uv = vec2(uv.x * 3.0, uv.y + time * data_stream_speed);
    float stream = step(0.98, noise(stream_uv)) * 0.8;
    return stream;
}

// Circuit pattern overlay
float circuit_lines(vec2 uv) {
    vec2 circuit_uv = uv * 8.0;
    float horizontal = step(0.95, fract(circuit_uv.y));
    float vertical = step(0.95, fract(circuit_uv.x));
    return max(horizontal, vertical) * circuit_intensity;
}

void fragment() {
    vec2 uv = UV;
    float time = TIME * time_speed;
    
    // Define zones based on screen position
    vec4 base_color;
    
    // Left side - Character portrait zone (0.0 to 0.4)
    if (uv.x < 0.4) {
        base_color = portrait_zone_color;
        // Add subtle blue tint for character area
        base_color += accent_color * 0.1;
    }
    // Right upper - Equipment zone (0.4 to 1.0, 0.0 to 0.7)
    else if (uv.x >= 0.4 && uv.y < 0.7) {
        base_color = equipment_zone_color;
        // Add red accent for equipment
        base_color += vec4(0.3, 0.1, 0.1, 0.0) * 0.2;
    }
    // Right lower - Module zone (0.4 to 1.0, 0.7 to 1.0)
    else {
        base_color = module_zone_color;
        // Add green accent for modules
        base_color += vec4(0.1, 0.3, 0.2, 0.0) * 0.2;
    }
    
    // Add technical overlays
    float grid = grid_pattern(uv, grid_size);
    float scan = scan_lines(uv, time);
    float streams = data_streams(uv, time);
    float circuits = circuit_lines(uv);
    
    // Combine effects
    vec4 technical_overlay = vec4(grid * 0.1 + scan * scan_line_intensity + streams + circuits);
    
    // Zone transition effects
    float transition_line = smoothstep(0.38, 0.42, uv.x) * smoothstep(0.42, 0.38, uv.x);
    transition_line += smoothstep(0.68, 0.72, uv.y) * smoothstep(0.72, 0.68, uv.y);
    transition_line *= accent_color.rgb * zone_transition;
    
    // Final composition
    COLOR = base_color + technical_overlay + vec4(transition_line, 1.0);
    COLOR.a = 1.0;
} 