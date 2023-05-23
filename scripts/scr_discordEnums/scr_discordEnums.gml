/* https://discord.com/developers/docs/interactions/message-components#component-object-component-types
   Used for message components, mainly .messageSend() and .messageEdit()
*/
enum DISCORD_COMPONENT_TYPE {
    actionRow = 1,     //Container for other components. All button components have to be added as a sub-component to an actionRow component
    button,            //A clickable button
    stringSelect,
	textInput,
	userSelect,
	roleSelect,
	mentionableSelect,
	channelSelect
}

/* https://discord.com/developers/docs/interactions/message-components#button-object-button-styles
   Used for message components, mainly .messageSend() and .messageEdit()
*/
enum DISCORD_BUTTON_STYLE {
    primary = 1,
    secondary = 2,
    success = 3,
    danger = 4,
    link = 5
}
	
/* https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-type
   Used for handling gateway events
*/
enum DISCORD_INTERACTION_TYPE {
	ping = 1,
	applicationCommand,
	messageComponent,
	applicationCommandAutocomplete,
	modalSubmit
}

/* https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-types
	For use in the .guildCommand discordBot methods
*/
enum DISCORD_COMMAND_TYPE {
	chatInput = 1, //Slash commands; a text-based command that shows up when a user types /
	user,          //A UI-based command that shows up when you right click or tap on a user
	message        //A UI-based command that shows up when you right click or tap on a message
}

/* https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-type
	
*/
enum DISCORD_COMMAND_OPTION_TYPE {
	subCommand = 1,
	subCommandGroup,
	string,
	integer,        //Any integer between -2^53 and 2^53
	boolean,
	user,
	channel,        //Includes all channel types + categories
	role,
	mentionable,    //Includes users and roles
	number,         //Any double between -2^53 and 2^53
	attachment      //attachment object
}

// https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags
enum DISCORD_PERMISSIONS {
    createInstantInvite = 0x0000000000000001,
    kickMembers = 0x0000000000000002,
    banMembers = 0x0000000000000004,
    administrator = 0x0000000000000008,
    manageChannels = 0x0000000000000010,
    manageGuild = 0x0000000000000020,
    addReactions = 0x0000000000000040,
    viewAuditLog = 0x0000000000000080,
    prioritySpeaker = 0x0000000000000100,
    stream = 0x0000000000000200,
    viewChannel = 0x0000000000000400,
    sendMessages = 0x0000000000000800,
    sendTtsMessages = 0x0000000000001000,
    manageMessages = 0x0000000000002000,
    embedLinks = 0x0000000000004000,
    attachFiles = 0x0000000000008000,
    readMessageHistory = 0x0000000000010000,
    mentionEveryone = 0x0000000000020000,
    useExternalEmojis = 0x0000000000040000,
    viewGuildInsights = 0x0000000000080000,
    connect = 0x0000000000100000,
    speak = 0x0000000000200000,
    muteMembers = 0x0000000000400000,
    deafenMembers = 0x0000000000800000,
    moveMembers = 0x0000000001000000,
    useVad = 0x0000000002000000,
    changeNickname = 0x0000000004000000,
    manageNicknames = 0x0000000008000000,
    manageRoles = 0x0000000010000000,
    manageWebhooks = 0x0000000020000000,
    manageGuildExpressions = 0x0000000040000000,
    useApplicationCommands = 0x0000000080000000,
    requestToSpeak = 0x0000000100000000,
    manageEvents = 0x0000000200000000,
    manageThreads = 0x0000000400000000,
    createPublicThreads = 0x0000000800000000,
    createPrivateThreads = 0x0000001000000000,
    useExternalStickers = 0x0000002000000000,
    sendMessagesInThreads = 0x0000004000000000,
    useEmbeddedActivities = 0x0000008000000000,
    moderateMembers = 0x0000010000000000,
    viewCreatorMonetizationAnalytics = 0x0000020000000000,
    useSoundboard = 0x0000040000000000,
    sendVoiceMessages = 0x0000400000000000
}



enum DISCORD_PRESENCE_ACTIVITY {
	game,
	streaming,
	listening,
	watching,
	custom,
	competing
}

/* https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-response-object-interaction-callback-type
   Used in .interactionResponseSend(), .interactionResponseEdit(), and .interactionResponseFollowUp() 
   For specifying what type of callback is being sent back to Discord in response to an "INTERACTION_CREATE" gateway event
*/
enum DISCORD_INTERACTION_CALLBACK_TYPE {
	pong = 1,                                //ACK a Ping, you probably wont use thim
	channelMessageWithSource = 4,            //respond to an interaction with a message
	deferredChannelMessageWithSource = 5,    //ACK an interaction and edit a response later, the user sees a loading state
	deferredUpdateMessage = 6,               //for components, ACK an interaction and edit the original message later; the user does not see a loading state
	updateMessage = 7,                       //for components, edit the message the component was attached to
	applicationCommandAutocompleteResult = 8,//respond to an autocomplete interaction with suggested choices
	modal = 9                                //respond to an interaction with a popup modal
}

