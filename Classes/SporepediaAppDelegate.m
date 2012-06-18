//
//  SporepediaAppDelegate.m
//  Sporepedia
//
//  Created by Spencer Alves on 1/28/09.
//  Copyright Spencer Alves 2009. All rights reserved.
//

#import "SporepediaAppDelegate.h"

@implementation SporepediaAppDelegate

@synthesize window;
@synthesize tabBarController, tabBar;

- (IBAction)linkClicked {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.spore.com/"]];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    featuredTable.searchTerm = @"FEATURED";    // 1
	featuredTable.searchType = @"search";
	recentTable.searchTerm = @"NEWEST";        // 2
	recentTable.searchType = @"search";
	popularTable.searchTerm = @"TOP_RATED";    // 3
	popularTable.searchType = @"search";
    popNewTable.searchTerm = @"TOP_RATED_NEW"; // 4
	popNewTable.searchType = @"search";
	ccTable.searchTerm = @"CUTE_AND_CREEPY";   // 5
	ccTable.searchType = @"search";
	randomTable.searchTerm = @"RANDOM";        // 6
	randomTable.searchType = @"search";
    maxisTable.searchTerm = @"MAXIS_MADE";     // 7
	maxisTable.searchType = @"search";
	// ...and about/info is 8

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedOrder = [defaults arrayForKey:@"savedTabOrder"];
	NSMutableArray *orderedTabs = [NSMutableArray arrayWithCapacity:8];
	
	if ([savedOrder count] > 0 ) {
		for (int i = 0; i < [savedOrder count]; i++){
			for (UIViewController *aController in tabBarController.viewControllers) {
				if (aController.tabBarItem.tag == [[savedOrder objectAtIndex:i] integerValue]) {
					[orderedTabs addObject:aController];
				}
			}
		}
		tabBarController.viewControllers = orderedTabs;
	}
	int selectedIndex = [defaults integerForKey:@"selectedTabIndex"];
	tabBarController.selectedIndex = selectedIndex;
	NSString *searchText = [defaults stringForKey:@"searchText"];
	searchController.searchTerm = searchText;
	searchController.searchBar.text = searchText;

    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSMutableArray *savedOrder = [NSMutableArray arrayWithCapacity:6];
	NSArray *tabOrderToSave = tabBarController.viewControllers;
	for (UIViewController *aViewController in tabOrderToSave) {
		[savedOrder addObject:[NSNumber numberWithInt:aViewController.tabBarItem.tag]];
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:savedOrder forKey:@"savedTabOrder"];
	[defaults setInteger:tabBarController.selectedIndex forKey:@"selectedTabIndex"];
	[defaults setObject:searchController.searchTerm forKey:@"searchText"];
}

@end

