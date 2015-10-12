//
//  ViewController.m
//  MeetMeUp
//
//  Created by Francis Bato on 10/12/15.
//  Copyright © 2015 Francis Bato. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property NSDictionary *results;
@property NSArray *meetups;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self search:@"mobile"];
    self.textField.text = @"mobile";


}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if ([textField.text containsString:@" "]){
        [textField.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    }


    [self search:textField.text];
    [textField resignFirstResponder];
    return YES;
}

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
          //  NSLog(@"log");

            [self.tableView reloadData];
        });

        }

        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Results" message:@"No meetups found with that search" preferredStyle:UIAlertControllerStyleAlert];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];


    NSDictionary *meetup = self.meetups[indexPath.row];
    NSDictionary *venue = meetup[@"venue"];

    cell.textLabel.text = meetup[@"name"];
    cell.detailTextLabel.text = venue[@"address_1"];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    DetailViewController *vc = [segue destinationViewController];


    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *selectedMeetup = self.meetups[indexPath.row];

    vc.meetup = selectedMeetup;


}

@end
