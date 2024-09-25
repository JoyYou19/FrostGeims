function send_start_game_packet(_socket){
	// Now send the player's registration data to the server
	var _buffer = buffer_create(1024, buffer_grow, 1);
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, NETWORK.STARTGAME); // Send the "CONNECT" packet type

	// Send the buffer to the server using the TCP connection
	network_send_raw(_socket, _buffer, buffer_tell(_buffer));

	// Clean up the buffer after sending
	buffer_delete(_buffer);
}