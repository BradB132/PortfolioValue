//
//  PVUserStockManager.m
//  PortfolioValue
//
//  Created by Brad Bambara on 1/13/14.
//  Copyright (c) 2014 Brad Bambara. All rights reserved.
//

#import "PVUserStockManager.h"
#import "UserStock.h"
#import "UserData.h"

#define kYahooApiInvalidResultPrefix @"N/A"

NSString * const kPVUserStockManagerFinishedPricesUpdateNotification = @"__kPVUserStockManagerFinishedPricesUpdateNotification__";

@implementation PVUserStockManager

+(void)verifyStockSymbol:(NSString *)symbol completion:(void (^)(BOOL))completionBlock
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
											 (unsigned long)NULL), ^(void) {
		
		//create the url for querying the stock price (using yahoo API)
		NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://finance.yahoo.com/d/quotes.csv?s=%@&f=a", symbol]];
		NSError* err;
		NSString* result = [NSString stringWithContentsOfURL:url usedEncoding:nil error:&err];
		BOOL success = (!err && ![result hasPrefix:kYahooApiInvalidResultPrefix]);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(success);
        });
	});
}

+(PVUserStockManager*)sharedInstance
{
    static PVUserStockManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PVUserStockManager alloc] init];
    });
    return sharedInstance;
}

-(NSString*)saveFileDirectory
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

-(NSString*)saveFilePath
{
	return [[self saveFileDirectory] stringByAppendingPathComponent:@"userData.xml"];
}

-(id)init
{
	self = [super init];
	if(self)
	{
		//load the user stocks from file (if we have a file)
		NSString* dataFullPath = [self saveFilePath];
		xmlDocPtr xmlDocument = xmlReadFile([dataFullPath UTF8String], NULL, XML_PARSE_XINCLUDE|XML_PARSE_NONET|XML_PARSE_NSCLEAN);
		if(xmlDocument)
		{
			UserData* loadedData = [[UserData alloc] initWithXML:xmlDocument->children parent:NULL];
			xmlFreeDoc(xmlDocument);
			
			_userStocks = loadedData.UserStocks;
			
			[self performSelector:@selector(refreshPriceData) withObject:nil afterDelay:0];
		}
		else
			_userStocks = [NSArray array];
	}
	return self;
}

-(void)saveDataToFile
{
	UserData* dataObj = [[UserData alloc] init];
	[dataObj.UserStocks addObjectsFromArray:_userStocks];
	NSString* xmlString = [dataObj printToXML];
	
	//make sure our directory exists
	NSString* saveDirectory = [self saveFileDirectory];
	if(![[NSFileManager defaultManager] fileExistsAtPath:saveDirectory])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:saveDirectory
								  withIntermediateDirectories:YES
												   attributes:nil
														error:nil];
	}
	[xmlString writeToFile:[self saveFilePath] atomically:NO encoding:NSASCIIStringEncoding error:nil];
}

-(void)notifyDataUpdate
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kPVUserStockManagerFinishedPricesUpdateNotification object:self];
}

-(BOOL)addUserStock:(UserStock*)newStock
{
	if(!newStock.symbolName)
		return NO;
	
	_userStocks = [_userStocks arrayByAddingObject:newStock];
	
	return YES;
}

-(void)removeUserStock:(UserStock*)stock
{
	if([_userStocks containsObject:stock])
	{
		NSMutableArray* copied = [NSMutableArray arrayWithArray:_userStocks];
		[copied removeObject:stock];
		_userStocks = [NSArray arrayWithArray:copied];
		
		[self saveDataToFile];
	}
}

-(UserStock*)stockForSymbol:(NSString*)symbol
{
	for(UserStock* stock in _userStocks)
	{
		if([stock.symbolName compare:symbol options:NSCaseInsensitiveSearch] == NSOrderedSame)
			return stock;
	}
	return nil;
}

-(void)refreshPriceData
{
	if(!([_userStocks count] > 0))
		return;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
											 (unsigned long)NULL), ^(void) {
		
		//create the url for querying the stock price (using yahoo API)
		NSMutableString* urlString = [NSMutableString stringWithString:@"http://finance.yahoo.com/d/quotes.csv?s="];
		BOOL firstStock = YES;
		for(UserStock* userStock in _userStocks)
		{
			if(firstStock)
				firstStock = NO;
			else
				[urlString appendString:@"+"];
			
			[urlString appendString:userStock.symbolName];
		}
		[urlString appendString:@"&f=sl1"];
		
		NSURL* url = [NSURL URLWithString:urlString];
		NSError* err;
		NSString* csv = [NSString stringWithContentsOfURL:url usedEncoding:nil error:&err];
		if(err)
			return;
		
		for(NSString* stockLine in [csv componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]])
		{
			if([stockLine length] <= 0)
				continue;
			
			NSArray* stockArgs = [stockLine componentsSeparatedByString:@","];
			
			//find the user stock object
			NSString* stockSymbol = stockArgs[0];
			stockSymbol = [stockSymbol substringWithRange:NSMakeRange(1, [stockSymbol length]-2)];
			UserStock* userStock = [self stockForSymbol:stockSymbol];
			if(userStock)
			{
				//set name match exactly what the server returned
				userStock.symbolName = stockSymbol;
				
				//set price with updated value
				NSString* priceArg = stockArgs[1];
				userStock.price = [priceArg floatValue];
			}
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self saveDataToFile];
			[self notifyDataUpdate];
        });
	});
}

@end
