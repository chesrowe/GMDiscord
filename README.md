# GMDiscord
 Discord API bindings for GameMaker LTS+. Write Discord applications in pure GML and handle interactions via the Discord gateway. This library is still incomplete, but has most of the major functionality from the API. 
 The library follows the [Discord API documentation](https://discord.com/developers/docs/intro) pretty strictly, although not every optional parameter may have been implemented yet for a particular function.
 - Read the docs [here](https://github.com/chesrowe/GMDiscord/wiki)
 
## Installation 
- Download the [latest release](https://github.com/chesrowe/GMDiscord/releases/latest) and import `GMDiscord.yymps` into your project.
- Put the object `obj_discordController` into your first room (it is persistant and needs to be present to handle gateway events)

## Examples
- I created a Discord bot that ai generates Magic the Gathering cards [here](https://github.com/chesrowe/MTG-AI) 
