// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function deal_damage(_player_id, _amount){
	
	// Now send the player's registration data to the server
	var _buffer = buffer_create(32, buffer_grow, 1);
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, NETWORK.DATA); 
	buffer_write(_buffer, buffer_u8, ACTION.DAMAGE); 
	buffer_write(_buffer, buffer_u16, _player_id); 
	buffer_write(_buffer, buffer_u16, _amount); 

	// Send the buffer to the server using the TCP connection
	network_send_raw(oNetwork.tcp_client, _buffer, buffer_tell(_buffer));

	// Clean up the buffer after sending
	buffer_delete(_buffer);
}