//
//  DetailViewController.m
//  MeetMeUp
//
//  Created by Francis Bato on 10/12/15.
//  Copyright © 2015 Francis Bato. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *RSVPCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostingGroupInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.meetup[@"venue"][@"name"];
    self.RSVPCountLabel.text = self.meetup[@"yes_rsvp_count"];
    self.hostingGroupInfoLabel.text = self.meetup[@"group"][@"name"];
    self.eventDescriptionLabel.text = self.meetup[@"description"];


}



@end
