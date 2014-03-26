//
//  XPTaskListVCtler.m
//  XPlan
//
//  Created by mjlee on 14-3-2.
//  Copyright (c) 2014年 mjlee. All rights reserved.
//

#import "XPTaskListVCtler.h"
#import "XPNewTaskVctler.h"
#import "IIViewDeckController.h"
#import "XPTaskTableViewCell.h"
#import "XPDialyStaticVCtler.h"
#import "GADBannerView.h"

static int kHeadViewBtnStartIdx = 1000;
@interface XPTaskListVCtler ()
{
    NSMutableArray* _taskListNormal;
    NSMutableArray* _taskListImportant;
    NSMutableArray* _taskListFinish;
}
@property(nonatomic,strong) GADBannerView* adsBannerView;
// NavButtons
-(void)onNavRightBtuAction:(id)sender;
// View Buttons
-(void)onAddTaskButtonAction:(id)sender;
// Datas
-(void)reLoadData;
//ViewDeck
//-(BOOL)openLeftView;
@end

@implementation XPTaskListVCtler
static NSString *sCellIdentifier;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    // Instruct the system to stop generating device orientation notifications.
//    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization，load data From Core Data
        // nav setting
//        UIBarButtonItem* rightBtn =
//        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(onNavRightBtuAction:)];
//        self.navigationItem.rightBarButtonItem = rightBtn;
        UIImage* imgnormal   = [UIImage imageNamed:@"nav_icon_static"];
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, imgnormal.size.width/2, imgnormal.size.height/2);
        [btn setImage:imgnormal forState:UIControlStateNormal];
        [btn addTarget:self
                action:@selector(onNavRightBtuAction:)
      forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* rightBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = rightBtn;

        // data prepare
        _taskListNormal    = [[NSMutableArray alloc] init];
        _taskListImportant = [[NSMutableArray alloc] init];;
        _taskListFinish    = [[NSMutableArray alloc] init];;
        // data load from core date
        [self reLoadData];
        sCellIdentifier = @"MoveCell";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"今日任务";
    
    // tableview
    self.view.backgroundColor = [UIColor whiteColor];
    //self.tableView = [[FMMoveTableView alloc] initWithFrame:self.tableView.frame style:UITableViewStylePlain];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight  = 50;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView reloadData];

    // register the task list change
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onTaskUpdateNotification:) name:kMyMsgTaskUpdateNotification object:nil];
    
    //adsBannerView = []
    GADBannerView * bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    // Specify the ad unit ID.
    bannerView.adUnitID = @"a15332320048fb4";
    bannerView.delegate = (id<GADBannerViewDelegate>)self;
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView.rootViewController = self;
    //self.tableView.tableHeaderView = bannerView;
    self.adsBannerView = bannerView;
    // Initiate a generic request to load it with an ad.
    [self.adsBannerView loadRequest:[GADRequest request]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - UItableviewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if(section == 0) count = [_taskListNormal count];
    if(section == 1) count = [_taskListImportant count];
    if(section == 2) count = [_taskListFinish count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XPTaskTableViewCell *cell = (XPTaskTableViewCell *)[tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (!cell) {
        cell = [[XPTaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sCellIdentifier tableview:tableView];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    TaskModel* atask = nil;
    if([indexPath section] == 0){
        atask = [_taskListNormal objectAtIndex:[indexPath row]];
    }else if([indexPath section] == 1){
        atask = [_taskListImportant objectAtIndex:[indexPath row]];
    }else if([indexPath section] == 2){
        atask = [_taskListFinish objectAtIndex:[indexPath row]];
    }
    [cell setTask:atask];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger se = indexPath.section;
    if (se == 0)
    {
        // save to core data
        TaskModel * task2Done = [_taskListNormal objectAtIndex:[indexPath row]];
        task2Done.status   = [NSNumber numberWithInt:XPTask_Status_Done];
        task2Done.dateDone = [NSDate date];
        XPAppDelegate* app = [XPAppDelegate shareInstance];
        [app.coreDataMgr updateTask:task2Done];
        [_taskListNormal removeObjectAtIndex:[indexPath row]];
        [self performSelector:@selector(reloadListByStatus:) withObject:nil afterDelay:0.5];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else if(se == 1)
    {
        // save to core data
        TaskModel * task2Done = [_taskListImportant objectAtIndex:[indexPath row]];
        task2Done.status   = [NSNumber numberWithInt:XPTask_Status_Done];
        task2Done.dateDone = [NSDate date];
        XPAppDelegate* app = [XPAppDelegate shareInstance];
        [app.coreDataMgr updateTask:task2Done];
        [_taskListImportant removeObjectAtIndex:[indexPath row]];
        [self performSelector:@selector(reloadListByStatus:) withObject:nil afterDelay:0.5];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else if(se == 2){
        //[_taskListFinish removeObjectAtIndex:[indexPath row]];
    }
}


#pragma mark- tableviewdelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TaskModel* atask = nil;
    if([indexPath section] == 0) atask = [_taskListNormal objectAtIndex:[indexPath row]];
    else if([indexPath section] == 1) atask = [_taskListImportant objectAtIndex:[indexPath row]];
    else if([indexPath section] == 2)return;
    
    XPNewTaskVctler* updatevc = [[XPNewTaskVctler alloc] init];
    updatevc.viewType    = XPNewTaskViewType_Update;
    updatevc.task2Update = atask;
    [self.navigationController pushViewController:updatevc animated:YES];
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray  *titleArray  = @[@"普通",@"重要",@"完成"];
    UIView* headview = [[UIView alloc] initWithFrame:CGRectZero];
    headview.autoresizingMask= UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    headview.backgroundColor = XPRGBColor(248, 248, 248, 0.88);
    /*
    NSUInteger count= [tableView numberOfRowsInSection:section];
    if (count > 0) {
        headview.layer.shadowColor   = [XPRGBColor(157, 157, 157, 0.8) CGColor];
        headview.layer.shadowOffset  = CGSizeMake(0,1);
        headview.layer.shadowOpacity = 1.0;
    }else{
        headview.layer.borderWidth = 0.5;
        headview.layer.borderColor = [XPRGBColor(157, 157, 157, 0.8) CGColor];
    }*/
    
    UILabel* sectionTItle = [UILabel new];
    sectionTItle.frame    = CGRectMake(18, 0, 0, 0);
    sectionTItle.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    sectionTItle.backgroundColor = kClearColor;
    sectionTItle.font       = [UIFont systemFontOfSize:18];
    sectionTItle.textColor  = XPRGBColor(25, 133, 255, 1.0);
    sectionTItle.text = titleArray[section];
    [headview addSubview:sectionTItle];
    
    if (section != 2) {
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        btn.tag   = kHeadViewBtnStartIdx + section;
        btn.frame = CGRectMake(CGRectGetWidth(tableView.frame)-46, 0, 40, 40);
        btn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        [btn addTarget:self action:@selector(onAddTaskButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [headview addSubview:btn];
    }
    
    UIView* divLine = [[UIView alloc] initWithFrame:CGRectMake(0,39, CGRectGetWidth(tableView.frame),1)];
    divLine.backgroundColor = XPRGBColor(220, 220, 220, 1.0);
    [headview addSubview:divLine];
    return headview;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

#pragma mark - datas
-(void)reLoadData{
    XPAppDelegate* app = [XPAppDelegate shareInstance];
    {   // Normal
        NSArray* normalList = [app.coreDataMgr queryTaskByDay:[NSDate date]
                                                      prLevel:XPTask_PriorityLevel_normal
                                                       status:XPTask_Status_ongoing];
        if (normalList && [normalList count]) {
            [_taskListNormal removeAllObjects];
            [_taskListNormal setArray:normalList];
        }else{
            [_taskListNormal removeAllObjects];
        }
    }
    
    {
        NSArray* importantList = [app.coreDataMgr queryTaskByDay:[NSDate date]
                                                         prLevel:XPTask_PriorityLevel_important
                                                          status:XPTask_Status_ongoing];
        if (importantList && [importantList count]) {
            [_taskListImportant removeAllObjects];
            [_taskListImportant setArray:importantList];
        }else{
            [_taskListImportant removeAllObjects];
        }
    }
    
    {
        NSArray* finishList = [app.coreDataMgr queryTaskByDay:[NSDate date]
                                                      prLevel:XPTask_PriorityLevel_all
                                                       status:XPTask_Status_Done];
        if (finishList && [finishList count]) {
            [_taskListFinish removeAllObjects];
            [_taskListFinish setArray:finishList];
        }else{
            [_taskListFinish removeAllObjects];
        }
    }
}

-(void)reloadListByStatus:(int)status
{
    XPAppDelegate* app = [XPAppDelegate shareInstance];
    NSArray* finishList = [app.coreDataMgr queryTaskByDay:[NSDate date]
                                                  prLevel:XPTask_PriorityLevel_all
                                                   status:XPTask_Status_Done];
    if (finishList && [finishList count]) {
        [_taskListFinish removeAllObjects];
        [_taskListFinish setArray:finishList];
    }else{
        [_taskListFinish removeAllObjects];
    }
    NSIndexSet* inset = [[NSIndexSet alloc] initWithIndex:2];
    [self.tableView reloadSections:inset
                  withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Navigation
-(void)onNavRightBtuAction:(id)sender{
    NSUInteger total = [_taskListFinish count] + [_taskListImportant count] + [_taskListNormal count];
    NSUInteger fnish = [_taskListFinish count];
    NSUInteger normal= [_taskListNormal count];
    NSUInteger important = [_taskListImportant count];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInteger:total]     forKey:@"total"];
    [dict setObject:[NSNumber numberWithInteger:fnish]     forKey:@"finished"];
    [dict setObject:[NSNumber numberWithInteger:normal]    forKey:@"normal"];
    [dict setObject:[NSNumber numberWithInteger:important] forKey:@"important"];
    
    XPDialyStaticVCtler* diarystv = [[XPDialyStaticVCtler alloc] init];
    diarystv.taskDatas = dict;
    [self.navigationController  pushViewController:diarystv animated:YES];
}

#pragma mark - view Buttons
-(void)onAddTaskButtonAction:(id)sender{
    UIButton* btn = (UIButton*)sender;

    XPNewTaskVctler* newTvctl = [[XPNewTaskVctler alloc] init];
    if (btn.tag == kHeadViewBtnStartIdx) {
        newTvctl.viewType = XPNewTaskViewType_NewNormal;
    }else{
        newTvctl.viewType = XPNewTaskViewType_NewImportant;
    }
    [self.navigationController pushViewController:newTvctl animated:YES];
    self.viewDeckController.panningMode = IIViewDeckNoPanning;
}

#pragma mark - notifications 
-(void)onTaskUpdateNotification:(NSNotification*)notice{
    [self reLoadData];
    [self.tableView reloadData];
}

#pragma mark - 
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    /*[UIView beginAnimations:@"BannerSlide" context:nil];
    bannerView.frame = CGRectMake(0.0,self.view.frame.size.height - bannerView.frame.size.height,
                                  bannerView.frame.size.width,
                                  bannerView.frame.size.height);
    [UIView commitAnimations];*/
    //self.tableView.tableFooterView = self.adsBannerView;
}
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}

@end
