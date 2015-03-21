//
//  InputCheck.m
//  StudentWithCoreData
//
//  Created by zhengcc on 15/1/6.
//  Copyright (c) 2015年 zhengcc. All rights reserved.
//

#import "InputCheck.h"

@implementation InputCheck

-(BOOL)isNumber:(NSString *)inputString
{
    for (int i = 0; i < inputString.length; i++) {
        char ch = [inputString characterAtIndex:i];
        if (ch <48 || ch >57) {
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)isValidNumber:(NSString *)inputString
{
    double number = [inputString doubleValue];
    if ((number < 0) || (number > 100)) {
        return NO;
    }
    
    return YES;
}

@end
