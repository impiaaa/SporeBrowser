//
//  SearchViewController.m
//  SporeBrowser
//
//  Created by Spencer Alves on 5/23/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "SearchViewController.h"


@implementation SearchViewController

@synthesize searchBar;

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.tableHeaderView = searchBar;
	searchBar.delegate = self;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchType = @"find";
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sb {
	sb.text = self.searchTerm;
	[sb resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)sb {
	self.searchTerm = sb.text;
	[self.data removeAllObjects];
	[self.tableView reloadData];
	[self startDownload];
	[sb resignFirstResponder];
}

@end
