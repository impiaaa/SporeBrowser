//
//  SearchViewController.h
//  SporeBrowser
//
//  Created by Spencer Alves on 5/23/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SporepediaTableViewController.h"

@interface SearchViewController : SporepediaTableViewController <UISearchBarDelegate> {
    IBOutlet UISearchBar *searchBar;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

@end
