//
//  FacebookComposer.m
//  Universal
//
//  Created by Obyadur Rahman on 1/2/13.
//
//

#define RETURN_CODE_FACEBOOK_CANCELLED 0
#define RETURN_CODE_FACEBOOK_SENT 1
#define RETURN_CODE_FACEBOOK_NOTSENT 2

#import "FacebookComposer.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DEFacebookComposeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DEFacebookComposeCustom.h"
#import <Social/Social.h>

/*


*/

@interface FacebookComposer ()

-(void) showFacebookComposerWithParameters:(NSDictionary*)parameters;
-(void) returnWithCode:(int)code;
//-(NSString *) getMimeTypeFromFileExtension:(NSString *)extension;

@end

@implementation FacebookComposer
/*
 */


// UNCOMMENT THIS METHOD if you want to use the plugin with versions of cordova < 2.2.0
- (void) showFacebookComposer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options {
    NSLog(@"FACEBOOK Composer- %@",options);
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                [options valueForKey:@"initialText"], @"initialText",
                                [options valueForKey:@"imageString"], @"imageString",
                                [options valueForKey:@"urlString"], @"urlString",
                                nil];
    [self showFacebookComposerWithParameters:parameters];
}

-(void) showFacebookComposerWithParameters:(NSDictionary*)parameters {
    NSLog(@"Calling Facebook Composer- %@",parameters);
    
    /*
    if ( NSClassFromString(@"SLComposeViewController") != nil ) {
    
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                
                int webviewResult = 0;
                
                if (result == SLComposeViewControllerResultCancelled) {
                    
                    NSLog(@"Cancelled");
                    webviewResult = RETURN_CODE_FACEBOOK_CANCELLED;
                    
                } else
                    
                {
                    NSLog(@"Done");
                    webviewResult = RETURN_CODE_FACEBOOK_SENT;
                }
                
                [controller dismissViewControllerAnimated:YES completion:Nil];
                [self returnWithCode:webviewResult];
            };
            controller.completionHandler =myBlock;
            
            [controller setInitialText:@"Test Post from mobile.safilsunny.com"];
            [controller addURL:[NSURL URLWithString:@"http://www.mobile.safilsunny.com"]];
            [controller addImage:[UIImage imageNamed:@"fb.png"]];
            
            [self.viewController presentViewController:controller animated:YES completion:Nil];
            
            
        }
        else{
            NSLog(@"UnAvailable");
            [self returnWithCode:RETURN_CODE_FACEBOOK_NOTSENT];
        }
    }
    */
    

    
    DEFacebookComposeCustom *facebookViewComposer = [[DEFacebookComposeCustom alloc] init];
    
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
    //[facebookViewComposer addImage:[UIImage imageNamed:@"1.jpg"]];
    // and/or
    // optional
        //[facebookViewComposer addURL:[NSURL URLWithString:@"http://applications.3d4medical.com/heart_pro.php"]];
    //[facebookViewComposer addURL:[NSURL URLWithString:[parameters objectForKey:@"urlString"]]];
    
    
    [facebookViewComposer setCompletionHandler:^(DEFacebookComposeCustomResult result) {
        
        int webviewResult = 0;
        
        switch (result) {
            case DEFacebookComposeViewControllerResultCancelled:
                NSLog(@"Facebook Result: Cancelled");
                webviewResult = RETURN_CODE_FACEBOOK_CANCELLED;
                break;
            case DEFacebookComposeViewControllerResultDone:
                NSLog(@"Facebook Result: Sent");
                webviewResult = RETURN_CODE_FACEBOOK_SENT;
                break;
            default:
                webviewResult = RETURN_CODE_FACEBOOK_NOTSENT;
                break;
        }
        
        [facebookViewComposer dismissModalViewControllerAnimated:YES];
        [self returnWithCode:webviewResult];
    }];
    
    // Present the tweet composition view controller modally.
    if (facebookViewComposer != nil) {
        [self.viewController presentViewController:facebookViewComposer animated:YES completion:^{ }];
    } else {
        [self returnWithCode:RETURN_CODE_FACEBOOK_NOTSENT];
    }
    
    [facebookViewComposer release];
    
    
    //[self viewDidLoad];
    //[self PublishToWall];
    
}

// Call the callback with the specified code
-(void) returnWithCode:(int)code {
    [self writeJavascript:[NSString stringWithFormat:@"window.plugins.facebookComposer._didFinishWithResult(%d);", code]];
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
