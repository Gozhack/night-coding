shader_type canvas_item;

uniform float scanline_count : hint_range(0, 1080) = 324.0;
uniform float scanline_opacity : hint_range(0, 1) = 0.1;
uniform float vignette_intensity : hint_range(0, 1) = 0.2;

void fragment() {
    // Base dark color instead of reading from a null texture
    vec3 base_color = vec3(0.01, 0.01, 0.02);
    
    // Scanlines
    float s = sin(UV.y * scanline_count * PI * 2.0);
    s = (s + 1.0) * 0.5;
    s = pow(s, 0.5);
    base_color.rgb *= mix(1.0, s, scanline_opacity);
    
    // Vignette
    float d = distance(UV, vec2(0.5));
    base_color.rgb *= 1.0 - (d * vignette_intensity);
    
    COLOR = vec4(base_color, 1.0);
}
