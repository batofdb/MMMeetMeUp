//
//  DetailViewController.m
//  MeetMeUp
//
//  Created by Francis Bato on 10/12/15.
//  Copyright © 2015 Francis Bato. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewController.h"
#import "CommentsViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *RSVPCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostingGroupInfoLabel;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionWebView;
@property int commentCount;
@property NSDictionary *results;
@property NSDictionary *metaData;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

-(void)updateUI{
    self.nameLabel.text = [NSString stringWithFormat:@"%@", self.meetup[@"name"]];
    self.RSVPCountLabel.text = [NSString stringWithFormat:@"RSVP Count: %@", self.meetup[@"yes_rsvp_count"]];
    self.hostingGroupInfoLabel.text = [NSString stringWithFormat:@"Host: %@", self.meetup[@"group"][@"name"]];
    NSString *decsriptionString = [NSString stringWithFormat:@"%@",self.meetup[@"description"]];

    [self makeCommentURL:self.meetup[@"id"]];

    [self.descriptionWebView loadHTMLString:decsriptionString baseURL:nil];
    [self.descriptionWebView reload];

}

-(void)makeCommentURL:(NSString *)eventID{

    NSString *customString =[NSString stringWithFormat:@"https://api.meetup.com/2/event_comments.json?event_id=%@&key=572016383a79486528177a5d12111c", eventID];
    NSURL *url = [NSURL URLWithString:customString];
    [self loadResultsWithUrl:url];
}


-(void)loadResultsWithUrl:(NSURL *)url{

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data){
            self.results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

            self.metaData = self.results[@"meta"];
            self.commentCount = [self.metaData[@"total_count"] intValue];

            dispatch_async(dispatch_get_main_queue(), ^{

                if (self.commentCount == 0){
                    self.commentsButton.enabled = NO;
                    self.commentsButton.titleLabel.text = @"Comments";
                    self.commentsButton.titleLabel.tintColor = [UIColor lightTextColor];
                } else {
                    self.commentsButton.enabled = YES;
                    self.commentsButton.titleLabel.text = [NSString stringWithFormat:@"Comments (%i)", self.commentCount];

                    self.commentsButton.titleLabel.tintColor = [UIColor darkTextColor];
                }

            });

        }

        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No comments found" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            }];

            [alert addAction:dismiss];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }];
    
    [task resume];


}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if ([segue.identifier isEqualToString:@"webViewSegue"]) {
        WebViewController *webVC = segue.destinationViewController;
        NSString *meetupURL = self.meetup[@"event_url"];
        [meetupURL stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        webVC.urlString = meetupURL;
    }
    if ([segue.identifier isEqualToString:@"commentsSegue"]) {
        CommentsViewController *commentVC = segue.destinationViewController;
        NSString *eventID = self.meetup[@"id"];
        commentVC.eventID = eventID;
    }
}


@end
