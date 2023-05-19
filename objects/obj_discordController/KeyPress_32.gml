//var _testCommand = new discordGuildCommand("test", "This is a new command", DISCORD_COMMAND_TYPE.chatInput, [], DISCORD_PERMISSIONS.administrator);  

//errorBot.guildCommandCreate(global.config.guildId, _testCommand, function(){
//	show_message(async_load[? "result"]);
//});

errorBot.userDMCreate("380999088201531392", function(){
	show_message(async_load[? "result"]);
}); 