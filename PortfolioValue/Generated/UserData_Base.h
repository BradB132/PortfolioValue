//
//  UserData_Base.h
//  GridFighter
//
//  Created by NoPLGenerator on 1/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#ifndef __USERDATA_BASE_H__
#define __USERDATA_BASE_H__

#import <Foundation/Foundation.h>
#import <libxml/parser.h>
//#import "NoPLRuntime.h"
#import "GridFighter_enums.h"
#import "GridFighter_typedefs.h"

@interface UserData_Base : NSObject
{
}

@property (nonatomic, weak) NSObject* parent;

@property (nonatomic, readonly) NSMutableArray* UserStocks;


-(id)initWithXML:(xmlNodePtr)node parent:(NSObject*)parentObj;

-(NSString*)printToXML;

-(void)load;
-(void)unload;

-(id)copyWithZone:(NSZone*)zone;

-(void)visitLoad;
-(void)visitUnload;

//-(NoPL_FunctionValue)evaluateFunction:(const char*)functionName argv:(const NoPL_FunctionValue*)argv argc:(unsigned int)argc;

//protected

-(void)appendXMLTagToString:(NSMutableString*)str;
-(void)appendXMLAttributesToString:(NSMutableString*)str;
-(void)appendXMLChildrenToString:(NSMutableString*)str;

@end

#endif //end __USERDATA_BASE_H__
