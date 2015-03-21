//
//  Teacher.h
//  StudentWithCoreData
//
//  Created by zhengcc on 15/1/6.
//  Copyright (c) 2015年 zhengcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Student;

@interface Teacher : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSSet *students;
@end

@interface Teacher (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(Student *)value;
- (void)removeStudentsObject:(Student *)value;
- (void)addStudents:(NSSet *)values;
- (void)removeStudents:(NSSet *)values;

@end
