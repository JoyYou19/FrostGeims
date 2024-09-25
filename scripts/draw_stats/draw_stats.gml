function draw_stats(){
	
	if(!instance_exists(global.client_player)) exit;
	
	var _xoffset = 120;
	var _yoffset = 120;

	draw_sprite(sStatbackground,0,_xoffset+40,RES_H-_yoffset-38);

	draw_sprite(sStatimages,0,_xoffset,RES_H-_yoffset);
	draw_radial_sprite(_xoffset,RES_H-_yoffset,0,sHealthbar,global.client_player.healthpoints/100);
	
	draw_radial_sprite(_xoffset-36,RES_H-_yoffset-108,0,sStatbar,1);
	draw_sprite(sStatimages,1,_xoffset-36,RES_H-_yoffset-108);
	
	draw_radial_sprite(_xoffset+64,RES_H-_yoffset-100,1,sStatbar,1);
	draw_sprite(sStatimages,2,_xoffset+64,RES_H-_yoffset-100);
	
	draw_radial_sprite(_xoffset+120,RES_H-_yoffset-16,2,sStatbar,1);
	draw_sprite(sStatimages,3,_xoffset+120,RES_H-_yoffset-16);

}

function draw_radial_sprite(_x,_y,_index,_sprite,_percentage){
// Assuming you have a sprite and its frame
var uvs = sprite_get_uvs(_sprite, _index);

// UVs of the sprite (top-left and bottom-right)
var u_min_x = uvs[0];  // Left U
var u_min_y = uvs[1];  // Top V
var u_max_x = uvs[2];  // Right U
var u_max_y = uvs[3];  // Bottom V

// Calculate the center of the UVs (in UV space)
var uv_center_x = (u_min_x + u_max_x) / 2;
var uv_center_y = (u_min_y + u_max_y) / 2;
// Set the shader
shader_set(shRadial);

// Pass the UV center to the shader
shader_set_uniform_f(shader_get_uniform(shRadial, "u_uv_center"), uv_center_x, uv_center_y);
shader_set_uniform_f(shader_get_uniform(shRadial, "u_health_percent"), _percentage);
// Draw the sprite (the radial gradient shader will be applied)
draw_sprite(_sprite,_index,_x,_y);

shader_reset(); // Reset the shader after drawing
}