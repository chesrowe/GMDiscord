// Execute request callbacks for HTTP requests sent 
var _callbackArraySize = array_length(requestCallbacks);
var _markForDeletionArray = [];

var _requestResponseId = async_load[? "id"];

if (_callbackArraySize > 0){
	//Loop through all of the requests and see which one is receving a response
	var _i = 0;
	
	repeat(_callbackArraySize){
		var _currentRequest = requestCallbacks[_i];
		
		if (_currentRequest.__requestId == _requestResponseId){
			var _requestResponse = async_load[? "result"];
			var _responseIsError = __discord_response_is_error(_requestResponse);
			
			if (typeof(_currentRequest.__callback) == "method" && !_responseIsError){		
				//If the response is not an error, execute the callback for that request			
				_currentRequest.__callback();					
			}else if (_responseIsError){
				__discord_error_print(_requestResponse);
			}
			
			array_push(_markForDeletionArray, _i);
		}
		
		_i++;
	}
		
	_i = 0;
		
	repeat(array_length(_markForDeletionArray)){
		array_delete(requestCallbacks, _markForDeletionArray[_i], 1);
		_i++;	
	}
}


