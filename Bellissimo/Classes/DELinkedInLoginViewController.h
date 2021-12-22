//
//  DELinkedInLoginViewController.h
//  Universal
//
//  Created by Zakir Hossain on 1/10/13.
//
//
#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OATokenManager.h"

@interface DELinkedInLoginViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIWebView *webView;
    //IBOutlet UIActivityIndicatorView *activityIndicator;
    //IBOutlet UITextField *addressBar;
    
    OAToken *requestToken;
    OAToken *accessToken;
    OAConsumer *consumer;
    
    NSDictionary *profile;
    
    BOOL isConnected;
    NSDate* _expirationDate;
    
    // Theses ivars could be made into a provider class
    // Then you could pass in different providers for Twitter, LinkedIn, etc
    NSString *apikey;
    NSString *secretkey;
    NSString *requestTokenURLString;
    NSURL *requestTokenURL;
    NSString *accessTokenURLString;
    NSURL *accessTokenURL;
    NSString *userLoginURLString;
    NSURL *userLoginURL;
    NSString *linkedInCallbackURL;
}
@property(nonatomic,retain)IBOutlet UIWebView *webView;
@property(nonatomic,retain)IBOutlet UIButton *closebtn;
@property(nonatomic,retain)IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL isConnected;
@property(nonatomic, copy) NSDate* expirationDate;

@property(nonatomic, retain) OAToken *requestToken;
@property(nonatomic, retain) OAToken *accessToken;
@property(nonatomic, retain) NSDictionary *profile;
@property(nonatomic, retain) OAConsumer *consumer;

- (void)initLinkedInApi;
- (void)requestTokenFromProvider;
- (void)allowUserToLogin;
- (void)accessTokenFromProvider;

- (BOOL)isSessionValid;
- (void)checkForPreviouslySavedAccessTokenInfo;
- (void)saveAccessTokenKeyInfo;
- (void)saveExpirationDate:(NSString *)msgBody;


- (IBAction)closeLinkedInLoginView:(id)sender;

@end
