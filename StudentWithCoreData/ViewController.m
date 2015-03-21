//
//  ViewController.m
//  StudentWithCoreData
//
//  Created by zhengcc on 15/1/5.
//  Copyright (c) 2015年 zhengcc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *TxtName;
@property (weak, nonatomic) IBOutlet UITextField *TxtNumber;
@property (weak, nonatomic) IBOutlet UITextField *TxtAge;
@property (weak, nonatomic) IBOutlet UITextField *TxtScore;
@property (weak, nonatomic) IBOutlet UITextField *TxtMemo;

@property (strong, nonatomic) InputCheck *checker;
@property (strong, nonatomic) UIAlertView *alert;

@end

@implementation ViewController

//从持久层中将想要的对象都取出来
-(NSArray *)queryData:(NSString *) entityName sortWith:(NSString *)sortDesc ascending:(BOOL) asc predicatString:(NSString *)ps
{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];//向持久层发出请求
    request.fetchLimit = 100;
    request.fetchBatchSize = 20;//缓存
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:sortDesc ascending:asc]];//这个属性是一个数组，只取了一个值
    if (ps) //ps是一个过滤条件，如果过滤条件不为空
        request.predicate = [NSPredicate predicateWithFormat:@"name contains %@", ps];//name中包含了ps中指定的字符串
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];//创建一个实体
    request.entity = entity;//把实体给请求对象
    NSError *error;
    NSArray *array = [self.context executeFetchRequest:request error:&error];//执行请求
    if (error) {
        NSLog(@"无法获取数据, %@", error);
    }
    return array;
}

//使用持久化框架保存数据
- (IBAction)DataSave:(UIButton *)sender
{
    Student *student;
    
    if (![self.checker isNumber:self.TxtAge.text])
    {
        self.alert.message = @"年龄不能包含英文字符";
        [self.alert show];
    }else if (![self.checker isValidNumber:self.TxtScore.text]){
        self.alert.message = @"成绩超过有效范围";
        [self.alert show];
    }
    else{
        
        if (self.indexPath == nil)
        {   //添加
            student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.context];
            [self.students addObject:student];
        }else{
            //修改
            student = self.students[self.indexPath.row];
        }
        
        student.name = self.TxtName.text;
        student.number = self.TxtNumber.text;
        student.age = [NSNumber numberWithInt:[self.TxtAge.text intValue]];//使用持久化框架，继承，所有的数据都是对象
        student.score = [NSNumber numberWithFloat:[self.TxtScore.text floatValue]];
        student.memo = self.TxtMemo.text;
        
        //teacher丢失
        NSArray *arrayForTeacher = [self queryData:@"Teacher" sortWith:@"name" ascending:YES predicatString:@"Bai Tian"];
        self.teacher = arrayForTeacher[0];
        student.whoTeach = self.teacher;
        
        NSError *errorStudent;
        if (![self.context save:&errorStudent]) {
            NSLog(@"保存时出错:%@", errorStudent);
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];//代码实现动画
    }
    
}

- (IBAction)DataClear:(UIButton *)sender
{
    self.TxtName.text = nil;
    self.TxtNumber.text = nil;
    self.TxtAge.text = nil;
    self.TxtScore.text = nil;
    self.TxtMemo.text = nil;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    if (self.indexPath != nil) {
        Student *student = self.students[self.indexPath.row];
        self.TxtName.text = student.name;
        self.TxtNumber.text = student.number;
        self.TxtAge.text = [NSString stringWithFormat:@"%@", [student.age stringValue]];
        self.TxtScore.text = [NSString stringWithFormat:@"%@", [student.score stringValue]];
        self.TxtMemo.text = student.memo;
        
        //NSLog(@"view will appear:%@", student);
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ((textField == self.TxtName) || (textField == self.TxtNumber) ||(textField == self.TxtAge) ||(textField == self.TxtScore) ||(textField == self.TxtMemo) ) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.checker = [[InputCheck alloc]init];
    self.alert = [[UIAlertView alloc]initWithTitle:@"保存失败" message:@"请检查输入信息是否有效" delegate:self cancelButtonTitle:@"重新输入" otherButtonTitles: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
