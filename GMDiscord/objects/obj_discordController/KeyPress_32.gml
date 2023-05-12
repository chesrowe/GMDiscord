
var _testButton = new discordMessageComponent(DISCORD_COMPONENT_TYPE.button, DISCORD_BUTTON_STYLE.primary, "TEST", -1, "TEST");
var _testActionRow = new discordMessageComponent(DISCORD_COMPONENT_TYPE.actionRow, -1, "", -1, "ACTION", "", [_testButton]);

errorBot.messageSend("1100867908755783694", "Testing a button interaction", -1, [_testActionRow]);