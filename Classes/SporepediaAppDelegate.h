//
//  SporepediaAppDelegate.h
//  Sporepedia
//
//  Created by Spencer Alves on 1/28/09.
//  Copyright Spencer Alves 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SporepediaTableViewController.h"

@interface SporepediaAppDelegate : NSObject<UIApplicationDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
    IBOutlet SporepediaTableViewController *ccTable;
    IBOutlet SporepediaTableViewController *featuredTable;
    IBOutlet SporepediaTableViewController *maxisTable;
    IBOutlet SporepediaTableViewController *popNewTable;
    IBOutlet SporepediaTableViewController *popularTable;
    IBOutlet SporepediaTableViewController *randomTable;
    IBOutlet SporepediaTableViewController *recentTable;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)dealloc;
- (IBAction)linkClicked;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
