// Ensure surfaces exist and create them if not
if (!surface_exists(lighting)) {
    lighting = surface_create(RES_W, RES_H);
    tex_lights = surface_get_texture(lighting);
}

if (!surface_exists(blur_surface)) {
    blur_surface = surface_create(RES_W, RES_H);
}

if (!surface_exists(lights_surface)) {
    lights_surface = surface_create(RES_W, RES_H);
}

if (!surface_exists(srf_ping)) {
    srf_ping = surface_create(RES_W, RES_H);
}

if (!surface_exists(srf_pong)) {
    srf_pong = surface_create(RES_W / 4, RES_H / 4);
    bloom_texture = surface_get_texture(srf_pong);
}

// Begin drawing the lighting surface
gpu_set_tex_filter(false);
surface_set_target(lighting);

// Clear the lighting surface to black (base for lights)
draw_clear(c_black);
gpu_set_blendmode(bm_normal);
with(oParticle){
	draw_set_alpha(0.7);
	draw_surface_stretched(light_particle_surface,0,0,camera_w,camera_h);
	draw_set_alpha(1);
}
//with(global.client_player){
//		var _angle_to_mouse = point_direction(x,y,mouse_x,mouse_y);
	
//	// Define the cone properties
//var cone_radius = 1900; // How far the player can see
//var cone_fov = 70;     // Field of view (in degrees)
//var num_segments = 10; // Number of segments to draw the cone smoothly

//// Calculate the half-FOV
//var half_fov = cone_fov / 2;

//var _x = x - camera_x;
//var _y = y - camera_y;

//// Start drawing the cone as a triangle fan
//draw_primitive_begin(pr_trianglefan);

//// First, add the player's position as the center of the fan with solid white
//draw_vertex_color(_x, _y, c_white, 0.1);

//// Draw the cone segments
//for (var i = -half_fov; i <= half_fov; i += cone_fov / num_segments) {
//    // Calculate the angle of each vertex in the cone
//    var angle = _angle_to_mouse + i;
    
//    // Calculate the vertex position at the edge of the cone
//    var vx = _x + lengthdir_x(cone_radius, angle);
//    var vy = _y + lengthdir_y(cone_radius, angle);
    
//    // Calculate distance from center of cone to this vertex
//    var dist = point_distance(_x, _y, vx, vy);
    
//    draw_vertex_color(vx, vy, c_white, 0.1); // Fade to transparent at the edges
//}

//// End drawing the primitive
//draw_primitive_end();
//}
// Reset shader and blend modes (no shader and normal blend mode)
gpu_set_blendmode(bm_normal);
shader_reset();

// Finish drawing to the lighting surface
surface_reset_target();

// BLOOM PROCESSING STAGE
// ----------------------------------------
// Apply bloom luminance shader to the lighting surface
shader_set(shader_bloom_lum);
shader_set_uniform_f(u_bloom_threshold, bloom_threshold);
shader_set_uniform_f(u_bloom_range, bloom_range);

// Draw the lighting surface to srf_ping with bloom luminance
surface_set_target(srf_ping);
draw_surface(lighting, 0, 0);
surface_reset_target();
shader_reset();

// Apply blur effect based on bloom settings if bloom is enabled
gpu_set_tex_filter(true);


shader_set(shader_blur);
shader_set_uniform_f(u_blur_size, RES_W, RES_H, blur_steps);

// Scale the image down to 1/4 size for better performance on the blur pass
surface_set_target(srf_pong);
draw_surface_ext(srf_ping, 0, 0, 0.25, 0.25, 0, c_white, 1);
surface_reset_target();
shader_reset();

// BLOOM BLENDING STAGE
// ----------------------------------------
// Blend the bloom effect back into the main scene
shader_set(shader_bloom_blend);
shader_set_uniform_f(u_bloom_intensity, intensity);
shader_set_uniform_f(u_bloom_darken, darken);
shader_set_uniform_f(u_bloom_saturation, saturation);
texture_set_stage(u_bloom_texture, bloom_texture);

surface_set_target(lights_surface);
draw_surface_ext(srf_pong, 0, 0, 4, 4, 0, c_white, 1); // Upscale the blurred texture
surface_reset_target();
shader_reset();

// Reset texture filtering
gpu_set_tex_filter(false);

// DRAW LIGHTS ONTO THE LIGHTING SURFACE
// ----------------------------------------
// Set the target to the lighting surface to apply lights
surface_set_target(lighting);
gpu_set_blendmode(bm_normal); 
draw_surface(lights_surface, 0, 0);

//Draw the Light
gpu_set_blendmode_ext_sepalpha(bm_inv_dest_alpha,bm_one,bm_zero,bm_zero);
shader_set(shDrawLights);
with(oLight){
	shader_set_uniform_f(shader_get_uniform(shDrawLights, "u_pos"), x-camera_x, y-camera_y);  // Light position
	shader_set_uniform_f(shader_get_uniform(shDrawLights, "u_radius"), radius); // Light radius
	shader_set_uniform_f(shader_get_uniform(shDrawLights, "u_str"), 2.0); // Light strength
	//draw_rectangle_color(_vx,_vy,_vx+320,_vy+180,color,color,color,color,0); //canvas for drawing the light
	draw_surface_ext(application_surface,0,0,1,1,0,col,1);
}
shader_reset();

// Reset blend mode and target
gpu_set_blendmode(bm_normal);
surface_reset_target();

// FINAL RENDERING STAGE
// ----------------------------------------
// Apply the main shader to apply the final post-processing effects
shader_set(shader);
shader_set_uniform_f_array(u_col, [color_get_red(_color) / 255, color_get_green(_color) / 255, color_get_blue(_color) / 255]);
texture_set_stage(s_lights, tex_lights);

// Render the final output on the application surface
if surface_exists(application_surface) {
    draw_surface(application_surface, 0, 0);
}

// Reset shader
shader_reset();