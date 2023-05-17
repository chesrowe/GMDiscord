/// @func discordBot(botToken, [useGatewayEvents])
/// @desc Create a new discord bot struct with the given token
/// @param {string} botToken Your bot's token found here https://discord.com/developers/applications
/// @param {bool} useGatewayEvents Whether or not to set up a gateway connect for this bot
function discordBot(_botToken, _useGatewayEvents = false) constructor {
	array_push(obj_discordController.botArray, self);
	__botToken = _botToken;
	
	#region messageSend(channelId, [content], [callback], [components], [embeds], [stickerIds], [files])
	
	/// @func messageSend(channelId, [content], [callback], [components], [embeds], [stickerIds], [files])
	/// @desc Sends a message to the given Discord channel. Must include at least one of the following: message, components, embeds, stickerIds, or files
	/// @param {string} channelId The id of the channel that the message is being sent to
	/// @param {string} content The Message you want to send (Up to 2000 characters)
	/// @param {function} callback The function to execute for the request's response. Default: -1
	/// @param {array} components Array of message component structs to include with the message. Default: -1
	/// @param {array} embeds Array of embed structs, up to 10 rich embeds(up to 6000 characters). Default: -1
	/// @param {array} stickerIds Array of snowflakes, IDs of up to 3 stickers in the server to send in the message. Default: -1
	/// @param {array} files Array of discordFile structs to send
	/// @param {bool} tts Whether or not the message content is text-to-speech
	static messageSend = function(_channelId, _content = "", _callback = -1, _components = -1, _embeds = -1, _stickerIds = -1, _files = -1, _tts = false){
		// Prepare the url and headers
		var _url = "https://discord.com/api/v10/channels/" + _channelId + "/messages";
		var _boundary = "----GMLBoundary" + string(random(1000000000));
		var _headers = ds_map_create();
		ds_map_add(_headers, "Content-Type", "multipart/form-data; boundary=" + _boundary);
		ds_map_add(_headers, "Authorization", "Bot " + __botToken);

		// Create a struct containing the message data
		var _bodyData = {};
	
		if (_content != ""){
			variable_struct_set(_bodyData, "content", _content);	
		}
	
		if (_components != -1){
			variable_struct_set(_bodyData, "components", _components);		
		}
	
		if (_embeds != -1){			
			if (_files != -1){
				//Assign ids to attachments
				var _i = 0;
			
				var _fileArrayLength = array_length(_files);
			
				repeat(_fileArrayLength){
					var _currentFile = _files[_i];
				
					_currentFile.__id = _i;
					_i++;	
				}
			
		        // Find any instances of attachment URLs in the embeds
			    var _authorAttachments = __discord_find_attachments(_embeds, "author", "icon_url", _files);
				var _footerAttachments = __discord_find_attachments(_embeds, "footer", "icon_url", _files);
			    var _attachments = array_merge(_authorAttachments, _footerAttachments);

			    // Add attachments to the _bodyData struct
			    if (array_length(_attachments) > 0) {
			        variable_struct_set(_bodyData, "attachments", _attachments);
			    }
			}
		    
			// Add embeds to the _bodyData struct
		    variable_struct_set(_bodyData, "embeds", _embeds);           
	    }
	
		if (_stickerIds != -1){
			variable_struct_set(_bodyData, "stickerIds", _stickerIds);			
		}
	
		if (_tts){
			variable_struct_set(_bodyData, "tts", true);			
		}

		// Create the multipart/form-data body content
		var _body = "";
	
		if (variable_struct_exists(_bodyData, "content") || variable_struct_exists(_bodyData, "components") || variable_struct_exists(_bodyData, "embeds") || variable_struct_exists(_bodyData, "stickerIds")){
			_body += "--" + _boundary + "\r\n";
			_body += "Content-Disposition: form-data; name=\"payload_json\"\r\n";
			_body += "Content-Type: application/json\r\n\r\n";
			_body += json_stringify(_bodyData) + "\r\n";
		} else {
			show_debug_message("From .messageSend: No message data was given to send");
			return;
		}
	
		// Add files to the multipart/form-data body
		if (_files != -1 && is_array(_files)){
			var _i = 0;
			var _filesArrayLength = array_length(_files);
		
			repeat(_filesArrayLength){
				var _currentFile = _files[_i];
				var _fileBuffer = buffer_load(_currentFile.__filePath);
				var _fileBase64 = buffer_base64_encode(_fileBuffer, 0, buffer_get_size(_fileBuffer));
				buffer_delete(_fileBuffer);
			
				_body += "--" + _boundary + "\r\n";
				_body += "Content-Disposition: form-data; name=\"files[" + string(_i) + "]\"; filename=\"" + _currentFile.__fileName + "\"\r\n";
				_body += "Content-Type: " + "image/png" + "\r\n";
				_body += "Content-Transfer-Encoding: base64\r\n\r\n";
				_body += _fileBase64 + "\r\n";
			
				_i++;	
			}
		}
	
		_body += "--" + _boundary + "--\r\n";

		// Send the HTTP request
		var _requestId = http_request(_url, "POST", _headers, _body);
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);		
	}
	
	#endregion
	
	#region messageEdit(channelId, messageId, [content], [callback], [components], [embeds], [attachments], [files])
	
	/// @func messageEdit(channelId, messageId, [content], [callback], [components], [embeds], [attachments], [files])
	/// @desc Edits a message in the given Discord channel. Must include at least one of the following: message, components, embeds, attachments, or files
	/// @param {string} channelId The id of the channel where the message is located
	/// @param {string} messageId The id of the message to be edited
	/// @param {string} content The new message content (Up to 2000 characters)
	/// @param {function} callback The function to execute for the request's response. Default: -1
	/// @param {array} components Array of message component structs to include with the message. Default: -1
	/// @param {array} embeds Array of embed structs, up to 10 rich embeds(up to 6000 characters). Default: -1
	/// @param {array} attachments Array of existing attachment objects to keep. Default: -1
	/// @param {array} files Array of discordFile structs to send
	static messageEdit = function(_channelId, _messageId, _content = "", _callback = -1, _components = -1, _embeds = -1, _attachments = -1, _files = -1){
		// Prepare the url and headers
		var _url = "https://discord.com/api/v10/channels/" + _channelId + "/messages/" + _messageId;
		var _boundary = "----GMLBoundary" + string(random(1000000000));
		var _headers = ds_map_create();
		ds_map_add(_headers, "Content-Type", "multipart/form-data; boundary=" + _boundary);
		ds_map_add(_headers, "Authorization", "Bot " + __botToken);

		// Create a struct containing the message data
		var _bodyData = {};
	
		if (_content != ""){
			variable_struct_set(_bodyData, "content", _content);	
		}
	
		if (_components != -1){
			variable_struct_set(_bodyData, "components", _components);		
		}
	
		if (_embeds != -1){			
			if (_files != -1){
				//Assign ids to attachments
				var _i = 0;
			
				var _fileArrayLength = array_length(_files);
			
				repeat(_fileArrayLength){
					var _currentFile = _files[_i];
				
					_currentFile.__id = _i;
					_i++;	
				}
			}
			
			// Add embeds to the _bodyData struct
			variable_struct_set(_bodyData, "embeds", _embeds);           
		}
		
		if (_attachments != -1){
			variable_struct_set(_bodyData, "attachments", _attachments);		
		}

		// Create the multipart/form-data body content
		var _body = "";
	
		if (variable_struct_exists(_bodyData, "content") || variable_struct_exists(_bodyData, "components") || variable_struct_exists(_bodyData, "embeds") || variable_struct_exists(_bodyData, "attachments")){
			_body += "--" + _boundary + "\r\n";
			_body += "Content-Disposition: form-data; name=\"payload_json\"\r\n";
			_body += "Content-Type: application/json\r\n\r\n";
			_body += json_stringify(_bodyData) + "\r\n";
		} else {
			show_debug_message("From .messageEdit: No message data was given to edit");
			return;
		}
	
		// Add files to the multipart/form-data body
		if (_files != -1 && is_array(_files)){
			var _i = 0;
			var _filesArrayLength = array_length(_files);
		
			repeat(_filesArrayLength){
				var _currentFile = _files[_i];
				var _fileBuffer = buffer_load(_currentFile.__filePath);
				var _fileBase64 = buffer_base64_encode(_fileBuffer, 0, buffer_get_size(_fileBuffer));
				buffer_delete(_fileBuffer);
			
				_body += "--" + _boundary + "\r\n";
				_body += "Content-Disposition: form-data; name=\"files[" + string(_i) + "]\"; filename=\"" + _currentFile.__fileName + "\"\r\n";
				_body += "Content-Type: " + "image/png" + "\r\n";
				_body += "Content-Transfer-Encoding: base64\r\n\r\n";
				_body += _fileBase64 + "\r\n";
			
				_i++;	
			}
		}
	
		_body += "--" + _boundary + "--\r\n";

		// Send the HTTP request
		var _requestId = http_request(_url, "PATCH", _headers, _body);
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);		
	}

	
	#endregion
	
	#region messageDelete(channelId, messageId, [callback])
	
	/// @func messageDelete(channelId, messageId, [callback])
	/// @desc Deletes a message from the given Discord channel
	/// @param {string} channelId The id of the channel that the message is being deleted from
	/// @param {string} messageId The id of the message to delete
	/// @param {function} callback The function to execute for the request's response. 
	static messageDelete = function(_channelId, _messageId, _callback = -1){
		__discord_send_http_request_standard("channels/" + _channelId + "/messages/" + _messageId, "DELETE", -1, __botToken, _callback);
	}

	#endregion
	
	#region messageDeleteBulk(channelId, messages, [callback])
	
	/// @func messageDeleteBulk(channelId, messages, [callback])
	/// @desc Deletes multiple messages in a single request
	/// @param {string} channelId The id of the channel containing the messages to be deleted
	/// @param {array} messages Array of message IDs to be deleted
	static messageDeleteBulk = function(_channelId, _messages, _callback = -1){
	    // Create a struct containing the message IDs
	    var _bodyData = {
	        messages: _messages
	    };

		__discord_send_http_request_standard("channels/" + _channelId + "/messages/bulk-delete", "POST", _bodyJson, __botToken, _callback);
	}

	#endregion
	
	#region messageGet(channelId, messageId, [callback])
	
	/// @func messageGet(channelId, messageId, [callback])
	/// @desc Retrieves a specific message in the channel
	/// @param {string} channelId The id of the channel that the message is in
	/// @param {string} messageId The id of the message you want to get
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messageGet = function(_channelId, _messageId, _callback = -1){
		// Prepare the url and headers
		var _url = "https://discord.com/api/v10/channels/" + _channelId + "/messages/" + _messageId;
		var _headers = ds_map_create();
		ds_map_add(_headers, "Authorization", "Bot " + __botToken);
		
		// Send the HTTP request
		var _requestId = http_request(_url, "GET", _headers, "");
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);
		
		__discord_send_http_request_standard("channels/" + _channelId + "/messages/" + _messageId, "GET", -1, __botToken, _callback);
	}

	
	#endregion
	
	#region messageGetBulk(channelId, [limit], [callback])
	
	/// @func messageGetBulk(channelId, [limit], [callback])
	/// @desc Fetches multiple messages in a channel
	/// @param {string} channelId The id of the channel from which to fetch the messages
	/// @param {real} limit The number of messages to fetch (1-100). Default: 50
	/// @param {function} callback The function to execute for the request's response. 
	static messageGetBulk = function(_channelId, _limit = 50, _callback = -1) {
		var _clampedLimit = clamp(_limit, 1, 100);
		
		// Prepare the url and headers
		var _urlEnpoint = "channels/" + _channelId + "/messages?limit=" + string(int64(_clampedLimit));
		__discord_send_http_request_standard(_urlEnpoint, "GET", -1, __botToken, _callback);
	}
	
	#endregion	
	
	#region messageGetPinned(channelId, [callback])
	
	/// @func messageGetPinned(channelId, [callback])
	/// @desc Retrieves all pinned messages in the given Discord channel
	/// @param {string} channelId The id of the channel that the pinned messages are being retrieved from
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messageGetPinned = function(_channelId, _callback = -1) {
		// Prepare the url and headers
		var _url = "https://discord.com/api/v10/channels/" + _channelId + "/pins";
		var _headers = ds_map_create();
		ds_map_add(_headers, "Content-Type", "application/json");
		ds_map_add(_headers, "Authorization", "Bot " + __botToken);

		// Send the HTTP request
		var _requestId = http_request(_url, "GET", _headers, "");
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);
	}
	
	#endregion
	
	#region messagePin(channelId, messageId, [callback])
	
	/// @func messagePin(channelId, messageId, [callback])
	/// @desc Pins a message in the given Discord channel
	/// @param {string} channelId The id of the channel where the message is located
	/// @param {string} messageId The id of the message to pin
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messagePin = function(_channelId, _messageId, _callback = -1){
		// Prepare the url and headers
		var _url = "https://discord.com/api/v10/channels/" + _channelId + "/pins/" + _messageId;
		var _headers = ds_map_create();
		ds_map_add(_headers, "Content-Type", "application/json");
		ds_map_add(_headers, "Authorization", "Bot " + __botToken);

		// Send the HTTP request
		var _requestId = http_request(_url, "PUT", _headers, "");
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);		
	}
	
	#endregion
	
	#region messageUnpin(channelId, messageId, [callback])

	/// @func messageUnpin(channelId, messageId, [callback])
	/// @desc Unpins a message from the given Discord channel
	/// @param {string} channelId The id of the channel that the message is being unpinned from
	/// @param {string} messageId The id of the message to unpin
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messageUnpin = function(_channelId, _messageId, _callback = -1) {
		// Prepare the url and headers
		var _url = "https://discord.com/api/v10/channels/" + _channelId + "/pins/" + _messageId;
		var _headers = ds_map_create();
		ds_map_add(_headers, "Authorization", "Bot " + __botToken);

		// Send the HTTP request
		var _requestId = http_request(_url, "DELETE", _headers, "");
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);
	}

	#endregion
	
	#region messageCrosspost(channelId, messageId, [callback])
	
	/// @func messageCrosspost(channelId, messageId, [callback])
	/// @desc Crossposts a message in a News Channel to following channels
	/// @param {string} channelId The id of the channel that the message is being crossposted from
	/// @param {string} messageId The id of the message to crosspost
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messageCrosspost = function(_channelId, _messageId, _callback = -1){
		// Prepare the url and headers
		var _url = "https://discord.com/api/v10/channels/" + _channelId + "/messages/" + _messageId + "/crosspost";
		var _headers = ds_map_create();
		ds_map_add(_headers, "Content-Type", "application/json");
		ds_map_add(_headers, "Authorization", "Bot " + __botToken);

		// Send the HTTP request
		var _requestId = http_request(_url, "POST", _headers, "");
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);
	}

	#endregion
	
	#region reactionCreate(channelId, messageId, emoji, [callback])
	
	/// @func reactionCreate(channelId, messageId, emoji, [callback])
	/// @desc Adds a reaction to a message in a given Discord channel
	/// @param {string} channelId The id of the channel that contains the message
	/// @param {string} messageId The id of the message to add the reaction to
	/// @param {string} emoji The emoji to use for the reaction
	static reactionCreate = function(_channelId, _messageId, _emoji, _callback = -1) {
	    // Prepare the URL and headers
	    var _url = "https://discord.com/api/v10/channels/" + _channelId + "/messages/" + _messageId + "/reactions/" + __url_encode(_emoji) + "/@me";
	    var _headers = ds_map_create();
	    ds_map_add(_headers, "Authorization", "Bot " + __botToken);

	    // Send the HTTP request
	    var _requestId = http_request(_url, "PUT", _headers, "");
	    __discord_add_request_to_sent(_requestId, _callback);

	    // Cleanup
	    ds_map_destroy(_headers);
	}

	#endregion
	
	#region triggerTypingIndicator(channelId, [callback])
	
	/// @func triggerTypingIndicator(channelId, [callback])
	/// @desc Triggers the typing indicator for the bot in the given Discord channel
	/// @param {string} channelId The id of the channel where the typing indicator will be shown
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static triggerTypingIndicator = function(_channelId, _callback = -1){
		// Prepare the url and headers
		var _url = "https://discord.com/api/v10/channels/" + _channelId + "/typing";
		var _headers = ds_map_create();
		ds_map_add(_headers, "Content-Type", "application/json");
		ds_map_add(_headers, "Authorization", "Bot " + __botToken);

		// Send the HTTP request
		var _requestId = http_request(_url, "POST", _headers, "");
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);		
	}
	
	#endregion
	
	#region Gateway event functions
	
	/// @func interactionResponseSend(interactionId, interactionToken, callbackType, [content], [callback], [components], [embeds], [tts])
	/// @desc Sends a response to the given Discord interaction.
	/// @param {string} interactionId The id of the interaction you are responding to
	/// @param {string} interactionToken The token of the interaction you are responding to
	/// @param {real} callbackType The type of callback, use the enum DISCORD_INTERATION_CALLBACK_TYPE
	/// @param {string} content The Message you want to send (Up to 2000 characters). Default: -1
	/// @param {function} callback The function to execute for the request's response. Default: -1
	/// @param {array} components Array of message component structs to include with the message. Default: -1
	/// @param {array} embeds Array of embed structs, up to 10 rich embeds(up to 6000 characters). Default: -1
	/// @param {bool} tts Whether or not the message content is text-to-speech. Default: false
	function interactionResponseSend(_interactionId, _interactionToken, _callbackType, _content = "", _callback = -1, _components = -1, _embeds = -1, _tts = false){
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

		// Send the HTTP request
		var _requestId = http_request(_url, "POST", _headers, _body);
		__discord_add_request_to_sent(_requestId, _callback);

		// Cleanup
		ds_map_destroy(_headers);		
	}
	
	/// presenceSend(activity, status)
	/// @param activity
	/// @param status
	static presenceSend = function(_activities, _status) {
	    var _payload = {
	        op: GATEWAY_OP_CODE.presenceUpdate,
	        d: {
	            since: int64(date_current_datetime()),
	            activities: _activities,
	            status: _status,
	            afk: false
	        }
	    };

	    __gatewayEventSend(_payload);
	}

	
	if (_useGatewayEvents){
		var _url = "wss://gateway.discord.gg/?v=10&encoding=json";
		__gatewaySocket = network_create_socket_ext(network_socket_wss, 443);
		__gatewayConnection = network_connect_raw_async(__gatewaySocket, _url, 443);	
	}else{
		__gatewaySocket = -1;
		__gatewayConnection = -1;	
	}
	
	__gatewayHeartbeatCounter = 0;
	__gatewayIndentityHandshake = false;
	__gatewaySequenceNumber = -1;
	__gatewayResumeUrl = "";
	__gatewaySessionId = ""
	gatewayEventCallbacks = {};
	
	/// @func __gatewaySendHeartbeat()
	/// @desc Sends a heartbeat to the Discord gateway to keep the connection alive
	function __gatewaySendHeartbeat(){
		var _payload = {
			op: GATEWAY_OP_CODE.heartbeat,
			d : (__gatewaySequenceNumber == -1) ? pointer_null : __gatewaySequenceNumber
		};	

		__gatewayEventSend(_payload);
	
		__gatewayHeartbeatCounter++;
		
		if (!__gatewayIndentityHandshake && __gatewayHeartbeatCounter > 0){
			__gatewaySendIdentity();	
		}
	}
	
	/// @func __gatewaySendIdentity()
	/// @desc after a heartbeat is established with the gateway, an indentity must be sent to finish setting up the connection
	function __gatewaySendIdentity() {
		var _botToken = __botToken;
	
	    var _payload = {
	        op: GATEWAY_OP_CODE.identify,
	        d: {
	            token: _botToken,
				intents: int64(513),
	            properties: {
					os: "Windows",
					browser: "BOT",
					device: "BOT"
	            },
	        }
	    };

		__gatewayEventSend(_payload);
	}
	
	/// @func __gatewayEventSend(payloadStruct)
	/// @desc Takes a struct, encodes it, and sends it to the Discord event
	function __gatewayEventSend(_payloadStruct){
		var _payloadString = json_stringify(_payloadStruct);
		var _payloadBuffer = buffer_create(0, buffer_grow, 1);
		buffer_write(_payloadBuffer, buffer_string, _payloadString);
		var _payloadBufferTrimmed = __trim_buffer(_payloadBuffer);
		network_send_raw(__gatewaySocket, _payloadBufferTrimmed, buffer_get_size(_payloadBufferTrimmed), network_send_text);
		buffer_delete(_payloadBufferTrimmed);		
	}
	
	#endregion
	
} 

enum DISCORD_COMPONENT_TYPE {
    actionRow = 1,
    button = 2,
    stringSelectMenu = 3
}

enum DISCORD_BUTTON_STYLE {
    primary = 1,
    secondary = 2,
    success = 3,
    danger = 4,
    link = 5
}

#region Other classes

/// @func discordMessageComponent(type, [style], [label], [emoji], [customId], [url], [options])
/// @desc Creates a new Discord message component.
/// @param {enum.ComponentType} type - The component type (ActionRow, Button, SelectMenu).
/// @param {enum.ButtonStyle} style - The button style (Primary, Secondary, Success, Danger, Link).
/// @param {string} label - The visible text on the button.
/// @param {struct.emoji} emoji - The emoji object with "name", "id", and "animated" properties.
/// @param {string} customId - The custom identifier for the component.
/// @param {string} url - The URL for the Link button style (Link).
/// @param {Array} components Array of sub-components
/// @param {Array} options - The options for the Select Menu component (array of discordMessageComponent structs with "label", "value", "description", "emoji", and "default" properties).
function discordMessageComponent(_type, _style = -1, _label = "", _emoji = -1, _customId = "id", _url = "", _components = -1, _options = -1) constructor {
    // Component type (ActionRow, Button, SelectMenu)
    type = _type;

    // Button Style (Primary, Secondary, Success, Danger, Link)
	if (_style != -1){
		style = _style;
	}

    // Button Label (visible text on the button)
    label = _label;

    // Emoji object with "name", "id", and "animated" properties
	if (_emoji != -1){
		emoji = _emoji;
	}

    // Custom identifier for the component
    custom_id = _customId;

    // URL for Link button style (Link)
    if (_url != ""){
		url = _url;
	}
	
	// Sub-components
	if (_components != -1){
		components = _components;
	}

    // Options for the Select Menu component (array of discordMessageComponentOption structs 
	if (_options != -1){
		options = _options;
	}
}

/// @func discordMessageComponentOption(label, value, description, emoji);
function discordMessageComponentOption(_label, _value = "", _description = "", _emoji = -1) constructor {
	label = _label;
	value = _value; 
	description = _description; 
	
	if (_emoji != -1){
		emoji = _emoji;	
	}
}

/// @func discordEmoji(name, [id], [animated])
/// @desc A emoji data object used in message components
/// @param {string} name The emoji like: "🔥"
/// @param {string} id Id used for custom emojis
/// @param {bool} animated Whether or not the emoji is animated
function discordEmoji(_name, _id = pointer_null, _animated = false) constructor {
	name = _name;
	id = _id;
	animated = _animated;
}

/// @func discordMessageEmbed([title], [type], [description], [url], [timestamp], [color], [footer], [image], [thumbnail], [video], [provider], [author], [fields])
/// @desc Creates a new Discord message embed.
/// @param {string} title - The title of the embed.
/// @param {string} type - The type of the embed (always "rich" for webhook embeds). All types: "rich", "image", "video", "gifv", "article", "link"
/// @param {string} description - The description of the embed.
/// @param {string} url - The URL of the embed.
/// @param {string} timestamp - The ISO8601 timestamp of the embed content.
/// @param {real} color - The color code of the embed.
/// @param {struct} footer - The footer information. Properties: "text", "icon_url" (optional).
/// @param {struct} image - The image information. Properties: "url", "height", "width"
/// @param {struct} thumbnail - The thumbnail information. Properties: "url", "height", "width"
/// @param {struct} video - The video information. Properties: "url", "proxy_url", "height", "width"
/// @param {struct} provider - The provider information. Properties: "name", and "url".
/// @param {struct} author - The author information. Properties: "name", "url" (optional), "icon_url" (optional).
/// @param {Array} fields - The array of embed field objects. Each field object has properties: "name", "value", "inline" (optional, default false).
function discordMessageEmbed(_title = "", _type = "rich", _description = "", _url = "", _timestamp = "", _color = -1, _footer = -1, _image = -1, _thumbnail = -1, _video = -1, _provider = -1, _author = -1, _fields = -1) constructor {
    // Title of the embed
    title = _title;

    // Type of the embed (always "rich" for webhook embeds)
    type = _type;

    // Description of the embed
    description = _description;

    // URL of the embed
	if (_url != ""){
		url = _url;
	}

    // ISO8601 timestamp of the embed content
    if (_timestamp != ""){
        timestamp = _timestamp;
    }

    // Color code of the embed
    if (_color != -1){
        color = _color;
    }

    // Footer information
    if (_footer != -1){
        footer = _footer;
    }

    // Image information
    if (_image != -1){
        image = _image;
    }

    // Thumbnail information
    if (_thumbnail != -1){
        thumbnail = _thumbnail;
    }

    // Video information
    if (_video != -1){
        video = _video;
    }

    // Provider information
    if (_provider != -1){
        provider = _provider;
    }

    // Author information
    if (_author != -1){
        author = _author;
    }

    // Fields information (array of embed field objects)
    if (_fields != -1){
        fields = _fields;
    }
}

/// @func discordFileAttachment(filePath, fileName, [fileDescription])
/// @desc Creates a new Discord file for sending in messages.
/// @param {string} filePath - Complete filePath for file being sent
/// @param {string} fileName - The name the file will be sent as.
/// @param {string} fileDescription - A description of the file
function discordFileAttachment(_filePath, _fileName, _fileDescripton = "") constructor {
	__filePath = _filePath;
	__fileName = _fileName;
	__fileDescription = _fileDescripton;
	__id = 0;
}

/// @func discordPresenceActivity(name, type)
/// @description Activity 
/// @param name
/// @param type The type of activity
function discordPresenceActivity(_name, _activityType, _url, _createdAt, _timestamps, _applicationId, _details, _state, _emoji, _party, _assets, _secrets, _instance, _flags, _buttons) constructor {
	name = _name;
	type = _activityType;
		
	if (_activityType == DISCORD_PRESENCE_ACTIVITY.streaming){
		url = _url
	}
}

#endregion







