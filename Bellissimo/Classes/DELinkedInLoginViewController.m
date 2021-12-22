//
//  DELinkedInLoginViewController.m
//  Universal
//
//  Created by Zakir Hossain on 1/10/13.
//
//


#import <Foundation/NSNotificationQueue.h>
#import "DELinkedInLoginViewController.h"


#define API_KEY_LENGTH 12
#define SECRET_KEY_LENGTH 16


@interface DELinkedInLoginViewController ()

@end

@implementation DELinkedInLoginViewController

@synthesize webView,closebtn,activityIndicator;
@synthesize requestToken, accessToken, profile, consumer;
@synthesize isConnected, expirationDate = _expirationDate;



- (void)saveExpirationDate:(NSString *)msgBody {
    
    NSArray *pairs = [msgBody componentsSeparatedByString:@"&"];
    
	for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([[elements objectAtIndex:0] isEqualToString:@"oauth_expires_in"])
        {
            
            // We have an access token, so parse the expiration date.
            NSString *expTime = [elements objectAtIndex:1];
            NSDate *expirationDate = [NSDate distantFuture];
            if (expTime != nil) {
                int expVal = [expTime intValue];
                if (expVal != 0) {
                    expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
                }
            }
            self.expirationDate = expirationDate;
        }
    }
}

-(void)checkForPreviouslySavedAccessTokenInfo{
    // Initially set the isConnected value to NO.
    isConnected = NO;
    
    // Check if there is a previous access token key in the user defaults file.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"LIAccessTokenKey"] &&
        [defaults objectForKey:@"LIExpirationDateKey"]) {
        
        NSData *data =[defaults objectForKey:@"LIAccessTokenKey"];
        self.accessToken = (OAToken*)[NSKeyedUnarchiver unarchiveObjectWithData: data];
        
        
        //self.accessToken = [defaults objectForKey:@"LIAccessTokenKey"];
        self.expirationDate = [defaults objectForKey:@"LIExpirationDateKey"];
        
        // Check if the facebook session is valid.
        // If it’s not valid clear any authorization and mark the status as not connected.
        if (![self isSessionValid]) {
            isConnected = NO;
        }
        else {
            isConnected = YES;
        }
    }
}

-(void)saveAccessTokenKeyInfo{
    if (self.accessToken!=nil && self.expirationDate!=nil) {
        // Save the access token key info into the user defaults.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSData* data= [NSKeyedArchiver archivedDataWithRootObject:self.accessToken];
        
        [defaults setObject:data forKey:@"LIAccessTokenKey"];
        [defaults setObject:self.expirationDate forKey:@"LIExpirationDateKey"];
        [defaults synchronize];
    }
}

- (BOOL)isSessionValid {
    return (self.accessToken != nil && self.expirationDate != nil
            && NSOrderedDescending == [self.expirationDate compare:[NSDate date]]);
    
}

//
// OAuth step 1a:
//
// The first step in the the OAuth process to make a request for a "request token".
// Yes it's confusing that the work request is mentioned twice like that, but it is whats happening.
//
- (void)requestTokenFromProvider
{
    OAMutableURLRequest *request =
    [[[OAMutableURLRequest alloc] initWithURL:requestTokenURL
                                     consumer:self.consumer
                                        token:nil
                                     callback:linkedInCallbackURL
                            signatureProvider:nil] autorelease];
    
    [request setHTTPMethod:@"POST"];
    
    OARequestParameter *nameParam = [[[OARequestParameter alloc] initWithName:@"scope"
                                                                       value:@"r_basicprofile+rw_nus"] autorelease];
    NSArray *params = [NSArray arrayWithObjects:nameParam, nil];
    [request setParameters:params];
    OARequestParameter * scopeParameter=[OARequestParameter requestParameter:@"scope" value:@"r_fullprofile rw_nus"];
    
    [request setParameters:[NSArray arrayWithObject:scopeParameter]];
    
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenResult:didFinish:)
                  didFailSelector:@selector(requestTokenResult:didFail:)];
}

//
// OAuth step 1b:
//
// When this method is called it means we have successfully received a request token.
// We then show a webView that sends the user to the LinkedIn login page.
// The request token is added as a parameter to the url of the login page.
// LinkedIn reads the token on their end to know which app the user is granting access to.
//
- (void)requestTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    if (ticket.didSucceed == NO)
        return;
    
    NSString *responseBody = [[[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding] autorelease];
    self.requestToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
    
    //[responseBody release];
    [self allowUserToLogin];
}

- (void)requestTokenResult:(OAServiceTicket *)ticket didFail:(NSData *)error
{
    NSLog(@"%@",[error description]);
}

//
// OAuth step 2:
//
// Show the user a browser displaying the LinkedIn login page.
// They type username/password and this is how they permit us to access their data
// We use a UIWebView for this.
//
// Sending the token information is required, but in this one case OAuth requires us
// to send URL query parameters instead of putting the token in the HTTP Authorization
// header as we do in all other cases.
//
- (void)allowUserToLogin
{
    NSString *userLoginURLWithToken = [NSString stringWithFormat:@"%@?oauth_token=%@",
                                       userLoginURLString, self.requestToken.key];
    
    userLoginURL = [NSURL URLWithString:userLoginURLWithToken];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL: userLoginURL];
    [webView loadRequest:request];
}


//
// OAuth step 3:
//
// This method is called when our webView browser loads a URL, this happens 3 times:
//
//      a) Our own [webView loadRequest] message sends the user to the LinkedIn login page.
//
//      b) The user types in their username/password and presses 'OK', this will submit
//         their credentials to LinkedIn
//
//      c) LinkedIn responds to the submit request by redirecting the browser to our callback URL
//         If the user approves they also add two parameters to the callback URL: oauth_token and oauth_verifier.
//         If the user does not allow access the parameter user_refused is returned.
//
//      Example URLs for these three load events:
//          a) https://www.linkedin.com/uas/oauth/authorize?oauth_token=<token value>
//
//          b) https://www.linkedin.com/uas/oauth/authorize/submit   OR
//             https://www.linkedin.com/uas/oauth/authenticate?oauth_token=<token value>&trk=uas-continue
//
//          c) hdlinked://linkedin/oauth?oauth_token=<token value>&oauth_verifier=63600     OR
//             hdlinked://linkedin/oauth?user_refused
//
//
//  We only need to handle case (c) to extract the oauth_verifier value
//
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
    
    [activityIndicator startAnimating];
    
    BOOL requestForCallbackURL = ([urlString rangeOfString:linkedInCallbackURL].location != NSNotFound);
    if ( requestForCallbackURL )
    {
        BOOL userAllowedAccess = ([urlString rangeOfString:@"user_refused"].location == NSNotFound);
        if ( userAllowedAccess )
        {
            [self.requestToken setVerifierWithUrl:url];
            [self accessTokenFromProvider];
        }
        else
        {
            // User refused to allow our app access
            // Notify parent and close this view
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"loginViewDidFinish"
             object:self
             userInfo:nil];
            
            [self removeFromParentViewController];
            //[self dismissModalViewControllerAnimated:YES];
        }
    }
    else
    {
        // Case (a) or (b), so ignore it
    }
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [activityIndicator stopAnimating];
    self.webView.alpha = 1.0;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [activityIndicator stopAnimating];
    self.webView.alpha = 1.0;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [activityIndicator startAnimating];
    self.webView.alpha = 0.5;
}
//
// OAuth step 4:
//
- (void)accessTokenFromProvider
{
    OAMutableURLRequest *request =
    [[[OAMutableURLRequest alloc] initWithURL:accessTokenURL
                                     consumer:self.consumer
                                        token:self.requestToken
                                     callback:nil
                            signatureProvider:nil] autorelease];
    
    [request setHTTPMethod:@"POST"];
    OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenResult:didFinish:)
                  didFailSelector:@selector(accessTokenResult:didFail:)];
}

- (void)accessTokenResult:(OAServiceTicket *)ticket didFinish:(NSData *)data
{
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    BOOL problem = ([responseBody rangeOfString:@"oauth_problem"].location != NSNotFound);
    if ( problem )
    {
        NSLog(@"Request access token failed.");
        NSLog(@"%@",responseBody);
    }
    else
    {
        self.accessToken = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
        //[self saveExpirationDate:responseBody];
        //[self saveAccessTokenKeyInfo];
    }
    // Notify parent and close this view
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"loginViewDidFinish"
     object:self];
    
    [self.view removeFromSuperview];
    //[self removeFromParentViewController];
    //[self dismissModalViewControllerAnimated:YES];
    [responseBody release];
}

//
//  This api consumer data could move to a provider object
//  to allow easy switching between LinkedIn, Twitter, etc.
//
- (void)initLinkedInApi
{
    
    //apikey = @"kff63w7ud8i5";
    //secretkey = @"hOU1atTQUQgpWfxT";
    
    apikey = @"4rz0ovlqygam";
    secretkey = @"09gfos530H9u2OfL";
    
    self.consumer = [[[OAConsumer alloc] initWithKey:apikey
                                             secret:secretkey
                                              realm:@"http://api.linkedin.com/"] autorelease];
    
    requestTokenURLString = @"https://api.linkedin.com/uas/oauth/requestToken";
    accessTokenURLString = @"https://api.linkedin.com/uas/oauth/accessToken";
    userLoginURLString = @"https://www.linkedin.com/uas/oauth/authorize";
    linkedInCallbackURL = @"hdlinked://linkedin/oauth";
    
    requestTokenURL = [[NSURL URLWithString:requestTokenURLString] retain];
    accessTokenURL = [[NSURL URLWithString:accessTokenURLString] retain];
    userLoginURL = [[NSURL URLWithString:userLoginURLString] retain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLinkedInApi];
    //[addressBar setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([apikey length] < API_KEY_LENGTH || [secretkey length] < SECRET_KEY_LENGTH)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"OAuth Starter Kit"
                              message: @"You must add your apikey and secretkey.  See the project file readme.txt"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        // Notify parent and close this view
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"loginViewDidFinish"
         object:self];
        
        //[self removeFromParentViewController];
        [self.view removeFromSuperview];
        //[self dismissModalViewControllerAnimated:YES];
    }
    
    [self requestTokenFromProvider];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_expirationDate release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    NSLog(@"Rotate");
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAll;
}

- (IBAction)closeLinkedInLoginView:(id)sender {
    
    NSLog(@"Close Login View");
    //[self removeFromParentViewController];
    [self.view removeFromSuperview];
}


@end
