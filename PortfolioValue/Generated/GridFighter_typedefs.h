//
//  GridFighter_typedefs.h
//  GridFighter
//
//  Created by NoPLGenerator on 1/14/14.
//  Copyright (c) 2014. All rights reserved.
//

#ifndef __GRIDFIGHTER_TYPEDEFS_H__
#define __GRIDFIGHTER_TYPEDEFS_H__

#import <UIKit/UIKit.h>

//handle conversions from strings
UIColor* string_to_UIColor(const char* colorString);
bool string_to_bool(const char* boolString);
CGPoint string_to_CGPoint(const char* pointString);
CGRect string_to_CGRect(const char* rectString);

NSString* escapeForXML(NSString* string);

#endif //end __GRIDFIGHTER_TYPEDEFS_H__

