//
//  DetailViewController.m
//  Sporepedia
//
//  Created by Spencer Alves on 4/4/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "DetailViewController.h"
#import "CommentViewController.h"
#import "StatsController.h"
#import "EventsController.h"
#import "UserViewController.h"

@implementation DetailViewController

@synthesize creation, tabBar;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewWillAppear:(BOOL)animated {
	self.title = creation.creationName;
	if (creation.rating > 10)
		ratingImage = [[UIImage imageNamed:@"ratings+2.png"] retain];
	else if (creation.rating > 4)
		ratingImage = [[UIImage imageNamed:@"ratings+1.png"] retain];
	else if (creation.rating > -2)
		ratingImage = [[UIImage imageNamed:@"ratings-0.png"] retain];
	else if (creation.rating > -6)
		ratingImage = [[UIImage imageNamed:@"ratings-1.png"] retain];
	else
		ratingImage = [[UIImage imageNamed:@"ratings-2.png"] retain];
	[super viewWillAppear:animated];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
    [super dealloc];
	[creation release];
	[ratingImage release];
	[tabBar release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *identifier = [NSString stringWithFormat:@"%i-%i", indexPath.section, indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
									   reuseIdentifier:identifier] autorelease];
		switch (indexPath.section) {
			case 0:
				switch (indexPath.row) {
					case 0: {
						if (creation.image == nil) {
							creation.detailCell = cell;
						}
						else {
							UIImageView *v = [[UIImageView alloc] initWithImage:creation.image];
							CGPoint pt = CGPointMake(150, 128);
							v.center = pt;
							[cell.contentView addSubview:v];
							[v release];
						}
						break;
					}
					case 1:
						cell.textLabel.text = creation.creationName;
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						break;
					case 2:
						cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
						if ([creation.creationDescription isEqualToString:@"NULL"]) {
							cell.textLabel.text = NSLocalizedString(@"No description", @"Creation has no description");
							cell.textLabel.textColor = [UIColor lightGrayColor];
							cell.selectionStyle = UITableViewCellSelectionStyleNone;
						}
						else {
							cell.textLabel.text = [creation.creationDescription stringByReplacingOccurrencesOfString:@"\n" withString:@""];
							cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						}						
						break;
					default:
						break;
				}
				break;
			case 1:
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Creation by %@", @"Creation author"), creation.author];
						cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						break;
					case 1: {
						NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
						[formatter setDateStyle:NSDateFormatterMediumStyle];
						[formatter setTimeStyle:NSDateFormatterShortStyle];
						cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Created on %@", @"Creation birthdate"), [formatter stringFromDate:creation.created]];
						cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						[formatter release];
						break;
					}
					case 2: {
						NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
						NSNumber *rating = [[NSNumber alloc] initWithDouble:creation.rating];
						[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
						[formatter setMinimumFractionDigits:3];
						[formatter setMaximumFractionDigits:3];
						NSString *str = [[NSString stringWithFormat:NSLocalizedString(@"Rated %@", @"Creation rating"), [formatter stringFromNumber:rating]] retain];
						cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
						cell.textLabel.text = str;
						cell.imageView.image = ratingImage;
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						[formatter release];
						[rating release];
						[str release];
						break;
					}
					case 3:
						if ([creation.tags isEqualToString:@"NULL"]) {
							cell.textLabel.text = NSLocalizedString(@"No tags", @"Creation has no tags");
							cell.textLabel.textColor = [UIColor lightGrayColor];
						}
						else
							cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Tags: %@", @"Creation tags"), creation.tags];
						cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];					
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						break;
					case 4:
						cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Type: %@", @"Creation type"), creation.localizedAssetType];
						cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];					
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						break;
					default:
						break;
				}
				break;
			case 2:
				switch (indexPath.row) {
					case 0:
						if ((creation.assetType == 0x9ea3031a) ||
							(creation.assetType == 0x372e2c04) ||
							(creation.assetType == 0xccc35c46) ||
							(creation.assetType == 0x65672ade) ||
							(creation.assetType == 0x4178b8e8)) {
							cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
							cell.textLabel.text = NSLocalizedString(@"Statistics", @"Creation statistics");
						}
						else {
							cell.textLabel.textColor = [UIColor lightGrayColor];
							cell.selectionStyle = UITableViewCellSelectionStyleNone;
							cell.textLabel.text = NSLocalizedString(@"Stats unavailable", @"Creation has no statistics (not a creature)");
						}						
						break;
					case 1:
						cell.textLabel.text = NSLocalizedString(@"Comments", @"Creation comments");
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						break;
					case 2:
						cell.textLabel.text = NSLocalizedString(@"Events", @"Creation events");
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						break;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.section == 0) && (indexPath.row == 0))
		return 257.0;
	else
		return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 3;
		case 1:
			return 5;
		case 2:
			return 3;
		default:
			return 0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	switch (newIndexPath.section) {
		case 0:
			switch (newIndexPath.row) {
				case 0: {
					UIActionSheet *sheet = [UIActionSheet alloc];
					sheet = [sheet initWithTitle:NSLocalizedString(@"Save image", @"UIActionSheet title")
										delegate:self
							   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel saving image")
						  destructiveButtonTitle:nil
							   otherButtonTitles:NSLocalizedString(@"Save thumbnail", @"Save thumbnail of creation"),
							 NSLocalizedString(@"Save large image", @"Save image of creation"),
							 nil];
					[sheet showFromTabBar:tabBar];
					[sheet release];
					break;
				}
				case 2:
					if (![creation.creationDescription isEqualToString:@"NULL"]) {
						UIViewController *vc = [[UIViewController alloc] init];
						UITextView *view = [[[UITextView alloc] init] retain];
						view.text = creation.creationDescription;
						view.editable = NO;
						view.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
						vc.view = view;
						vc.title = NSLocalizedString(@"Description", @"Title for description screen");
						vc.navigationItem.title = vc.title;
						[view release];
						[self.navigationController pushViewController:vc animated:YES];
						[vc release];
					}
					break;
			}
			break;
		case 1:
			if (newIndexPath.row == 0) {
				UserViewController *vc = [[UserViewController alloc] initWithStyle:UITableViewStyleGrouped];
				vc.userName = creation.author;
				[self.navigationController pushViewController:vc animated:YES];
				[vc release];
			}
			break;
		case 2:
			switch (newIndexPath.row) {
				case 0:
					if ((creation.assetType == 0x9ea3031a) ||
						(creation.assetType == 0x372e2c04) ||
						(creation.assetType == 0xccc35c46) ||
						(creation.assetType == 0x65672ade) ||
						(creation.assetType == 0x4178b8e8)) {
						StatsController *vc = [[StatsController alloc] initWithStyle:UITableViewStyleGrouped];
						vc.assetID = creation.ident;
						[self.navigationController pushViewController:vc animated:YES];
						[vc release];
					}
					break;
				case 1: {
					CommentViewController *vc = [[CommentViewController alloc] init];
					vc.assetID = creation.ident;
					[self.navigationController pushViewController:vc animated:YES];
					[vc release];
					break;
				}
				case 2: {
					EventsController *vc = [[EventsController alloc] init];
					vc.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.spore.com/atom/events/asset/%@", creation.ident]];
					UIWebView *v = [[UIWebView alloc] init];
					vc.view = v;
					[v release];
					[vc startDownload];
					[self.navigationController pushViewController:vc animated:YES];
					[vc release];
					break;
				}
			}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			UIImageWriteToSavedPhotosAlbum([creation thumb], nil, nil, nil);
			break;
		case 1:
			UIImageWriteToSavedPhotosAlbum([creation image], nil, nil, nil);
			break;
		default:
			break;
	}
	[self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
}

@end
