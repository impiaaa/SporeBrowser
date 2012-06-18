//
//  StatsController.m
//  SporeBrowser
//
//  Created by Spencer Alves on 4/30/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "StatsController.h"

@implementation StatsController

@synthesize assetID;

- (void)viewWillAppear:(BOOL)animated {
	if (!animated || (stats == nil)) {
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/rest/creature/%@", assetID]];
		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:30.0];
		xmlConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (xmlConnection)
			xmlData = [[NSMutableData data] retain];
		stats = [[NSMutableDictionary alloc] init];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		[self.tableView reloadData];
	}		
	self.title = NSLocalizedString(@"Stats", @"Title for creature statistics");
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
		if (stats)
			[stats release];
		stats = nil;
	}
	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	if (stats) {
		[stats removeAllObjects];
		[stats release];
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
    return 4;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: // Abilities
            return 5;
        case 1: // Attack
        case 2: // Social
            return 4;
        case 3: // Stature, info etc.
            return 8;
        default:
            return 0;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"stat";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *key = @"";
    switch (indexPath.section) {
        case 0: // Abilities
            switch (indexPath.row) {
                case 0:
                    key = @"glide";
                    break;
                case 1:
                    key = @"graspercount";
                    break;
                case 2:
                    key = @"sense";
                    break;
                case 3:
                    key = @"sprint";
                    break;
                case 4:
                    key = @"stealth";
                    break;
                default:
                    break;
            }
            break;
        case 1: // Attack
            switch (indexPath.row) {
                case 0:
                    key = @"bite";
                    break;
                case 1:
                    key = @"charge";
                    break;
                case 2:
                    key = @"spit";
                    break;
                case 3:
                    key = @"strike";
                    break;
                default:
                    break;
            }
            break;
        case 2: // Social
            switch (indexPath.row) {
                case 0:
                    key = @"dance";
                    break;
                case 1:
                    key = @"gesture";
                    break;
                case 2:
                    key = @"posture";
                    break;
                case 3:
                    key = @"sing";
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    key = @"cost";
                    break;
                case 1:
                    key = @"health";
                    break;
                case 2:
                    key = @"height";
                    break;
                case 3:
                    key = @"meanness";
                    break;
                case 4:
                    key = @"cuteness";
                    break;
                case 5:
                    key = @"bonecount";
                    break;
                case 6:
                    key = @"footcount";
                    break;
                case 7:
                    key = @"basegear";
                    break;
                case 8:
                    key = @"diet";
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	cell.textLabel.text = NSLocalizedStringFromTable(key, @"Stats", nil);
	if (indexPath.section == 3 && indexPath.row == 7) {
		switch ([[stats valueForKey:key] unsignedCharValue]) {
			case CARNIVORE:
				cell.detailTextLabel.text = NSLocalizedStringFromTable(@"Carnivore", @"Stats", nil);
				break;
			case HERBIVORE:
				cell.detailTextLabel.text = NSLocalizedStringFromTable(@"Herbivore", @"Stats", nil);
				break;
			case OMNIVORE:
				cell.detailTextLabel.text = NSLocalizedStringFromTable(@"Omnivore", @"Stats", nil);
				break;
			default:
				break;
		}
	}
	else
		cell.detailTextLabel.text = [[stats valueForKey:key] stringValue];
    //NSString *path = [key stringByAppendingPathExtension:@"png"];
    //UIImage *image = [UIImage imageNamed:path];
    //cell.imageView.image = image;
    //NSLog(@"imagView = %@", cell.imageView);
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedStringFromTable(@"Abilities", @"Stats", nil);
        case 1:
            return NSLocalizedStringFromTable(@"Attack", @"Stats", nil);
        case 2:
            return NSLocalizedStringFromTable(@"Social", @"Stats", nil);
        case 3:
            return NSLocalizedStringFromTable(@"Other info", @"Stats", nil);
        default:
            break;
    }
    return nil;
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

#pragma mark NSXMLParser methods

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName
	 attributes:(NSDictionary *)attributeDict {
	
	if (currentTag)
		[currentTag release];
	currentTag = [[elementName lowercaseString] retain];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
	
	if ([currentTag isEqualToString:@"status"] ||
		[currentTag isEqualToString:@"input"] ||
		[currentTag isEqualToString:@"creature"]) {
	}
	else if ([currentTag isEqualToString:@"cost"])
		[stats setValue:[NSNumber numberWithInt:[tempData intValue]] forKey:currentTag];
	else if ([currentTag isEqualToString:@"height"] ||
			 [currentTag isEqualToString:@"meanness"] ||
			 [currentTag isEqualToString:@"cuteness"])
		[stats setValue:[NSNumber numberWithFloat:[tempData floatValue]] forKey:currentTag];
	else if ([currentTag isEqualToString:@"carnivore"]) {
		if ([tempData boolValue]) {
			if ([[stats valueForKey:@"diet"] unsignedCharValue] == HERBIVORE)
				[stats setValue:[NSNumber numberWithUnsignedChar:OMNIVORE] forKey:@"diet"];
			else
				[stats setValue:[NSNumber numberWithUnsignedChar:CARNIVORE] forKey:@"diet"];
		}
	}
	else if ([currentTag isEqualToString:@"herbivore"]) {
		if ([tempData boolValue]) {
			if ([[stats valueForKey:@"diet"] unsignedCharValue] == CARNIVORE)
				[stats setValue:[NSNumber numberWithUnsignedChar:OMNIVORE] forKey:@"diet"];
			else
				[stats setValue:[NSNumber numberWithUnsignedChar:HERBIVORE] forKey:@"diet"];
		}
	}
	else
		[stats setValue:[NSNumber numberWithInt:[tempData floatValue]] forKey:currentTag];
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

