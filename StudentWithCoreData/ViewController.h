//
//  ViewController.h
//  StudentWithCoreData
//
//  Created by zhengcc on 15/1/5.
//  Copyright (c) 2015年 zhengcc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Teacher.h"
#import "Student.h"
#import "InputCheck.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *students;
@property (strong, nonatomic) Teacher *teacher;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end

