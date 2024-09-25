// Networking event that takes in all the packets for the game

switch(async_load[? "type"]){
	case network_type_data:
		
		var _packet = async_load[? "buffer"];
		
		var _packet_type = buffer_read(_packet, buffer_u8);
		
		handle_network_packet(_packet_type, _packet);
	break;
	
	case network_type_non_blocking_connect:
		var _socket = async_load[? "socket"];
		var _success = async_load[? "succeeded"];
		
		if(_success){
			show_debug_message("Connection TCP successful");
			
			// Now send the player's registration data to the server
			var _buffer = buffer_create(1024, buffer_grow, 1);
			buffer_seek(_buffer, buffer_seek_start, 0);
			buffer_write(_buffer, buffer_u8, NETWORK.CONNECT); // Send the "CONNECT" packet type
			buffer_write(_buffer, buffer_u16, string_length(player_name)); // Send the player name length
			buffer_write(_buffer, buffer_string, player_name); // Send the player name

			// Send the buffer to the server using the TCP connection
			network_send_raw(_socket, _buffer, buffer_tell(_buffer));

			// Clean up the buffer after sending
			buffer_delete(_buffer);
		}
	break;
}