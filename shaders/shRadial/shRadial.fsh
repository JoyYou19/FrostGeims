varying vec2 v_vTexcoord;      // Texture coordinates (passed from the vertex shader)
uniform vec2 u_uv_center;      // UV-space center of the sprite
uniform float u_health_percent; // Health as a percentage (0.0 to 1.0)

void main() {
    // Calculate the direction from the center in UV space
    vec2 direction = v_vTexcoord - u_uv_center;

    // Calculate the angle in radians (-π to π)
    float angle = atan(direction.y, direction.x);

    // Adjust the angle so that 0 radians corresponds to the top (rotate by π/2 or 90 degrees)
    angle += 1.57079633; // Add 90 degrees in radians (π/2)

    // Normalize the angle to [0.0, 1.0] (convert from [-π, π] to [0, 1])
    if (angle < 0.0) {
        angle += 6.2831853; // If angle is negative, make it positive by adding 2π (360 degrees)
    }

    float normalized_angle = angle / (2.0 * 3.14159265);

    // Invert the angle to make it move clockwise
    normalized_angle = 1.0 - normalized_angle;

    // Only draw the sprite if the normalized angle is within the health percentage
    if (normalized_angle <= u_health_percent) {
        // Draw the sprite normally
        gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
    } else {
        // Otherwise, discard the fragment (don't draw it)
        discard;
    }
}
