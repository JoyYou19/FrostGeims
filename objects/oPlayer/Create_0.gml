player_id = 0;
player_name = "";
healthpoints = 100;
image_speed = 0.4;

function send_movement_packet(){
	// Create a buffer to send a movement packet
	var _buff = buffer_create(32, buffer_grow, 1);
	buffer_seek(_buff, buffer_seek_start, 0);

	// Define the packet as a DATA packet for movement
	buffer_write(_buff, buffer_u8, NETWORK.DATA); // Packet type: DATA
	buffer_write(_buff, buffer_u8, ACTION.MOVE);  // Action type: MOVE
	buffer_write(_buff, buffer_u16, global.client_id); // The unique ID of the player (client)

	// Write the player's x and y coordinates
	buffer_write(_buff, buffer_u16, x); // Player's X coordinate
	buffer_write(_buff, buffer_u16, y); // Player's Y coordinate

	// Send the packet to the server via UDP
	network_send_udp_raw(oNetwork.udp_client, oNetwork.server_ip, oNetwork.udp_server_port, _buff, buffer_tell(_buff));

	// Clean up the buffer after sending
	buffer_delete(_buff);
}