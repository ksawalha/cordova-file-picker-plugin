var exec = require('cordova/exec');

exports.selectFiles = function(success, error) {
    exec(success, error, "FilePicker", "selectFiles", []);
};
