//
//  ViewController.m
//  MalltipProfile
//
//  Created by DJ Mitchell on 4/5/15.
//  Copyright (c) 2015 Killectro. All rights reserved.
//

#import "ViewController.h"
#import "JEProgressView.h"
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UIImageView+AFNetworking.h"

NSString *const kMapMarkerIcon = @"\uf041";
NSString *const kCancelText = @"CANCEL";
NSString *const kImportFromFacebookText = @"IMPORT FROM FACEBOOK";
NSUInteger const kFacebookScore = 20;
NSUInteger const kTwitterScore = 20;
NSUInteger const kShareScore = 30;
NSUInteger const kPointsPerLevel = 100;

@interface ViewController ()

// Header properties
// We use a custom control to get around this iOS bug that has yet to be fixed: http://stackoverflow.com/questions/22311516/uiprogressview-custom-track-and-progress-images-in-ios-7-1
@property (weak, nonatomic) IBOutlet JEProgressView *levelProgressView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
// Use a label to overlay the + button on the image. Ideally we would have an asset for this so we don't have to create it programatically
@property (weak, nonatomic) IBOutlet UILabel *plusButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *mapMarkerIcon;

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

// Miscellaneous properties
@property (strong, nonatomic) NSNumberFormatter *formatter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createMapMarkerIcon];
    [self customizeButtons];
    [self customizeImageView];
    [self customizeProgressView];
    [self updateScoreInterface];
    
    // TODO: Mention the bug with Facebook
    // TODO: Mention the bug with UIProgressView
    // TODO: Mention the bug with JEProgressView and UIAlertController (that's the reason why I had to use UIAlertView/UIActionSheet)
}

#pragma mark - Custom accessors

- (NSNumberFormatter *)formatter {
    // Creating a number formatter is computationally expensive and we know we will only do it once, let's only do it once
    if (_formatter) return _formatter;
    
    _formatter = [[NSNumberFormatter alloc] init];
    _formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return _formatter;
}

- (NSUInteger)level {
    _level = (NSUInteger) self.totalScore / kPointsPerLevel;
    return _level;
}

- (NSUInteger)currentProgress {
    _currentProgress = self.totalScore % kPointsPerLevel;
    return _currentProgress;
}

#pragma mark - UI Customization 

- (void)createMapMarkerIcon {
    // This unicode value corresponds to the font-awesome icon for a map marker
    self.mapMarkerIcon.text = kMapMarkerIcon;
}

- (void)customizeImageView {
    [self roundViewEdge:self.profileImageView cornerRadius:self.profileImageView.frame.size.height / 2];
    [self roundViewEdge:self.plusButtonLabel cornerRadius:self.plusButtonLabel.frame.size.height / 2];
    
    self.plusButtonLabel.backgroundColor = [UIColor colorWithRed:255.f green:255.f blue:255.f alpha:.2f];
}

- (void)customizeButtons {
    self.facebookButton.backgroundColor = [UIColor whiteColor];
    self.twitterButton.backgroundColor = [UIColor whiteColor];
    self.shareButton.backgroundColor = [UIColor whiteColor];
    [self roundViewEdge:self.facebookButton cornerRadius:3.f];
    [self roundViewEdge:self.twitterButton cornerRadius:3.f];
    [self roundViewEdge:self.shareButton cornerRadius:3.f];
    [self addBorderToView:self.facebookButton];
    [self addBorderToView:self.twitterButton];
    [self addBorderToView:self.shareButton];
}

- (void)roundViewEdge:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}

- (void)addBorderToView:(UIView *)view {
    view.layer.borderColor = [[UIColor colorWithRed:180/255 green:180/255 blue:180/225 alpha:.25f] CGColor];
    view.layer.borderWidth = 1.f;
}

- (void)customizeProgressView {
    self.levelProgressView.progressImage = [[UIImage imageNamed:@"progress-indicator-striped-image"] resizableImageWithCapInsets:UIEdgeInsetsZero];
    self.levelProgressView.clipsToBounds = YES;
    self.levelProgressView.layer.cornerRadius = 3.f;
}

- (void)setProfileImage:(NSURL *)imageURL {
    // Set their profile image
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    
    // Use AFNetworking here because it gives you a nice API you can use to retrieve images, plus it gives you image caching for free.
    [self.profileImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.profileImageView.image = image;
        self.plusButtonLabel.hidden = YES;
        [self endNetworkActivity];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [self displayProfileImageError];
        [self endNetworkActivity];
    }];
}

#pragma mark - UI Actions

- (IBAction)facebookButtonPressed:(id)sender {
    [self incrementScore:kFacebookScore];
}

- (IBAction)twitterButtonPressed:(id)sender {
    [self incrementScore:kTwitterScore];
}

- (IBAction)shareButtonPressed:(id)sender {
    [self incrementScore:kShareScore];
}

- (IBAction)addPhotoPressed:(id)sender {

    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:kCancelText destructiveButtonTitle:nil otherButtonTitles:kImportFromFacebookText, nil] showInView:self.view];
}

- (void)beginNetworkActivity {
    [self.activityIndicator startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)endNetworkActivity {
    [self.activityIndicator stopAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)displayProfileImageError {
    [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                message:@"Something went wrong while retrieving your Facebook profile picture."
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

#pragma mark - Score logic

- (void)incrementScore:(NSUInteger)increment {
    self.totalScore += increment;
    [self updateScoreInterface];
}

- (void)updateScoreInterface {
    self.pointsLabel.text = [NSString stringWithFormat:@"%@ POINTS", [self.formatter stringFromNumber:@(self.totalScore)]];
    self.levelLabel.text = [NSString stringWithFormat:@"LEVEL %@", [self.formatter stringFromNumber:@(self.level)]];
    
    // Dividing our current progress by our max points per level will get us our progress between 0-1
    float progress = (float)self.currentProgress / kPointsPerLevel;
    [self.levelProgressView setProgress:progress animated:YES];
}

#pragma mark - Facebook methods

- (void)getFacebookProfileImageURL:(void (^)(NSURL *imageURL))completion {
    // You have to pass a completion block
    NSParameterAssert(completion);
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, NSDictionary *result, NSError *error) {
        if (!error) {
            NSString *userID = result[@"id"];
            CGFloat width = self.profileImageView.frame.size.width;
            CGFloat height = self.profileImageView.frame.size.height;
            
            NSString *profileImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&width=%d&height=%d", userID, (int)width, (int)height];
            
            completion([NSURL URLWithString:profileImageURL]);
        }
        else {
            completion(nil);
        }
    }];
}

- (void)setFacebookImage {
    
    [self beginNetworkActivity];

    // Determine whether or not the user is logged in already
    if ([FBSDKAccessToken currentAccessToken]) {
        // Get their user ID
        [self getFacebookProfileImageURL:^(NSURL *imageURL) {
            
            if (imageURL) {
                [self setProfileImage:imageURL];
            }
            else {
                [self displayProfileImageError];
                [self endNetworkActivity];
            }
        }];
    }
    else {
        // Ask the user to log in so we can access their profile picture
        [[FBSDKLoginManager new] logInWithReadPermissions:@[@"public_profile"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            
            // Get their user ID
            [self getFacebookProfileImageURL:^(NSURL *imageURL) {
                
                if (imageURL) {
                    [self setProfileImage:imageURL];
                }
                else {
                    [self displayProfileImageError];
                    [self endNetworkActivity];
                }
            }];
        }];
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:kImportFromFacebookText]) {
        [self setFacebookImage];
    }
}

#pragma mark - Miscellaneous 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
