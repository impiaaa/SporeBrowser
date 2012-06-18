//
//  DetailViewController.h
//  Sporepedia
//
//  Created by Spencer Alves on 4/4/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Creation.h"

@interface DetailViewController : UITableViewController <UIActionSheetDelegate> {
	Creation *creation;
	UIImage *ratingImage;
	UITabBar *tabBar;
}

@property (retain) Creation *creation;
@property (retain) UITabBar *tabBar;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)dealloc;
- (void)didReceiveMemoryWarning;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
