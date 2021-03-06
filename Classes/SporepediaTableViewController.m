//
//  SporepediaTableViewController.m
//  Sporepedia
//
//  Created by Spencer Alves on 2/21/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "SporepediaTableViewController.h"
#import "Creation.h"
#import "DetailViewController.h"
#import "SporepediaAppDelegate.h"

@implementation SporepediaTableViewController

@synthesize searchTerm, searchType;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	/*if (loadingImage != nil) {
	 [loadingImage release];
	 }*/
	if ((!animated) || ([data count] == 0)) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/rest/assets/%@/%@/0/10", searchType, searchTerm]];
		if ([searchType isEqualToString:@"user"])
			self.title = searchTerm;
		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:30.0];
		xmlConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		if (xmlConnection)
			xmlData=[[NSMutableData data] retain];
		if (tempData)
			[tempData release];
		tempData = [[NSMutableString alloc] init];
		data = [[NSMutableArray arrayWithCapacity:10] retain];
	}
	if (!animated)
		[self.tableView reloadData];
	self.navigationItem.title = self.title;
	self.tableView.rowHeight = 128.0;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if (!animated) {
		if (xmlConnection)
			[xmlConnection cancel];
		[data makeObjectsPerformSelector:@selector(cancelConnections)];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[data removeAllObjects];
		[data release];
		if (xmlData) {
			[xmlData release];
			xmlData = nil;
		}
		if (xmlConnection)
			[xmlConnection release];
		xmlConnection = nil;
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[data removeAllObjects];
	[data release];
	if (loadingImage)
		[loadingImage release];
	[searchTerm release];
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
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	unsigned short count = [data count];
	if (count == 0)
		return 0;
    return count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	if (indexPath.row < [data count]) {
		Creation *asset = [data objectAtIndex:indexPath.row];
		cell = [tableView dequeueReusableCellWithIdentifier:asset.ident];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:asset.ident] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			asset.cell = cell;
			cell.textLabel.text = asset.creationName;
			UILabel *label = (UILabel *)[[[cell contentView] subviews] objectAtIndex:0];
			label.numberOfLines = 3;
		}
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"load more"];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"load more"] autorelease];
			cell.textLabel.text = NSLocalizedString(@"Load 10 more…", @"Load more in a list");
			cell.textLabel.textColor = [UIColor colorWithRed:0.140625 green:0.4375 blue:0.84375 alpha:1.0];
			UILabel *label = (UILabel *)[[[cell contentView] subviews] objectAtIndex:0];
			label.textAlignment = UITextAlignmentCenter;
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	if (newIndexPath.row < [data count]) {
		DetailViewController *vc = [[DetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.creation = [data objectAtIndex:newIndexPath.row];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
	else {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/rest/assets/%@/%@/%i/10", searchType, searchTerm, [data count]]];
		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:30.0];
		xmlConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		if (xmlConnection)
			xmlData=[[NSMutableData data] retain];
		if (tempData) {
			[tempData release];
			tempData = nil;
		}
		tempData = [[NSMutableString alloc] init];
		[tableView deselectRowAtIndexPath:newIndexPath animated:YES];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName
	 attributes:(NSDictionary *)attributeDict {
	
	if ([elementName caseInsensitiveCompare:@"asset"] == 0) {
		Creation *c = [[[Creation alloc] init] autorelease];
		[data addObject:c];
	}
	if (currentTag)
		[currentTag release];
	currentTag = [[elementName lowercaseString] retain];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
	
	Creation *asset = [data lastObject];
	if ([elementName isEqualToString:@"thumb"])
		[asset setImageFromURLString:tempData isLarge:NO];
	else if ([elementName isEqualToString:@"image"])
		[asset setImageFromURLString:tempData isLarge:YES];
	else if ([elementName isEqualToString:@"created"]) {
		[tempData appendString:@" GMT"];
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS zzz"];
		asset.created = [inputFormatter dateFromString:tempData];
		[inputFormatter release];
	}
	else if ([elementName isEqualToString:@"rating"])
		asset.rating = [tempData doubleValue];
	else if ([elementName isEqualToString:@"subtype"]) {
		unsigned long x;
		sscanf([tempData UTF8String], "%x", &x);
		asset.assetType = x;
		asset.localizedAssetType = NSLocalizedStringFromTable(tempData, @"Types", nil);
	}
	if (tempData)
		[tempData release];
	tempData = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	Creation *asset = [data lastObject];
	if ((currentTag == nil) || ([currentTag length] == 0) || (string == nil))
		return;
	if ([currentTag isEqualToString:@"id"])
		[asset.ident appendString:string];
	else if ([currentTag isEqualToString:@"name"])
		[asset.creationName appendString:string];
	else if ([currentTag isEqualToString:@"author"])
		[asset.author appendString:string];
	else if ([currentTag isEqualToString:@"description"])
		[asset.creationDescription appendString:string];
	else if ([currentTag isEqualToString:@"tags"])
		[asset.tags appendString:string];
	else
		[tempData appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Had parse error: %@", parseError);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[xmlData setLength:0];	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)recievedData {
	[xmlData appendData:recievedData];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate:self];
	[parser setShouldResolveExternalEntities:YES];
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
	[[self tableView] reloadData];
	[data makeObjectsPerformSelector:@selector(refreshCell)];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	[self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (!decelerate)
		[self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	unsigned short firstCellIndex = [scrollView contentOffset].y/128;
	Creation *asset;
	for (unsigned short i = firstCellIndex; (i < 4+firstCellIndex) && (i < (int)[data count]); i++) {
		asset = [data objectAtIndex:i];
		[asset refreshCell];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[xmlData release];
	xmlData = nil;
	[xmlConnection release];
	xmlConnection = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Download error occured")
								message:[error localizedDescription]
							   delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", @"Confirm download error")
					  otherButtonTitles:nil];
	[alert show];
    [alert release];
}

@end
