/// Async Networking event
var _data = async_load;
var _socketId = _data[? "id"];

var _i = 0;

repeat(array_length(obj_discordController.botArray)){
	var _currentBot = obj_discordController.botArray[_i];
	
	if (_currentBot.__gatewaySocket == _socketId){
		/// Async Networking event
		switch (async_load[? "type"]) {
			case network_type_connect:
				//IDK
		        break;
			
			case network_type_disconnect:
				var _url = "wss://gateway.discord.gg/?v=10&encoding=json";
				_currentBot.__gatewaySocket = network_create_socket_ext(network_socket_wss, 443);
				_currentBot.__gatewayConnection = network_connect_raw_async(_currentBot.__gatewaySocket, _url, 443);
				show_message("DISCONNECTED");
				break;

			case network_type_data:
				var _receivedData = __discord_gateWay_event_parse();
		
				// Store the sequence number if it exists
				if (_receivedData.s != pointer_null) {
				    global.__gatewaySequenceNumber = _receivedData.s;
				}

				// Event Handling
				switch (_receivedData.op){
				    case GATEWAY_OP_CODE.hello:
						_currentBot.__gatewaySendHeartbeat();
				        var _heartbeatInterval = floor(_receivedData.d.heartbeat_interval / 1000);  // Convert ms to seconds
						show_debug_message(_heartbeatInterval);
						//Create a Time Source to send heartbeats
						var _heartbeatTimeSource = time_source_create(
					        time_source_global,
					        _heartbeatInterval,
					        time_source_units_seconds,
					        _currentBot.__gatewaySendHeartbeat,
							[],
							-1
				        );
				        time_source_start(_heartbeatTimeSource);					
				        break;
				
					case GATEWAY_OP_CODE.heartbeatACK:
						__discordTrace("Heartbeat received");
						break;
				
					case GATEWAY_OP_CODE.heartbeat:
						__discordTrace("Heatbeat required");
						_currentBot.__gatewaySendHeartbeat();
						break;
				
					case GATEWAY_OP_CODE.dispatch:
						if (is_string(_receivedData.t)){
							__discordTrace(_receivedData.t);
							switch (_receivedData.t){
								case "READY":
									_currentBot.__gatewayIndentityHandshake = true;
									__discordTrace("Identity handshake complete");
									break;
								
								default: 
									if (variable_struct_exists(_currentBot.gatewayEventCallbacks, _receivedData.t)){
										var _callback = _currentBot.gatewayEventCallbacks[$	_receivedData.t];
										_callback();
									}
									break
							}
						}
						break;
				}
				break;
		}	
	}
	
	_i++;
}

