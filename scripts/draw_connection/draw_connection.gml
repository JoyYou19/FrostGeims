// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function draw_connection(){

if global.game_started exit;

if(global.client_id != -1){
	
	draw_set_color(c_black);
	draw_rectangle(0,0,RES_W,RES_H,false);
	draw_set_color(c_white);
	
	draw_set_font(fTemp);
	draw_set_halign(fa_center);
	draw_text(RES_W/2,RES_H/2,"Play");
	var _separation = 0;
	with(oPlayer){
		draw_text(100+_separation,200,player_name);
		_separation += 100;
	}

	if(point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), RES_W/2-100,RES_H/2-50,RES_W/2+100,RES_H/2+50)){
		if(mouse_check_button_pressed(mb_left)){
			send_start_game_packet(tcp_client);
		}
	}
	
} else {
	static connect_string = "Connect";
	static timer = 0;

	draw_set_color(c_black);
	draw_rectangle(0,0,RES_W,RES_H,false);
	draw_set_color(c_white);

	draw_set_font(fTemp);
	draw_set_halign(fa_center);
	draw_text(RES_W/2,RES_H/2,connect_string);

	if(point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), RES_W/2-100,RES_H/2-50,RES_W/2+100,RES_H/2+50)){
		if(mouse_check_button_pressed(mb_left)){
			connect_to_server(tcp_client,server_ip,tcp_server_port);
		}
	}

	if(global.client_id == -1){
		timer ++;
	
		if(timer >= 30){
			connect_string += ".";
		
			if(string_length(connect_string) > 10){
				connect_string = "Connect";
			}
			timer = 0;
		}
	}
}

}