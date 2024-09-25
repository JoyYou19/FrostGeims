// Initialize lighting and bloom settings

// Initial default values
lighting        = -1;
tex_lights      = -1;
blur_surface    = -1;
lights_surface  = -1;
bloom_texture   = -1;
srf_ping        = -1;
srf_pong        = -1;

// Default color for lighting
_color = c_white;//make_color_rgb(0, 0, 10);

// Global settings
global.bloom = 1;
depth = -300;

// SHADER INITIALIZATION
// ----------------------------------------
// Main lighting shader
shader          = shLighting;
u_col           = shader_get_uniform(shader, "col");
s_lights        = shader_get_sampler_index(shader, "lights");

// Bloom luminance shader
shader_bloom_lum = shBloom;
u_bloom_threshold = shader_get_uniform(shader_bloom_lum, "bloom_threshold");
u_bloom_range    = shader_get_uniform(shader_bloom_lum, "bloom_range");

// Blur shader
shader_blur      = shBlur;
u_blur_size      = shader_get_uniform(shader_blur, "size");

// Bloom blending shader
shader_bloom_blend = shBloomBlend;
u_bloom_intensity  = shader_get_uniform(shader_bloom_blend, "bloom_intensity");
u_bloom_darken     = shader_get_uniform(shader_bloom_blend, "bloom_darken");
u_bloom_saturation = shader_get_uniform(shader_bloom_blend, "bloom_saturation");
u_bloom_texture    = shader_get_sampler_index(shader_bloom_blend, "bloom_texture");

// BLOOM SETTINGS
// ----------------------------------------
// Default bloom settings
bloom_threshold = 0.0;    // Bloom threshold (controls what brightness is affected)
bloom_range     = 0.0;      // Bloom range (controls the spread of bloom effect)
blur_steps      = global.bloom;  // Number of blur steps based on bloom intensity

// Blending settings for bloom effect
intensity   = 4;    // Controls how strong the bloom effect is
darken      = 1;    // Darkening effect of bloom
saturation  = 1;    // Saturation level for bloom colors