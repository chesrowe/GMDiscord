## **What are application commands?**
> Application commands are native ways to interact with apps in the Discord client. There are 3 types of commands accessible in different interfaces: the chat input, a message's context menu (top-right menu or right-clicking in a message), and a user's context menu (right-clicking on a user).

Read the offical docs about application commands [here](https://discord.com/developers/docs/interactions/application-commands).

### **There are three different types of application commands:**
- Chat input(slash commands)
- Message context menu (top-right menu or right-clicking in a message)
- User context menu (right-clicking on a user).

Commands can be either global or tied to a guild(server).

### **How to response to commands**
When a user uses a command, a "INTERACTION_CREATE" [gateway event](https://discord.com/developers/docs/topics/gateway-events) is fired off

## **Constructors**

### **`.discordGuildCommand(name, description, type, options, defaultMemberPermissions, [dmPermission], [defaultPermission], [nsfw])`**
Constructs a new discordGuildCommand struct.

#### **Parameters**

- **`name`** *(string)*: The name of the command.
- **`description`** *(string)*: The description of the command.
- **`type`** *(enum.DISCORD_COMMAND_TYPE)*: The type of the command.
- **`options`** *(Array)*: The options for the command.
- **`defaultMemberPermissions`** *(string)*: The default member permissions for the command. Use DISCORD_PERMISSIONS enum. 
- **`dmPermission`** *(bool, optional)*: Whether the command is available in DMs. Default: false.
- **`defaultPermission`** *(bool, optional)*: Whether the command is enabled by default. Default: true.
- **`nsfw`** *(bool, optional)*: Whether the command is age-restricted. Default: false.

#### **Example**

```gml
// Create a simple slash command where the user types /ping
var _guildId = "12344566778";
var _testGuildCommand = new discordGuildCommand("ping", "Just a test.", DISCORD_COMMAND_TYPE.chatInput);

// Callback that outputs the newly created command's id
var _callback = function(){
    show_message("Command created with id: " + string(_responseData.id));
}

myBot.guildCommandCreate(_guildId, _testGuildCommand, _callback);
```

### **`.discordCommandOption(type, name, description, required, [choices], [options], [channelTypes], [minValue], [maxValue], [minLength], [maxLength], [autocomplete])`**
Constructs a new discordCommandOption struct. These are used for commands of the `DISCORD_COMMAND_TYPE.stringInput` type

#### **Parameters**

- **`type`** *(enum.DISCORD_COMMAND_OPTION_TYPE)*: The type of the option. Use the enum DISCORD_COMMAND_OPTION_TYPE.
- **`name`** *(string)*: The name of the option.
- **`description`** *(string)*: The description of the option.
- **`required`** *(bool)*: Whether the option is required.
- **`choices`** *(Array, optional)*: The choices for the option.
- **`options`** *(Array, optional)*: The options for the option.
- **`channelTypes`** *(Array, optional)*: The channel types for the option.
- **`minValue`** *(real, optional)*: The minimum value for the option.
- **`maxValue`** *(real, optional)*: The maximum value for the option.
- **`minLength`** *(real, optional)*: The minimum length for the option.
- **`maxLength`** *(real, optional)*: The maximum length for the option.
- **`autocomplete`** *(bool, optional)*: Whether autocomplete is enabled for the option.

#### **Example**
```gml

```