//
//  UserData_Base.m
//  GridFighter
//
//  Created by NoPLGenerator on 1/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "UserData_Base.h"
#import "UserStock.h"

@implementation UserData_Base

-(id)init
{
	self = [super init];
	if(self)
	{
		_UserStocks = [[NSMutableArray alloc] init];
	}
	return self;
}

-(id)initWithXML:(xmlNodePtr)node parent:(NSObject*)parentObj
{
	self = [super init];
	if(self)
	{
		self.parent = parentObj;
		_UserStocks = [[NSMutableArray alloc] init];

		xmlNodePtr child = node->children;
		while(child)
		{
			if(child->type == XML_ELEMENT_NODE)
			{
				Class _c = NSClassFromString([NSString stringWithUTF8String:(char*)child->name]);
				if(_c)
				{
					NSObject* newObj = [[_c alloc] initWithXML:child parent:parentObj];
					if([newObj isKindOfClass:[UserStock class]])
						[_UserStocks addObject:newObj];
				}
			}
			child = child->next;
		}
	}
	return self;
}

-(void)load
{
	//override this in subclasses
}

-(void)unload
{
	//override this in subclasses
}

-(void)visitLoad
{
	[self load];

	for(UserStock* child in _UserStocks)
		[child visitLoad];
}

-(void)visitUnload
{
	[self unload];

	for(UserStock* child in _UserStocks)
		[child visitUnload];
}
-(NSString*)printToXML
{
	NSMutableString* str = [[NSMutableString alloc] init];
	[str appendString:@"<"];
	[str appendString:@"?xml version=\"1.0\" encoding=\"UTF-8\" ?"];
	[str appendString:@">"];

	[self appendXMLTagToString:str];

	return str;
}

-(void)appendXMLTagToString:(NSMutableString*)str
{
	[str appendString:@"<UserData"];
	[self appendXMLAttributesToString:str];
	[str appendString:@">"];
	[self appendXMLChildrenToString:str];
	[str appendString:@"</UserData>"];
}

-(void)appendXMLAttributesToString:(NSMutableString*)str
{
}

-(void)appendXMLChildrenToString:(NSMutableString*)str
{
	for(UserStock* child in _UserStocks)
		[child appendXMLTagToString:str];
}

/*-(NoPL_FunctionValue)evaluateFunction:(const char*)functionName argv:(const NoPL_FunctionValue*)argv argc:(unsigned int)argc
{
	NoPL_FunctionValue retVal;
	retVal.type = NoPL_DataType_Uninitialized;
	
	if(argc == 0)
	{
		//accessors
		if(!strcmp(functionName, "UserStocks"))
		{
			retVal.pointerValue = (__bridge void *)(_UserStocks);
			retVal.type = NoPL_DataType_Pointer;
		}
	}
	else
	{
		//mutators
	}
	return retVal;
}*/

-(NSString*)description
{
	NSMutableString* str = [[NSMutableString alloc] init];
	[str appendString:NSStringFromClass([self class])];
	[self appendXMLAttributesToString:str];
	return str;
}

-(id)copyWithZone:(NSZone*)zone
{
	UserData_Base* copy = [[[self class] alloc] init];
	for(UserStock* child in self.UserStocks)
		[copy.UserStocks addObject:[child copy]];
	return copy;
}

@end
