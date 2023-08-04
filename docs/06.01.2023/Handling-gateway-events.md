## What are gateway events?
> "The Gateway API lets apps open secure WebSocket connections with Discord to receive events about actions that take place in a server/guild, like when a channel is updated or a role is created. There are a few cases where apps will also use Gateway connections to update or request resources, like when updating voice state."

Make sure and read the [docs](https://discord.com/developers/docs/topics/gateway) to understand how Gateway events work!

## How do they work in GMDiscord?
When constructing a new discordBot, make sure the `useGatewayEvents` argument(the third argument) is set to true
```Gml
testBot = new discordBot(botToken, botApplicationId, true)
```
Also, you may have as many bots as you want it your program, each with their own active gateway connection. A list of all possible events can be found [here](https://discord.com/developers/docs/topics/gateway#list-of-intents). Some examples are:
- `MESSAGE_CREATE`
- `MESSAGE_UPDATE`
- `MESSAGE_DELETE`
- `MESSAGE_DELETE_BULK`

You can respond to gateway events via callbacks stored in a discordBot's `gatewayEventCallbacks` struct. The callbacks are executed in the networking async event. Here is a basic example:
```gml
//This outputs a debug message when a new message is sent in a server the bot is in.
myBot.gatewayEventCallbacks[$ "MESSAGE_CREATE"] = function(){
    show_debug_message("A message has been sent");
}
```

To handle gateway events in a more advanced way, you'll need to use the `discord_gateWay_event_parse()` function that parses out the event's JSON payload into a struct. This struct will contain the following properties:
- **`op`** *(integer)*: [Gateway opcode](https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes), which indicates the payload type
- **`d`** *(Struct)*: Event data (In our examples, this will be a [message object](https://discord.com/developers/docs/resources/channel#message-object))
- **`s`** *(integer)*: Sequence number of event used for [resuming sessions](https://discord.com/developers/docs/topics/gateway#resuming) and [heartbeating](https://discord.com/developers/docs/topics/gateway#sending-heartbeats)
- **`t`** *(string)*: Event name (In our examples, this will be `"MESSAGE_CREATE"`)

Here is taking the previous example one more step
```gml
//This will send a debug message containing the last sent message in a bot's server
myBot.gatewayEventCallbacks[$ "MESSAGE_CREATE"] = function(){
    var _event = discord_gateway_event_parse();
    var _messageData = _event.d;
    show_debug_message("New message: " + string(_messageData.content));
}
```

### Full Sloppy Example from [MTG-AI](https://github.com/chesrowe/MTG-AI)
```javascript
//This code adds a new callback to the magicBot's `gatewayEventCallbacks` struct that listens for a "INTERACTION_CREATE" gateway event
magicBot = new discordBot(global.config.MTGBotToken, global.config.MTGApplicationId, true);
magicBot.gatewayEventCallbacks[$ "INTERACTION_CREATE"] = function(){
    var _event = discord_gateWay_event_parse();
    var _eventData = _event.d;	
	
    switch(_eventData.type){
        case DISCORD_INTERACTION_TYPE.applicationCommand:
	    switch(_eventData.data.name){
	        //This is for the /generate command
                case "generate":		
	            var _interactionToken = _eventData.token;
		    var _userId = _eventData.member.user.id;
		    var _cardTheme = _eventData.data.options[0].value;
		    var _cardNumber = _eventData.data.options[1].value;
		    
            // Responding to the command with interactionResponseSend		
		    obj_controller.magicBot.interactionResponseSend(_eventData.id, _eventData.token, DISCORD_INTERACTION_CALLBACK_TYPE.channelMessageWithSource, "Card(s) generating (0 of " + string(_cardNumber) + ")");
		    var _newJob = new job(_cardTheme, _cardNumber, _interactionToken, _userId);
		    array_push(jobsInProgressArray, _newJob);
		    var _firstRequest = send_chatgpt_request(card_prompt(_cardTheme));
		    array_push(_newJob.cardTextRequestIdArray, _firstRequest);
		    break;
            }
	    break;
    }
}
```