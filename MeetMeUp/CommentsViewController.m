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

    NSArray *timeAndDate = [self dateAndTimeStringFromEpoch:self.comments[indexPath.row][@"time"]];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",self.comments[indexPath.row][@"member_name"], [NSString stringWithFormat:@"%@%@", timeAndDate[0], timeAndDate[1]]];
    cell.textLabel.text = self.comments[indexPath.row][@"comment"];

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

                [self.tableView reloadData];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    MemberViewController *commentVC = segue.destinationViewController;
    commentVC.memberID = self.comments[indexPath.row][@"member_id"];

}

@end
