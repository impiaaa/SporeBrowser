//
//  DetailViewController.m
//  Sporepedia
//
//  Created by Spencer Alves on 4/4/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "DetailViewController.h"

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

- initWithCreation:(Creation *)cr {
	[super initWithStyle:UITableViewStyleGrouped];
	self.creation = cr;
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
	return self;
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
	[ratingImage release];
	[creation release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:creation.ident];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero
									   reuseIdentifier:[NSString stringWithFormat:@"%@-%i-%i", creation.ident, indexPath.section, indexPath.row]] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	switch (indexPath.row) {
		case 0:
			if (indexPath.section == 0) {
				UIImageView *view = [[[UIImageView alloc] initWithImage:creation.image] retain];
				view.transform = CGAffineTransformMakeTranslation(32.0, 0.0);
				creation.detailImageView = view;
				[cell addSubview:view];
				[view release];
			}
			else {
				cell.text = [NSString stringWithFormat:NSLocalizedString(@"Creation by %@", @"Creation author"), creation.author];
				cell.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			break;
		case 1:
			if (indexPath.section == 0) {
				cell.text = creation.creationName;
			}
			else {
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setDateStyle:NSDateFormatterMediumStyle];
				[formatter setTimeStyle:NSDateFormatterShortStyle];
				cell.text = [NSString stringWithFormat:NSLocalizedString(@"Created on %@", @"Creation birthdate"), [formatter stringFromDate:creation.created]];
				cell.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
				[formatter release];
			}
			break;
		case 2:
			if (indexPath.section == 0) {
				if (![creation.creationDescription isEqualToString:@"NULL"]) {
					cell.text = creation.creationDescription;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
				}
			}
			else {
				NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
				NSNumber *rating = [[NSNumber alloc] initWithDouble:creation.rating];
				[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
				[formatter setMinimumFractionDigits:3];
				[formatter setMaximumFractionDigits:3];
				NSString *str = [[NSString stringWithFormat:NSLocalizedString(@"Rated %@", @"Creation rating"), [formatter stringFromNumber:rating]] retain];
				cell.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
				cell.text = str;
				cell.image = ratingImage;
				[formatter release];
				[rating release];
				[str release];
			}
			break;
		case 3:
			if (![creation.tags isEqualToString:@"NULL"])
				cell.text = [NSString stringWithFormat:NSLocalizedString(@"Tags: %@", @"Creation tags"), creation.tags];
			cell.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
			break;
		default:
			break;
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
			return 4;
		default:
			return 0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	if ((newIndexPath.section == 1) && (newIndexPath.row == 0)) {
		SporepediaTableViewController *vc = [[SporepediaTableViewController alloc] init];
		vc.searchTerm = creation.author;
		vc.isUser = YES;
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
	else if ((newIndexPath.section == 0) && (newIndexPath.row == 2) && (![creation.creationDescription isEqualToString:@"NULL"])) {
		UIViewController *vc = [[UIViewController alloc] init];
		UITextView *view = [[[UITextView alloc] init] retain];
		view.text = creation.creationDescription;
		view.editable = NO;
		view.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
		vc.view = view;
		[view release];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	}
}

@end
