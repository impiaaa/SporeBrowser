//
//  DetailViewController.m
//  Sporepedia
//
//  Created by Spencer Alves on 4/4/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "DetailViewController.h"
#import "SporepediaTableViewController.h"

@implementation DetailViewController

@synthesize creation;

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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%i-%i", indexPath.section, indexPath.row]];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:[NSString stringWithFormat:@"%i-%i", indexPath.section, indexPath.row]] autorelease];
		switch (indexPath.section) {
			case 0:
				switch (indexPath.row) {
					case 0: {
						cell.selectionStyle = UITableViewCellSelectionStyleNone;
						if (creation.image == nil) {
							creation.detailCell = cell;
						}
						else {
							UIImageView *v = [[UIImageView alloc] initWithImage:creation.image];
							v.center = CGPointMake(160, 128);
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
			default:
				break;
		}
	}
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ((indexPath.section == 0) && (indexPath.row == 0))
		return 256.0;
	else
		return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 3;
		case 1:
			return 5;
		default:
			return 0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	switch (newIndexPath.section) {
		case 0:
			switch (newIndexPath.row) {
				case 2:
					if (![creation.creationDescription isEqualToString:@"NULL"]) {
						UIViewController *vc = [[UIViewController alloc] init];
						UITextView *view = [[UITextView alloc] init];
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
				SporepediaTableViewController *vc = [[SporepediaTableViewController alloc] initWithStyle:UITableViewStylePlain];
				vc.searchTerm = creation.author;
				vc.searchType = @"user";
				[self.navigationController pushViewController:vc animated:YES];
				[vc release];
			}
			break;
		default:
			break;
	}
}

@end
