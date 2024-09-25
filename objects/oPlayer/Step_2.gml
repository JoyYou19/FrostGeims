if(global.client_id == player_id){
	
	if(x < xprevious){
		sprite_index = sPlayerWalk;
		image_xscale = -1;
	}

	if(x > xprevious){
		sprite_index = sPlayerWalk;
		image_xscale = 1;
	}
	
	if(y != yprevious){
		sprite_index = sPlayerWalk;
	}
}

if(x == xprevious && y == yprevious) sprite_index = sPlayer;