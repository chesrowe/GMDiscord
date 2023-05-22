global.__heartbeatCounter = 0;
global.__indentityHandshake = false;
global.__gatewaySequenceNumber = -1;

enum GATEWAY_OP_CODE {
	dispatch = 0,
	heartbeat = 1,
	identify = 2,
	presenceUpdate = 3,
	voiceStateUpdate = 4,
	resume = 6,
	reconnect = 7,
	requestGuildMembers = 8,
	invalidSession = 9,
	hello = 10,
	heartbeatACK = 11
}

enum DISCORD_PRESENCE_ACTIVITY {
	game,
	streaming,
	listening,
	watching,
	custom,
	competing
}

enum DISCORD_INTERACTION_CALLBACK_TYPE {
	channelMessageWithSource = 4,
	deferredChannelMessageWithSource = 5,
	deferredUpdateMessage = 6,
	updateMessage = 7,
	applicationCommandAutocompleteResult = 8,
	modal = 9
}

/// @func discord_interaction_response(interactionId, interactionToken, callbackType, [content], [callback], [components], [embeds], [tts])
/// @desc Sends a response to the given Discord interaction.
/// @param {string} interactionId The id of the interaction you are responding to
/// @param {string} interactionToken The token of the interaction you are responding to
/// @param {real} callbackType The type of callback, use the enum DISCORD_INTERATION_CALLBACK_TYPE
/// @param {string} content The Message you want to send (Up to 2000 characters). Default: -1
/// @param {function} callback The function to execute for the request's response. Default: -1
/// @param {array} components Array of message component structs to include with the message. Default: -1
/// @param {array} embeds Array of embed structs, up to 10 rich embeds(up to 6000 characters). Default: -1
/// @param {bool} tts Whether or not the message content is text-to-speech. Default: false
function discord_interaction_response(_interactionId, _interactionToken, _callbackType, _content = "", _callback = -1, _components = -1, _embeds = -1, _tts = false){
	// Prepare the url and headers
	var _url = "https://discord.com/api/v10/interactions/" + _interactionId + "/" + _interactionToken + "/callback";
	var _headers = ds_map_create();
	ds_map_add(_headers, "Content-Type", "application/json");
	ds_map_add(_headers, "Authorization", "Bot " + __botToken);

	// Create a struct containing the response data
	var _responseData = {
		type: _callbackType, // 4 represents a response of type "MESSAGE_CONTENT" 
		data: {}
	};

	if (_content != ""){
		variable_struct_set(_responseData.data, "content", _content);	
	}
	
	if (_components != -1){
		variable_struct_set(_responseData.data, "components", _components);		
	}
	
	if (_embeds != -1){			
		// Add embeds to the _responseData.data struct
		variable_struct_set(_responseData.data, "embeds", _embeds);           
	}
	
	if (_tts){
		variable_struct_set(_responseData.data, "tts", true);			
	}

	// Stringify the _responseData struct
	var _body = json_stringify(_responseData);
	
	if (variable_struct_exists(_responseData.data, "content") || variable_struct_exists(_responseData.data, "components") || variable_struct_exists(_responseData.data, "embeds")){
		// If there is any content to send in the response, proceed
	} else {
		show_debug_message("From discord_interaction_response: No response data was given to send");
		return;
	}

	// Send the HTTP request
	var _requestId = http_request(_url, "POST", _headers, _body);
	__discord_add_request_to_sent(_requestId, _callback);

	// Cleanup
	ds_map_destroy(_headers);		
}


