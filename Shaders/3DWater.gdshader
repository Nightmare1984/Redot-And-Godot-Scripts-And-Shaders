shader_type spatial;

uniform sampler2D noise_texture : hint_default_white;
uniform vec2 noise_scale = vec2(1.0);
uniform float puddle_threshold = 0.5; // Controls puddle size
uniform vec4 water_color : source_color = vec4(0.1, 0.3, 0.4, 0.8);
uniform float metallic = 0.8;
uniform float roughness = 0.1;
uniform float depth_scale = 0.2;
uniform float ripple_speed = 1.0;
uniform float ripple_strength = 0.05;

void fragment() {
    // Get main noise for puddle shape
    vec2 scaled_uv = UV * noise_scale;
    float time = TIME * ripple_speed;
    
    // Create moving ripples by sampling noise at different positions
    float noise1 = texture(noise_texture, scaled_uv + vec2(time * 0.1, time * 0.15)).r;
    float noise2 = texture(noise_texture, scaled_uv * 1.4 - vec2(time * 0.12, time * 0.13)).r;
    
    // Combine noise samples for more natural look
    float combined_noise = (noise1 + noise2) * 0.5;
    
    // Create puddle mask
    float puddle_mask = smoothstep(puddle_threshold - 0.1, puddle_threshold + 0.1, combined_noise);
    
    // Add ripple effect to normal map
    vec2 ripple_offset = vec2(
        texture(noise_texture, scaled_uv + vec2(time * 0.2, 0.0)).r - 0.5,
        texture(noise_texture, scaled_uv + vec2(0.0, time * 0.2)).r - 0.5
    ) * ripple_strength;
    
    // Calculate normal map from ripples
    vec3 normal = normalize(vec3(ripple_offset.x, 1.0, ripple_offset.y));
    
    // Apply depth based on noise
    float depth = (1.0 - combined_noise) * depth_scale * puddle_mask;
    
    // Set material properties
    ALBEDO = mix(vec3(0.5), water_color.rgb, puddle_mask);
    ALPHA = water_color.a * puddle_mask;
    METALLIC = metallic * puddle_mask;
    ROUGHNESS = roughness * puddle_mask;
    NORMAL_MAP = normal;
    
    // Create depth effect using AO and height
    AO = 1.0 - (depth * 0.5);
    HEIGHT = depth;
}