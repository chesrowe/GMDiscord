//Creates the persisent controller object 
var _createController = function(){
	instance_create_depth(0, 0, 0, obj_discordController);	
}

var _controllerCreationTimeSource = time_source_create(time_source_global, 1, time_source_units_frames, _createController);

//time_source_start(_controllerCreationTimeSource);