/// @func discordMessageComponent(type, [style], [label], [customId], [emoji], [url], [components], [options])
/// @desc Creates a new Discord message component.
/// @param {real.DISCORD_COMPONENT_TYPE} type The component type (ActionRow, Button, SelectMenu).
/// @param {real.DISCORD_BUTTON_STYLE} style The button style (Primary, Secondary, Success, Danger, Link).
/// @param {string} label The visible text on a button.
/// @param {string} customId The custom identifier for the component.
/// @param {struct.emoji} emoji The emoji struct with "name", "id", and "animated" properties.
/// @param {string} url The URL for the Link button style (Link).
/// @param {Array} components Array of sub-components
/// @param {Array} options The options for the Select Menu component (array of discordMessageComponent structs with "label", "value", "description", "emoji", and "default" properties).
function discordMessageComponent(_type, _style = -1, _label = "", _customId = "id", _emoji = -1, _url = "", _components = -1, _options = -1) constructor {
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

/// @url https://discord.com/developers/docs/interactions/message-components#button-object
/// @func discordMessageComponentButton(customId, label, style, [emoji], [url], [disabled])
/// @desc Constructs a new message components of the button type
/// @param {string} customId The custom identifier for the component. If the button is of the link type, this argument is ignored
/// @param {string} label The visible text on the button.
/// @param {real.DISCORD_BUTTON_STYLE} style The button style (Primary, Secondary, Success, Danger, Link).
/// @param {struct.discordEmoji} emoji The discordEmoji struct with "name", "id", and "animated" properties. Default: -1
/// @param {string} url Only for link type buttons, the url that will open when the button is clicked. Default: ""
/// @param {bool} disabled Whether the button is disabled. default: false
function discordMessageComponentButton(_customId, _label, _style, _emoji = -1, _url = -1, _disabled = false) constructor{
	type = DISCORD_COMPONENT_TYPE.button;
	style = _style;
	label = _label;
	disabled = _disabled;
	
	if (_emoji != -1){
		emoji = _emoji;	
	}
	
	switch(style){
		case DISCORD_BUTTON_STYLE.primary:
		case DISCORD_BUTTON_STYLE.secondary:
		case DISCORD_BUTTON_STYLE.success:
		case DISCORD_BUTTON_STYLE.danger:
			custom_id = _customId;			
			break;
		
		case DISCORD_BUTTON_STYLE.link:
			url = _url;
			break;
	}
}

/// @func discordMessageComponentActionRow(customId, label, style)
/// @desc Constructs a new message components of the actionrow type
/// @param {array} components Array of message components
function discordMessageComponentActionRow(_components) constructor{
	type = DISCORD_COMPONENT_TYPE.actionRow;
	components = _components;
}

/// @func discordMessageComponentSelectMenu(type, customId, [options], [channelTypes], [placeholder], [minValues], [maxValues], [disabled])
/// @desc Constructs a new message components of the select menu type
function discordMessageComponentSelectMenu(_type, _customId, _options = [], _channelTypes = -1, _placeholder = "", _minValues = 1, _maxValues = 1, _disabled = false) constructor{
	type = _type;
	custom_id = _customId;
	placeholder = _placeholder;
	min_values = _minValues;
	max_values = _maxValues;
	disabled = _disabled;
	
	if (type == DISCORD_COMPONENT_TYPE.stringSelect){
		options = _options;
	}
	
	if (type == DISCORD_COMPONENT_TYPE.channelSelect){
		channel_types = _channelTypes;	
	}
}

/// @func discordMessageComponentSelectOption(label, [value], [description], [emoji], [default]);
function discordMessageComponentSelectOption(_label, _value = "", _description = "", _emoji = -1, _default = false) constructor {
	label = _label;
	value = _value; 
	description = _description; 
	//self[$ "default"] = _default;
	
	if (_emoji != -1){
		emoji = _emoji;	
	}
}