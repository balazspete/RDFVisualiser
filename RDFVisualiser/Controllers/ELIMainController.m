//
//    ELIMainController.m
//    RDFVisualiser
//
//    Copyright 2014 Balazs Pete <balazs@eliendrae.net>
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
//

#import "ELIMainController.h"
#import "ELIPropertyCell.h"

#import <Redland-ObjC.h>
#import <AFNetworking/AFNetworking.h>

#import "ELIRDFResponseSerialiser.h"
#import "ELIRDFRequestSerializer.h"

//#import

@interface ELIMainController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *results;
@property NSURL *url;
@property BOOL loading;

@end

@implementation ELIMainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.results = [[NSMutableArray alloc] init];
    [self.goButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressGoButton:)]];
    
    [self.navigationView setTranslucent:YES];
    [self.navigationView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *result = [self.results objectAtIndex:indexPath.row];
    RedlandNode *predicate = [result objectForKey:@"predicate"];
    RedlandNode *value = [result objectForKey:@"value"];
    
    ELIPropertyCell *cell;
    
    if ([value isResource])
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ResourcePropertyCell" forIndexPath:indexPath];
        cell.isLink = YES;
        [cell.valueLabel setText:[value description]];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LiteralPropertyCell" forIndexPath:indexPath];
        [cell.valueLabel setText:[value literalValue]];
    }
    
    [cell.propertyLabel setText:[predicate description]];
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *result = [self.results objectAtIndex:indexPath.row];
    RedlandNode *value = [result objectForKey:@"value"];
    
    if (value.isLiteral)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        self.uriField.text = [value URIStringValue];
        [self getURI];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self getURI];
}
     
- (void)didPressGoButton:(UITapGestureRecognizer *)recogniser
{
    [self getURI];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.uriField endEditing:YES];
    return YES;
}

- (void)getURI
{
    if (self.loading)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading"
                                                        message:@"Currently loading another resource."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    self.loading = YES;
    self.url = [[NSURL alloc] initWithString:self.uriField.text];
    [self.progressView setProgress:0.1];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    ELIRDFRequestSerializer *requestSerializer = [[ELIRDFRequestSerializer alloc] init];
    
    NSMutableURLRequest *request = [requestSerializer GETRequest:self.url];
    [manager setResponseSerializer:[[ELIRDFResponseSerialiser alloc] init]];
    [manager setRequestSerializer:requestSerializer];
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self displayRDF:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self.progressView setProgress:0];
        self.loading = NO;
    }];
    
    [operation start];
}

- (void)displayRDF:(RedlandModel*)model
{
    [self.progressView setProgress:0.5];
    RedlandNode *node = [RedlandNode nodeWithURIString:[self.url absoluteString]];
    
    NSString *queryString = @"SELECT * WHERE {?a ?predicate ?value}";
    
    RedlandQuery *query = [RedlandQuery queryWithLanguageName:RedlandSPARQLLanguageName queryString:queryString baseURI:node.URIValue];
    RedlandQueryResultsEnumerator *results = [[query executeOnModel:model] resultEnumerator];
    
    
    [self.results removeAllObjects];
    
    [self.progressView setProgress:0.75];
    
    while (true)
    {
        RedlandStatement *statement = [results nextObject];
        if (statement)
        {
            [self.results addObject:statement];
            NSLog(@"result");
        }
        else
        {
            NSLog(@"no more results");
            break;
        }
    }
    
    [self.tableView reloadData];
    [self.progressView setProgress:1];
    
    self.loading = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.navigationView.frame.size.height;
}


@end
