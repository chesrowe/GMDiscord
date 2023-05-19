var _testCommand = new discordGuildCommand("test", "This is a new command", DISCORD_COMMAND_TYPE.chatInput, [], DISCORD_PERMISSIONS.administrator);  

errorBot.guildCommandCreate(global.config.guildId, _testCommand, function(){
	show_message(async_load[? "result"]);
});