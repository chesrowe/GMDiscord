/// @func discordMessageEmbed([title], [type], [description], [url], [timestamp], [color], [footer], [image], [thumbnail], [video], [provider], [author], [fields])
/// @desc Creates a new Discord message embed.
/// @param {string} title - The title of the embed.
/// @param {string} type - The type of the embed (always "rich" for webhook embeds). All types: "rich", "image", "video", "gifv", "article", "link"
/// @param {string} description - The description of the embed.
/// @param {string} url - The URL of the embed.
/// @param {string} timestamp - The ISO8601 timestamp of the embed content.
/// @param {real} color - The color code of the embed.
/// @param {struct.discordMessageEmbedFooter} footer - The footer information. 
/// @param {struct.discordMessageEmbedImage} image - The image information. 
/// @param {struct.discordMessageEmbedThumnail} thumbnail - The thumbnail information. 
/// @param {struct.discordMessageEmbedVideo} video - The video information. 
/// @param {struct.discordMessageEmbedProvider} provider - The provider information. 
/// @param {struct.discordMessageEmbed} author - The author information. 
/// @param {Array<struct.discordMessageEmbedField>} fields - The array of embed field structs. 
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

/// @param {string} text - The footer text.
/// @param {string} iconUrl - The URL of the footer icon.
/// @param {string} proxyIconUrl - A proxied URL of the footer icon.
function discordMessageEmbedFooter(_text = "", _iconUrl = "", _proxyIconUrl = "") constructor {
    text = _text;
    
	if (_iconUrl != ""){
        icon_url = _iconUrl;
    }
    
	if (_proxyIconUrl != ""){
        proxy_icon_url = _proxyIconUrl;
    }
}

/// @param {string} url - The source URL of the image.
/// @param {string} proxyUrl - A proxied URL of the image.
/// @param {real} height - The height of the image.
/// @param {real} width - The width of the image.
function discordMessageEmbedImage(_url = "", _proxyUrl = "", _height = -1, _width = -1) constructor {
    if (_url != ""){
        url = _url;
    }
    if (_proxyUrl != ""){
        proxy_url = _proxyUrl;
    }
    if (_height != -1){
        height = _height;
    }
    if (_width != -1){
        width = _width;
    }
}

/// @param {string} url - The source URL of the thumbnail.
/// @param {string} proxyUrl - A proxied URL of the thumbnail.
/// @param {real} height - The height of the thumbnail.
/// @param {real} width - The width of the thumbnail.
function discordMessageEmbedThumbnail(_url = "", _proxyUrl = "", _height = -1, _width = -1) constructor {
    if (_url != ""){
        url = _url;
    }
    if (_proxyUrl != ""){
        proxy_url = _proxyUrl;
    }
    if (_height != -1){
        height = _height;
    }
    if (_width != -1){
        width = _width;
    }
}


/// @param {string} url - The source URL of the video.
/// @param {real} height - The height of the video.
/// @param {real} width - The width of the video.
function discordMessageEmbedVideo(_url = "", _height = -1, _width = -1) constructor {
    if (_url != ""){
        url = _url;
    }
    if (_height != -1){
        height = _height;
    }
    if (_width != -1){
        width = _width;
    }
}

/// @param {string} name - The name of the provider.
/// @param {string} url - The URL of the provider.
function discordMessageEmbedProvider(_name = "", _url = "") constructor {
    if (_name != ""){
        name = _name;
    }
    if (_url != ""){
        url = _url;
    }
}

/// @param {string} name - The name of the author.
/// @param {string} url - The URL of the author.
/// @param {string} iconUrl - The URL of the author icon.
/// @param {string} proxyIconUrl - A proxied URL of the author icon.
function discordMessageEmbedAuthor(_name = "", _url = "", _iconUrl = "", _proxyIconUrl = "") constructor {
    if (_name != ""){
        name = _name;
    }
    if (_url != ""){
        url = _url;
    }
    if (_iconUrl != ""){
        icon_url = _iconUrl;
    }
    if (_proxyIconUrl != ""){
        proxy_icon_url = _proxyIconUrl;
    }
}

/// @param {string} name - The name of the field.
/// @param {string} value - The value of the field.
/// @param {bool} inline - Whether or not this field should display inline.
function discordMessageEmbedField(_name = "", _value = "", _inline = false) constructor {
    name = _name;
    value = _value;
    inline = _inline;
}




