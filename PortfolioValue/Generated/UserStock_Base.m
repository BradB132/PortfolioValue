//
//  UserStock_Base.m
//  GridFighter
//
//  Created by NoPLGenerator on 1/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "UserStock_Base.h"

@implementation UserStock_Base

-(id)initWithXML:(xmlNodePtr)node parent:(NSObject*)parentObj
{
	self = [super init];
	if(self)
	{
		self.parent = parentObj;
		char* attrVal = (char*)xmlGetProp(node, (xmlChar*)"symbolName");
		if(attrVal)
		{
			self.symbolName = [NSString stringWithUTF8String:attrVal];
			xmlFree(attrVal);
		}
		attrVal = (char*)xmlGetProp(node, (xmlChar*)"sharesOwned");
		if(attrVal)
		{
			_sharesOwned = atof(attrVal);
			xmlFree(attrVal);
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
}

-(void)visitUnload
{
	[self unload];
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
	[str appendString:@"<UserStock"];
	[self appendXMLAttributesToString:str];
	[str appendString:@"/>"];
}

-(void)appendXMLAttributesToString:(NSMutableString*)str
{
	if([_symbolName length] > 0)
		[str appendFormat:@" symbolName=\"%@\"", escapeForXML(_symbolName)];
	[str appendFormat:@" sharesOwned=\"%g\"", _sharesOwned];
}

-(void)appendXMLChildrenToString:(NSMutableString*)str
{
}

/*-(NoPL_FunctionValue)evaluateFunction:(const char*)functionName argv:(const NoPL_FunctionValue*)argv argc:(unsigned int)argc
{
	NoPL_FunctionValue retVal;
	retVal.type = NoPL_DataType_Uninitialized;
	
	if(argc == 0)
	{
		//accessors
		if(!strcmp(functionName, "symbolName"))
		{
			NoPL_assignString([_symbolName UTF8String], retVal);
		}
		else if(!strcmp(functionName, "sharesOwned"))
		{
			retVal.numberValue = _sharesOwned;
			retVal.type = NoPL_DataType_Number;
		}
	}
	else
	{
		//mutators
		if(!strcmp(functionName, "setSymbolName"))
		{
			if(argc == 1 && argv[0].type == NoPL_DataType_String)
			{
				[self setSymbolName:[NSString stringWithUTF8String:argv[0].stringValue]];
				retVal.type = NoPL_DataType_Void;
			}
		}
		else if(!strcmp(functionName, "setSharesOwned"))
		{
			if(argc == 1 && argv[0].type == NoPL_DataType_Number)
			{
				[self setSharesOwned:argv[0].numberValue];
				retVal.type = NoPL_DataType_Void;
			}
		}
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
	UserStock_Base* copy = [[[self class] alloc] init];
	copy.symbolName = self.symbolName;
	copy.sharesOwned = self.sharesOwned;
	return copy;
}

@end
