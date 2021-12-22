//
//  TweetComposer.m
//  Universal
//
//  Created by Obyadur Rahman on 1/2/13.
//
//

#define RETURN_CODE_TWEET_CANCELLED 0
#define RETURN_CODE_TWEET_SENT 1
#define RETURN_CODE_TWEET_NOTSENT 2

#import "TweetComposer.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface TweetComposer ()

-(void) showTweetComposerWithParameters:(NSDictionary*)parameters;
-(void) returnWithCode:(int)code;
//-(NSString *) getMimeTypeFromFileExtension:(NSString *)extension;

@end

@implementation TweetComposer


// UNCOMMENT THIS METHOD if you want to use the plugin with versions of cordova < 2.2.0
- (void) showTweetComposer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"Native TWEET Composer- %@",options);
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [options valueForKey:@"initialText"], @"initialText",
                                [options valueForKey:@"imageString"], @"imageString",
                                [options valueForKey:@"urlString"], @"urlString",
                                nil];
    [self showTweetComposerWithParameters:parameters];
}

-(void) showTweetComposerWithParameters:(NSDictionary*)parameters {
    NSLog(@"Calling TWEET Composer- %@",parameters);
    if ([TWTweetComposeViewController canSendTweet]) {
    
        // Set up the built-in twitter composition view controller.
        TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
        
        // Set the initial tweet text. See the framework for additional properties that can be set.
        //[tweetViewController setInitialText:@"Hello. This is a tweet."];
        
        // set initial Text
        @try {
            NSString* initialText = [parameters objectForKey:@"initialText"];
            /*initialText = [initialText stringByReplacingOccurrencesOfString:@"<strong>"
                                                                 withString:@""];
            initialText = [initialText stringByReplacingOccurrencesOfString:@"</strong>"
                                                                 withString:@""];*/
            initialText = [initialText stringByReplacingOccurrencesOfString:@"<br>"
                                                                 withString:@"\n"];
            
            if (initialText) {
                [tweetViewController setInitialText:initialText];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"TweetComposer - Cannot set initial Text; error: %@", exception);
        }
        
        // set image String
        @try {
            NSString* imageString = [parameters objectForKey:@"imageString"];
            if (imageString) {
                [tweetViewController addImage:[UIImage imageNamed:imageString]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"TweetComposer - Cannot set Image; error: %@", exception);
        }
        
        // set url String
        @try {
            NSString* urlString = [parameters objectForKey:@"urlString"];
            if (urlString) {
                [tweetViewController addURL:[NSURL URLWithString:urlString]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"TweetComposer - Cannot set URL; error: %@", exception);
        }
        
        // Create the completion handler block.
        [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {

            int webviewResult = 0;
            
            switch (result) {
                case TWTweetComposeViewControllerResultCancelled:
                    // The cancel button was tapped.
                    webviewResult = RETURN_CODE_TWEET_CANCELLED;
                    break;
                case TWTweetComposeViewControllerResultDone:
                    // The tweet was sent.
                    webviewResult = RETURN_CODE_TWEET_SENT;
                    break;
                default:
                    webviewResult = RETURN_CODE_TWEET_NOTSENT;
                    break;
            }
            
            // Dismiss the tweet composition view controller.
            [tweetViewController dismissModalViewControllerAnimated:YES];
            [self returnWithCode:webviewResult];
        }];
        
        // Present the tweet composition view controller modally.
        if (tweetViewController != nil) {
            [self.viewController presentModalViewController:tweetViewController animated:YES];
        } else {
            [self returnWithCode:RETURN_CODE_TWEET_NOTSENT];
        }
        
        [tweetViewController release];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self returnWithCode:RETURN_CODE_TWEET_NOTSENT];
        
    }
    
}

// Call the callback with the specified code
-(void) returnWithCode:(int)code {
    [self writeJavascript:[NSString stringWithFormat:@"window.plugins.tweetComposer._didFinishWithResult(%d);", code]];
}

/*
// Retrieve the mime type from the file extension
-(NSString *) getMimeTypeFromFileExtension:(NSString *)extension {
    if (!extension)
        return nil;
    CFStringRef pathExtension, type;
    // Get the UTI from the file's extension
    pathExtension = (CFStringRef)extension;
    type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    
    // Converting UTI to a mime type
    return (NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
}
*/

@end
