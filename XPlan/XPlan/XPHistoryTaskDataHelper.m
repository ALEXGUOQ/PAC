//
//  XPHistoryTaskDataHelper.m
//  XPlan
//
//  Created by mjlee on 14-3-18.
//  Copyright (c) 2014年 mjlee. All rights reserved.
//

#import "XPHistoryTaskDataHelper.h"
#import "XPDataManager.h"
@interface XPHistoryTaskDataHelper()
{
    NSUInteger _curPageNormal;
    NSUInteger _curPageImportant;
    NSUInteger _curPageFinished;
    
    NSUInteger _totalNormal;
    NSUInteger _totalImportant;
    NSUInteger _totalFinished;
}
@end

@implementation XPHistoryTaskDataHelper
-(id)init{
    self = [super init];
    if (self) {
        NSMutableArray*listNormal    = [[NSMutableArray alloc] init];
        NSMutableArray*listImportant = [[NSMutableArray alloc] init];
        NSMutableArray*listFinished  = [[NSMutableArray alloc] init];
        _curPageNormal   = 0;
        _curPageImportant= 0;
        _curPageFinished = 0;
        _totalNormal = 0;
        _totalImportant = 0;
        _totalFinished  = 0;
        
        self.listNormal = listNormal;
        self.listImportant = listImportant;
        self.listFinished  = listFinished;
        
        
        XPDataManager* dmg = [XPAppDelegate shareInstance].coreDataMgr;
        _totalNormal   = [dmg getHistoryTaskCount:XPTask_PriorityLevel_normal status:XPTask_Status_ongoing];
        _totalImportant= [dmg getHistoryTaskCount:XPTask_PriorityLevel_important status:XPTask_Status_ongoing];
        _totalFinished = [dmg getHistoryTaskCount:XPTask_PriorityLevel_all status:XPTask_Status_Done];
        
        {
            NSArray* tary = [dmg queryHistoryTask:XPTask_PriorityLevel_normal status:XPTask_Status_ongoing page:_curPageNormal];
            if (tary && [tary count]) {
                [self.listNormal setArray:tary];
            }
        }
        
        {
            NSArray* tary = [dmg queryHistoryTask:XPTask_PriorityLevel_important status:XPTask_Status_ongoing page:_curPageImportant];
            if (tary && [tary count]) {
                [self.listImportant setArray:tary];
            }
        }
        
        {
            NSArray* tary = [dmg queryHistoryTask:XPTask_PriorityLevel_all status:XPTask_Status_Done page:_curPageFinished];
            if (tary && [tary count]) {
                [self.listFinished setArray:tary];
            }
        }
    }
    return self;
}

-(BOOL)checkIfHadHistoryTask:(XPTaskPriorityLevel)priority
{
    XPDataManager* dmg = [XPAppDelegate shareInstance].coreDataMgr;
    return [dmg checkIfHasHistoryTask:priority];
}

-(BOOL)hasNextPage:(XPTaskPriorityLevel)priority
{
    if (priority == XPTask_PriorityLevel_normal) {
        int page = _totalNormal/20;
        if (_totalNormal%20 != 0) {
            page ++;
        }
        if (_curPageNormal >= page-1)
        {
            return NO;
        }else
        {
            return YES;
        }
    }
    if (priority == XPTask_PriorityLevel_important) {
        int page = _totalImportant/20;
        if (_totalImportant%20 != 0) {
            page ++;
        }
        if (_curPageImportant >= page-1)
        {
            return NO;
        }else
        {
            return YES;
        }
    }
    if (priority == XPTask_PriorityLevel_all) {
        int page = _totalFinished/20;
        if (_totalFinished%20 != 0) {
            page ++;
        }
        if (_curPageFinished >= page-1)
        {
            return NO;
        }else
        {
            return YES;
        }
    }
    return NO;
}

-(void)getNextPage:(XPTaskPriorityLevel)priority
{
    if (NO == [self hasNextPage:priority]) {
        return;
    }
    
//    NSArray* tary = [dmg queryHistoryTask:priority status:XPTask_Status_ongoing page:_curPageNormal];
//    if (tary && [tary count]) {
//    }
}

@end
