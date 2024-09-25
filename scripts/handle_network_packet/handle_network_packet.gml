// The function that deals with all the packets in the game
function handle_network_packet(_packet_type, _packet){

	switch(_packet_type){
		case NETWORK.CONNECT:
			handle_connect_packet(_packet);
		break;
		
		case NETWORK.DATA:
			handle_data_packet(_packet);
		break;
		
		case NETWORK.DISCONNECT:
			handle_disconnect_packet(_packet);
		break;
		
		case NETWORK.STARTGAME:
			global.game_started = true;
		break;
	}
}

function handle_disconnect_packet(_packet) {
    // Read the player ID of the disconnected client
    var _player_id = buffer_read(_packet, buffer_u16);

    // Find and remove the player instance
    var _player_instance = ds_map_find_value(instances, _player_id);
    if (!is_undefined(_player_instance)) {
        instance_destroy(_player_instance); // Remove the player object
        ds_map_delete(instances, _player_id); // Remove the entry from the map
        show_debug_message("Player " + string(_player_id) + " disconnected and was removed.");
    }
}

// Function that handles incomming data
function handle_data_packet(_packet){
	// Get the data action
	var _action_type = buffer_read(_packet, buffer_u8);
	
	show_debug_message("Data packet received");
	
	switch(_action_type){
		// The movement sync
		case ACTION.MOVE:
			var _player_id = buffer_read(_packet,buffer_u16);
			var _x = buffer_read(_packet, buffer_u16);
			var _y = buffer_read(_packet, buffer_u16);
			
			// If the packet is coming from yourself, don't update your own position (FOR SMOOTHNESS)
			if _player_id == global.client_id return;
			
			var _player_instance = ds_map_find_value(instances,_player_id);
			if(!is_undefined(_player_instance)){
				if(instance_exists(_player_instance)){
					_player_instance.x = _x;
					_player_instance.y = _y;
				}
			}
		break;
	}
}

// Function that correctly handles, creates and manages connections
function handle_connect_packet(_packet){
	var _received_id = buffer_read(_packet, buffer_u16);
	
	if(global.client_id == -1){
		global.client_id = _received_id;
		
		send_udp_handshake(udp_client,server_ip,udp_server_port);
	} 
	
	var _num_clients = buffer_read(_packet, buffer_u16);
	
	// Loop through the clients list and assign each one to the instances ds_map
	for (var i = 0; i < _num_clients; i++){
		/* Determine the player ID, as well as determine the length of the name
		because whenever receiving a packet in gamemaker it doest know how
		big it is, so it should know before reading it */
		var _player_id = buffer_read(_packet, buffer_u16);
		var _name_length = buffer_read(_packet, buffer_u16);
		
		// Read the name of the player
		var _name_buffer = buffer_create(_name_length, buffer_fixed, 1);
		buffer_copy(_packet, buffer_tell(_packet), _name_length, _name_buffer, 0);
		buffer_seek(_name_buffer, buffer_seek_start, 0);
		var _player_name = buffer_read(_name_buffer,buffer_string);
		buffer_delete(_name_buffer);
		
		if(!ds_map_exists(instances,_player_id)){
			var _new_player = instance_create_depth(0,0,0,oPlayer);
			_new_player.player_id = _player_id;
			_new_player.player_name = _player_name;
			
			if(_player_id == global.client_id){
				oCamera.obj_follow = _new_player;
			}
			
			// Player gets added to the instances
			ds_map_add(instances,_player_id, _new_player);
		}
		
		/* VERY IMPORTANT to make sure to offset the buffer to the length of the name because
		we need to move exactly the number of bytes so we get to the next player entry. */
		buffer_seek(_packet, buffer_seek_relative, _name_length);
	}
}