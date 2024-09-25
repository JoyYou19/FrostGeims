var targetX = -1;
var targetY = -1;

if(instance_exists(obj_follow)){
	var _dist = point_distance(obj_follow.x,obj_follow.y,mouse_x,mouse_y);
	var _direction = point_direction(obj_follow.x,obj_follow.y,mouse_x,mouse_y);

	var real_x = obj_follow.x + lengthdir_x(_dist/10,_direction);
	var real_y = obj_follow.y + lengthdir_y(_dist/10,_direction);

	targetX = real_x-camera_w/2;
	targetY = real_y-camera_h/2;
	
	targetX = clamp(targetX,0,120*80);
	targetY = clamp(targetY,0,120*80);
}

camera_x = lerp(camera_x, targetX, CAM_SMOOTH);
camera_y = lerp(camera_y, targetY, CAM_SMOOTH);

var shake = power(shakeValue, 2) * shakePower;
xshake = random_range(-shake, shake);
yshake = random_range(-shake, shake);
camera_x += xshake;
camera_y += yshake;
	
camera_set_view_pos(camera,camera_x,camera_y);
camera_set_view_size(camera,camera_w,camera_h);
camera_set_view_angle(camera,random_range(-shake,shake)*0.5);

if(shakeValue > 0) {
	shakeValue -= 0.1;
}
