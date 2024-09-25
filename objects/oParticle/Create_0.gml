particle_surface = -1; // The base particle surface
light_particle_surface = -1; // The surface responsible for light up particles

particle_system = part_system_create();
light_particle_system = part_system_create();
part_system_automatic_draw(particle_system,false);
part_system_automatic_draw(light_particle_system,false);

bullet = part_type_create();
part_type_life(bullet,10,10);
part_type_shape(bullet,pt_shape_line);
part_type_blend(bullet,false);
part_type_alpha2(bullet,1,0);
part_type_color3(bullet,make_color_rgb(255,255,100),c_white,c_gray);