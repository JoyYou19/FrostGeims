switch(global.current_ui){
	case UI.NONE:
		draw_stats();
	break;
	
	case UI.INVENTORY:
		draw_inventory();
	break;
}

if keyboard_check_pressed(vk_tab){
	if (global.current_ui == UI.NONE) { global.current_ui = UI.INVENTORY return };
	
	global.current_ui = UI.NONE return;
}