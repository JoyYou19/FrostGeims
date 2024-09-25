if(player_id == global.client_id){
	//deal_damage(player_id,10);
	var  mouse_direction = point_direction(x,y,mouse_x,mouse_y);
	var _renem = 0;
	// Now send the player's registration data to the server
	var _buffer = buffer_create(32, buffer_grow, 1);
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, NETWORK.DATA); 
	buffer_write(_buffer, buffer_u8, ACTION.SHOOT); 
	buffer_write(_buffer,buffer_u16,irandom(30000));//The Id that the shoot sends
	buffer_write(_buffer,buffer_u16,global.client_id);
	buffer_write(_buffer,buffer_u16,x+lengthdir_x(90,mouse_direction+_renem));
	buffer_write(_buffer,buffer_u16,y-22+lengthdir_y(90,mouse_direction+_renem));
	buffer_write(_buffer,buffer_u16,mouse_direction+_renem);
	buffer_write(_buffer,buffer_u16,40);

	// Send the buffer to the server using the TCP connection
	network_send_raw(oNetwork.tcp_client, _buffer, buffer_tell(_buffer));

	// Clean up the buffer after sending
	buffer_delete(_buffer);


}