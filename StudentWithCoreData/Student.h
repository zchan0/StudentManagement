//
//  Student.h
//  StudentWithCoreData
//
//  Created by zhengcc on 15/1/6.
//  Copyright (c) 2015年 zhengcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Teacher;

@interface Student : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSNumber * score;
@property (nonatomic, retain) Teacher *whoTeach;

@end
