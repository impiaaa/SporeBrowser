//
//  BuddyController.h
//  SporeBrowser
//
//  Created by Spencer Alves on 5/9/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuddyController : UITableViewController<NSXMLParserDelegate> {
	NSMutableArray *buddies;
	NSMutableString *tempData;
	NSMutableData *xmlData;
	NSURLConnection *xmlConnection;
	NSXMLParser *parser;
	NSString *userName;
}

- (void)didReceiveMemoryWarning;
- (void)dealloc;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)recievedData;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

@property (retain) NSString *userName;

@end
