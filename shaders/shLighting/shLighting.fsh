/*-----------------------------------------------------------------------------
Day and Night Shader: Tint, Contrast, Brightness, Saturation and Pop Lights
Fragment Shader: Apply effects. overlay tint. blend light surface
-----------------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 col;           // Color tint for the light overlay
uniform sampler2D lights;   // Light surface (texture)

void main()
{
    // Base color of the texture
    vec3 base_col = texture2D(gm_BaseTexture, v_vTexcoord).rgb;

    // Convert the base color to greyscale (for more control over tint effects)
    float grey = dot(base_col, vec3(0.299, 0.587, 0.114));

    // Darkness factor for overlay
    float darkness = 0.02;

    // Contrast value for the base color
    float contrast = 1.1;

    // Apply tint effect: Mix between base color and darkened version based on 'col' tint
    vec3 out_col = mix(base_col, base_col * darkness, 1.0 - col);

    // Add contrast adjustment to enhance visual clarity
    out_col = (out_col - 0.5) * contrast + 0.5;

    // Handle lights
    vec3 lights_col = texture2D(lights, v_vTexcoord).rgb;

    // Get the average brightness of the light's color (greyscale version of light)
    float light_brightness = dot(lights_col, vec3(0.333));

    // Apply a stronger falloff for lights: Modulate brightness based on distance from center
    // This line is crucial: The `pow` function allows you to control the falloff curve.
    light_brightness = pow(light_brightness, 2.0);  // Higher exponent = more focused lights

    // Blend the light with the base color based on the adjusted brightness
    out_col = mix(out_col, base_col * normalize(lights_col + 0.05) * 2.0, light_brightness);

    // Output the final color
    gl_FragColor = vec4(out_col, 1.0);
}
