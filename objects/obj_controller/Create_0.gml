myBot = new discordBot(global.config.errorBotToken, global.config.errorApplicationId, true);

var _guildId = "1090453953482866738";
var _userId = "1101162577725227108";
var _channelId = "1113607940977463387"

// Define the callback function to handle the response
var _callback = function() {
    show_debug_message("Message with an attachment sent!");
};

var _fileAttachment = new discordFileAttachment("C:/Users/madma/OneDrive/Desktop/Cockroach-05-1802025153.jpg", "cockroach.jpg", "A cockroach");

// Call the method
myBot.messageEdit(_channelId, "1114011904147468400", "Editeadsfgsadddddd", _callback);