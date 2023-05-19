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












