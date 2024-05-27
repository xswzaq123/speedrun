shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float frequency = 8.0;
uniform vec4 flashColor: source_color = vec4(1.0,1.0,1.0,1.0);


void fragment() {
    float mainAlpha = texture(TEXTURE, UV).a;
    vec4 newColor = mix(COLOR, vec4(vec3(flashColor.rgb), mainAlpha), progress);
    COLOR = newColor;
}
