//
//  XPDataManager.m
//  XPlan
//
//  Created by mjlee on 14-2-22.
//  Copyright (c) 2014年 mjlee. All rights reserved.
//

#import "XPDataManager.h"
#import "NSDate+Category.h"

@interface XPDataManager(){
}
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation XPDataManager
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - CoreData
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"coreData:Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
//初始化context对象
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    //这里的URLForResource:@"lich" 的url名字（lich）要和你建立datamodel时候取的名字是一样的，至于怎么建datamodel很多教程讲的很清楚
#if IfCoreDataDebug
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"XPlanModel" withExtension:@"momd"];
#else
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"XPlanModel" withExtension:@"momd"];
#endif
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    //这个地方的.sqlite名字没有限制，就是一个数据库文件的名字
#if IfCoreDataDebug
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"XPlanModel.sqlite"];
#else
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"XPlanModel.sqlite"];
#endif
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error])
    {
        NSLog(@"coreData:Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory
/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Data CURD
#pragma mark - task-list-curd
-(void)insertTask:(NSString*)content date:(NSDate*)datecreate type:(XPTaskType)taskType prLevel:(XPTaskPriorityLevel)prLevel
          project:(ProjectModel*)project
{
   NSManagedObjectContext *context = [self managedObjectContext];
   TaskModel* newTask  = [NSEntityDescription insertNewObjectForEntityForName:@"TaskModel"
                                                      inManagedObjectContext:context];
    do
    {
        if (!newTask){
            break;
        }
        newTask.content    = content;
        newTask.dateCreate = datecreate;
        newTask.status     = [NSNumber numberWithInteger:XPTask_Status_ongoing];
        newTask.type       = [NSNumber numberWithInteger:taskType];
        newTask.prLevel    = [NSNumber numberWithInteger:prLevel];
        newTask.dateDone   = nil;
        newTask.project    = nil;
        
        NSError *error;
        if(![context save:&error]){
            NSLog(@"Task Add fail：%@",[error localizedDescription]);
            break;
        }
    } while (NO);
}

-(void)updateTask:(TaskModel*)task2update
{
    NSManagedObjectContext *context = [self managedObjectContext];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"content=%@",task2update.content];
    //首先建立一个request,这里相当于sqlite中的查询条件，具体格式参考苹果文档
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TaskModel"
                                   inManagedObjectContext:context]];
    [request setPredicate:predicate];

    NSError *error = nil;
    //这里获取到的是一个数组，你需要取出你要更新的那个obj
    NSArray *result = [context executeFetchRequest:request error:&error];
    for (TaskModel *info in result){
        info.content    = task2update.content;
        info.dateCreate = task2update.dateCreate;
        info.status     = task2update.status;
        info.type       = task2update.type;
        info.prLevel    = task2update.prLevel;
        info.dateDone   = task2update.dateDone;
        info.project    = task2update.project;
        if ([context save:&error]) {
            NSLog(@"更新成功");
        }else{
            NSLog(@"更新失败");
        }
    }
}

-(void)deleteTask:(NSString*)content
{
    
}

-(NSArray*)queryTaskByDay:(NSDate*)day prLevel:(XPTaskPriorityLevel)alevel status:(XPTaskStatus)astatus
{
    NSManagedObjectContext *context = [self managedObjectContext];
    // 查询条件
    NSDate* dayBegin  = [day startOfDay];
    NSDate* dayEnd    = [day endOfDay];
    NSNumber* status  = [NSNumber numberWithInt:astatus];
    NSNumber* plLevel = [NSNumber numberWithInt:alevel];
    NSPredicate * predicate= nil;
    if (alevel == XPTask_PriorityLevel_all) {
        predicate = [NSPredicate predicateWithFormat:@"(dateCreate >= %@) AND (dateCreate <= %@) AND status=%@ AND prLevel!=%@", dayBegin,dayEnd,status,plLevel];
    }else{
        predicate = [NSPredicate predicateWithFormat:@"(dateCreate >= %@) AND (dateCreate <= %@) AND status=%@ AND prLevel=%@", dayBegin,dayEnd,status,plLevel];
    }
    
    //首先你需要建立一个request
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"dateCreate" ascending:NO selector:nil];
    NSArray *sortDescriptors   = [NSArray arrayWithObjects:dateSort,nil];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TaskModel"
                                   inManagedObjectContext:context]];
    [request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptors];

    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    return result;
}

-(NSArray*)queryHistoryTask:(XPTaskPriorityLevel)alevel status:(int)astatus page:(NSUInteger)page
{
    NSManagedObjectContext *context = [self managedObjectContext];
    // 查询条件
    NSDate* day = [NSDate date];
    NSDate* dayBegin  = [day startOfDay];
    NSDate* dayEnd    = [day endOfDay];
    NSNumber* status = [NSNumber numberWithInt:astatus];
    NSNumber* level  = [NSNumber numberWithInt:alevel];
    NSPredicate *predicate = nil;
    if (alevel == XPTask_PriorityLevel_all) {
        predicate = [NSPredicate predicateWithFormat:@"status=%@ AND prLevel!=%@ AND ((dateCreate < %@) OR (dateCreate > %@))",status,level,dayBegin,dayEnd];
    }else{
        predicate = [NSPredicate predicateWithFormat:@"status=%@ AND prLevel=%@ AND ((dateCreate < %@) OR (dateCreate > %@))",status,level,dayBegin,dayEnd];
    }
    
    //首先你需要建立一个request:排序
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"dateCreate" ascending:NO selector:nil];
    NSArray *sortDescriptors   = [NSArray arrayWithObjects:dateSort,nil];
    NSFetchRequest * request   = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TaskModel"
                                   inManagedObjectContext:context]];
    [request setPredicate:predicate];
    [request setFetchOffset:page*10];
    [request setFetchLimit:10];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    return result;
}

-(BOOL)checkIfHasHistoryTask:(XPTaskPriorityLevel)alevel
{
    NSManagedObjectContext *context = [self managedObjectContext];
    // 查询条件
    NSDate* day = [NSDate date];
    NSDate* dayBegin  = [day startOfDay];
    NSNumber* level  = [NSNumber numberWithInt:alevel];
    NSPredicate *predicate = nil;
    predicate = [NSPredicate predicateWithFormat:@"prLevel=%@ AND dateCreate < %@",level,dayBegin];
    
    //首先你需要建立一个request
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"TaskModel"
                                   inManagedObjectContext:context]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result && [result count])
    {
        return YES;
    }
    return NO;
}

-(NSUInteger)getHistoryTaskCount:(XPTaskPriorityLevel)alevel status:(int)astatus
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSUInteger entityCount = 0;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TaskModel" inManagedObjectContext:context];
    NSDate* day = [NSDate date];
    NSDate* dayBegin = [day startOfDay];
    NSNumber* level  = [NSNumber numberWithInt:alevel];
    NSNumber* status = [NSNumber numberWithInt:astatus];
    NSPredicate *predicate = nil;
    
    if (alevel == XPTask_PriorityLevel_all) {
        predicate = [NSPredicate predicateWithFormat:@"status=%@ AND prLevel!=%@ AND dateCreate < %@",status,level,dayBegin];
    }else{
        predicate = [NSPredicate predicateWithFormat:@"status=%@ AND prLevel=%@ AND dateCreate < %@",status,level,dayBegin];
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setIncludesSubentities:NO];
    NSError *error = nil;
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    if(error == nil){
        entityCount = count;
    }
    return entityCount;
}
@end
