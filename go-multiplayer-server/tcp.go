package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"math/rand"
	"net"
	"time"
)

// Start the TCP server for handling connection and disconnection
func startTCPServer() {
	tcpAddress, err := net.ResolveTCPAddr("tcp", ":12346") // Use a TCP port
	if err != nil {
		fmt.Println("Error resolving TCP address:", err)
		return
	}

	listener, err := net.ListenTCP("tcp", tcpAddress)
	if err != nil {
		fmt.Println("Error starting TCP server:", err)
		return
	}
	defer listener.Close()

	fmt.Println("TCP server started on port 12346...")

	for {
		conn, err := listener.AcceptTCP()
		if err != nil {
			fmt.Println("Error accepting TCP connection:", err)
			continue
		}

		// Handle each connection in a goroutine
		go handleTCPConnection(conn)
	}
}

// Handle incoming TCP connections (connect, disconnect)
func handleTCPConnection(conn *net.TCPConn) {
	defer conn.Close()

	buffer := make([]byte, 1024)
	for {
		n, err := conn.Read(buffer)
		if err != nil {
			fmt.Println("Error reading from TCP connection:", err)
			return
		}

		// Process TCP packet (e.g., connect/disconnect logic)
		processTCPPacket(conn, buffer[:n])
	}
}

// Process incoming TCP packets
func processTCPPacket(conn *net.TCPConn, data []byte) {
	packetType := int(data[0])

	switch packetType {
	case CONNECT:
		// Handle connection via TCP
		handleConnect(conn, data[1:])
		fmt.Println("Processing TCP connect packet...")
		// Handle the connection logic here
	case DISCONNECT:
		// Handle disconnection via TCP
		handleDisconnect(conn)
	case STARTGAME:
		startGame(conn)
	case DATA:
		handleTCPDataPacket(conn, data[1:])

	default:
		fmt.Println("Unknown TCP packet type received")
	}
}

// Handle in-game data sent via TCP (e.g., damage, stats updates)
func handleTCPDataPacket(conn *net.TCPConn, data []byte) {
	// Read the action type (second byte in the packet)
	actionType := int(data[0])

	switch actionType {
	case ACTION_DAMAGE:
		handleDamageAction(conn, data[1:]) // Handle damage action
		fmt.Println("Processing damage action...")
	case ACTION_SHOOT:
		handleShootPacket(conn, data[1:])

	// Add more actions like movement, stats, etc.
	default:
		fmt.Println("Unknown TCP action type received")
	}
}

// Handle damage action sent via TCP
func handleDamageAction(conn *net.TCPConn, data []byte) {
	// Read the player ID (2 bytes)
	playerID := binary.LittleEndian.Uint16(data[0:2])

	// Read the damage amount (2 bytes)
	damageAmount := binary.LittleEndian.Uint16(data[2:4])

	fmt.Printf("Player %d takes %d damage.\n", playerID, damageAmount)

	// Apply damage logic, such as reducing health and notifying other clients
	applyDamage(playerID, damageAmount)
}

// Function to apply damage to a player
func applyDamage(playerID uint16, damageAmount uint16) {
	// Find the player by playerID and reduce their health
	for _, client := range clients {
		if client.ID == playerID {
			client.Stats.Health -= float32(damageAmount)
			fmt.Printf("Player %d now has %.2f health remaining.\n", playerID, client.Stats.Health)

			// Send updated health to all other clients (if necessary)
			notifyHealthUpdate(client)
			break
		}
	}
}

// Notify all clients about updated health of a player
func notifyHealthUpdate(client *Client) {
	var buffer bytes.Buffer
	buffer.WriteByte(DATA)                 // Packet type
	buffer.WriteByte(ACTION_HEALTH_UPDATE) // Action type for health update

	// Write the player's ID and new health value
	binary.Write(&buffer, binary.LittleEndian, client.ID)
	binary.Write(&buffer, binary.LittleEndian, client.Stats.Health)

	// Send the updated health to all connected clients
	for _, otherClient := range clients {
		_, err := otherClient.TCPConn.Write(buffer.Bytes())
		if err != nil {
			fmt.Println("Error sending health update to client:", err)
		}
	}
}

// Notify all clients that the game has started and send a random seed
func startGame(conn *net.TCPConn) {
	fmt.Println("Received start game packet from client")

	// Generate a random seed based on the current time
	rand.Seed(time.Now().UnixNano()) // Seed the random number generator
	seed := rand.Uint32()            // Generate a random seed (32-bit integer)

	fmt.Printf("Generated seed: %d\n", seed)

	// Broadcast the STARTGAME notification along with the seed to all clients
	for _, client := range clients {
		// Create a buffer to send the STARTGAME packet and seed
		var buffer bytes.Buffer
		buffer.WriteByte(STARTGAME) // Write the STARTGAME packet type

		// Write the generated seed to the buffer (send as a 32-bit unsigned integer)
		binary.Write(&buffer, binary.LittleEndian, seed)

		// Send the packet via TCP to the client
		_, err := client.TCPConn.Write(buffer.Bytes())
		if err != nil {
			fmt.Println("Error sending start game packet to client:", err)
		}
	}

	fmt.Println("Notified all clients that the game has started with seed:", seed)
}

// Handle shooting action from the client
func handleShootPacket(conn *net.TCPConn, data []byte) {
	var bulletID uint16
	var clientID uint16
	var x uint16
	var y uint16
	var direction uint16
	var speed uint16

	// Read bullet data from the packet (skip bullet storage)
	bulletID = binary.LittleEndian.Uint16(data[0:2])   // Bullet unique ID
	clientID = binary.LittleEndian.Uint16(data[2:4])   // Player's client ID
	x = binary.LittleEndian.Uint16(data[4:6])          // X position
	y = binary.LittleEndian.Uint16(data[6:8])          // Y position
	direction = binary.LittleEndian.Uint16(data[8:10]) // Direction of the bullet
	speed = binary.LittleEndian.Uint16(data[10:12])    // Speed

	// Broadcast the shot event to all clients
	broadcastShoot(clientID, bulletID, x, y, direction, speed)
}

// Broadcast the shooting event to all other players
func broadcastShoot(clientID, bulletID, x, y, direction, speed uint16) {
	var buffer bytes.Buffer
	buffer.WriteByte(DATA)         // Packet type: DATA
	buffer.WriteByte(ACTION_SHOOT) // Action type: SHOOT

	// Write bullet data
	binary.Write(&buffer, binary.LittleEndian, bulletID)
	binary.Write(&buffer, binary.LittleEndian, clientID)
	binary.Write(&buffer, binary.LittleEndian, x)
	binary.Write(&buffer, binary.LittleEndian, y)
	binary.Write(&buffer, binary.LittleEndian, direction)
	binary.Write(&buffer, binary.LittleEndian, speed)

	// Send the packet to all clients
	for _, client := range clients {
		_, err := client.TCPConn.Write(buffer.Bytes())
		if err != nil {
			fmt.Println("Error broadcasting shoot event to client:", err)
		}
	}
}

// Handle new client connection via TCP
func handleConnect(conn *net.TCPConn, data []byte) {
	// Read the player's name from the packet (after the packet type)
	nameLength := binary.LittleEndian.Uint16(data) // Read the length of the name
	clientName := string(data[2 : 2+nameLength])   // Read the name itself

	// Assign a new unique ID to the client
	clientCounter++
	clientID := clientCounter

	// Create new client and store it using the client ID as the key
	newClient := &Client{
		ID:       clientID,
		Name:     clientName,
		TCPConn:  conn,
		LastSeen: time.Now(),
		Stats: Stats{
			Health:      100.0,
			Stamina:     100.0,
			Sleep:       100.0,
			Water:       100.0,
			Hunger:      100.0,
			Temperature: 37.0, // (CELSIUS)
		},
	}

	clients[clientID] = newClient // Index by client ID
	tcpConnections[conn] = clientID
	fmt.Printf("New client connected: ID=%d, Name=%s, Address=%s\n", clientID, clientName, conn.RemoteAddr().String())

	// Send the list of all connected clients to the new player
	sendClientList(conn, newClient.ID)

	// Notify all existing clients about the new player
	broadcastNewClient(newClient)
}

// Handle client disconnection via TCP
func handleDisconnect(conn *net.TCPConn) {
	// Get the client ID associated with this connection
	clientID, exists := tcpConnections[conn]
	if !exists {
		fmt.Println("Unknown connection disconnected")
		return
	}

	// Remove the client from the server's client list
	if client, exists := clients[clientID]; exists {
		delete(clients, clientID)
		fmt.Printf("Client %s disconnected, ID: %d\n", client.Name, client.ID)

		// Broadcast the disconnection to all other clients
		broadcastClientDisconnection(client.ID)
	}

	// Remove the TCP connection from the tcpConnections map
	delete(tcpConnections, conn)
}

// Send the current client list to the newly connected player via TCP
func sendClientList(conn *net.TCPConn, newClientID uint16) {
	var buffer bytes.Buffer
	buffer.WriteByte(CONNECT)

	// First, send the new client's own ID so it knows its own identity
	binary.Write(&buffer, binary.LittleEndian, newClientID)

	// Write the number of connected players
	binary.Write(&buffer, binary.LittleEndian, uint16(len(clients)))

	// Send the list of all connected clients (including the new client)
	for _, client := range clients {
		// Write client ID
		binary.Write(&buffer, binary.LittleEndian, client.ID)
		// Write name length
		nameBytes := []byte(client.Name)
		nameLength := uint16(len(nameBytes))
		binary.Write(&buffer, binary.LittleEndian, nameLength)
		// Write the actual name
		buffer.Write(nameBytes)
	}

	// Send the buffer to the new player
	_, err := conn.Write(buffer.Bytes())
	if err != nil {
		fmt.Println("Error sending client list:", err)
	}
}

// Broadcast new client information to all existing players via TCP
func broadcastNewClient(newClient *Client) {
	var buffer bytes.Buffer
	buffer.WriteByte(CONNECT) // Packet type

	// Include the new client's ID at the start
	binary.Write(&buffer, binary.LittleEndian, newClient.ID)

	// Write number of clients (in this case, only 1 because it's the new player being broadcasted)
	binary.Write(&buffer, binary.LittleEndian, uint16(1))

	// Write the new client's ID
	binary.Write(&buffer, binary.LittleEndian, newClient.ID)

	// Write the name length
	nameBytes := []byte(newClient.Name)
	nameLength := uint16(len(nameBytes))
	binary.Write(&buffer, binary.LittleEndian, nameLength)

	// Write the actual name
	buffer.Write(nameBytes)

	// Broadcast this to all other clients
	for _, client := range clients {
		if client.ID != newClient.ID { // Don't send it to the newly connected client
			_, err := client.TCPConn.Write(buffer.Bytes())
			if err != nil {
				fmt.Println("Error sending new client info:", err)
			}
		}
	}
}

// Broadcast disconnection to all connected clients via TCP
func broadcastClientDisconnection(clientID uint16) {
	var buffer bytes.Buffer
	buffer.WriteByte(DISCONNECT) // Packet type: DISCONNECT

	// Write the ID of the client that disconnected
	binary.Write(&buffer, binary.LittleEndian, clientID)

	// Broadcast the disconnection to all clients
	for _, client := range clients {
		_, err := client.TCPConn.Write(buffer.Bytes())
		if err != nil {
			fmt.Println("Error broadcasting client disconnection:", err)
		}
	}
}
