/* File system related functions */

/// @func file_directory_get_contents(dirPath, filter, includeDirs?, recursive?)
/// @Desc Returns an array of every file within a given directory
/// @param {string} dirPath The path of the directory
/// @param {string} filter File extensions to to get ("*.json;*.png;")
/// @param {bool} includeDirs? Whether or not to include folders in the returned array
/// @param {bool} recursive? Whether or not to recursively loop through all subdirectories and include their content
function file_directory_get_contents(dname, pattern, includedirs, recursive) {
	var i = 0; var result = undefined; 
	var tmp = directory_contents_first(dname, pattern, includedirs, recursive);
	while (tmp != "") {
		tmp = string_replace_all(tmp, "\\", "/");
		result[i] = tmp; i++;
		tmp = directory_contents_next();
	}
	directory_contents_close();
	return result;
}

/// @func file_directory_print_contents(dirPath, filter, includeDirs?, recursive?)
/// @Desc Prints the content of a directory to the console
/// @param {string} dirPath The path of the directory
/// @param {string} filter File extensions to to get ("*.json;*.png;")
/// @param {bool} includeDirs? Whether or not to include folders in the returned array
/// @param {bool} recursive? Whether or not to recursively loop through all subdirectories and include their content
function file_directory_print_contents(dname, pattern, includedirs, recursive) {
	var result = file_directory_get_contents(dname, pattern, includedirs, recursive);
	if (!is_undefined(result) && is_array(result)) {
		for (var i = 0; i < array_length(result); i++) {
			show_debug_message(result[i]);
		}
	}
}

/// @func file_executable_get_directory()
/// @desc Returns the file path for the game's executable
function file_executable_get_directory(){
	var _originalPath = executable_get_directory();	
	var _fixedPath = string_replace_all(_originalPath, "\\", "/");
	
	return _fixedPath;
}


/// @func file_project_get_directory()
/// @desc If the game is ran from the IDE, this will return the file path to the game's project file
function file_project_get_directory(){
	var _originalPath = DynamoProjectDirectory();
	var _fixedPath = string_replace_all(_originalPath, "\\", "/");
	
	return _fixedPath;
}

/// @func file_directory_get_appdata_path()
/// @desc Returns the current user's appdata folder path
/// @return string
function file_directory_get_appdata_path(){
	/* The filesystem extension being used here has a function to return the temp files folder
	   within appdata, but we just want appdata so fuck it */
	var _tempPath = directory_get_temporary_path();	
	var _fixedTempPath = string_replace_all(_tempPath, "\\", "/");
	var _appdataPath = string_replace_all(_fixedTempPath, "/Local/Temp/", "/");
	return _appdataPath;
}

/// @func file_directory_exists(directoryName)
/// @desc Checks to see if the given directory exists or not
/// @param {string} directoryName The filepath of the directory to check
function file_directory_exists(_directoryName){
	return directory_exists(_directoryName);
}


/// @func file_directory_create(directoryName)
/// @desc Creates a new directory with the given name
/// @param {string} directoryName The filepath of the directory you wish to create
function file_directory_create(_directoryName){
	directory_create(_directoryName);	
}


