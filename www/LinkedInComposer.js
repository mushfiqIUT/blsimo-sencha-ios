// window.plugins.tweetComposer

function LinkedInComposer() {
	this.resultCallback = null; // Function
}

LinkedInComposer.ComposeResultType = {
Cancelled:0,
Sent:1,
NotSent:2
}



// showLinkedInComposer : all args optional
LinkedInComposer.prototype.showLinkedInComposer = function(initialText,imageString,urlString) {
	var args = {};
	if(initialText)
		args.initialText = initialText;
	if(imageString)
		args.imageString = imageString;
	if(urlString)
		args.urlString = urlString;
	
	cordova.exec(null, null, "LinkedInComposer", "showLinkedInComposer", [args]);
}

LinkedInComposer.prototype.showLinkedInComposerWithCallback = function(callback, initialText, imageString,urlString) {
	this.resultCallback = callback;
	this.showLinkedInComposer.apply(this,[initialText,imageString,urlString]);
}

LinkedInComposer.prototype._didFinishWithResult = function(res) {
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
					   
					   window.plugins.linkedinComposer = new LinkedInComposer();
					   });