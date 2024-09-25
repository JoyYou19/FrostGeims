package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"net"
)

func handleDataPacket(addr *net.UDPAddr, conn *net.UDPConn, data []byte) {
	// Read the action type (second byte in the packet)
	actionType := int(data[0])

	switch actionType {
	case ACTION_MOVE:
		handleMoveAction(addr, conn, data[1:])
	default:
		fmt.Println("Unknown action type received")
	}
}

func handleMoveAction(addr *net.UDPAddr, conn *net.UDPConn, data []byte) {
	// Read the client ID (first 2 bytes)
	clientID := binary.LittleEndian.Uint16(data[0:2])

	// Read the x and y coordinates (next 2 bytes each)
	x := binary.LittleEndian.Uint16(data[2:4])
	y := binary.LittleEndian.Uint16(data[4:6])

	// Find the client based on clientID and update their position
	if client, exists := clients[clientID]; exists { // Change to clientID lookup
		client.X = x
		client.Y = y
		clients[clientID] = client // Update the client information

		// Broadcast the updated position to all other clients
		broadcastPlayerMovement(conn, clientID, x, y)
	} else {
		fmt.Println("Client not found for ID:", clientID)
	}
}

func broadcastPlayerMovement(conn *net.UDPConn, clientID uint16, x uint16, y uint16) {
	for _, client := range clients {
		if client.ID != clientID { // Don't send to the client who sent the movement packet
			var buffer bytes.Buffer
			buffer.WriteByte(DATA)        // Packet type: DATA
			buffer.WriteByte(ACTION_MOVE) // Action type: MOVE

			// Write the client ID and the new coordinates
			binary.Write(&buffer, binary.LittleEndian, clientID)
			binary.Write(&buffer, binary.LittleEndian, x)
			binary.Write(&buffer, binary.LittleEndian, y)

			// Send the movement update to the other clients
			_, err := conn.WriteToUDP(buffer.Bytes(), client.Address)
			fmt.Println("Broadcasting player moevement:", client.Address)
			if err != nil {
				fmt.Println("Error broadcasting player movement:", err)
			}
		}
	}
}
