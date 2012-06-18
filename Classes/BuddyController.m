//
//  BuddyController.m
//  SporeBrowser
//
//  Created by Spencer Alves on 5/9/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "BuddyController.h"
#import "UserViewController.h"

@implementation BuddyController

@synthesize userName;

- (void)viewWillAppear:(BOOL)animated {
	if (!animated || (buddies == nil)) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/rest/users/buddies/%@/0/20",
										   [userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:30.0];
		xmlConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (xmlConnection)
			xmlData = [[NSMutableData data] retain];
		buddies = [[NSMutableArray alloc] init];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[self.tableView reloadData];
	}		
	self.title = NSLocalizedString(@"Buddies", @"Title for buddy view");
	self.navigationItem.title = self.title;
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (!animated) {
		if (xmlConnection) {
			[xmlConnection cancel];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			[xmlConnection release];
			xmlConnection = nil;
			if (xmlData)
				[xmlData release];
		}
		if (buddies)
			[buddies release];
		buddies = nil;
	}
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	if (buddies) {
		[buddies removeAllObjects];
		[buddies release];
	}
	if (tempData)
		[tempData release];
	if (xmlData)
		[xmlData release];
	if (xmlConnection)
		[xmlConnection release];
	if (parser)
		[parser release];
	if (userName)
		[userName release];
	[super dealloc];
}	

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	unsigned c = [buddies count];
	if (c != 0)
		c++;
    return c;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	if (indexPath.row < [buddies count]) {
		static NSString *CellIdentifier = @"buddy";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		cell.textLabel.text = [buddies objectAtIndex:indexPath.row];
	}
	else {
		static NSString *CellIdentifier = @"load more";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			cell.textLabel.text = NSLocalizedString(@"Load 20 more…", @"Load more in a list of buddies");
			cell.textLabel.textColor = [UIColor colorWithRed:0.140625 green:0.4375 blue:0.84375 alpha:1.0];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row < [buddies count]) {
		UserViewController *vc = [[UserViewController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.userName = [buddies objectAtIndex:indexPath.row];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];		
	}
	else {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/rest/users/buddies/%@/%i/20",
										   [userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
										   [buddies count]]];
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

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
	
	if ([elementName isEqualToString:@"name"])
		[buddies addObject:tempData];
	if (tempData)
		[tempData release];
	tempData = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (string == nil)
		return;
	[tempData appendString:string];
}

@end

