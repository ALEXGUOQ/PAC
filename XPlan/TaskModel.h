//
//  TaskModel.h
//  XPlan
//
//  Created by mjlee on 14-3-22.
//  Copyright (c) 2014年 mjlee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectModel;

@interface TaskModel : NSManagedObject

@property (nonatomic, retain) NSNumber * content;
@property (nonatomic, retain) NSDate * dateCreate;
@property (nonatomic, retain) NSDate * dateDone;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * prLevel;
@property (nonatomic, retain) ProjectModel *project;

@end
