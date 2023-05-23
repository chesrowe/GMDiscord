/// @function discord_response_is_error(jsonString)
/// @description Check if a response from the Discord API is an error message.
/// @param jsonString The JSON string to check.
/// @returns Whether the response represents an error.
function discord_response_is_error(_responseJson) {
   if (!is_string(_responseJson)){
		return true;   
   }
   
   // Parse the JSON string into a ds_map.
    var _response = json_parse(_responseJson);

    // Check if the 'code' and 'errors' keys are present in the response.
    if (variable_struct_exists(_response, "code") && variable_struct_exists(_response, "errors")) {
       // If both keys are present, the response is an error message.
        return true;
    }else{
        // If either key is missing, the response is not an error message.
        return false;
    }
}


/// @desc Parses async_load and returns a struct containing the data
function discord_gateWay_event_parse(){
	var _buffer = async_load[? "buffer"];
	buffer_seek(_buffer, buffer_seek_start, 0);

	var _dataJsonString = buffer_read(_buffer, buffer_string);
	return json_parse(_dataJsonString);	
}