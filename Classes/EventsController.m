//
//  EventsController.m
//  SporeBrowser
//
//  Created by Spencer Alves on 5/1/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "EventsController.h"
#import "UserViewController.h"

@implementation EventsController

@synthesize url;

- (void)startDownload {
	NSURLRequest *request=[NSURLRequest requestWithURL:url
										   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
									   timeoutInterval:30.0];
	xmlConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (xmlConnection)
		xmlData = [[NSMutableData data] retain];
	htmlString = [[NSMutableString alloc] initWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"theme.css\" /></head><body>"];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[(UIWebView *)self.view setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = NSLocalizedString(@"Events", @"Title for events view");
	self.navigationItem.title = self.title;
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	if (htmlString)
		[htmlString release];
	if (event)
		[event release];
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
	if (url)
		[url release];
	[super dealloc];
}	

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *u = [request URL];
	if ((u == nil) || (navigationType == UIWebViewNavigationTypeOther))
		return YES;
    if (![[u host] isEqualToString:@"www.spore.com"])
        return NO;
	if ([[u path] hasPrefix:@"/view/profile/"]) {
		UserViewController *vc = [[UserViewController alloc] initWithStyle:UITableViewStyleGrouped];
		vc.userName = [[[u path] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
		return NO;
	}
	else if ([[u path] hasPrefix:@"/sporepedia"]) { // we need to check the prefix because some links use the path, not the anchor
		// TODO: make this work!
		return NO;
	}
    else if ([[u path] isEqualToString:@"/"]) { // This happens with links to achievements
        return NO;
    }
	else {
		return ![[UIApplication sharedApplication] openURL:[request URL]];
        // so if it fails to open in Safari, try to open it ourselves
	}
}

#pragma mark NSURLConnection delegate methods

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
	NSRange range = [htmlString rangeOfString:@"<hr>" options:NSBackwardsSearch];
	if (range.location == NSNotFound)
		[htmlString appendFormat:@"<div class=\"noevents\">%@</div></body></html>", NSLocalizedString(@"No events", @"No events for asset or author")];
	else
		[htmlString replaceCharactersInRange:range withString:@"</body></html>"];
	[(UIWebView *)self.view loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	[htmlString release];
	htmlString = nil;
	[url release];
	url = nil;
	[tempData release];
	tempData = nil;
	[currentTag release];
	currentTag = nil;
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

#pragma mark NSXMLParser delegate methods

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName
	 attributes:(NSDictionary *)attributeDict {
	
	if ([elementName caseInsensitiveCompare:@"entry"] == 0)
		event = [[NSMutableDictionary alloc] init];
	if (currentTag)
		[currentTag release];
	currentTag = [[elementName lowercaseString] retain];
}

NSString *imageForEventId(NSString *s) {
    int i = [s intValue];
    switch (i) {
        case 1:   // switched avatar
            return @"spd_IconAvatar.png";
        case 3:   // added buddy
            return @"spd_IconBuddy.png";
        case 4:   // created sporecast
            return @"spd_IconNewSporecast.png";
        case 5:   // commented
            return @"spd_IconCommentsEvent.png";
        case 7:   // earned achievement
            return @"spd_IconAchievement.png";
        case 8:   // completed cell stage
        case 9:   // killed cells
        case 10:  // died in cell
            return @"spd_IconEventCLG.png";
        case 11:  // extincted
        case 12:  // befriended
        case 13:  // epicized in creature
        case 14:  // added to posse
            return @"spd_IconEventCRG.png";
        case 15:  // epicized in tribe
        case 16:  // killed epic in tribe
        case 17:  // domesticated
        case 18:  // lost tribe stage
            return @"spd_IconEventTRG.png";
        case 20:  // charmed epic
        case 21:  // captured
        case 22:  // used superweapon
        case 24:  // won civilization stage
            return @"spd_IconEventCVG.png";
        case 25:  // epicized in space
        case 26:  // eradicated
        case 27:  // added to fleet
        case 28:  // formed alliance
        case 29:  // declared war
            return @"spd_IconEventSPG.png";
        case 32:  // won gold trophy
        case 33:  // lost gold trophy
        case 34:  // won silver trophy
        case 35:  // lost silver trophy
        case 36:  // won bronze trophy
        case 37:  // lost bronze trophy
            return @"spd_IconEventADV.png";
    }
    return @"spd_IconAchievement.png"; // because sometimes it has the achievement id instead
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
	
	if ([elementName isEqualToString:@"entry"]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		[htmlString appendFormat:@"<img src=\"%@\" class=\"image\"><div class=\"message\">%@</div><div class=\"date\">%@</div><hr>",
								 imageForEventId([event valueForKey:@"id"]),
								 [event valueForKey:@"content"],
								 [formatter stringFromDate:[event valueForKey:@"published"]]];
		[event release];
		[formatter release];
		event = nil;
	}
	else if ([elementName isEqualToString:@"published"] && (event != nil)) {
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
		[event setValue:[inputFormatter dateFromString:tempData] forKey:elementName];
		[inputFormatter release];
	}
	else
		[event setValue:tempData forKey:elementName];
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

