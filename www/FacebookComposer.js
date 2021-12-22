// window.plugins.tweetComposer

function FacebookComposer() {
	this.resultCallback = null; // Function
}

FacebookComposer.ComposeResultType = {
Cancelled:0,
Sent:1,
NotSent:2
}



// showFacebookComposer : all args optional
FacebookComposer.prototype.showFacebookComposer = function(initialText,imageString,urlString) {
	var args = {};
	if(initialText)
		args.initialText = initialText;
	if(imageString)
		args.imageString = imageString;
	if(urlString)
		args.urlString = urlString;
	
	cordova.exec(null, null, "FacebookComposer", "showFacebookComposer", [args]);
}

FacebookComposer.prototype.showFacebookComposerWithCallback = function(callback, initialText, imageString,urlString) {
	this.resultCallback = callback;
	this.showFacebookComposer.apply(this,[initialText,imageString,urlString]);
}

FacebookComposer.prototype._didFinishWithResult = function(res) {
	this.resultCallback(res);
}

cordova.addConstructor(function()  {
					   if(!window.plugins)
					   {
					   window.plugins = {};
					   }
					   
					   // shim to work in 1.5 and 1.6
					   if (!window.Cordova) {
					   window.Cordova = cordova;
					   };
					   
					   window.plugins.facebookComposer = new FacebookComposer();
					   });