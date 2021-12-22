//
//  TweetComposer.h
//  Universal
//
//  Created by Obyadur Rahman on 1/2/13.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>


@interface TweetComposer : CDVPlugin


// UNCOMMENT THIS METHOD if you want to use the plugin with versions of cordova < 2.2.0
- (void) showTweetComposer:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
