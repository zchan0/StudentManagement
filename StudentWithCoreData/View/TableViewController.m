//
//  TableViewController.m
//  StudentWithCoreData
//
//  Created by zhengcc on 15/1/5.
//  Copyright (c) 2015年 zhengcc. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"

@interface TableViewController ()

@property (strong, nonatomic) NSManagedObjectContext *context;//上下文引用对象
@property (strong, nonatomic) NSMutableArray *students;//从持久层中取出的对象放入该数组

//通过子类进行操作，而不用键值对的方式进行操作
//每次添加学生对象到持久层中时，也要添加一些教师的信息
@property (strong, nonatomic) Student *student;
@property (strong, nonatomic) Teacher *teacher;

@end

@implementation TableViewController

//多线程处理
//从后台取数据的过程放到一个异步线程中，当取回来再转到主线程（涉及到UI，放到主线程执行）
- (IBAction)refreshData:(UIRefreshControl *)sender
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.students removeAllObjects];
        [self loadData];
        dispatch_async(dispatch_get_main_queue(), ^{[self.tableView reloadData];});
    });
    [self.refreshControl endRefreshing];
}

-(NSManagedObjectContext *)context
{
    if (!_context) {
        AppDelegate *coreDataManager = [[AppDelegate alloc]init];
        _context = [coreDataManager managedObjectContext];
    }
    return _context;
}

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

-(void)loadData
{
    NSArray *arrayForStudents = [self queryData:@"Student" sortWith:@"number" ascending:YES predicatString:nil];
    _students = [NSMutableArray array];//初始化student属性
    for (Student *stu in arrayForStudents) {
        [_students addObject:stu];//将取回来的数据放入这个可变数组中
    }
}

-(NSMutableArray *)students
{
    //覆盖了getter方法
    if (!_students) {
        [self loadData];
    }
    
    return _students;
}

-(Teacher *)teacher
{
    if (!_teacher) {
        NSArray *arrayForTeacher = [self queryData:@"Teacher" sortWith:@"name" ascending:YES predicatString:@"Bai Tian"];
        if (arrayForTeacher.count > 0)
        {
            //查询结果大于0，说明已经找到了老师
            _teacher = arrayForTeacher[0];
        }else{
            //如果不是大于0，说明还没有加入持久层
            NSError *error;
            Teacher *th = [NSEntityDescription insertNewObjectForEntityForName:@"Teacher" inManagedObjectContext:self.context];//插入/新建一个对象
            th.name = @"Bai Tian";
            th.age = [NSNumber numberWithInt:99];
            th.number = @"ST00002";
            [self.context save:&error];
            _teacher = th;
        }
    }
    return _teacher;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addInfo"]) {
        if ([segue.destinationViewController isKindOfClass:[ViewController class]]) {
            ViewController *vc = (ViewController *)segue.destinationViewController;
            vc.students = self.students;//将表视图上显示的所有对象都要传过去
            vc.context = self.context;//为了保存到持久层中
            vc.indexPath = nil;//添加
            vc.teacher = self.teacher;//添加新的学生的时候，其老师的信息也要添加
            NSLog(@"vc.teacher is %@",vc.teacher);
        }
    }
    
    if ([segue.identifier isEqualToString:@"viewDetail"]) {
        if ([segue.destinationViewController isKindOfClass:[ViewController class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];//sender代表点击的表单元，获取它的位置，存放到indexPath
            ViewController *vc = (ViewController *)segue.destinationViewController;
            vc.context = self.context;
            vc.students = self.students;
            vc.indexPath = indexPath;//查看，要指定表单元的位置
            vc.teacher = self.teacher;
        }
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - searchBar 

-(void)searchInName:(NSString *)searchString
{
    [self.students removeAllObjects];
    NSArray *arrayForStudents = [self queryData:@"Student" sortWith:@"number" ascending:YES predicatString:searchString];
    for (Student *stu in arrayForStudents) {
        [self.students addObject:stu];
    }
    [self.tableView reloadData];
}

//协议中的方法

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //textDidChange:随着敲击字符，改动表视图中的内容
    if (searchText.length == 0) {
        return;
    }
    [self searchInName:searchText];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchInName:searchBar.text];
    [searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self searchInName:nil];
    [searchBar resignFirstResponder];
}

#pragma mark - Table view data source

//说明表视图有多少section，每个section有多少个cell
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableVie
{
    // 目前只有一个section
    return 1;
}

//告知UITableView表单元的数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // students数组中的元素个数
    return [self.students count];
}

//当表视图要生成的时候，将数据取出来，生成表单元，将数据放进去
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"studentCell" forIndexPath:indexPath];
    self.student = self.students[indexPath.row];
    cell.textLabel.text = self.student.name;
    cell.detailTextLabel.text = self.student.number;
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 删除
        [self.context deleteObject:self.students[indexPath.row]];
        [self.students removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSError *error;
        [self.context save:&error];//保证删除保存到磁盘
    
    }
}

//触碰到附件小图标的时候
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //用代码的方式，从故事板中实例化一个视图控制器
    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"modifyView"];
    vc.students = self.students;
    vc.indexPath = indexPath;
    vc.context = self.context;
    [self.navigationController pushViewController:vc animated:YES];//用代码的方式过渡到其它界面
    
}



@end
