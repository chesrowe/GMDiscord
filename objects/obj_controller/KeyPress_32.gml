var _guildId = "1090453953482866738";
var _userId = "1101162577725227108";
var _channelId = "1113607940977463387"

var _callback = function(_response) {
    var _roles = _response;
    
    // Process the roles data
    for (var i = 0; i < array_length(_roles); i++) {
        var _role = _roles[i];
        var _roleId = _role.id;
        var _roleName = _role.name;
        
        show_debug_message("Role ID: " + _roleId);
        show_debug_message("Role Name: " + _roleName);
    }
};

// Call the method
myBot.guildRolesGet(_guildId, _callback);