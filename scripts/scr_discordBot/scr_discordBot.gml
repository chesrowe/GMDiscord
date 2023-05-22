/// @func discordBot(botToken, applicationId, [useGatewayEvents])
/// @desc Create a new discord bot struct with the given token and application id
/// @param {string} botToken Your bot's token found here https://discord.com/developers/applications
/// @param {string} applicationId Your bot's application id
/// @param {bool} useGatewayEvents Whether or not to set up a gateway connect for this bot
function discordBot(_botToken, _applicationId, _useGatewayEvents = false) constructor {
	array_push(obj_discordController.botArray, self);
	__botToken = _botToken;
	__applicationId = _applicationId;
	
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

		var _urlEndpoint = "channels/" + _channelId + "/messages/bulk-delete";
		__discord_send_http_request_standard(_urlEndpoint, "POST", _bodyJson, __botToken, _callback);
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
		var _urlEnpoint = "channels/" + _channelId + "/pins";
		__discord_send_http_request_standard(_urlEnpoint, "GET", -1, __botToken, _callback);
	}
	
	#endregion
	
	#region messagePin(channelId, messageId, [callback])
	
	/// @func messagePin(channelId, messageId, [callback])
	/// @desc Pins a message in the given Discord channel
	/// @param {string} channelId The id of the channel where the message is located
	/// @param {string} messageId The id of the message to pin
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messagePin = function(_channelId, _messageId, _callback = -1){
		var _urlEnpoint = "channels/" + _channelId + "/pins/" + _messageId;
		__discord_send_http_request_standard(_urlEnpoint, "PUT", -1, __botToken, _callback);
	}
	
	#endregion
	
	#region messageUnpin(channelId, messageId, [callback])

	/// @func messageUnpin(channelId, messageId, [callback])
	/// @desc Unpins a message from the given Discord channel
	/// @param {string} channelId The id of the channel that the message is being unpinned from
	/// @param {string} messageId The id of the message to unpin
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messageUnpin = function(_channelId, _messageId, _callback = -1) {		
		var _urlEnpoint = "channels/" + _channelId + "/pins/" + _messageId;
		__discord_send_http_request_standard(_urlEnpoint, "DELETE", -1, __botToken, _callback);
	}

	#endregion
	
	#region messageCrosspost(channelId, messageId, [callback])
	
	/// @func messageCrosspost(channelId, messageId, [callback])
	/// @desc Crossposts a message in a News Channel to following channels
	/// @param {string} channelId The id of the channel that the message is being crossposted from
	/// @param {string} messageId The id of the message to crosspost
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messageCrosspost = function(_channelId, _messageId, _callback = -1){		
		var _urlEnpoint = "channels/" + _channelId + "/messages/" + _messageId + "/crosspost";
		__discord_send_http_request_standard(_urlEnpoint, "POST", -1, __botToken, _callback);
	}

	#endregion
	
	#region messageReactionCreate(channelId, messageId, emoji, [callback])
	
	/// @func messageReactionCreate(channelId, messageId, emoji, [callback])
	/// @desc Adds a reaction to a message in a given Discord channel
	/// @param {string} channelId The id of the channel that contains the message
	/// @param {string} messageId The id of the message to add the reaction to
	/// @param {string} emoji The emoji to use for the reaction
	static messageReactionCreate = function(_channelId, _messageId, _emoji, _callback = -1) {	
		var _urlEnpoint = "channels/" + _channelId + "/messages/" + _messageId + "/reactions/" + __url_encode(_emoji) + "/@me";
		__discord_send_http_request_standard(_urlEnpoint, "PUT", -1, __botToken, _callback);
	}

	#endregion
	
	#region messageReactionDelete(channelId, messageId, emoji, [callback])

	/// @func messageReactionDelete(channelId, messageId, emoji, [callback])
	/// @desc Deletes a reaction from a message
	/// @param {string} channelId The id of the channel that contains the message
	/// @param {string} messageId The id of the message to remove the reaction from
	/// @param {string} emoji The url-encoded emoji to remove
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messageReactionDelete = function(_channelId, _messageId, _emoji, _callback = -1){
		__discord_send_http_request_standard("channels/" + _channelId + "/messages/" + _messageId + "/reactions/" + _emoji + "/@me", "DELETE", -1, __botToken, _callback);
	}

	#endregion
	
	#region messageReactionsDeleteAll(channelId, messageId, [callback])

	/// @func messageReactionsDeleteAll(channelId, messageId, [callback])
	/// @desc Deletes all reactions from a message
	/// @param {string} channelId The id of the channel that contains the message
	/// @param {string} messageId The id of the message to remove all reactions from
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static messageReactionsDeleteAll = function(_channelId, _messageId, _callback = -1){
		__discord_send_http_request_standard("channels/" + _channelId + "/messages/" + _messageId + "/reactions", "DELETE", -1, __botToken, _callback);
	}

	#endregion
	
	#region userGet(userId, [callback])

	/// @func userGet(userId, [callback])
	/// @desc Retrieves a user object
	/// @param {string} userId The id of the user you want to get
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static userGet = function(_userId, _callback = -1){
		__discord_send_http_request_standard("users/" + _userId, "GET", -1, __botToken, _callback);
	}

	#endregion
	
	#region DMCreate(recipientId, [callback])

	/// @func DMCreate(recipientId, [callback])
	/// @desc Opens a direct message channel with a user
	/// @param {string} recipientId The id of the user to open a direct message with
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static DMCreate = function(_recipientId, _callback = -1){
		// Create a struct containing the recipientId
		var _bodyData = {
			recipient_id: _recipientId
		};

		__discord_send_http_request_standard("users/@me/channels", "POST", _bodyData, __botToken, _callback);
	}

	#endregion
	
	#region channelCreate(guildId, channelData, [callback])

	/// @func channelCreate(guildId, channelData, [callback])
	/// @desc Creates a new guild channel
	/// @param {string} guildId The id of the guild to create the channel in
	/// @param {struct} channelData The data for the new channel
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static channelCreate = function(_guildId, _channelData, _callback = -1){
		__discord_send_http_request_standard("guilds/" + _guildId + "/channels", "POST", _channelData, __botToken, _callback);
	}

	#endregion
	
	#region channelDelete(channelId, [callback])
	
	/// @func channelDelete(channelId, [callback])
	/// @desc Deletes a specific channel
	/// @param {string} channelId The id of the channel you want to delete
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static channelDelete = function(_channelId, _callback = -1){
		__discord_send_http_request_standard("channels/" + _channelId, "DELETE", -1, __botToken, _callback);
	}

	#endregion
	
	#region guildCommandCreate(guildId, commandData, [callback])
	
	/// @func guildCommandCreate(guildId, commandData, [callback])
	/// @desc Registers a new command for a guild
	/// @param {string} guildId The id of the guild where the command will be registered
	/// @param {struct.discordGuildCommand} commandData Struct containing the command's name, description, and options
	static guildCommandCreate = function(_guildId, _commandData, _callback = -1){
	    var _urlEndpoint = "applications/" + __applicationId + "/guilds/" + _guildId + "/commands";
	    __discord_send_http_request_standard(_urlEndpoint, "POST", _commandData, __botToken, _callback);
	}

	#endregion
	
	#region guildCommandEdit(guildId, commandId, commandData, [callback])
   
	/// @func guildCommandEdit(guildId, commandId, commandData, [callback])
	/// @desc Edits an existing command for a guild
	/// @param {string} guildId The id of the guild where the command exists
	/// @param {string} commandId The id of the command that will be edited
	/// @param {struct.discordGuildCommand} commandData Struct containing the command's new name, description, and options
	static guildCommandEdit = function(_guildId, _commandId, _commandData, _callback = -1){
	    var _urlEndpoint = "applications/" + __applicationId + "/guilds/" + _guildId + "/commands/" + _commandId;
	    __discord_send_http_request_standard(_urlEndpoint, "PATCH", _commandData, __botToken, _callback);
	}

	#endregion
	
	#region guildCommandDelete(guildId, commandId, [callback])
	
	/// @func guildCommandDelete(guildId, commandId, [callback])
	/// @desc Deletes a command for a guild
	/// @param {string} guildId The id of the guild where the command will be deleted
	/// @param {string} commandId The id of the command to delete
	static guildCommandDelete = function(_guildId, _commandId, _callback = -1){
	    var _urlEndpoint = "applications/" + __applicationId + "/guilds/" + _guildId + "/commands/" + _commandId;
	    __discord_send_http_request_standard(_urlEndpoint, "DELETE", -1, __botToken, _callback);
	}
	
	#endregion
	
	#region guildCommandGet(guildId, commandId, [callback])
	
	/// @func guildCommandGet(guildId, commandId, [callback])
	/// @desc Retrieves a specific command for a guild
	/// @param {string} guildId The id of the guild where the command will be retrieved from
	/// @param {string} commandId The id of the command to be retrieved
	/// @param {function} [callback] The function to execute when a response to the request is received
	static guildCommandGet = function(_guildId, _commandId, _callback = -1){
		// Prepare the endpoint url
		var _urlEndpoint = "applications/" + __applicationId + "/guilds/" + _guildId + "/commands/" + _commandId;
		__discord_send_http_request_standard(_urlEndpoint, "GET", -1, __botToken, _callback);
	}

	#endregion
	
	#region guildMemberBan(guildId, userId, [deleteMessageDays], [reason], [callback])
	
	/// @func guildMemberBan(guildId, userId, [deleteMessageDays], [reason], [callback])
	/// @desc Bans a guild member
	/// @param {string} guildId The id of the guild
	/// @param {string} userId The id of the user to ban
	/// @param {real} deleteMessageDays Number of days to delete messages for (0-7). Default: 0
	/// @param {string} reason The reason for the ban. Default: ""
	/// @param {function} callback The function to execute for the request's response. 
	static guildMemberBan = function(_guildId, _userId, _deleteMessageDays = 0, _reason = "", _callback = -1){
		var _urlEndpoint = "guilds/" + _guildId + "/bans/" + _userId;
		var _bodyData = {
			delete_message_days: _deleteMessageDays,
			reason: _reason
		};
		
		__discord_send_http_request_standard(_urlEndpoint, "PUT", _bodyData, __botToken, _callback);
	}

	#endregion
	
	#region guildMemberUnban(guildId, userId, [callback])
	
	/// @func guildMemberUnban(guildId, userId, [callback])
	/// @desc Unbans a guild member
	/// @param {string} guildId The id of the guild
	/// @param {string} userId The id of the user to unban
	/// @param {function} callback The function to execute for the request's response. 
	static guildMemberUnban = function(_guildId, _userId, _callback = -1){
		var _urlEndpoint = "guilds/" + _guildId + "/bans/" + _userId;
		
		__discord_send_http_request_standard(_urlEndpoint, "DELETE", -1, __botToken, _callback);
	}

	#endregion
	
	#region guildMemberKick(guildId, userId, [reason], [callback])
	
	/// @func guildMemberKick(guildId, userId, [reason], [callback])
	/// @desc Kicks a guild member
	/// @param {string} guildId The id of the guild
	/// @param {string} userId The id of the user to kick
	/// @param {string} reason The reason for the kick. Default: ""
	/// @param {function} callback The function to execute for the request's response. 
	static guildMemberKick = function(_guildId, _userId, _reason = "", _callback = -1){
		var _urlEndpoint = "guilds/" + _guildId + "/members/" + _userId;
		var _bodyData = {
			reason: _reason
		};
		
		__discord_send_http_request_standard(_urlEndpoint, "DELETE", _bodyData, __botToken, _callback);
	}

	#endregion
	
	#region guildMembersGet(guildId, [callback])
	
	/// @func guildMembersGet(guildId, [callback])
	/// @desc Fetches the members of a server
	/// @param {string} guildId The id of the guild (server) from which to fetch the members
	/// @param {function} callback The function to execute for the request's response.
	static guildMembersGet = function(_guildId, _callback = -1){
	    __discord_send_http_request_standard("guilds/" + _guildId + "/members", "GET", -1, __botToken, _callback);
	}
	
	#endregion
	
	#region guildChannelsGet(guildId, [callback])
	
	/// @func guildChannelsGet(guildId, [callback])
	/// @desc Fetches the channels of a server
	/// @param {string} guildId The id of the guild (server) from which to fetch the channels
	/// @param {function} callback The function to execute for the request's response.
	static guildChannelsGet = function(_guildId, _callback = -1){
	    __discord_send_http_request_standard("guilds/" + _guildId + "/channels", "GET", -1, __botToken, _callback);
	}
	
	#endregion
	
	#region triggerTypingIndicator(channelId, [callback])
	
	/// @func triggerTypingIndicator(channelId, [callback])
	/// @desc Triggers the typing indicator for the bot in the given Discord channel
	/// @param {string} channelId The id of the channel where the typing indicator will be shown
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static triggerTypingIndicator = function(_channelId, _callback = -1){
		var _urlEnpoint = "channels/" + _channelId + "/typing";
		__discord_send_http_request_standard(_urlEnpoint, "POST", -1, __botToken, _callback);
	}
	
	#endregion
	
	#region Gateway event functions
	
	#region interactionResponseSend(interactionId, interactionToken, callbackType, [content], [callback], [components], [embeds], [tts])
	
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
		var _urlEndpoint = "interactions/" + _interactionId + "/" + _interactionToken + "/callback";

		// Create a struct containing the response data
		var _responseData = {
			type: _callbackType, 
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
	
		__discord_send_http_request_standard(_urlEndpoint, "POST", _responseData, __botToken, _callback);
	}
	
	#endregion
	
	#region interactionResponseEdit(interactionToken, [content], [callback], [components], [embeds], [attachments], [files])
	
	/// @func interactionResponseEdit(applicationId, interactionToken, [content], [callback], [components], [embeds], [attachments], [files])
	/// @desc Edits the initial response to an Interaction. Must include at least one of the following: message, components, embeds, attachments, or files
	/// @param {string} interactionToken The token for the Interaction
	/// @param {string} content The new message content (Up to 2000 characters)
	/// @param {function} callback The function to execute for the request's response. Default: -1
	/// @param {array} components Array of message component structs to include with the message. Default: -1
	/// @param {array} embeds Array of embed structs, up to 10 rich embeds(up to 6000 characters). Default: -1
	/// @param {array} attachments Array of existing attachment objects to keep. Default: -1
	/// @param {array} files Array of discordFile structs to send
	/// @see messageEdit
	static interactionResponseEdit = function(_interactionToken, _content = "", _callback = -1, _components = -1, _embeds = -1, _attachments = -1, _files = -1){
		// Replace the url
		var _endpointUrl = "webhooks/" + __applicationId + "/" + _interactionToken + "/messages/@original";
		
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

		 __discord_send_http_request_multipart(_endpointUrl, "PATCH", _bodyData, _files, __botToken, _callback);
	}
    
	#endregion
	
	#region interactionResponseDelete(applicationId, interactionToken, [callback])
	
	/// @func interactionResponseDelete(applicationId, interactionToken, [callback])
	/// @desc Deletes the initial response to an Interaction
	/// @param {string} applicationId The id of the application
	/// @param {string} interactionToken The token for the Interaction
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static interactionResponseDelete = function(_applicationId, _interactionToken, _callback = -1){
		// Prepare the url and headers
		var _endpointUrl = "webhooks/" + _applicationId + "/" + _interactionToken + "/messages/@original";

		__discord_send_http_request_standard(_endpointUrl, "DELETE", -1, __botToken, _callback);
	}
    #endregion

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
	__gatewayNumberOfDisconnects = 0;
	gatewayEventCallbacks = {};
	
	/// @func __gatewaySendHeartbeat()
	/// @desc Sends a heartbeat to the Discord gateway to keep the connection alive
	function __gatewaySendHeartbeat(){
		var _payload = {
			op: GATEWAY_OP_CODE.heartbeat,
			d : (__gatewaySequenceNumber == -1) ? pointer_null : __gatewaySequenceNumber
		};	

		var _bytesSent = __gatewayEventSend(_payload);
		
		if (_bytesSent > 0){	
			__gatewayHeartbeatCounter++;
		
			if (!__gatewayIndentityHandshake && __gatewayHeartbeatCounter > 0){
				__gatewaySendIdentity();	
			}
		}else{
			__gatewayHeartbeatCounter = 0;	
			var _url = "wss://gateway.discord.gg/?v=10&encoding=json";
			__gatewaySocket = network_create_socket_ext(network_socket_wss, 443);
			__gatewayConnection = network_connect_raw_async(__gatewaySocket, _url, 443);
			__gatewayNumberOfDisconnects++;
			__discordTrace("Connection to gateway lost: reconnecting...");
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
		//Returns the number of bytes sent or a number less than 0 if it failed
		var _bytesSent = network_send_raw(__gatewaySocket, _payloadBufferTrimmed, buffer_get_size(_payloadBufferTrimmed), network_send_text);
		buffer_delete(_payloadBufferTrimmed);		
		return _bytesSent;
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
	
enum DISCORD_INTERACTION_TYPE {
	ping = 1,
	applicationCommand,
	messageComponent,
	applicationCommandAutocomplete,
	modalSubmit
}

enum DISCORD_COMMAND_TYPE {
	chatInput = 1,
	user,
	message
}

enum DISCORD_COMMAND_OPTION_TYPE {
	subCommand = 1,
	subCommandGroup,
	string,
	integer,
	boolean,
	user,
	channel,
	role,
	mentionable,
	number,
	attachment
}

enum DISCORD_PERMISSIONS {
    createInstantInvite = 0x0000000000000001,
    kickMembers = 0x0000000000000002,
    banMembers = 0x0000000000000004,
    administrator = 0x0000000000000008,
    manageChannels = 0x0000000000000010,
    manageGuild = 0x0000000000000020,
    addReactions = 0x0000000000000040,
    viewAuditLog = 0x0000000000000080,
    prioritySpeaker = 0x0000000000000100,
    stream = 0x0000000000000200,
    viewChannel = 0x0000000000000400,
    sendMessages = 0x0000000000000800,
    sendTtsMessages = 0x0000000000001000,
    manageMessages = 0x0000000000002000,
    embedLinks = 0x0000000000004000,
    attachFiles = 0x0000000000008000,
    readMessageHistory = 0x0000000000010000,
    mentionEveryone = 0x0000000000020000,
    useExternalEmojis = 0x0000000000040000,
    viewGuildInsights = 0x0000000000080000,
    connect = 0x0000000000100000,
    speak = 0x0000000000200000,
    muteMembers = 0x0000000000400000,
    deafenMembers = 0x0000000000800000,
    moveMembers = 0x0000000001000000,
    useVad = 0x0000000002000000,
    changeNickname = 0x0000000004000000,
    manageNicknames = 0x0000000008000000,
    manageRoles = 0x0000000010000000,
    manageWebhooks = 0x0000000020000000,
    manageGuildExpressions = 0x0000000040000000,
    useApplicationCommands = 0x0000000080000000,
    requestToSpeak = 0x0000000100000000,
    manageEvents = 0x0000000200000000,
    manageThreads = 0x0000000400000000,
    createPublicThreads = 0x0000000800000000,
    createPrivateThreads = 0x0000001000000000,
    useExternalStickers = 0x0000002000000000,
    sendMessagesInThreads = 0x0000004000000000,
    useEmbeddedActivities = 0x0000008000000000,
    moderateMembers = 0x0000010000000000,
    viewCreatorMonetizationAnalytics = 0x0000020000000000,
    useSoundboard = 0x0000040000000000,
    sendVoiceMessages = 0x0000400000000000
}

#region Other classes

/// @func discordGuildCommand(name, description, type, options, defaultMemberPermissions, [dmPermission], [defaultPermission], [nsfw])
/// @desc Constructs a new guildCommand object.
/// @param {string} name The name of the command.
/// @param {string} description The description of the command.
/// @param {number} type The type of the command.
/// @param {Array} options The options for the command.
/// @param {string} defaultMemberPermissions The default member permissions for the command. Use DISCORD_PERMISSIONS enum. 
/// @param {boolean} dmPermission Whether the command is available in DMs.
/// @param {boolean} defaultPermission Whether the command is enabled by default.
/// @param {boolean} nsfw Whether the command is age-restricted.
function discordGuildCommand(_name, _description, _type, _options, _defaultMemberPermissions, _dmPermission = true, _defaultPermission = true, _nsfw = false) constructor {
    name = _name;
    description = _description;
    type = _type;
	
	if (array_length(_options) > 0){
		options = _options;
	}
	
    default_member_permissions = _defaultMemberPermissions;
    dm_permission = _dmPermission;
    default_permission = _defaultPermission;
    nsfw = _nsfw;
}

/// @func discordCommandOption(type, name, description, required, [choices], [options], [channelTypes], [minValue], [maxValue], [minLength], [maxLength], [autocomplete])
/// @desc Constructs a new discordCommandOption struct.
/// @param {number} type - The type of the option. Use the enum DISCORD_COMMAND_OPTION_TYPE
/// @param {string} name - The name of the option.
/// @param {string} description - The description of the option.
/// @param {boolean} required - Whether the option is required.
/// @param {Array} choices - The choices for the option.
/// @param {Array} options - The options for the option.
/// @param {Array} channelTypes - The channel types for the option.
/// @param {number} minValue - The minimum value for the option.
/// @param {number} maxValue - The maximum value for the option.
/// @param {number} minLength - The minimum length for the option.
/// @param {number} maxLength - The maximum length for the option.
/// @param {boolean} autocomplete - Whether autocomplete is enabled for the option.
function discordCommandOption(_type, _name, _description, _required, _choices = -1, _options = -1, _channelTypes = -1, _minValue = infinity, _maxValue = infinity, _minLength  = infinity, _maxLength = infinity, _autocomplete = false) constructor {
    type = _type;
    name = _name;
    description = _description;
    required = _required;
    
	if (_choices != -1){
		choices = _choices;
	}
	
	if (_options != -1){
		options = _options;
	}
	
    if (_channelTypes != -1){
		channelTypes = _channelTypes;
	}
	
	if (_minValue != infinity){
		minValue = _minValue;
	}
	
	if (_maxValue != infinity){
		maxValue = _maxValue;
	}
	
	if (_minLength != infinity){
		minLength = _minLength;
	}
	
	if (_maxLength != infinity){
		maxLength = _maxLength;
	}
    
	if (_autocomplete){
		autocomplete = _autocomplete;
	}
}

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







