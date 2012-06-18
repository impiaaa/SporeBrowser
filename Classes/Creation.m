//
//  Creation.m
//  Sporepedia
//
//  Created by Spencer Alves on 2/27/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import "Creation.h"


@implementation Creation

@synthesize ident, creationName, thumb, image, author, created, rating, assetType, localizedAssetType, parent, creationDescription, tags;
@synthesize cell, detailCell;

- init{
    if ((self = [super init])) {
        ident = [[NSMutableString alloc] init];
		creationName = [[NSMutableString alloc] init];
		author = [[NSMutableString alloc] init];
		localizedAssetType = [[NSMutableString alloc] init];
		parent = [[NSMutableString alloc] init];
		creationDescription = [[NSMutableString alloc] init];
		tags = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)setImageFromURLString:(NSString *)urlString isLarge:(BOOL)isLarge {
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request=[NSURLRequest requestWithURL:url
										   cachePolicy:NSURLRequestReturnCacheDataElseLoad
									   timeoutInterval:60.0];
	if (isLarge) {
		imageConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (imageConnection)
			imageData=[[NSMutableData data] retain];
	}
	else {
		thumbConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
		if (thumbConnection)
			thumbData=[[NSMutableData data] retain];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if (connection == thumbConnection) {
		[thumbData setLength:0];
	}
	else if (connection == imageConnection) {
		[imageData setLength:0];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (connection == thumbConnection) {
		[thumbData appendData:data];
	}
	else if (connection == imageConnection) {
		[imageData appendData:data];
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)refreshCell {
	if ((thumb == nil) || (cell == nil))
		return;
	if ((cell.imageView.image != thumb) || (cell.imageView.image == nil))
		cell.imageView.image = thumb;
	[cell setNeedsLayout];
	[cell setNeedsDisplay];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (connection == thumbConnection) {
		if (thumb != nil)
			[thumb release];
		thumb = [[UIImage imageWithData:thumbData] retain];
		[self refreshCell];
		[thumbData release];
		thumbData = nil;
		if (thumbConnection)
			[thumbConnection release];
		thumbConnection = nil;
	}
	else if (connection == imageConnection) {
		if (image != nil)
			[image release];
		image = [[UIImage imageWithData:imageData] retain];
		if (detailCell != nil) {
			UIImageView *v = [[UIImageView alloc] initWithImage:image];
			v.center = CGPointMake(150, 128);
			[detailCell.contentView addSubview:v];
			[v release];
			[detailCell setNeedsLayout];
			[detailCell setNeedsDisplay];
		}
		[imageData release];
		imageData = nil;
		if (imageConnection)
			[imageConnection release];
		imageConnection = nil;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)cancelConnections {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (thumbConnection)
		[thumbConnection cancel];
	if (imageConnection)
		[imageConnection cancel];
}

- (void)dealloc {
	[ident release];
	[creationName release];
	[thumb release];
	[image release];
	[author release];
	[created release];
	[localizedAssetType release];
	[parent release];
	[creationDescription release];
	[tags release];
	if (thumbConnection)
		[thumbConnection release];
	if (thumbData)
		[thumbData release];
	if (imageConnection)
		[imageConnection release];
	if (imageData)
		[imageData release];
	[cell release];
	[detailCell release];
	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (connection == thumbConnection) {
		[thumbData release];
		thumbData = nil;
		[thumbConnection release];
		thumbConnection = nil;
        thumb = [UIImage imageNamed:@"notfound.png"];
        [self refreshCell];
	}
	else if (connection == imageConnection) {
		[imageData release];
		imageData = nil;
		[imageConnection release];
		imageConnection = nil;
	}
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSLog(@"Download error: %@ Connection: %@", error, connection);
}

@end
