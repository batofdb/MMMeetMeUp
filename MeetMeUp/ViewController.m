//
//  ViewController.m
//  MeetMeUp
//
//  Created by Francis Bato on 10/12/15.
//  Copyright © 2015 Francis Bato. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "MeetupTableViewCell.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@property NSDictionary *results;
@property NSArray *meetups;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Default search
    [self search:@"mobile"];
    self.searchBar.text = @"mobile";
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self setNeedsStatusBarAppearanceUpdate];

    //This was the one thing needed to make status bar text white. Go figure.
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];


}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];


    if (![searchBar.text isEqualToString:@""]){
        if ([searchBar.text containsString:@" "]){
            NSString *newString = searchBar.text;
            [newString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            [self search:newString];
        } else {
            [self search:searchBar.text];
        }
    }
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//
//    if (![textField.text isEqualToString:@""]){
//        if ([textField.text containsString:@" "]){
//            [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//        }
//        [self search:textField.text];
//        [textField resignFirstResponder];
//    }
//    return YES;
//}

-(void)search:(NSString *)searchString{

    NSString *customString =[NSString stringWithFormat:@"https://api.meetup.com/2/open_events.json?zip=94115&text=%@&time=,1w&key=572016383a79486528177a5d12111c", searchString];
    NSURL *url = [NSURL URLWithString:customString];
    [self loadResultsWithUrl:url];
}

-(void)loadResultsWithUrl:(NSURL *)url{

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (data){
        self.results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

        self.meetups = [[NSArray alloc] init];
        self.meetups = self.results[@"results"];

        dispatch_async(dispatch_get_main_queue(), ^{

            [self.tableView reloadData];
        });

        }

        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"No meetups found with that search." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.textField.text = @"";
            }];

            [alert addAction:dismiss];
            [self presentViewController:alert animated:YES completion:nil];
        }

    }];
    
    [task resume];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.meetups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    MeetupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *meetup = self.meetups[indexPath.row];
    NSDictionary *venue = meetup[@"venue"];

    cell.eventNameLabel.text = meetup[@"name"];
    cell.eventLocationLabel.text = venue[@"address_1"];
    cell.eventDateLabel.text = [self dateAndTimeStringFromEpoch:meetup[@"time"]][0];
    cell.eventTimeLabel.text = [self dateAndTimeStringFromEpoch:meetup[@"time"]][1];



    return cell;
}

-(NSArray *)dateAndTimeStringFromEpoch:(id)epochNumber{

    NSTimeInterval seconds = [epochNumber doubleValue]/1000.0;
    NSDate* epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    NSDateFormatter* dateFormatterDay = [[NSDateFormatter alloc] init];
    [dateFormatterDay setDateFormat:@"EEE, MMM d"];
    NSDateFormatter* dateFormatterTime = [[NSDateFormatter alloc] init];
    [dateFormatterTime setDateFormat:@"hh:mm aaa"];

    NSArray *dateAndTime = @[[dateFormatterDay stringFromDate:epochNSDate], [dateFormatterTime stringFromDate:epochNSDate]];

    return dateAndTime;

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    DetailViewController *vc = [segue destinationViewController];

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *selectedMeetup = self.meetups[indexPath.row];

    vc.meetup = selectedMeetup;
}

@end
