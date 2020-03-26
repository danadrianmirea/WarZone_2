extends Panel

var selected_btn = null




func _on_spec_pressed():
	if selected_btn:
		if selected_btn != $container/spec:
			$container/spec.self_modulate = selected_btn.self_modulate
			selected_btn.self_modulate = Color8(255,255,255,255)
			selected_btn = $container/spec
			changePanelTween("spec_panel")
	else:
		selected_btn = $container/spec
		selected_btn.self_modulate = Color8(66,210,41,255)
		changePanelTween("spec_panel")


func _on_quit_pressed():
	if selected_btn:
		if selected_btn != $container/quit:
			$container/quit.self_modulate = selected_btn.self_modulate
			selected_btn.self_modulate = Color8(255,255,255,255)
			selected_btn = $container/quit
			changePanelTween("exit_panel")
	else:
		selected_btn = $container/quit
		selected_btn.self_modulate = Color8(66,210,41,255)
		changePanelTween("exit_panel")


########################Tweeeeening#######################################

var selected_panel = null
onready var panel_pos = $panel_pos.position

func changePanelTween(node_name : String):
	var node = get_node(node_name)
	if node == selected_panel:
		print("Error same node")
		return
	var delay = 0.0
	$Tween.remove_all()
	if selected_panel:
		delay = 0.2
		selected_panel.rect_position = panel_pos
		$Tween.interpolate_property(selected_panel,"rect_position",selected_panel.rect_position,
			selected_panel.rect_position + Vector2(550,0),0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	
	node.rect_position = panel_pos - Vector2(0,550)
	$Tween.interpolate_property(node,"rect_position",node.rect_position,panel_pos,
		0.5,Tween.TRANS_QUAD,Tween.EASE_OUT,delay)
	selected_panel = node
	$Tween.start()
