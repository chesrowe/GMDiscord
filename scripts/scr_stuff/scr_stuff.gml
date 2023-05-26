var _configPath = "C:/Users/madma/OneDrive/Desktop/GMDiscord/config.json"
global.config = json_load(_configPath);
global.lastMessageId = "";
global.lastUserMessageId = ""; 
global.lastBotMessageId = "";

/// @func json_load(filePath)
/// @desc Loads a json file and parses in as a struct then returns that struct or -1 if failed
/// @param {string} filePath The path to the json file
function json_load(_filePath){
	var _buff = buffer_load(_filePath);
	
	if (_buff != -1){
		var _str = buffer_read(_buff, buffer_text);
		buffer_delete(_buff);
		//var _parsedJson =  json_parse(_str);
		var _parsedJson = json_parse(_str);
		return is_struct(_parsedJson) ? _parsedJson : -1;
	}else{
		return -1;
	}
}

function struct_pretty_print(_struct){
	var _jsonString = json_stringify(_struct);
	
	return json_pretty_print(_jsonString);
}

function json_pretty_print(_jsonString) {
    var _result = "";
    var _indent = "";
    var _i = 0;
    var _jsonStringLength = string_length(_jsonString);
    var _inString = false;
    var _lastChar = "";
    var _currentString = "";

    // If the string begins and ends with a double quote, remove those quotes
    if (string_char_at(_jsonString, 1) == "\"" && string_char_at(_jsonString, _jsonStringLength) == "\"") {
        _jsonString = string_copy(_jsonString, 2, _jsonStringLength - 2);
        _jsonStringLength -= 2;
    }

    // Loop through each character in the JSON string
    for (_i = 1; _i <= _jsonStringLength; _i += 1) {
        var _currentChar = string_char_at(_jsonString, _i);

        switch (_currentChar) {
            case "{":
            case "[":
                if (!_inString) {
                    _indent += "    ";
                    _result += _currentChar + "\n" + _indent;
                } else {
                    _currentString += _currentChar;
                    _result += _currentChar;
                }
                break;

            case "}":
            case "]":
                if (!_inString) {
                    _indent = string_copy(_indent, 1, string_length(_indent) - 4);
                    _result += "\n" + _indent + _currentChar;
                } else {
                    _currentString += _currentChar;
                    _result += _currentChar;
                }
                break;

            case ",":
                if (!_inString) {
                    _result += ",\n" + _indent;
                } else {
                    _currentString += _currentChar;
                    _result += _currentChar;
                }
                break;

            case ":":
                if (!_inString) {
                    _result += ": ";
                } else {
                    _currentString += _currentChar;
                    _result += _currentChar;
                }
                break;

            case "\"":
                if (_lastChar != "\\") {
                    _inString = !_inString;
                    _currentString += _currentChar;
                    _result += _currentChar;

                    // Check if the string we just finished is a JSON string
                    if (!_inString) {
                        if (string_char_at(_currentString, 1) == "{" && string_char_at(_currentString, string_length(_currentString)) == "}" ||
                            string_char_at(_currentString, 1) == "[" && string_char_at(_currentString, string_length(_currentString)) == "]") {
                            var _nestedJSON = json_decode(_currentString);
                            if (_nestedJSON != undefined) {
                                // Pretty print the nested JSON string
                                var _nestedString = json_pretty_print(_currentString);
                                // Replace the JSON string in the result with the prettified version
                                _result = string_replace(_result, _currentString, _nestedString);
                            }
                        }
                        _currentString = "";
                    }
                } else {
                    _currentString += _currentChar;
                    _result += _currentChar;
                }
                break;

            default:
                _currentString += _currentChar;
                _result += _currentChar;
        }

        _lastChar = _currentChar;
    }
	
	_result = string_replace_all(_result, "\\", "");

    return _result;
}


























