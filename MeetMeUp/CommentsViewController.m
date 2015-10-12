//
//  CommentsViewController.m
//  MeetMeUp
//
//  Created by Francis Bato on 10/12/15.
//  Copyright © 2015 Francis Bato. All rights reserved.
//

#import "CommentsViewController.h"
#import "MemberViewController.h"

@interface CommentsViewController () <UITableViewDataSource, UITableViewDelegate>

@property NSDictionary *results;
@property NSArray *comments;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCommentURL:self.eventID];

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.comments[indexPath.row][@"time"] doubleValue]/1000.0];

    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",date,self.comments[indexPath.row][@"member_name"]];
    cell.detailTextLabel.text = self.comments[indexPath.row][@"comment"];

    return cell;
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

            self.comments = [[NSArray alloc] init];
            self.comments = self.results[@"results"];


            dispatch_async(dispatch_get_main_queue(), ^{
                //  NSLog(@"log");

                [self.tableView reloadData];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    MemberViewController *commentVC = segue.destinationViewController;
    commentVC.memberID = self.comments[indexPath.row][@"member_id"];

}

@end
