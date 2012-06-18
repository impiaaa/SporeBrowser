//
//  UserViewController.m
//  SporeBrowser
//
//  Created by Spencer Alves on 5/3/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "UserViewController.h"
#import "SporepediaTableViewController.h"
#import "EventsController.h"
#import "BuddyController.h"

@implementation UserViewController

@synthesize userName;

- (void)viewWillAppear:(BOOL)animated {
	if (!animated || (image == nil) || (tagline == nil)) {
		[self.tableView reloadData];
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/rest/user/%@",
										   [userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
										   timeoutInterval:30.0];
		connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (connection)
			data = [[NSMutableData data] retain];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}		
	self.title = userName;
	self.navigationItem.title = userName;
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	if (!animated) {
		if (connection) {
			[connection cancel];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			[connection release];
			connection = nil;
			if (data)
				[data release];
            data = nil;
		}
		if (image)
			[image release];
		image = nil;
		if (tagline)
			[tagline release];
		tagline = nil;
		if (date)
			[date release];
		date = nil;
	}
	[super viewWillDisappear:animated];
}	

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
	if (image)
		[image release];
	if (tagline)
		[tagline release];
	if (date)
		[date release];
	if (currentTag)
		[currentTag release];
	if (tempData)
		[tempData release];
	if (data)
		[data release];
	if (connection) {
		[connection cancel];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[connection release];
	}
	if (parser)
		[parser release];
	if (userName)
		[userName release];
	[super dealloc];
}	

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
		return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tagline == nil)
		return 0;
	switch (section) {
		case 0:
			return 3;
		case 1:
			return 3;
		default:
			return 0;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%i-%i", indexPath.section, indexPath.row]];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
									   reuseIdentifier:[NSString stringWithFormat:@"%i-%i", indexPath.section, indexPath.row]] autorelease];
		switch (indexPath.section) {
			case 0:
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = userName;
						cell.imageView.image = image;
						break;
					case 1:
						if ([tagline length] == 0) {
							cell.textLabel.text = NSLocalizedString(@"No tagline", @"User has no tagline");
							cell.textLabel.textColor = [UIColor lightGrayColor];
						}
						else
							cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"\"%@\"", @"Tagline in quotes"), tagline];
						cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
						break;
					case 2: {
						NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
						[formatter setDateStyle:NSDateFormatterMediumStyle];
						[formatter setTimeStyle:NSDateFormatterShortStyle];
						cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Created on %@", @"Author date"), [formatter stringFromDate:date]];
						cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
						[formatter release];
						break;
					}
					default:
						break;
				}
				break;
			case 1:
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = NSLocalizedString(@"Creations", @"Author's creations");
						break;
					case 1:
						cell.textLabel.text = NSLocalizedString(@"Buddies", @"Author's buddies");
						break;
					case 2:
						cell.textLabel.text = NSLocalizedString(@"Events", @"Author's events");
						break;
					/*case 3:
						 cell.text = NSLocalizedString(@"Sporecasts", @"Author's Sporecasts");
						 break;
					case 4:
						 cell.text = NSLocalizedString(@"Achievements", @"Author's achievements");
						 break;*/
					default:
						break;
				}
				break;
			default:
				break;
		}
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.section == 0) && (indexPath.row == 0) && (image != nil))
		return image.size.height+1;
	else
		return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	if (newIndexPath.section == 1) {
		switch (newIndexPath.row) {
			case 0: {
				SporepediaTableViewController *vc = [[SporepediaTableViewController alloc] init];
				vc.searchTerm = userName;
				vc.searchType = @"user";
				[self.navigationController pushViewController:vc animated:YES];
				[vc release];
				break;
			}
			case 1: {
				BuddyController *vc = [[BuddyController alloc] init];
				vc.userName = userName;
				[self.navigationController pushViewController:vc animated:YES];
				[vc release];
				break;
			}
			case 2: {
				EventsController *vc = [[EventsController alloc] init];
				vc.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/atom/events/user/%@", userName]];
				UIWebView *v = [[UIWebView alloc] init];
				vc.view = v;
				[v release];
				[vc startDownload];
				[self.navigationController pushViewController:vc animated:YES];
				[vc release];
				break;
			}
			default:
				break;
		}
	}
}

#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)c didReceiveResponse:(NSURLResponse *)response {
	[data setLength:0];	
}

- (void)connection:(NSURLConnection *)c didReceiveData:(NSData *)recievedData {
	[data appendData:recievedData];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

UIImage *scaleAndRotateImage(UIImage *image)
{
    int kMaxResolution = 240; // Or whatever
	
    CGImageRef imgRef = image.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
			
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
			
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
			
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
			
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
    }
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return imageCopy;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)c {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (tagline == nil) {
		parser = [[NSXMLParser alloc] initWithData:data];
		[parser setDelegate:self];
		if (connection)
			[connection release];
		connection = nil;
		if (data)
			[data release];
		data = nil;
		[parser parse];
		[parser release];
		parser = nil;
	}
	else {
		image = [[UIImage alloc] initWithData:data];
		if (connection)
			[connection release];
		connection = nil;
		if (data)
			[data release];
		data = nil;
		if (image.size.width > 240) {
			UIImage *newImage = scaleAndRotateImage(image);
			[image release];
			image = [newImage retain];
		}
		[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].imageView.image = image;
	}
	[self.tableView reloadData];
}

- (void)connection:(NSURLConnection *)c didFailWithError:(NSError *)error {
	[data release];
	data = nil;
	[connection release];
	connection = nil;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	UIAlertView *a = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Download error occured")
								message:[error localizedDescription]
							   delegate:nil cancelButtonTitle:NSLocalizedString(@"Okay", @"Confirm download error")
					  otherButtonTitles:nil];
    [a show];
    [a release];
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
	
	if ([elementName isEqualToString:@"image"]) {
		NSURL *url = [NSURL URLWithString:[tempData stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		NSURLRequest *request=[NSURLRequest requestWithURL:url
											   cachePolicy:NSURLRequestReturnCacheDataElseLoad
										   timeoutInterval:60.0];
		connection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		if (connection)
			data=[[NSMutableData data] retain];
	}
	else if ([elementName isEqualToString:@"tagline"]) {
		tagline = [tempData copy];
	}
	else if ([elementName isEqualToString:@"creation"]) {
		[tempData appendString:@" GMT"];
		NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
		[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS zzz"];
		date = [[inputFormatter dateFromString:tempData] retain];
		[inputFormatter release];
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

