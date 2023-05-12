// Execute request callbacks
var _callbackArraySize = array_length(requestCallbacks);
var _markForDeletionArray = [];

if (_callbackArraySize > 0){
	var _i = 0;
	
	repeat(_callbackArraySize){
		var _currentRequest = requestCallbacks[_i];
		
		if (_currentRequest.__requestId == async_load[? "id"]){
			if (typeof(_currentRequest.__callback) == "method"){
				_currentRequest.__callback();	
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


