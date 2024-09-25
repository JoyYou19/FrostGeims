// Main step event
if(global.client_id == player_id){
	var _input_left = keyboard_check(ord("A"));
	var _input_right = keyboard_check(ord("D"));
	var _input_up = keyboard_check(ord("W"));
	var _input_down = keyboard_check(ord("S"));

	var _hsp = _input_right - _input_left;
	var _vsp = _input_down - _input_up;
	
	if (_hsp != 0) and (_vsp != 0) { _hsp *= 0.707107; _vsp *= 0.707107; }
	
	x += _hsp*10;
	y += _vsp*10;
	
	if(_hsp != 0 || _vsp != 0){
		send_movement_packet();
	}
}

var _bullet_collision = instance_place(x,y,oBullet);
with(_bullet_collision){
	if(bullet_id == global.client_id){
		if(other.player_id !=global.client_id){
			deal_damage(other.player_id,10);
			instance_destroy();
		}
	} else {
		instance_destroy();
	}
}