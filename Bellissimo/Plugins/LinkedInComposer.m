//
//  LinkedInComposer.m
//  Universal
//
//  Created by Zakir Hossain on 1/9/13.
//
//

#import "LinkedInComposer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DELinkedInCompose.h"
#import "AppDelegate.h"

#define RETURN_CODE_LINKEDIN_CANCELLED 0
#define RETURN_CODE_LINKEDIN_SENT 1
#define RETURN_CODE_LINKEDIN_NOTSENT 2

@interface LinkedInComposer ()

-(void) showLinkedInComposerWithParameters:(NSDictionary*)parameters;
-(void) returnWithCode:(int)code;
//-(NSString *) getMimeTypeFromFileExtension:(NSString *)extension;

@end


@implementation LinkedInComposer


// UNCOMMENT THIS METHOD if you want to use the plugin with versions of cordova < 2.2.0
- (void) showLinkedInComposer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"LINKEDIN Composer- %@",options);
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [options valueForKey:@"initialText"], @"initialText",
                                [options valueForKey:@"imageString"], @"imageString",
                                [options valueForKey:@"urlString"], @"urlString",
                                nil];
    [self showLinkedInComposerWithParameters:parameters];
}

-(void) showLinkedInComposerWithParameters:(NSDictionary*)parameters {
    NSLog(@"Calling LINKEDIN Composer- %@",parameters);
    
    /*
        // set initial Text
        @try {
            NSString* initialText = [parameters objectForKey:@"initialText"];
            if (initialText) {
               // [tweetViewController setInitialText:initialText];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"TweetComposer - Cannot set initial Text; error: %@", exception);
        }
        
        // set image String
        @try {
            NSString* imageString = [parameters objectForKey:@"imageString"];
            if (imageString) {
                //[tweetViewController addImage:[UIImage imageNamed:imageString]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"TweetComposer - Cannot set Image; error: %@", exception);
        }
        
        // set url String
        @try {
            NSString* urlString = [parameters objectForKey:@"urlString"];
            if (urlString) {
                //[tweetViewController addURL:[NSURL URLWithString:urlString]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"TweetComposer - Cannot set URL; error: %@", exception);
        }
    ProfileTabView *profileViewController = [[ProfileTabView alloc] initWithNibName:nil bundle:nil];
    [self.viewController presentModalViewController:profileViewController animated:NO];
    */
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.linkedin==nil) {
        DELinkedInCompose *facebookViewComposer = [[DELinkedInCompose alloc] init];
        
        appDelegate.linkedin = facebookViewComposer;
        
        [facebookViewComposer release];
    }
    
    DELinkedInCompose *facebookViewComposer = [(DELinkedInCompose*)appDelegate.linkedin retain];//[[DELinkedInCompose alloc] init];
    
    // If you want to use the Facebook app with multiple iOS apps you can set an URL scheme suffix
    //    facebookViewComposer.urlSchemeSuffix = @"facebooksample";
    
    self.viewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    //[facebookViewComposer setInitialText:@"Look on this"];
    
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
            [facebookViewComposer setInitialText:initialText];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"TweetComposer - Cannot set initial Text; error: %@", exception);
    }
    
    // optional
    [facebookViewComposer addImage:[UIImage imageNamed:@"1.jpg"]];
    // and/or
    // optional
    //    [facebookViewComposer addURL:[NSURL URLWithString:@"http://applications.3d4medical.com/heart_pro.php"]];
    
    [facebookViewComposer setCompletionHandler:^(DELinkedInComposeResult result) {
        
        int webviewResult = 0;
        
        switch (result) {
            case DELinkedInComposeResultCancelled:
                NSLog(@"Facebook Result: Cancelled");
                webviewResult = RETURN_CODE_LINKEDIN_CANCELLED;
                break;
            case DELinkedInComposeResultDone:
                NSLog(@"Facebook Result: Sent");
                webviewResult = RETURN_CODE_LINKEDIN_SENT;
                break;
            default:
                webviewResult = RETURN_CODE_LINKEDIN_NOTSENT;
                break;
        }
        
        [facebookViewComposer dismissModalViewControllerAnimated:YES];
        [self returnWithCode:webviewResult];
    }];
    
    // Present the tweet composition view controller modally.
    if (facebookViewComposer != nil) {
        [self.viewController presentViewController:facebookViewComposer animated:YES completion:^{ }];
    } else {
        [self returnWithCode:RETURN_CODE_LINKEDIN_NOTSENT];
    }
    
    [facebookViewComposer release];
    

    
}

// Call the callback with the specified code
-(void) returnWithCode:(int)code {
    [self writeJavascript:[NSString stringWithFormat:@"window.plugins.linkedinComposer._didFinishWithResult(%d);", code]];
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
