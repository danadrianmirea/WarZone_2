extends Control

onready var connect_button = get_node("Button")
onready var ip_address = get_node("container/ip_address")

var network = null


func _ready():
	connect_button.connect("pressed", self, "_on_connect_pressed")
	var server_listener = load("res://scripts/networking/ServerListener.gd").new()
	add_child(server_listener)


func _on_connect_pressed():
	network = load("res://scripts/networking/Network.gd").new()
	get_tree().root.add_child(network)
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_success", self, "_on_connection_success")
	network.connectToServer(ip_address.text)


func _on_connection_failed():
	print("JoinGame::Failed to connect to server")
	network.queue_free()
	network = null


func _on_connection_success():
	print("JoinGame::Connected to server")
	var level_manager = load("res://scripts/general/LevelManager.gd").new()
	get_tree().root.add_child(level_manager)
	level_manager.joinLevel()
	queue_free()
