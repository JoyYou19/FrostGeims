// Server data
server_ip = "62.85.88.97";
udp_server_port = 12345;
tcp_server_port = 12346; // Specific TCP port to differentiate from UDP

// The client that the player uses
udp_client = network_create_socket(network_socket_udp);
tcp_client = network_create_socket(network_socket_tcp);

// The map that holds all the instances currently connected to this client
instances = ds_map_create();
global.client_id = -1;

// Specifies the type of packet being sent
enum NETWORK{
	CONNECT,
	DATA,
	DISCONNECT,
	STARTGAME,
}

// Specifies the action of the DATA packet being sent
enum ACTION{
	MOVE,
	DAMAGE,
	HEALTH_UPDATE,
	SHOOT,
}

player_name = string(irandom(10000));

global.seed = -1; // The seed the players use
global.game_started = false; // The flag that determines if the game has been started by the client
global.client_player = noone; // Store the player of the current instance.

// COPY THE GAME STRING TO RUN A SEPARATE COPY OF IT
clipboard_set_text( parameter_string( 0 ) + " -game \"" + parameter_string( 2 ) + "\"" );