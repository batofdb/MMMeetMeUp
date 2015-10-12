//
//  MemberViewController.m
//  MeetMeUp
//
//  Created by Francis Bato on 10/12/15.
//  Copyright © 2015 Francis Bato. All rights reserved.
//

#import "MemberViewController.h"

@interface MemberViewController ()
@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;


@property NSDictionary *results;

@end

@implementation MemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    [self makeMemberInfoURL:self.memberID];

}


-(void)makeMemberInfoURL:(NSString *)memberID{

    NSString *customString =[NSString stringWithFormat:@"https://api.meetup.com/2/member/%@.json?&key=572016383a79486528177a5d12111c", memberID];
    NSURL *url = [NSURL URLWithString:customString];
    [self loadResultsWithUrl:url];
}


-(void)loadResultsWithUrl:(NSURL *)url{

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data){
            self.results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                //  NSLog(@"log");

                self.memberNameLabel.text = self.results[@"name"];

                self.locationLabel.text = [NSString stringWithFormat:@"%@, %@", self.results[@"city"],self.results[@"country"]];

                self.bioLabel.text = self.results[@"bio"];


                NSString *photoURL = self.results[@"photo"][@"photo_link"];
                [photoURL stringByReplacingOccurrencesOfString:@"\\" withString:@""];


                NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photoURL]];
                self.profileImageView.image = [UIImage imageWithData:imageData];
            });

        }

        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No comments" message:@"No comments found with this meetup." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            }];

            [alert addAction:dismiss];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }];
    
    [task resume];
}
@end
