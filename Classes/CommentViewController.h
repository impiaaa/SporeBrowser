//
//  CommentViewController.h
//  SporeBrowser
//
//  Created by Spencer Alves on 09-04-27.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UITableViewController<NSXMLParserDelegate> {
	NSMutableArray *comments;
	NSString *currentTag;
	NSMutableString *tempData;
	NSMutableData *xmlData;
	NSURLConnection *xmlConnection;
	NSXMLParser *parser;
	NSString *assetID;
}

- (void)didReceiveMemoryWarning;
- (void)dealloc;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)recievedData;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
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

@property (retain) NSString *assetID;

@end
