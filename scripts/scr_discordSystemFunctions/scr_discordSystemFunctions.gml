/// @func __discord_add_request(requestId,[callback])
/// @desc Adds a new http request to the requestCallbacks array in the Discord controller object
/// @param {real} requestId The id returned by http_request() 
/// @param {function} callback Optional callback function to execute when a response to the request is received
function __discord_add_request(_requestId, _callback = -1){
	var _request = new __discordHttpRequest(_requestId, _callback);
	array_push(obj_discordController.requestCallbacks, _request);
}

/// @desc Created for each new request made by a discord bot's methods
/// @param {real} id number returned by http_request()
/// @param {function} callback A function to execute once a response is received from the request
function __discordHttpRequest(_id, _callback = -1) constructor{
	__requestId = _id;
	__callback = _callback;
}

function __discord_send_file(_channelId, _filePath, _fileName, _botToken) {	 
	// Set the Discord API endpoint to send the image
    var _url = "https://discord.com/api/v10/channels/" + _channelId + "/messages";

    // Load the image file as a buffer
    var _fileBuffer = buffer_load(_filePath);

    // Base64 encode the image buffer
    var _base64Image = buffer_base64_encode(_fileBuffer, 0, buffer_get_size(_fileBuffer));

    // Create a new buffer to store the multipart form data
    var _formData = buffer_create(0, buffer_grow, 1);

    // Add the required form data fields
    var _boundary = "----GMLBoundary";
    var _header = "--" + _boundary + "\r\n";
    var _footer = "\r\n--" + _boundary + "--\r\n";

    // Add the file field with the base64 encoded file data
	var _fileType = "file"
    var _fileField = _header + "Content-Disposition: form-data; name=\"files[0]\"; filename=" + _fileName + "\r\n" + "Content-Type: " + _fileType + "\r\n" + "Content-Transfer-Encoding: base64\r\n\r\n";
    buffer_write(_formData, buffer_string, _fileField);
    buffer_write(_formData, buffer_string, _base64Image);
    buffer_write(_formData, buffer_string, _footer);

    // Prepare the HTTP request headers
    var _headers = ds_map_create();
    ds_map_add(_headers, "Content-Type", "multipart/form-data; boundary=" + _boundary);
    ds_map_add(_headers, "Authorization", "Bot " + _botToken);

    // Send the HTTP request
    var _requestId = http_request(_url, "POST", _headers, _formData);

    // Clean up the resources
    buffer_delete(_fileBuffer);
    buffer_delete(_formData);
    ds_map_destroy(_headers);
}

/// @function __discord_find_attachments(_embeds, _property, _subProperty, _files)
/// @param {array} embeds Array of embed structs
/// @param {string} property The property to look for in the embed structs
/// @param {string} subProperty The subproperty inside the _property to look for attachment URLs
/// @param {array} files Array of file structs
/// @return {array} Array of attachment structs with the correct id and description
function __discord_find_attachments(_embeds, _property, _subProperty, _files) {
	var _attachments = [];
	for (var _i = 0; _i < array_length(_embeds); _i++) {
		var _embed = _embeds[_i];
		if (variable_struct_exists(_embed, _property) && variable_struct_exists(_embed[$_property], _subProperty) && string_pos("attachment://", _embed[$_property][$_subProperty]) == 1) {
		    var _attachmentFileName = string_delete(_embed[$_property][$_subProperty], 1, 13);
            
		    // Find the correct file in the _files array
		    var _fileId = -1;
		    var _fileDescription = "";
		    for (var _j = 0; _j < array_length(_files); _j++) {
		        if (_files[_j].__fileName == _attachmentFileName) {
		            _fileId = _j;
		            _fileDescription = _files[_j].__fileDescription;
		            break;
		        }
		    }
            
		    // Add the attachment struct to the _attachments array
		    if (_fileId != -1) {
		        array_push(_attachments, {
		            id: _fileId,
		            description: _fileDescription,
		            filename: _attachmentFileName
		        });
		    }
		}
	}
	return _attachments;
}

/// @func __url_encode(string)
/// @desc URL-encodes the given string
/// @param {string} string The string to be URL-encoded
/// @return {string} The URL-encoded string
function __url_encode(_str) {
	var _encodedStr = "";
	var _strLength = string_length(_str);

	for (var _i = 1; _i <= _strLength; _i++) {
		var _char = string_char_at(_str, _i);

		// Check if the character is alphanumeric, hyphen, underscore, period or tilde
		if (string_pos(_char, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~") > 0) {
			_encodedStr += _char;
		} else {
			// Encode the character as a percent-encoded string
			var _byteArray = __string_unicode_to_byte_array(_char);
			var _byteArrayLength = array_length(_byteArray);

			for (var _j = 0; _j < _byteArrayLength; _j++) {
				var _hex = string_upper(string(__base_convert(_byteArray[_j], 10, 16)));
				if (string_length(_hex) < 2) {
					_hex = "0" + _hex;
				}
				_encodedStr += "%" + _hex;
			}
		}
	}

	return _encodedStr;
}

/// @func __string_unicode_to_byte_array(str)
/// @desc Converts a Unicode string to a byte array using UTF-8 encoding
/// @param {string} str The Unicode string to be converted
/// @return {array} The byte array representing the UTF-8 encoded string
function __string_unicode_to_byte_array(_str) {
	var _byteArray = [];
	var _strLength = string_length(_str);

	for (var _i = 1; _i <= _strLength; _i++) {
		var _charCode = string_ord_at(_str, _i);

		if (_charCode < 0x80) {
			array_push(_byteArray, _charCode);
		} else if (_charCode < 0x800) {
			array_push(_byteArray, 0xC0 | (_charCode >> 6));
			array_push(_byteArray, 0x80 | (_charCode & 0x3F));
		} else if (_charCode < 0x10000) {
			array_push(_byteArray, 0xE0 | (_charCode >> 12));
			array_push(_byteArray, 0x80 | ((_charCode >> 6) & 0x3F));
			array_push(_byteArray, 0x80 | (_charCode & 0x3F));
		} else {
			array_push(_byteArray, 0xF0 | (_charCode >> 18));
			array_push(_byteArray, 0x80 | ((_charCode >> 12) & 0x3F));
			array_push(_byteArray, 0x80 | ((_charCode >> 6) & 0x3F));
			array_push(_byteArray, 0x80 | (_charCode & 0x3F));
		}
	}

	return _byteArray;
}

/// @func __base_convert(number, fromBase, toBase)
/// @desc Converts a number from one base to another
/// @param {real} number The number to be converted
/// @param {real} fromBase The base of the input number
/// @param {real} toBase The base to convert the number to
/// @return {string} The number converted to the target base
function __base_convert(_number, _fromBase, _toBase) {
	var _digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	var _result = "";

	// Convert the input number to base 10
	var _base10Number = 0;
	var _strNumber = string(_number);
	var _strLength = string_length(_strNumber);
	var _mult = 1;

	for (var _i = _strLength; _i >= 1; _i--) {
		var _char = string_char_at(_strNumber, _i);
		var _charValue = string_pos(_char, _digits) - 1;
		_base10Number += _charValue * _mult;
		_mult *= _fromBase;
	}

	// Convert the base 10 number to the target base
	while (_base10Number > 0) {
		var _remainder = _base10Number % _toBase;
		_result = string_char_at(_digits, _remainder + 1) + _result;
		_base10Number = floor(_base10Number / _toBase);
	}

	return _result;
}

/// @function __trim_buffer(inputBuffer)
/// @description Trims trailing 00 bytes from a buffer
/// @param {id.buffer} inputBuffer The buffer to trim
/// @return {id.buffer} The trimmed buffer
function __trim_buffer(inputBuffer) {
    var bufferSize = buffer_get_size(inputBuffer);
    var trimmedSize = bufferSize;

    // Go from the end of the buffer backwards
    for (var i = bufferSize - 1; i >= 0; i--) {
        buffer_seek(inputBuffer, buffer_seek_start, i);
        if (buffer_read(inputBuffer, buffer_u8) != 0) {
            trimmedSize = i + 1;
            break;
        }
    }

    // Create a new buffer with the trimmed size
    var trimmedBuffer = buffer_create(trimmedSize, buffer_fixed, 1);

    // Copy the data from the old buffer to the new one
    buffer_copy(inputBuffer, 0, trimmedSize, trimmedBuffer, 0);

    // Delete the old buffer
    buffer_delete(inputBuffer);

    return trimmedBuffer;
}


/// @func __discordTrace(_text)
function __discordTrace(_text){
	if (DISCORD_VERBOSE){
		show_debug_message("Discord: " + string(_text));	
	}
}

/// @desc Parses async_load and returns a struct containing the data
function __discord_gateWay_event_parse(){
	var _buffer = async_load[? "buffer"];
	buffer_seek(_buffer, buffer_seek_start, 0);

	var _dataJsonString = buffer_read(_buffer, buffer_string);
	return json_parse(_dataJsonString);	
}






