//
//  EventsController.h
//  SporeBrowser
//
//  Created by Spencer Alves on 5/1/09.
//  Copyright 2009 Spencer Alves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsController : UIViewController <UIWebViewDelegate, NSXMLParserDelegate> {
	NSMutableString *htmlString;
	NSMutableDictionary *event;
	NSString *currentTag;
	NSMutableString *tempData;
	NSMutableData *xmlData;
	NSURLConnection *xmlConnection;
	NSXMLParser *parser;
	NSURL *url;
}

- (void)startDownload;
- (void)viewWillAppear:(BOOL)animated;
- (void)didReceiveMemoryWarning;
- (void)dealloc;
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

@property (retain) NSURL *url;

@end
