//
//  DetailViewController.h
//  Sporepedia
//
//  Created by Spencer Alves on 4/4/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Creation.h"

@interface DetailViewController : UITableViewController {
	Creation *creation;
	UIImage *ratingImage;
}

@property (retain) Creation *creation;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)dealloc;
- (void)didReceiveMemoryWarning;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath;
- initWithCreation:(Creation *)cr;

@end
