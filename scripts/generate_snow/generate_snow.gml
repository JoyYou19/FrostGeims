function generate_snow(_width, _height, _grid_size, _tileset, _seed){
	var _increment = 0.1;
	static start_x = 1000;
	static start_y = 1000;
	
	tilemap_set_width(_tileset,_width);
	tilemap_set_height(_tileset,_height);
	
	for(var i = 0; i < _width; i++){
		var _ypos = start_y;
		for(var j = 0; j < _height; j++){
			
			var _perlin_value = perlin_noise(start_x, _ypos, _seed);
			var _tile_value = map_value(_perlin_value, -1, 1, 0, 1);
			
			if(_tile_value > 0.5){
				// Set the tile to be the snow grass tile
				tilemap_set_at_pixel(_tileset,4,i*80,j*80);
			} else {
				// Set the tile to be just empty snow tile
				tilemap_set_at_pixel(_tileset,3,i*80,j*80);
			}
			
			_ypos += _increment;
		}
		start_x += _increment;
	}
	
	// Loop through the tiles and autotile them
	for(var i = 0; i < _width; i++){
		for(var j = 0; j < _height; j++){
			if(tilemap_get(_tileset,i,j) != 3){
				tilemap_set(_tileset,tile_bitmasking(i,j,_tileset),i,j);
			}
		}
	}
}