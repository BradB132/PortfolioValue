//
//  PVUserStockManager.h
//  PortfolioValue
//
//  Created by Brad Bambara on 1/13/14.
//  Copyright (c) 2014 Brad Bambara. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserStock;

extern NSString* const kPVUserStockManagerFinishedPricesUpdateNotification;

@interface PVUserStockManager : NSObject

@property (nonatomic, readonly) NSArray* userStocks;
@property (nonatomic, readonly) BOOL isUpdateInProgress;
@property (nonatomic, readonly) NSDate* lastUpdated;

+(PVUserStockManager*)sharedInstance;
+(void)verifyStockSymbol:(NSString*)symbol completion:(void (^)(BOOL success))completionBlock;

-(BOOL)addUserStock:(UserStock*)newStock;
-(void)removeUserStock:(UserStock*)stock;
-(UserStock*)stockForSymbol:(NSString*)symbol;
-(void)refreshPriceData;

@end
