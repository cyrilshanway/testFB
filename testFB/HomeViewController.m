//
//  HomeViewController.m
//  testFB
//
//  Created by Cyrilshanway on 2014/12/3.
//  Copyright (c) 2014年 Cyrilshanway. All rights reserved.
//

#import "HomeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFNetworking.h"

@interface HomeViewController ()

@property (readonly, nonatomic, strong) UIImage *responseImage;
@property (nonatomic,strong)UIImage *profileImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *takePicBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;



@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [FBAppEvents activateApp];
//    
//    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.center = self.view.center;
//    
//    //loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), 5);
//    [self.view addSubview:loginView];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonClicked:(id)sender
{
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    } else {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"publish_actions", @"read_stream"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
                 if (error) {
                     // Handle error
                     NSLog(@"[fb login] an error occurs");
                 }
                 else {
                     NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
                     
                     [userData setObject:[FBuser objectForKey:@"id"] forKey:@"id"];
                     
                     if ([[FBuser allKeys] containsObject:@"email"])
                         [userData setObject:[FBuser objectForKey:@"email"]  forKey:@"UserName"];
                     else
                         [userData setObject:@""  forKey:@"UserName"];
                     
                     if ([[FBuser allKeys] containsObject:@"name"])
                         [userData setObject:[FBuser objectForKey:@"name"]   forKey:@"NickName"];
                     else
                         [userData setObject:@""  forKey:@"NickName"];
                     
                     NSString *fbAccessToken = [[[FBSession activeSession] accessTokenData] accessToken];
                     NSDate *expireationdate = [[[FBSession activeSession] accessTokenData] expirationDate];
                     
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     
                     [defaults setObject:fbAccessToken forKey:@"FBAccessTokenKey"];
                     [defaults setObject:expireationdate forKey:@"FBExpirationDateKey"];
                     
                     [defaults synchronize];
                     
                     NSString *profileImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=33&height=33", [FBuser objectForKey:@"id"]];
                     
                     [defaults setObject:profileImageURL forKey:@"Photo"];
                     
                     NSURL *imageURL = [NSURL URLWithString:profileImageURL];
                     AFImageRequestOperation* imageOperation = [AFImageRequestOperation imageRequestOperationWithRequest: [NSURLRequest requestWithURL:imageURL] success:^(UIImage *image) {
                         NSLog(@"Get Image from facebook");
                         self.profileImage = image;
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:nil];
                     }];
                     
                     NSOperationQueue* queue = [[NSOperationQueue alloc] init];
                     [queue addOperation:imageOperation];
                     
                     //[self.delegate loginReturn:YES userInfo:userData FailWithError:nil];
                 }
             }];
         }];
    }
}

- (BOOL)isFBsessionValid
{
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults objectForKey:@"GeneralAccessTokenKey"];
    if (accessToken == nil)
        return NO;
    
    if (FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        return YES;
    }
    else {
        return NO;
    }
}
- (IBAction)takePicBtnPressed:(id)sender {
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
