//
//  CommentViewController.m
//  SporeBrowser
//
//  Created by Spencer Alves on 09-04-27.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "CommentViewController.h"
#import "UserViewController.h"

@implementation CommentViewController

@synthesize assetID;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated {
	if (!animated || (comments == nil)) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/rest/comments/%@/0/20", assetID]];
		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:30.0];
		xmlConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (xmlConnection)
			xmlData = [[NSMutableData data] retain];
		comments = [[NSMutableArray alloc] init];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[self.tableView reloadData];
	}		
	self.title = NSLocalizedString(@"Comments", @"Title for comment view");
	self.navigationItem.title = self.title;
	self.tableView.rowHeight = 44.0;
	[super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
- (void)viewWillDisappear:(BOOL)animated {
	if (!animated) {
		if (xmlConnection) {
			[xmlConnection cancel];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			[xmlConnection release];
			xmlConnection = nil;
			if (xmlData)
				[xmlData release];
            xmlData = nil;
		}
		if (comments)
			[comments release];
		comments = nil;
	}
	[super viewWillDisappear:animated];
}
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	if (comments) {
		[comments removeAllObjects];
		[comments release];
	}
	if (currentTag)
		[currentTag release];
	if (tempData)
		[tempData release];
	if (xmlData)
		[xmlData release];
	if (xmlConnection)
		[xmlConnection release];
	if (parser)
		[parser release];
	if (assetID)
		[assetID release];
	[super dealloc];
}	

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	unsigned c = [comments count];
	if (c != 0)
		c++; // :-)
    return c;
}

#define CELL_CONTENT_WIDTH 300.0f // -20 because of accessory
#define CELL_CONTENT_MARGIN 10.0f

- (void)setCommentFullText:(NSMutableDictionary *)comment {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[comment setValue:[NSString stringWithFormat:NSLocalizedString(@"%@\nby %@ on %@", @"Comment format"),
					   [comment valueForKey:@"message"],
					   [comment valueForKey:@"sender"],
					   [formatter stringFromDate:[comment valueForKey:@"date"]]] forKey:@"fullText"];
	[formatter release];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	if (indexPath.row < [comments count]) {
		static NSString *CellIdentifier = @"comment";
		NSMutableDictionary *comment = [comments objectAtIndex:indexPath.row];
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.textLabel.minimumFontSize = [UIFont systemFontSize];
			cell.textLabel.numberOfLines = 0;
			cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		}
		if (![[comment allKeys] containsObject:@"fullText"]) {
			[self setCommentFullText:comment];
		}
		cell.textLabel.text = [[comment valueForKey:@"fullText"] retain];
		CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
		CGSize size = [cell.textLabel.text sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
		CGRect frame = CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), size.height);
        cell.textLabel.frame = frame;
	}
	else {
		static NSString *CellIdentifier = @"load more";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
            UILabel *label = cell.textLabel;
			label.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
			label.text = NSLocalizedString(@"Load 20 more…", @"Load more in a list of comments");
			label.textColor = [UIColor colorWithRed:0.140625 green:0.4375 blue:0.84375 alpha:1.0];
			label.textAlignment = UITextAlignmentCenter;
		}
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [comments count]) {
		NSMutableDictionary *comment = [comments objectAtIndex:indexPath.row];
		if (![[comment allKeys] containsObject:@"fullText"]) {
			[self setCommentFullText:comment];
		}
		NSString *text = [comment valueForKey:@"fullText"];
		CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
		CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
		//CGFloat height = MAX(size.height, 22.0f);
		return size.height + (CELL_CONTENT_MARGIN * 2);
	}
	else {
		return 44.0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [comments count]) {
		UserViewController *vc = [[UserViewController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.userName = [[comments objectAtIndex:indexPath.row] valueForKey:@"sender"];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
    }
	else {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/rest/comments/%@/%i/20",
										   assetID,
										   [comments count]]];
		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:30.0];
		xmlConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (xmlConnection)
			xmlData=[[NSMutableData data] retain];
		if (tempData) {
			[tempData release];
			tempData = nil;
		}
		tempData = [[NSMutableString alloc] init];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[xmlData setLength:0];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)recievedData {
	[xmlData appendData:recievedData];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate:self];
	[parser parse];
	[parser release];
	parser = nil;
	if (xmlData) {
		[xmlData release];
		xmlData = nil;
	}
	if (xmlConnection)
		[xmlConnection release];
	xmlConnection = nil;
	[self.tableView reloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[xmlData release];
	xmlData = nil;
	[xmlConnection release];
	xmlConnection = nil;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Download error occured")
								message:[error localizedDescription]
							   delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", @"Confirm download error")
					  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark NSXMLParser methods

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName
	 attributes:(NSDictionary *)attributeDict {

	if ([elementName caseInsensitiveCompare:@"comment"] == 0) {
		NSMutableDictionary *comment = [[NSMutableDictionary alloc] init];
		[comments addObject:comment];
		[comment release];
	}
	if (currentTag)
		[currentTag release];
	currentTag = [[elementName lowercaseString] retain];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
	
	NSMutableDictionary *comment = [comments lastObject];
	if ([elementName isEqualToString:@"date"]) {
		[tempData appendString:@" GMT"];
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS zzz"];
		[comment setValue:[inputFormatter dateFromString:tempData] forKey:elementName];
		[inputFormatter release];
	}
	else {
		[comment setValue:tempData forKey:elementName];
	}
	if (tempData)
		[tempData release];
	tempData = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if ((currentTag == nil) || ([currentTag length] == 0) || (string == nil))
		return;
	[tempData appendString:string];
}

@end
