/// @function __discord_response_is_error(jsonString)
/// @description Check if a response from the Discord API is an error message.
/// @param jsonString The JSON string to check.
/// @returns Whether the response represents an error.
function __discord_response_is_error(_responseJson) {
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

/// @Func __discord_error_print(json)
/// @param {string} discordResponse The JSON response from the Discord API
function __discord_error_print(_discordResponse){
    var _error = json_parse(_discordResponse);
	var _errorMessageToOutput = "Something is wrong with your HTTP request!\n"; 
    
    // Check if the main error fields exist
    if (variable_struct_exists(_error, "code") && variable_struct_exists(_error, "message")) {
        _errorMessageToOutput += "Error Code: " + string(_error.code) + "\n";
        _errorMessageToOutput += "Message: " + _error.message  + "\n";
    }
    
    // Check if the 'errors' object exists
    if (variable_struct_exists(_error, "errors")) {
        var _errorDetails = _error.errors;
        
        // Iterate over the keys in the 'errors' struct
        var _keys = variable_struct_get_names(_errorDetails);
        for (var i = 0; i < array_length(_keys); i++) {
            var _key = _keys[i];
            var _detail = variable_struct_get(_errorDetails, _key);
            
            // Check if the detail error fields exist
            if (variable_struct_exists(_detail, "_errors")) {
                var _errorsArray = _detail._errors;
                
                // Iterate over the errors in the '_errors' array
                for (var j = 0; j < array_length(_errorsArray); j++) {
                    var _errorItem = _errorsArray[j];
                    
                    // Check if the error item fields exist
                    if (variable_struct_exists(_errorItem, "code") && variable_struct_exists(_errorItem, "message")) {
                        _errorMessageToOutput += "Detail Error Code: " + string(_errorItem.code) + "\n";
                        _errorMessageToOutput += "Detail Message: " + _errorItem.message + "\n";
                    }
                }
            }
        }
    }
	
	__discordTrace(_errorMessageToOutput);
}


/// @desc Parses async_load and returns a struct containing the data
function discord_gateWay_event_parse(){
	var _buffer = async_load[? "buffer"];
	buffer_seek(_buffer, buffer_seek_start, 0);

	var _dataJsonString = buffer_read(_buffer, buffer_string);
	return json_parse(_dataJsonString);	
}