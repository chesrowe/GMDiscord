myBot = new discordBot(global.config.errorBotToken, global.config.errorApplicationId, true);

// Create a simple slash command where the user types /ping
var _testGuildCommand = new discordGuildCommand("ping", "Just a test.", DISCORD_COMMAND_TYPE.chatInput);

//myBot.guildCommandCreate(global.config.serverId, _testGuildCommand, function(){
//	show_debug_message(json_parse(async_load[? "result"]));	
//});

var _guildId = "1090453953482866738";
var _userId = "1101162577725227108"

// Define the callback function to handle the response
var _callback = function() {
    show_debug_message("The request responded!");
};

// Call the method
myBot.guildChannelsGet(_guildId, _callback);

