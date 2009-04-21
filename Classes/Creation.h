//
//  Creation.h
//  Sporepedia
//
//  Created by Spencer Alves on 2/27/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SporepediaTableViewController.h"

@interface Creation : NSObject {
	NSMutableString *ident;
	NSMutableString *creationName;
	UIImage *thumb;
	UIImage *image;
	NSMutableString *author;
	NSDate *created;
	double rating;
	NSMutableString *assetType;
	unsigned subtype;
	NSMutableString *parent;
	NSMutableString *creationDescription;
	NSMutableString *tags;
	NSMutableData *thumbData;
	NSMutableData *imageData;
	NSURLConnection *thumbConnection;
	NSURLConnection *imageConnection;
	UITableViewCell *cell;
	UIImageView *detailImageView;
	SporepediaTableViewController *table;
}

@property (retain) NSMutableString *ident;
@property (retain) NSMutableString *creationName;
@property (retain) UIImage *thumb;
@property (retain) UIImage *image;
@property (retain) NSMutableString *author;
@property (retain) NSDate *created;
@property double rating;
@property (retain) NSMutableString *assetType;
@property unsigned subtype;
@property (retain) NSMutableString *parent;
@property (retain) NSMutableString *creationDescription;
@property (retain) NSMutableString *tags;
@property (retain) UITableViewCell *cell;
@property (retain) UIImageView *detailImageView;
@property (retain) SporepediaTableViewController *table;

- init;
- (void)setImageFromURLString:(NSString *)urlString isLarge:(BOOL)isLarge;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)refreshCell;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)cancelConnections;
- (void)dealloc;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end
