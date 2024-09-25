// Simplified Circular Light Shader with Color Support
varying vec2 v_vTexcoord;
varying vec2 pos;
varying vec4 v_vColour; // Vertex color to apply light colors

uniform vec2 u_pos;     // Light source position (in screen space or texture space)
uniform float u_radius; // Radius of the light
uniform float u_str;    // Strength of the light

void main() {
    // Calculate the distance from the light source to the current pixel
    vec2 dis = pos - u_pos;
    float dist = length(dis);

    // Calculate light strength based on the distance (inverse-distance formula)
    float str = clamp(1.0 - (dist / u_radius), 0.0, 1.0); // Strength fades with distance

    // Get the base color from the texture
    vec4 base_color = texture2D(gm_BaseTexture, v_vTexcoord);

    // Modulate the light color using v_vColour (vertex color) and light strength
    vec4 light_color = v_vColour * vec4(vec3(str * u_str), 1.0); // Apply the light color

    // Output the final color, modulated by both the light color and the base texture color
    gl_FragColor = base_color * light_color;
}
