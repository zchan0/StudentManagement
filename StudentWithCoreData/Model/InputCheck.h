//
//  InputCheck.h
//  StudentWithCoreData
//
//  Created by zhengcc on 15/1/6.
//  Copyright (c) 2015年 zhengcc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InputCheck : NSObject

//判断输入字符串是否为数字
-(BOOL)isNumber:(NSString *)inputString;

//判断输入字符串代表的数字是否在有效范围
-(BOOL)isValidNumber:(NSString *)inputString;

@end
