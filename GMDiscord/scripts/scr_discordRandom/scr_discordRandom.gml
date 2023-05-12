/// @param {id.buffer} buffer
/// @param {real} ?bytesPerRow
/// @returns {string} text representation
function buffer_prettyprint(_buf, _per_row = 20) {
    static _out = buffer_create(16, buffer_grow, 1);
    static _chars = buffer_create(16, buffer_grow, 1);
    buffer_seek(_out, buffer_seek_start, 0);
    buffer_seek(_chars, buffer_seek_start, 0);
    var _size = buffer_get_size(_buf);
    var _tell = buffer_tell(_buf);
    
    // header:
    buffer_write(_out, buffer_text, "buffer(size: ");
    buffer_write(_out, buffer_text, string(_size));
    buffer_write(_out, buffer_text, ", tell: ");
    buffer_write(_out, buffer_text, string(_tell));
    buffer_write(_out, buffer_text, ", type: ");
    switch (buffer_get_type(_buf)) {
        case buffer_fixed:   buffer_write(_out, buffer_text, "buffer_fixed"  ); break;
        case buffer_grow:    buffer_write(_out, buffer_text, "buffer_grow"   ); break;
        case buffer_fast:    buffer_write(_out, buffer_text, "buffer_fast"   ); break;
        case buffer_wrap:    buffer_write(_out, buffer_text, "buffer_wrap"   ); break;
        case buffer_vbuffer: buffer_write(_out, buffer_text, "buffer_vbuffer"); break;
        default: buffer_write(_out, buffer_text, string(buffer_get_type(_buf))); break;
    }
    buffer_write(_out, buffer_text, "):");
    
    for (var i = 0; i < _size; i++) {
        if (i % _per_row == 0) { // row start
            if (i > 0) { // printable chars
                buffer_write(_out, buffer_text, " | ");
                buffer_write(_chars, buffer_u8, 0);
                buffer_seek(_chars, buffer_seek_start, 0);
                buffer_write(_out, buffer_text, buffer_read(_chars, buffer_string));
                buffer_seek(_chars, buffer_seek_start, 0);
            }
            
            buffer_write(_out, buffer_u8, ord("\n"));
            buffer_write(_out, buffer_text, string_format(i, 6, 0));
            buffer_write(_out, buffer_text, " |");
        }
        buffer_write(_out, buffer_u8, i == _tell ? ord(">") : ord(" "));
        var _byte = buffer_peek(_buf, i, buffer_u8);
        
        // write byte if in printable range or an "unknown" symbol otherwise
        if (_byte >= 32 && _byte < 128) {
            buffer_write(_chars, buffer_u8, _byte);
        } else {
            buffer_write(_chars, buffer_text, "·");
        }
        
        // write the hexadecimal presentation:
        var _hex = _byte >> 4;
        buffer_write(_out, buffer_u8, _hex >= 10 ? ord("A") - 10 + _hex : ord("0") + _hex);
        _hex = _byte & 15;
        buffer_write(_out, buffer_u8, _hex >= 10 ? ord("A") - 10 + _hex : ord("0") + _hex);
    }
    
    // last row's spaces and printable chars:
    if (_size % _per_row != 0) {
        repeat (_per_row - (_size % _per_row)) {
            buffer_write(_out, buffer_text, "   ");
        }
    }
    buffer_write(_out, buffer_text, " | ");
    buffer_write(_chars, buffer_u8, 0);
    buffer_seek(_chars, buffer_seek_start, 0);
    buffer_write(_out, buffer_text, buffer_read(_chars, buffer_string));
    
    buffer_write(_out, buffer_u8, 0);
    buffer_seek(_out, buffer_seek_start, 0);
    return buffer_read(_out, buffer_text);
}

/// @function array_merge(_array1, _array2)
/// @param {array} array1 First array to merge
/// @param {array} array2 Second array to merge
/// @return {array} Merged array containing elements from both input arrays
function array_merge(_array1, _array2) {
    var _mergedArray = [];
    var _length1 = array_length(_array1);
    var _length2 = array_length(_array2);
    
    // Copy elements from the first array to the merged array
    for (var _i = 0; _i < _length1; _i++) {
        _mergedArray[_i] = _array1[_i];
    }
    
    // Copy elements from the second array to the merged array
    for (var _i = 0; _i < _length2; _i++) {
        _mergedArray[_length1 + _i] = _array2[_i];
    }
    
    return _mergedArray;
}
