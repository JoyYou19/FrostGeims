if !surface_exists(particle_surface) particle_surface = surface_create(camera_w/4, camera_h/4);
if !surface_exists(light_particle_surface) light_particle_surface = surface_create(camera_w/4, camera_h/4);

#region // Surface without lights
surface_set_target(particle_surface);
draw_clear_alpha(c_white,0);

part_system_position(particle_system,-camera_x/4, -camera_y/4);
part_system_drawit(particle_system);

surface_reset_target();

draw_surface_stretched(particle_surface,camera_x,camera_y,camera_w,camera_h);
#endregion

#region // Surface with lights
surface_set_target(light_particle_surface);
draw_clear_alpha(c_white,0);

part_system_position(light_particle_system,-camera_x/4, -camera_y/4);
part_system_drawit(light_particle_system);

surface_reset_target();

draw_surface_stretched(light_particle_surface,camera_x,camera_y,camera_w,camera_h);
#endregion