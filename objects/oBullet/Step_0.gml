part_type_size(oParticle.bullet,0.17,0.17,0,false);
part_type_direction(oParticle.bullet,direction-180,direction-180,0,false);
part_type_orientation(oParticle.bullet,direction-180,direction-180,0,false,false);
part_emitter_region(oParticle.light_particle_system,particle_emitter,(x/4),(x/4),(y/4),(y/4),ps_shape_line,ps_distr_invgaussian)
part_emitter_burst(oParticle.light_particle_system,particle_emitter,oParticle.bullet,1);

death_timer -=1;

if death_timer <=0 instance_destroy();