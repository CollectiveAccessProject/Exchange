var page = require('webpage').create();

var url = 'http://www.collectiveaccess.org/';

//SPECIFY VIEWPORT SIZE OF THE SCREENCAPTURE
page.viewportSize = {
	width: 1280,
	height: 900
};

//SPECIFY CLIP RECTANGLE SIZE OF THE SCREENCAPTURE
page.clipRect = {
	top: 0,
	left: 0,
	width: 1280,
	height: 1280
};

page.open(url, function(status) {
	page.render('screenshot.png');
	phantom.exit();
});
