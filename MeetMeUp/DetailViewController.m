//
//  DetailViewController.m
//  MeetMeUp
//
//  Created by Francis Bato on 10/12/15.
//  Copyright © 2015 Francis Bato. All rights reserved.
//

#import "DetailViewController.h"
#import "WebViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *RSVPCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostingGroupInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIWebView *descriptionWebView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.meetup[@"venue"][@"name"];
    self.RSVPCountLabel.text = [NSString stringWithFormat:@"%@", self.meetup[@"yes_rsvp_count"]];
    self.hostingGroupInfoLabel.text = self.meetup[@"group"][@"name"];

    NSString *decsriptionString = [NSString stringWithFormat:@"%@",self.meetup[@"description"]];

    [self.descriptionWebView loadHTMLString:decsriptionString baseURL:nil];

    [self.descriptionWebView reload];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    WebViewController *webVC = segue.destinationViewController;

    NSString *meetupURL = self.meetup[@"event_url"];
    [meetupURL stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    webVC.urlString = meetupURL;
}


@end
