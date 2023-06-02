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
			    var _attachments = __discord_array_merge(_authorAttachments, _footerAttachments);

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
	
		__discord_send_http_request_multipart("channels/" + _channelId + "/messages", "POST", _bodyData, _files, __botToken, _callback);
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

		__discord_send_http_request_multipart("channels/" + _channelId + "/messages/" + _messageId, "PATCH", _bodyData, _files, __botToken, _callback);
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
		var _urlEndpoint = "channels/" + _channelId + "/messages/" + _messageId;	
		__discord_send_http_request_standard(_urlEndpoint, -1, __botToken, _callback);
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
		var _urlEnpoint = "channels/" + _channelId + "/messages/" + _messageId + "/reactions/" + __discord_url_encode(_emoji) + "/@me";
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
		__discord_send_http_request_standard("channels/" + _channelId + "/messages/" + _messageId + "/reactions/" + __discord_url_encode(_emoji) + "/@me", "DELETE", -1, __botToken, _callback);
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
	/// @param {struct.discordGuildCommand} discordGuildCommand Struct containing the command's name, description, and options
	/// @param {function} callback Optional callback function to execute for the request's response
	static guildCommandCreate = function(_guildId, _command, _callback = -1){
	    var _urlEndpoint = "applications/" + __applicationId + "/guilds/" + _guildId + "/commands";
	    __discord_send_http_request_standard(_urlEndpoint, "POST", _command, __botToken, _callback);
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
	
	#region guildMemberBan(guildId, userId, [callback], [deleteMessageSeconds], [reason])
	
	/// @func guildMemberBan(guildId, userId, [callback], [deleteMessageDays], [reason])
	/// @desc Bans a guild member
	/// @param {string} guildId The id of the guild
	/// @param {string} userId The id of the user to ban
	/// @param {function} callback The function to execute for the request's response. 
	/// @param {real} deleteMessageSeconds number of seconds to delete messages for, between 0 and 604800 (7 days) Default: 0
	/// @param {string} reason The reason for the ban. Default: ""
	static guildMemberBan = function(_guildId, _userId,  _callback = -1, _deleteMessageSeconds = 0, _reason = ""){
		var _urlEndpoint = "guilds/" + _guildId + "/bans/" + _userId;
		var _bodyData = {
			delete_message_seconds: _deleteMessageSeconds,
		};
		
		var _additonalHeaders = -1;
		
		if (_reason != ""){
			_additonalHeaders = ds_map_create();
			_additonalHeaders[? "X-Audit-Log-Reason"] = _reason;
		}
		
		__discord_send_http_request_standard(_urlEndpoint, "PUT", _bodyData, __botToken, _callback, _additonalHeaders);
		
		ds_map_destroy(_additonalHeaders);
	}

	#endregion
	
	#region guildMemberBanGet(guildId, userId, [callback])
	
	/// @func guildMemberBanGet(guildId, userId, [callback])
	/// @desc Gets a previously banned user's `ban object`
	/// @param {string} guildId The id of the guild the user was banned in
	/// @param {string} userId The id of the ban that has been previously banned
	/// @param {function} callback The function to execute for the request's response. 
	static guildMemberBanGet = function(_guildId, _userId,  _callback = -1){
		var _urlEndpoint = "guilds/" + _guildId + "/bans/" + _userId;
		
		__discord_send_http_request_standard(_urlEndpoint, "GET", -1, __botToken, _callback);
	}

	#endregion
	
	#region guildMemberUnban(guildId, userId, [callback])
	
	/// @func guildMemberUnban(guildId, userId, [callback], [reason])
	/// @desc Unbans a guild member
	/// @param {string} guildId The id of the guild
	/// @param {string} userId The id of the user to unban
	/// @param {function} callback The function to execute for the request's response. 
	/// @param {string} reason The reason that the member is being unbanned. 
	static guildMemberUnban = function(_guildId, _userId, _callback = -1, _reason = ""){
		var _urlEndpoint = "guilds/" + _guildId + "/bans/" + _userId;
		
		var _bodyData = {};
		
		var _additonalHeaders = -1;
		
		if (_reason != ""){
			_additonalHeaders = ds_map_create();
			_additonalHeaders[? "X-Audit-Log-Reason"] = _reason;
		}
		
		__discord_send_http_request_standard(_urlEndpoint, "DELETE", _bodyData, __botToken, _callback);
	}

	#endregion
	
	#region guildMemberKick(guildId, userId, [callback], [reason])
	
	/// @func guildMemberKick(guildId, userId, [callback], [reason])
	/// @desc Kicks a guild member
	/// @param {string} guildId The id of the guild
	/// @param {string} userId The id of the user to kick
	/// @param {function} callback The function to execute for the request's response. 	
	/// @param {string} reason The reason for the kick. Default: ""
	static guildMemberKick = function(_guildId, _userId, _callback = -1, _reason = ""){
		var _urlEndpoint = "guilds/" + _guildId + "/members/" + _userId;
		var _bodyData = {};
		
		var _additonalHeaders = -1;
		
		if (_reason != ""){
			_additonalHeaders = ds_map_create();
			_additonalHeaders[? "X-Audit-Log-Reason"] = _reason;
		}
		
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
	
	#region guildRolesGet(guildId, [callback])
	
	/// @func guildRolesGet(guildId, [callback])
	/// @desc Fetches the roles of a server
	/// @param {string} guildId The id of the guild (server) from which to fetch the roles
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static guildRolesGet = function(_guildId, _callback = -1){
	    var _urlEndpoint = "guilds/" + _guildId + "/roles";
	    __discord_send_http_request_standard(_urlEndpoint, "GET", -1, __botToken, _callback);
	}
	
	#endregion
	
	#region guildRoleCreate(guildId, [callback])
	
	/// @func guildRoleCreate(guildId, [callback])
	/// @desc Creates a new role in a server
	/// @param {string} guildId The id of the guild (server) where the role will be created
	/// @param {function} callback The function to execute for the request's response. Default: -1
	/// @param {string} name The name of the role
	/// @param {string} permissions bitwise value of the enabled/disabled permissions
	/// @param {real} color bitwise value of the enabled/disabled permissions
	/// @param {bool} hoist whether the role should be displayed separately in the sidebar
	/// @param {any} icon the role's icon image (if the guild has the ROLE_ICONS feature)
	/// @param {string} unicodeEmoji the role's unicode emoji as a standard emoji (if the guild has the ROLE_ICONS feature)
	/// @param {bool} mentionable whether the role should be mentionable
	static guildRoleCreate = function(_guildId, _callback = -1, _name = "new role", _permissions = -1, _color = 0, _hoist = false, _icon = pointer_null, _unicodeEmoji = pointer_null, _mentionable = false){
	    var _urlEndpoint = "guilds/" + _guildId + "/roles";
		
		var _bodyData = {
			name: _name,
			color: _color,
			hoist: _hoist,
			icon: _icon,
			unicode_emoji: _unicodeEmoji,
			mentionable: _mentionable
		}
		
		if (_permissions != -1){
			_bodyData[$ "permissions"] = _permissions;	
		}
		
	    __discord_send_http_request_standard(_urlEndpoint, "POST", _bodyData, __botToken, _callback);
	}
	
	#endregion
	
	#region guildRoleDelete(guildId, roleId, [callback])
	
	/// @func guildRoleDelete(guildId, roleId, [callback])
	/// @desc Deletes a role from a server
	/// @param {string} guildId The id of the guild (server) where the role will be deleted
	/// @param {string} roleId The id of the role to be deleted
	/// @param {function} callback The function to execute for the request's response. Default: -1
	static guildRoleDelete = function(_guildId, _roleId, _callback = -1){
	    var _urlEndpoint = "guilds/" + _guildId + "/roles/" + _roleId;
	    __discord_send_http_request_standard(_urlEndpoint, "DELETE", -1, __botToken, _callback);
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
	
	//Set up gateway events
	__gatewaySocket = -1;
	__gatewayConnection = -1;	
	__gatewayHeartbeatCounter = 0;
	__gatewayHeartbeatTimeSource = -1;
	__gatewayIndentityHandshake = false;
	__gatewaySequenceNumber = -1;
	__gatewayResumeUrl = "";
	__gatewaySessionId = ""
	__gatewayNumberOfDisconnects = 0;
	__gatewayReconnect = false;
	gatewayEventCallbacks = {};
	
	if (_useGatewayEvents){
		__discord_gateway_new_connection(self);
	}
	
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
	
	#region interactionResponseFollowUp(interactionToken, content, [callback], [components], [embeds], [attachments], [files])
	
	/// @func interactionResponseFollowUp(interactionToken, content, [callback], [components], [embeds], [attachments], [files])
	/// @desc Sends a new follow-up message to an Interaction. Must include a message.
	/// @param {string} interactionToken The token for the Interaction
	/// @param {string} content The new message content (Up to 2000 characters)
	/// @param {function} callback The function to execute for the request's response. Default: -1
	/// @param {array} components Array of message component structs to include with the message. Default: -1
	/// @param {array} embeds Array of embed structs, up to 10 rich embeds(up to 6000 characters). Default: -1
	/// @param {array} attachments Array of existing attachment objects to keep. Default: -1
	/// @param {array} files Array of discordFile structs to send
	static interactionResponseFollowUp = function(_interactionToken, _content, _callback = -1, _components = -1, _embeds = -1, _attachments = -1, _files = -1){
		// Replace the url
		var _endpointUrl = "webhooks/" + __applicationId + "/" + _interactionToken;
		
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

		 __discord_send_http_request_multipart(_endpointUrl, "POST", _bodyData, _files, __botToken, _callback);
	}
	
    #endregion

	#region presenceSend(activity, status)
	
	/// @func presenceSend(activity, status)
	/// @desc Updates a bot's presence
	/// @param activity
	/// @param status
	static presenceSend = function(_activities, _status) {
	    var _payload = {
	        op: DISCORD_GATEWAY_OP_CODE.presenceUpdate,
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
	
	#region System methods
	
	/// @func __gatewaySendHeartbeat()
	/// @desc Sends a heartbeat to the Discord gateway to keep the connection alive
	__gatewaySendHeartbeat = function(){
		var _payload = {
			op: DISCORD_GATEWAY_OP_CODE.heartbeat,
			d : (__gatewaySequenceNumber == -1) ? pointer_null : __gatewaySequenceNumber
		};	

		var _bytesSent = __gatewayEventSend(_payload);
		
		if (_bytesSent > 0){	
			__gatewayHeartbeatCounter++;
		
			if (__gatewayHeartbeatCounter > 0){
				if (!__gatewayIndentityHandshake && !__gatewayReconnect){
					__gatewaySendIdentity();	
				}else if (__gatewayReconnect){		
					__gatewaySendResume();
				}
			}
		}else{
			__discordTrace("Connection to gateway lost: reconnecting...");
			__discord_gateway_reconnect(self);
		}
	}
	
	/// @func __gatewaySendIdentity()
	/// @desc after a heartbeat is established with the gateway, an identity must be sent to finish setting up the connection
	function __gatewaySendIdentity() {
		var _botToken = __botToken;
	
	    var _payload = {
	        op: DISCORD_GATEWAY_OP_CODE.identify,
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
	
	/// @func __gatewaySendResume()
	/// @desc Sends a resume event for use after a disconnect
	function __gatewaySendResume() {
		//Send resume gateway event to discord
		var _resumeData = {
			op: DISCORD_GATEWAY_OP_CODE.resume,
			d: {
				token: __botToken,
				session_id: __gatewaySessionId,
				seq: int64(__gatewaySequenceNumber)
			}
		}
						
		__gatewayEventSend(_resumeData);		
	}
	
	/// @func __gatewayEventSend(payloadStruct)
	/// @desc Takes a struct, encodes it, and sends it to the Discord event
	function __gatewayEventSend(_payloadStruct){
		var _payloadString = json_stringify(_payloadStruct);
		var _payloadBuffer = buffer_create(0, buffer_grow, 1);
		buffer_write(_payloadBuffer, buffer_string, _payloadString);
		var _payloadBufferTrimmed = __discord_gateway_trim_buffer(_payloadBuffer);
		//Returns the number of bytes sent or a number less than 0 if it failed
		var _bytesSent = network_send_raw(__gatewaySocket, _payloadBufferTrimmed, buffer_get_size(_payloadBufferTrimmed), network_send_text);
		buffer_delete(_payloadBufferTrimmed);		
		return _bytesSent;
	}
	
	#endregion
	
	#endregion	
} 

