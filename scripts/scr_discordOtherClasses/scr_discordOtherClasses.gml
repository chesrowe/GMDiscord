/* The Discord API often times expects MANY, MANY different types of JSON objects to be sent in an http request's JSON payload. 
   Below are the most important ones, although not all are present yet and some arguments requiring a JSON object may need to be passed as a struct created on the spot.
*/

/// @func discordGuildCommand(name, description, type, options, defaultMemberPermissions, [dmPermission], [defaultPermission], [nsfw])
/// @desc Constructs a new guildCommand object.
/// @param {string} name The name of the command.
/// @param {string} description The description of the command.
/// @param {real.DISCORD_COMMAND_TYPE} type The type of the command.
/// @param {Array} options The options for the command.
/// @param {string} defaultMemberPermissions The default member permissions for the command. Use DISCORD_PERMISSIONS enum. 
/// @param {bool} dmPermission Whether the command is available in DMs.
/// @param {bool} defaultPermission Whether the command is enabled by default.
/// @param {bool} nsfw Whether the command is age-restricted.
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
/// @param {real.DISCORD_COMMAND_OPTION_TYPE} type - The type of the option. Use the enum DISCORD_COMMAND_OPTION_TYPE
/// @param {string} name - The name of the option.
/// @param {string} description - The description of the option.
/// @param {bool} required - Whether the option is required.
/// @param {Array} choices - The choices for the option.
/// @param {Array} options - The options for the option.
/// @param {Array} channelTypes - The channel types for the option.
/// @param {real} minValue - The minimum value for the option.
/// @param {real} maxValue - The maximum value for the option.
/// @param {real} minLength - The minimum length for the option.
/// @param {real} maxLength - The maximum length for the option.
/// @param {bool} autocomplete - Whether autocomplete is enabled for the option.
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
/// @desc Activity 
/// @param name
/// @param {enum.DISCORD_PRESENCE_ACTIVITY} type The type of activity
function discordPresenceActivity(_name, _activityType, _url, _createdAt, _timestamps, _applicationId, _details, _state, _emoji, _party, _assets, _secrets, _instance, _flags, _buttons) constructor {
	name = _name;
	type = _activityType;
		
	if (_activityType == DISCORD_PRESENCE_ACTIVITY.streaming){
		url = _url
	}
}

