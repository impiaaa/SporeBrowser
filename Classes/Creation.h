//
//  Creation.h
//  Sporepedia
//
//  Created by Spencer Alves on 2/27/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Creation : NSObject {
	NSMutableString *ident;
	NSMutableString *creationName;
	UIImage *thumb;
	UIImage *image;
	NSMutableString *author;
	NSDate *created;
	double rating;
	unsigned long assetType;
	NSString *localizedAssetType;
	NSMutableString *parent;
	NSMutableString *creationDescription;
	NSMutableString *tags;
	NSMutableData *thumbData;
	NSMutableData *imageData;
	NSURLConnection *thumbConnection;
	NSURLConnection *imageConnection;
	UITableViewCell *cell;
	UITableViewCell *detailCell;
}

@property (retain) NSMutableString *ident;
@property (retain) NSMutableString *creationName;
@property (retain) UIImage *thumb;
@property (retain) UIImage *image;
@property (retain) NSMutableString *author;
@property (retain) NSDate *created;
@property double rating;
@property unsigned long assetType;
@property (retain) NSString *localizedAssetType;
@property (retain) NSMutableString *parent;
@property (retain) NSMutableString *creationDescription;
@property (retain) NSMutableString *tags;
@property (retain) UITableViewCell *cell;
@property (retain) UITableViewCell *detailCell;

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
