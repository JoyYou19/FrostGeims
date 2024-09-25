package main

import (
	"encoding/binary"
	"fmt"
	"net"
	"time"
)

const (
	CONNECT = iota
	DATA
	DISCONNECT
	STARTGAME
)

const (
	ACTION_MOVE = iota
)

type Client struct {
	ID       uint16
	Name     string
	Address  *net.UDPAddr
	TCPConn  *net.TCPConn
	LastSeen time.Time
	X        uint16
	Y        uint16
	Stats    Stats
}

type Stats struct {
	Health      float32
	Stamina     float32
	Sleep       float32
	Water       float32
	Hunger      float32
	Temperature float32
}

var clients = make(map[uint16]*Client)
var clientCounter uint16 = 0 // Unique client ID counter

// Map to track TCP connections and associated client IDs
var tcpConnections = make(map[*net.TCPConn]uint16)

func main() {
	// Start UDP server
	Server()
}

// Function to start the UDP server
func Server() {
	go startUDPServer()
	startTCPServer()
}

// Start the UDP server for handling fast real-time data (like movement)
func startUDPServer() {
	address, err := net.ResolveUDPAddr("udp", ":12345")
	if err != nil {
		fmt.Println("Error resolving UDP address:", err)
		return
	}

	conn, err := net.ListenUDP("udp", address)
	if err != nil {
		fmt.Println("Error starting UDP server:", err)
		return
	}
	defer conn.Close()

	fmt.Println("UDP server started on port 12345...")

	buffer := make([]byte, 1024)

	for {
		n, addr, err := conn.ReadFromUDP(buffer)
		if err != nil {
			fmt.Println("Error reading from UDP connection:", err)
			continue
		}

		packetType := int(buffer[0]) // First byte is the packet type
		handlePacket(packetType, addr, conn, buffer[:n])
	}
}

// Handle incoming packets
func handlePacket(packetType int, addr *net.UDPAddr, conn *net.UDPConn, data []byte) {
	switch packetType {
	case DATA:
		handleDataPacket(addr, conn, data[1:])
	case CONNECT:
		handleUDPHandshake(addr, conn, data[1:])
	default:
		fmt.Println("Unknown packet type received")
	}
}

// Handle UDP handshake to assign UDP address
func handleUDPHandshake(addr *net.UDPAddr, conn *net.UDPConn, data []byte) {
	// Read the client ID from the UDP packet (starting after packet type)
	clientID := binary.LittleEndian.Uint16(data[0:2])

	// Find the client using the client ID and update the UDP address
	for _, client := range clients {
		if client.ID == clientID {
			client.Address = addr // Store the UDP address
			fmt.Printf("Client %s (ID: %d) UDP address set to %s\n", client.Name, client.ID, addr.String())
			break
		}
	}
}
