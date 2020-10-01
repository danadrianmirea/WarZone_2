extends CanvasLayer


var mode_settings = {
	round_time = 8, # Round time limit in minutes
	max_score = 500
}

var CP_minimap = preload("res://Objects/Game_modes/CheckPoints/CPMinimap.tscn")

var time_elasped = 0
var focused_point = null
var teams = Array()

onready var timer_label = $top_panel/Label
onready var points_node = $top_panel/points
onready var progress_bar = $top_panel/ProgressBar
onready var t_score_label = $top_panel/t/Label
onready var ct_score_label = $top_panel/ct/Label 
onready var level = get_tree().get_nodes_in_group("Level")[0]
onready var checkpoints = get_tree().get_nodes_in_group("CheckPoint")


func _ready():
	# Get teams and index them acording to team_id
	var _teams = get_tree().get_nodes_in_group("Team")
	if _teams[0].team_id == 0:
		teams = _teams
	else:
		teams.append(_teams[1])
		teams.append(_teams[0])
	
	for i in checkpoints:
		i.connect("team_captured_point", self, "P_on_team_captured_point")
		i.connect("local_player_entered", self, "P_on_local_player_entered")
		i.connect("local_player_exited", self, "P_on_local_player_exited")
	
	level.connect("player_created", self, "P_on_player_joined")
	
	if get_tree().is_network_server():
		level.connect("player_created", self, "S_on_unit_joined")
		level.connect("bot_created", self, "S_on_unit_joined")
		$Delays/updateScore_dl.start()


func _on_Timer_timeout():
	time_elasped += 1
	rpc_unreliable("P_syncTime", time_elasped)


remotesync func P_syncTime(time : int):
	time_elasped = time
	# Show time remaining in panel
	var time_limit = mode_settings.round_time * 60
	var _min_ : int = (time_limit - time)/60.0
	var _sec_ : int = int(time_limit - time) % 60
	timer_label.text = String(_min_) + " : " + String(max(_sec_,0))


func P_on_team_captured_point(point):
	var rect = points_node.get_node(String(point.id))
	if point.holding_team == 0:
		rect.color = Color8(201, 55, 31)
	else:
		rect.color = Color8(17,64, 194)


func P_on_local_player_entered(point):
	focused_point = point
	progress_bar.value = point.value
	progress_bar.max_value = point.max_points
	progress_bar.show()


func P_on_local_player_exited():
	focused_point = null
	progress_bar.hide()


func _process(_delta):
	if focused_point:
		progress_bar.value = focused_point.value


func P_on_player_joined(plr):
	if plr.is_network_master():
		var minimap_panel = plr.hud.get_node("Minimap")
		var minimap = minimap_panel.get_node("Minimap")
		var new_minimap = CP_minimap.instance()
		new_minimap.name = "Minimap"
		new_minimap.rect_size = minimap.rect_size
		minimap.queue_free()
		minimap_panel.add_child(new_minimap)
		print("Loaded Custom minimap")



func S_on_unit_joined(unit):
	if unit.is_in_group("Bot"):
		unit.connect("bot_killed",self,"S_on_unit_killed")
	else:
		unit.connect("player_killed",self,"S_on_unit_killed")


func S_on_unit_killed(unit):
	unit.get_node("respawn_timer").start()



func _on_updateScore_dl_timeout():
	for i in checkpoints:
		if teams[0].team_id == i.holding_team:
			teams[0].score += 1
		elif teams[1].team_id == i.holding_team:
			teams[1].score += 1
	
	rpc("P_update_displayScore", teams[0].score, teams[1].score)



remotesync func P_update_displayScore(t_scr, ct_scr):
	teams[0].score = t_scr
	teams[1].score = ct_scr
	
	t_score_label.text = String(t_scr)
	ct_score_label.text = String(ct_scr)

