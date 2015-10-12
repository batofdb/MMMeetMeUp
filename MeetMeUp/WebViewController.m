//
//  WebViewController.m
//  MeetMeUp
//
//  Created by Philip Henson on 10/12/15.
//  Copyright © 2015 Francis Bato. All rights reserved.
//  Taken from following project

//
//  SafariMainViewController.m
//  SafariTNG
//
//  Created by Richard Martinez on 9/30/15.
//  Copyright © 2015 Shotty Shack Games. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIStackView *navigationStackView;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextField *addressBar;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *stopLoadingButton;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *pageTitle;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) NSString *currentPage;
@end

@implementation WebViewController

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadURL:self.urlString];

    self.currentPage = self.webView.request.URL.absoluteString;

    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;


    [self toggleButton:self.backButton toEnable:NO];
    [self toggleButton:self.forwardButton toEnable:NO];
    [self toggleButton:self.refreshButton toEnable:NO];
    self.pageTitle.alpha = 0;

}

-(void)toggleButton:(UIButton *)button toEnable:(BOOL)enable {
    if (enable){
        button.enabled = YES;
        button.alpha = 1;
    } else {
        button.enabled = NO;
        button.alpha = 0.2;
    }
}

#pragma mark - Utility Methods
- (void) loadURL: (NSString *) urlString {
//    if (![urlString hasPrefix:@"http"]) {
//        urlString = [NSString stringWithFormat:@"http://%@", urlString];
//    }

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - WebView Delegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    //  ---------------------------
    //  Update views
    //  ---------------------------
    [self.spinner startAnimating];

    [self toggleButton:self.refreshButton toEnable:NO];
    [self toggleButton:self.stopLoadingButton toEnable:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //  ---------------------------
    //  Update views
    //  ---------------------------
    [self toggleButton:self.backButton toEnable:self.webView.canGoBack];
    [self toggleButton:self.forwardButton toEnable:self.webView.canGoForward];
    [self toggleButton:self.stopLoadingButton toEnable:NO];
    [self toggleButton:self.refreshButton toEnable:YES];

    [self.spinner stopAnimating];

    self.addressBar.text = self.webView.request.URL.absoluteString;
    self.pageTitle.text = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];


    if (![self.webView.request.URL.absoluteString isEqualToString:self.currentPage]) {
        [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.pageTitle.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.75 delay:1.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.pageTitle.alpha = 0.0;
            } completion:nil];
        }];

        self.currentPage = self.webView.request.URL.absoluteString;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Page Load Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *goHomeButton = [UIAlertAction actionWithTitle:@"Go Home"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self loadURL:@"http://www.mobilemakers.co"];
                                                         }];

    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             [self.webView stopLoading];
                                                         }];
    [alert addAction:goHomeButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];

    [self.spinner stopAnimating];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loadURL:textField.text];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y < 0) {

        if (self.addressBar.frame.origin.y > 0) {

            [UIView animateWithDuration:0.5 animations:^{

                self.addressBar.frame = CGRectMake(self.addressBar.frame.origin.x, self.addressBar.frame.origin.y - 2*self.addressBar.frame.size.height, self.addressBar.frame.size.width, self.addressBar.frame.size.height);

                self.doneButton.frame = CGRectMake(self.doneButton.frame.origin.x, self.doneButton.frame.origin.y - 2*self.doneButton.frame.size.height, self.doneButton.frame.size.width, self.doneButton.frame.size.height);

                self.webView.frame = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y - self.addressBar.frame.size.height, self.webView.frame.size.width, self.webView.frame.size.height + 1.5*self.addressBar.frame.size.height + self.navigationStackView.frame.size.height);

                self.navigationStackView.frame = CGRectMake(self.navigationStackView.frame.origin.x, self.navigationStackView.frame.origin.y + self.navigationStackView.frame.size.height, self.navigationStackView.frame.size.width, self.navigationStackView.frame.size.height);

                self.pageTitle.frame = CGRectMake(self.pageTitle.frame.origin.x, self.pageTitle.frame.origin.y + self.navigationStackView.frame.size.height, self.pageTitle.frame.size.width, self.pageTitle.frame.size.height);

                //                self.addressBar.alpha = 0;
                //                self.navigationStackView.alpha = 0;

            }];

        }

    } else if ([scrollView.panGestureRecognizer translationInView:scrollView.superview].y > 0){
        if (self.addressBar.frame.origin.y < 0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.addressBar.frame = CGRectMake(self.addressBar.frame.origin.x, self.addressBar.frame.origin.y + 2*self.addressBar.frame.size.height, self.addressBar.frame.size.width, self.addressBar.frame.size.height);

                self.doneButton.frame = CGRectMake(self.doneButton.frame.origin.x, self.doneButton.frame.origin.y + 2*self.doneButton.frame.size.height, self.doneButton.frame.size.width, self.doneButton.frame.size.height);

                self.webView.frame = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y + self.addressBar.frame.size.height, self.webView.frame.size.width, self.webView.frame.size.height - 1.5*self.addressBar.frame.size.height - self.navigationStackView.frame.size.height);

                self.navigationStackView.frame = CGRectMake(self.navigationStackView.frame.origin.x, self.navigationStackView.frame.origin.y - self.navigationStackView.frame.size.height, self.navigationStackView.frame.size.width, self.navigationStackView.frame.size.height);

                self.pageTitle.frame = CGRectMake(self.pageTitle.frame.origin.x, self.pageTitle.frame.origin.y - self.navigationStackView.frame.size.height, self.pageTitle.frame.size.width, self.pageTitle.frame.size.height);

                self.addressBar.alpha = 1;
                self.navigationStackView.alpha = 1;

            }];


        }

    }
}

#pragma mark - IBAction Methods
- (IBAction)onBackButtonPressed:(UIButton *)sender {
    [self.webView goBack];
}

- (IBAction)onForwardButtonPressed:(UIButton *)sender {
    [self.webView goForward];
}

- (IBAction)onStopLoadingButtonPressed:(UIButton *)sender {
    [self.webView stopLoading];
}

- (IBAction)onReloadButtonPressed:(UIButton *)sender {
    self.currentPage = @"";
    [self.webView reload];
}

- (IBAction)onPlusButtonPressed:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Coming Soon!"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)doneButton:(UIButton *)sender {

    [self dismissViewControllerAnimated:YES completion:^{

    }];
}





@end

