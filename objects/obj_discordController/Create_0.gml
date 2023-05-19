requestCallbacks = [];
botArray = [];
global.lastMessageTest = -1;

errorBot = new discordBot(global.config.errorBotToken, global.config.applicationId, true);
errorBot.gatewayEventCallbacks[$ "INTERACTION_CREATE"] = function(){
	var _messageEvent = __discord_gateWay_event_parse().d;
	__discordTrace("Command was sent");
	
	errorBot.interactionResponseSend(_messageEvent.id, _messageEvent.token, DISCORD_INTERATION_CALLBACK_TYPE.channelMessageWithSource, "asdf");
}


// Create a footer object
var footerInfo = {
    text: "Footer",
    icon_url: "attachment://tree2.png"
};

// Create an image object
var imageInfo = {
    url: "attachment://tree.png"
};

// Create a thumbnail object
var thumbnailInfo = {
    url: "attachment://tree2.png"
};

// Create an author object
var authorInfo = {
    name: "Cataclysmic Studios",
    url: "https://i.imgur.com/RsSW8Ej.mp4",
    icon_url: "attachment://tree.png"
};

// Create an array of field objects
var fieldsInfo = [
    {
        name: "Field 1",
        value: "Field 1 value",
        inline: true
    },
    {
        name: "Field 2",
        value: "Field 2 value",
        inline: true
    }
];

var _videoInfo = {
	url: "https://i.imgur.com/RsSW8Ej.mp4",
	height: 512,
	width: 512
};

var _provider = {
	name: "Jo Moma",
	url: "https://www.deeznuts.com"
}

// Create a message embed
var exampleEmbed = new discordMessageEmbed(
    "Augury Playtest",
    "rich",
    "Come join us for a limted playtest from july 10 - 18. Explore the caves and face the games first boss.",
    "https://i.imgur.com/RsSW8Ej.mp4",
    "", // Optional timestamp
    0x00FF00, // Color code (green)
    footerInfo,
    -1,
    -1,
    -1, // Optional video info
    -1, // Optional provider info
    authorInfo,
    -1
);

var _primaryButton = new discordMessageComponent(DISCORD_COMPONENT_TYPE.button, DISCORD_BUTTON_STYLE.link, "Play here!", new discordEmoji("AuguryLogo", "813832230849478718"), "", "https://www.google.com");
var _actionRow = new discordMessageComponent(DISCORD_COMPONENT_TYPE.actionRow, -1, "", -1, "", "", [_primaryButton]);

var _file = new discordFileAttachment("tree.png", "tree.png");
var _file2 = new discordFileAttachment("tree2.png", "tree2.png");

var _messageCallback = function(){
	//show_message(async_load[? "status"]);
	
	if (async_load[? "result"] != undefined && is_string(async_load[? "result"])){
		var _data = json_parse(async_load[? "result"]);
		show_message(_data);
		
		//var _messageIdArray = [];
		
		//var _i = 0;
		
		//repeat(array_length(_data)){
		//	array_push(_messageIdArray,_data[_i].id);
			
		//	_i++;	
		//}
		
		//errorBot.messageDeleteBulk("1100867908755783694", _messageIdArray);
	}
}

//errorBot.reactionCreate("1100867908755783694", "1102719201602445403", "AuguryLogo:813832230849478718", _messageCallback);


