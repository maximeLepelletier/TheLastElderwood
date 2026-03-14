shader_type canvas_item;

uniform float radius_ratio = 0.5
; // 0.5 = cercle parfait

void fragment() {
    vec2 uv = UV;                 // coordonnées locales
    vec2 center = vec2(0.5, 0.5);
    
    float min_dim = min(TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y);
    float radius = radius_ratio ;

    float dist = length(uv - center);

    vec4 tex = texture(TEXTURE, uv);

    if (dist <= radius) {
        COLOR = tex;
    } else {
        COLOR = vec4(tex.rgb, 0.0);
    }
}