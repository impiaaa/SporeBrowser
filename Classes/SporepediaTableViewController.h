//
//  SporepediaTableViewController.h
//  Sporepedia
//
//  Created by Spencer Alves on 2/21/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SporepediaTableViewController : UITableViewController {
	NSMutableArray *data;
	UIImage *loadingImage;
	NSString *searchTerm;
	NSString *currentTag;
	NSMutableString *tempData;
	NSMutableData *xmlData;
	NSURLConnection *xmlConnection;
	NSXMLParser *parser;
	BOOL isUser;
	unsigned leftToLoad;
}

- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)didReceiveMemoryWarning;
- (void)dealloc;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName
	 attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)recievedData;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)creationDidFinishLoading;

@property (nonatomic, retain) NSString *searchTerm;
@property BOOL isUser;

@end
