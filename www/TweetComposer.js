// window.plugins.tweetComposer

function TweetComposer() {
	this.resultCallback = null; // Function
}

TweetComposer.ComposeResultType = {
Cancelled:0,
Sent:1,
NotSent:2
}



// showTweetComposer : all args optional
TweetComposer.prototype.showTweetComposer = function(initialText,imageString,urlString) {
	var args = {};
	if(initialText)
		args.initialText = initialText;
	if(imageString)
		args.imageString = imageString;
	if(urlString)
		args.urlString = urlString;
	
	cordova.exec(null, null, "TweetComposer", "showTweetComposer", [args]);
}

TweetComposer.prototype.showTweetComposerWithCallback = function(callback, initialText, imageString,urlString) {
	this.resultCallback = callback;
	this.showTweetComposer.apply(this,[initialText,imageString,urlString]);
}

TweetComposer.prototype._didFinishWithResult = function(res) {
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
					   
					   window.plugins.tweetComposer = new TweetComposer();
					   });