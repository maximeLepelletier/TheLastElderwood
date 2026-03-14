shader_type canvas_item;

// Couleurs principales
uniform vec4 base_color  = vec4(0.0, 1.0, 0.2, 1.0);
uniform vec4 vein_color  = vec4(0.5, 1.0, 0.3, 1.0);

// Vitesse du flux
uniform float speed : hint_range(0.0, 10.0) = 2.0;

// Taille des veines
uniform float vein_frequency : hint_range(1.0, 50.0) = 15.0;
uniform float vein_amplitude : hint_range(0.0, 0.5) = 0.05;

// Taille des bulles
uniform float bubble_size : hint_range(0.0, 0.2) = 0.03;
uniform float bubble_speed : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    vec2 uv = UV;

    // --- Flux principal (déplacement horizontal)
    float flow = fract(uv.x * vein_frequency + TIME * speed);

    // --- Veines sinusoïdales
    float vein = sin((uv.y + flow) * 6.28) * vein_amplitude;

    // --- Bulles : cercles animés aléatoires
    float bubbles = 0.0;
    for (int i = 0; i < 5; i++) {
        float bx = fract(float(i) * 0.618 + TIME * bubble_speed);
        float by = fract(sin(float(i)*3.14) * 0.5 + uv.y);
        float d = distance(uv, vec2(bx, by));
        bubbles += smoothstep(bubble_size, 0.0, d);
    }

    // --- Combinaison
    float intensity = flow + vein + bubbles * 0.3;

    // --- Couleur finale
    COLOR = mix(base_color, vein_color, intensity);
}