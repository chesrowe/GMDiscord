/// @desc Parses async_load and returns a struct containing the data
function discord_gateWay_event_parse(){
	var _buffer = async_load[? "buffer"];
	buffer_seek(_buffer, buffer_seek_start, 0);

	var _dataJsonString = buffer_read(_buffer, buffer_string);
	return json_parse(_dataJsonString);	
}

/// @desc Parses the async_load map in a HTTP async event into a struct or array. Used in a discordBot method's callback execution
/// @return struct or array
function discord_http_response_parse(){
	return json_parse(json_encode(async_load));	
}

/// @desc Parses the async_load map's "result" key in a HTTP async event which is typically the data you will be working with
/// @return Struct or array
function discord_http_response_result(){
	return json_parse(json_encode(async_load)).result;	
}