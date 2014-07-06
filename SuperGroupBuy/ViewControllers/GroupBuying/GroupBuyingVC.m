//
//  GroupBuyingVC.m
//  SuperGroupBuying
//
//  Created by lanouhn on 14-4-2.
//  Copyright (c) 2014年 lanouhn. All rights reserved.
//

#import "GroupBuyingVC.h"
#import "GroupBuyingDetailVC.h"
#import "GroupBuyingCell.h"
#import "CommonDefine.h"
#import "SignatrueEncryption.h"
#import "NetWorkRequest.h"
#import "GroupBuying.h"
#import "CityListVC.h"
#import "DropDown.h"
#import "UIWindow+YzdHUD.h"
@interface GroupBuyingVC ()
{
    NSMutableArray *_groupBuyingArr;
    //-----------------------------------
    
    NetWorkRequest *_request;//商家请求数据
    NetWorkRequest *_regionRequest;//分区列表请求数据
    NetWorkRequest *_categoryRequest;//分类列表请求
    NetWorkRequest *_cityRequest;//城市定位请求
    NSInteger _page;//页数
    //    NSString *_city;//切换城市
    UIButton *_LeftItemBtn;//当前城市按钮
    UIButton *_areaBtn;//分区按钮
    UIButton *_classBtn;//分类按钮
    UIButton *_sortBtn;//排序按钮
    NSDictionary *_sortDic;//排序字典
    NSInteger _sortNum;//排序字典对应的key
    NSString *_region;//所选分区
    NSMutableArray *_regionArr;//分区列表数组
    //    NSDictionary *_cityDic;//请求分区得到当前城市字典（包含所有分区和街道）传往2级列表
    NSString *_category;//所选分类
    NSMutableArray *_categoryArr;//分类列表数组
    //    NSDictionary *_categoryDic;//请求分类得到的所有分类字典，传往2级列表
    UIView *_shadeView;
    
}
@property(nonatomic,retain)DropDown *dropDown;
@property(nonatomic,retain)DropDown *dropDown2;
@property(nonatomic,retain)DropDown *dropDown3;

@property(nonatomic,retain)NSString *city;

@property(nonatomic,retain)NSDictionary *cityDic;//请求分区得到当前城市字典（包含所有分区和街道）传往2级列表
@property(nonatomic,retain)NSDictionary *categoryDic;//请求分类得到的所有分类字典，传往2级列表

@property(nonatomic,retain)NSMutableDictionary *dicIn;
@end

@implementation GroupBuyingVC


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    
    if (_dropDown != nil) {
        [self dropDownRelease];
    }
    if (_dropDown2 != nil ) {
        [self dropDown2Release];
    }
    if (_dropDown3 != nil) {
        [self dropDown3Release];
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle:) name:@"city" object:@"Shops"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.tabBarController.navigationItem.title = @"团购";
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    //结果排序，1:默认，2:价格低优先，3:价格高优先，4:购买人数多优先，5:最新发布优先，6:即将结束优先
    _sortDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"默认",@"2",@"价格低优先", @"3",@"价格高优先",@"4",@"购买人数多优先",@"5",@"最新发布优先",@"6",@"即将结束优先",nil];
    self.navigationItem.title = @"团购";
    _request = [[NetWorkRequest alloc] init];
    _request.deligate = self;
    _regionRequest = [[NetWorkRequest alloc] init];
    _regionRequest.deligate = self;
    _categoryRequest = [[NetWorkRequest alloc] init];
    _categoryRequest.deligate = self;
    _cityRequest = [[NetWorkRequest alloc] init];
    _cityRequest.deligate = self;
    _groupBuyingArr = [[NSMutableArray alloc] init];
    _regionArr = [[NSMutableArray alloc] init];
    _categoryArr = [[NSMutableArray alloc] init];
    _page = 1;
    
    
    
    _city = @"上海";//当前城市
    _category = @"美食";//默认分类
    _region = nil;
    _sortNum = 1;
    _shadeView = [[UIView alloc] initWithFrame:self.tableView.frame];
    _shadeView.backgroundColor = [UIColor lightGrayColor];
    _shadeView.alpha = 0.7;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 1;
    [tap addTarget:self action:@selector(tap:)];
    [_shadeView addGestureRecognizer:tap];
    [tap release];
    [self loadData];
    [self createClassiflyView];
    [self createLeftItem];
    [self createHeaderView];
    [self showRefreshHeader:YES];

    
}
//- (void)handle:(NSNotification *)notification
//{
//    NSLog(@"%@%@%@",[notification object],[notification name],[notification userInfo]);
//    //取出的内容，取出通知的发出对象，取出通知所传的值
//}

#pragma mark 遮罩手势
- (void)tap:(UIGestureRecognizer *)tap
{
    if (_dropDown != nil) {
        [self dropDownRelease];
    }
    if (_dropDown2 != nil ) {
        [self dropDown2Release];
    }
    if (_dropDown3 != nil) {
        [self dropDown3Release];
    }
}

#pragma mark 分类自定义View
- (void)createClassiflyView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    [view release];
    _areaBtn = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
    _areaBtn.frame = CGRectMake(0, 0, 107, 44);
    [_areaBtn setTitle:@"分区" forState:UIControlStateNormal];
    [_areaBtn.layer setBorderWidth:1.0];
    [_areaBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_areaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_areaBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    _areaBtn.backgroundColor = [UIColor orangeColor];
    _areaBtn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    [_areaBtn addObserver:self forKeyPath:@"titleLabel.text" options:NSKeyValueObservingOptionNew context:0];
    [view addSubview:_areaBtn];
    
    _classBtn = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
    _classBtn.frame = CGRectMake(107, 0, 107, 44);
    [_classBtn setTitle:_category forState:UIControlStateNormal];
    [_classBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _classBtn.backgroundColor = [UIColor orangeColor];
    [_classBtn.layer setBorderWidth:1.0];
    [_classBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [_classBtn addTarget:self action:@selector(click2:) forControlEvents:UIControlEventTouchUpInside];
    _classBtn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    [_classBtn addObserver:self forKeyPath:@"titleLabel.text" options:NSKeyValueObservingOptionNew context:0];
    [view addSubview:_classBtn];
    
    _sortBtn = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
    _sortBtn.frame = CGRectMake(214, 0, 106, 44);
    _sortBtn.backgroundColor = [UIColor orangeColor];
    [_sortBtn.layer setBorderWidth:1.0];
    [_sortBtn.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [_sortBtn setTitle:@"默认排序" forState:UIControlStateNormal];
    [_sortBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sortBtn addTarget:self action:@selector(click3:) forControlEvents:UIControlEventTouchUpInside];
    _sortBtn.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    [_sortBtn addObserver:self forKeyPath:@"titleLabel.text" options:NSKeyValueObservingOptionNew context:0];
    [view addSubview:_sortBtn];
    
}
#pragma mark 观察者事件
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == _sortBtn) {
        _sortNum = [[_sortDic objectForKey:[change objectForKey:@"new"]] intValue];
        _page = 1;
        [self loadData];
        [self.tableView reloadData];
        
    }else if (object == _areaBtn) {
        [_region release];
        _region = [[change objectForKey:@"new"] retain];
        _page = 1;
        [self loadData];
        [self.tableView reloadData];
        
    }else if(object == _classBtn){
        _category = [[change objectForKey:@"new"] retain];
        _page = 1;
        [self loadData];
        [self.tableView reloadData];
        
    }
}
#pragma mark 分类点击事件
- (void)click:(UIButton *)btn
{
    if (_dropDown == nil) {
        if (_dropDown2 != nil) {
            [self dropDown2Release];
        }
        
        if (_dropDown3 != nil) {
            [self dropDown3Release];
        }
        [btn.superview.superview addSubview:_shadeView];
        _dropDown = [[DropDown alloc]initWithButton:btn array:_regionArr height:250];
        _dropDown.delegate = self;
        _dropDown.dic = _cityDic;
        [_dropDown analysisSelf_dic];
    }else
    {
        [self dropDownRelease];
    }
}
- (void)click2:(UIButton *)btn
{
    if (_dropDown2 == nil) {
        if (_dropDown != nil) {
            [self dropDownRelease];
        }
        
        if (_dropDown3 != nil) {
            [self dropDown3Release];
        }
        [btn.superview.superview addSubview:_shadeView];
        _dropDown2= [[DropDown alloc]initWithButton:btn array:_categoryArr height:250];
        _dropDown2.delegate = self;
        _dropDown2.dic = _categoryDic;
        [_dropDown2 analysisSelf_dic];
    }else
    {
        [self dropDown2Release];
    }
}
- (void)click3:(UIButton *)btn
{
    //结果排序，1:默认，2:价格低优先，3:价格高优先，4:购买人数多优先，5:最新发布优先，6:即将结束优先
    NSArray *array = [NSArray arrayWithObjects: @"默认",@"价格低优先",@"价格高优先",@"购买人数多优先",@"最新发布优先",@"即将结束优先",nil];
    if (_dropDown3 == nil) {
        if (_dropDown2 != nil) {
            [self dropDown2Release];
        }
        
        if (_dropDown != nil) {
            [self dropDownRelease];
        }
        [btn.superview.superview addSubview:_shadeView];
        _dropDown3 = [[DropDown alloc]initWithButton:btn array:array height:250];
        _dropDown3.delegate = self;
        _dropDown3.dropDown_Flag = 1;
    }else
    {
        [self dropDown3Release];
    }
}
#pragma mark 下拉列表对象
- (void)dropDownDelegateWithDropDown:(DropDown *)dropDown;
{
    if (dropDown == _dropDown) {
        [self dropDownRelease];
    }else if (dropDown == _dropDown2){
        [self dropDown2Release];
    }else if (dropDown == _dropDown3){
        [self dropDown3Release];
    }
}
- (void)dropDownRelease
{
    _dropDown.hidden = YES;
    _dropDown.theNewDropDown.hidden = YES;
    _dropDown.delegate = nil;
    [_dropDown release];
    _dropDown = nil;
    [_shadeView removeFromSuperview];
}
- (void)dropDown2Release
{
    _dropDown2.hidden = YES;
    _dropDown2.theNewDropDown.hidden = YES;
    _dropDown2.delegate = nil;
    [_dropDown2 release];
    _dropDown2 = nil;
    [_shadeView removeFromSuperview];
}
- (void)dropDown3Release
{
    _dropDown3.hidden = YES;
    _dropDown3.theNewDropDown.hidden = YES;
    _dropDown3.delegate = nil;
    [_dropDown3 release];
    _dropDown3 = nil;
    [_shadeView removeFromSuperview];
}
#pragma mark 当前城市按钮
- (void)createLeftItem
{
    _LeftItemBtn = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
    _LeftItemBtn.frame = CGRectMake(0, 0, 80, 35);
    [_LeftItemBtn setTitle:_city forState:UIControlStateNormal];
    [_LeftItemBtn addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside ];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:_LeftItemBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    [leftItem release];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    [backItem release];
    
}
- (void)push
{
    CityListVC  *cityListVC = [[CityListVC alloc] init];
    UINavigationController *cityListNavigationVC = [[UINavigationController alloc] initWithRootViewController:cityListVC];
    cityListVC.cityFlag = 3;
    cityListVC.delegete = self;
    [self presentViewController:cityListNavigationVC animated:YES completion:nil];
    [cityListVC release];
    [cityListNavigationVC release];
}
-(void)beginToReloadData:(EGORefreshPos)aRefreshPos
{
    //上拉刷新
    if (aRefreshPos == EGORefreshHeader) {
        _page = 1;
    }else if (aRefreshPos == EGORefreshFooter){
        //下拉加载
        _page++;
    }
    [self loadData];
}
//城市列表代理方法
- (void)setCityListDelegate:(NSString *)city
{
    self.city = city;
    _region = nil;
    _category = @"美食";
    _page = 1;
    [_areaBtn setTitle:@"分区" forState:UIControlStateNormal];
    [_classBtn setTitle:_category forState:UIControlStateNormal];
    [_sortBtn setTitle:@"默认排序" forState:UIControlStateNormal];
    [_LeftItemBtn setTitle:_city forState:UIControlStateNormal];
    //当切换城市之后,根据选中的城市去请求该城市所对应的商家列表,商区以及分类
    [self loadData];
}
#pragma mark - loadData
//请求网络
-(void)loadData
{
    if (_region != nil) {
        self.dicIn = [NSMutableDictionary dictionaryWithObjectsAndKeys:_city,@"city",@"10",@"limit" ,[NSString stringWithFormat:@"%d",_page],@"page",[NSString stringWithFormat:@"%d",_sortNum],@"sort",_region,@"region",_category,@"category", nil];
        NSMutableDictionary *dicOut = [SignatrueEncryption encryptedParamsWithBaseParams:_dicIn];
        NSString *urlString = [NSString stringWithFormat:@"http://api.dianping.com/v1/deal/find_deals?appkey=%@&sign=%@&city=%@&category=%@&limit=%d&page=%d&region=%@&sort=%d",kAPP_KEY,[dicOut objectForKey:@"sign"],[dicOut objectForKey:@"city"],[dicOut objectForKey:@"category"],[[dicOut objectForKey:@"limit"] intValue],[[dicOut objectForKey:@"page"] intValue],[dicOut objectForKey:@"region"],[[dicOut objectForKey:@"sort"] intValue]];
        [_request loadDataWithURLString:urlString];
    }else{
        self.dicIn = [NSMutableDictionary dictionaryWithObjectsAndKeys:_city,@"city",@"10",@"limit" ,[NSString stringWithFormat:@"%d",_page],@"page",[NSString stringWithFormat:@"%d",_sortNum],@"sort",_category,@"category", nil];
        NSMutableDictionary *dicOut = [SignatrueEncryption encryptedParamsWithBaseParams:_dicIn];
        NSString *urlString = [NSString stringWithFormat:@"http://api.dianping.com/v1/deal/find_deals?appkey=%@&sign=%@&city=%@&category=%@&limit=%d&page=%d&sort=%d",kAPP_KEY,[dicOut objectForKey:@"sign"],[dicOut objectForKey:@"city"],[dicOut objectForKey:@"category"],[[dicOut objectForKey:@"limit"] intValue],[[dicOut objectForKey:@"page"] intValue],[[dicOut objectForKey:@"sort"] intValue]];
        [_request loadDataWithURLString:urlString];
    }
    [self loadDataRegion];
    [self loadDataCategory];
}
//请求分区列表
- (void)loadDataRegion
{
    NSMutableDictionary *regionDicIn = [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];
    NSMutableDictionary *regionDicOut = [SignatrueEncryption encryptedParamsWithBaseParams:regionDicIn];
    
    NSString *regionUrlString = [NSString stringWithFormat:@"http://api.dianping.com/v1/metadata/get_regions_with_deals?appkey=%@&sign=%@",kAPP_KEY,[regionDicOut objectForKey:@"sign"]];
    
    [_regionRequest loadDataWithURLString: regionUrlString];
    
}
//请求分类类表
- (void)loadDataCategory
{
    NSMutableDictionary *categoryDicIn = [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];
    NSMutableDictionary *categoryDicOut = [SignatrueEncryption encryptedParamsWithBaseParams:categoryDicIn];
    NSString *categoryUrlString = [NSString stringWithFormat:@"http://api.dianping.com/v1/metadata/get_categories_with_deals?appkey=%@&sign=%@",kAPP_KEY,[categoryDicOut objectForKey:@"sign"]];
    [_categoryRequest loadDataWithURLString:categoryUrlString];
}
#pragma mark - NetWorkRequesDelegate
//请求数据成功之后执行代理方法
- (void)request:(NetWorkRequest *)netWorkRequest
   didFinishing:(NSData *)data
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (netWorkRequest == _request) {
        [self parseBusinessDataWithDic:dic];
    }else if(netWorkRequest == _regionRequest){
        [self parseRegionDataWithDic:dic];
    }else if(netWorkRequest == _categoryRequest){
        [self parseCategoryDataWithDic:dic];
    }
}
//解析团购请求得到的信息
- (void)parseBusinessDataWithDic:(NSDictionary *)dataDic
{
    if (_page == 1) {
        [_groupBuyingArr removeAllObjects];
    }
    NSArray *arr = [dataDic objectForKey:@"deals"];
    NSString *count = [dataDic objectForKey:@"count"];
    for (NSDictionary *tempDic in arr) {
        GroupBuying *groupBuying = [[GroupBuying alloc] initWithGroupBuying:tempDic];
        [_groupBuyingArr addObject:groupBuying];
        [groupBuying release];
    }
    [self.tableView reloadData];
    [self finishReloadingData];
    if ([count intValue] == [[_dicIn objectForKey:@"limit"] intValue]) {
        [self setFooterView];
        [self.view.window showHUDWithText:[NSString stringWithFormat:@"成功加载%d条数据", [count intValue]] Type:ShowPhotoYes Enabled:YES];
    } else if ([count intValue] != [[_dicIn objectForKey:@"limit"] intValue]){
        [self.view.window showHUDWithText:[NSString stringWithFormat:@"成功加载%d条数据", [count intValue]] Type:ShowPhotoYes Enabled:YES];
        [self performSelector:@selector(removeFooter) withObject:nil afterDelay:1.5];
        [self removeFooterView];
    }//如果headView 和FootView 距离太近，刷新那个类会处理不敏感，刷新或者加载会走两次，所以需要判断是否要加FootView 而且要把上次的FootView移除
    //        [self setFooterView];//判断 是否可以上拉加载///////////////////////
}
//解析商区请求得到的数据
- (void)parseRegionDataWithDic:(NSDictionary *)dataDic
{
    NSArray *cityArr = [dataDic objectForKey:@"cities"] ;
    for (NSDictionary *dicTemp in cityArr) {
        if ([[dicTemp objectForKey:@"city_name"] isEqualToString:_city]) {
            self.cityDic = [NSDictionary dictionaryWithDictionary:dicTemp] ;//得到传往下一个列表的数据
        }
    }
    NSArray *regionBig = [_cityDic objectForKey:@"districts"];
    [_regionArr removeAllObjects];//每次请求清空一下地区数组
    for (NSDictionary *dicTemp in regionBig) {
        [_regionArr addObject:[dicTemp objectForKey:@"district_name"]];
    }
    
}
//解析分类请求得到的数据
- (void)parseCategoryDataWithDic:(NSDictionary *)dataDic
{
    self.categoryDic = dataDic;//得到传往下一个列表的数据
    NSArray *arr = [_categoryDic objectForKey:@"categories"];
    [_categoryArr removeAllObjects];//每次请求清空一下分类数组
    for (NSDictionary *tempDic in arr) {
        [_categoryArr addObject:[tempDic objectForKey:@"category_name"]];
    }
    
}



//延迟取消 菊花, 显示没有更多数据了
- (void)removeFooter
{
    [self.view.window showHUDWithText:@"没有更多数据了" Type:ShowPhotoNo Enabled:YES];
}
//请求数据失败之后执行代理方法
- (void)request:(NetWorkRequest *)netWorkRequest
didFailWithError:(NSError *)error
{
    [self.view.window showHUDWithText:@"加载失败" Type:ShowPhotoNo Enabled:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupBuyingDetailVC *groupBuyingVC = [[GroupBuyingDetailVC alloc] init];
    
    groupBuyingVC.groupDetail = [_groupBuyingArr objectAtIndex:indexPath.row];
    [self.navigationController hidesBottomBarWhenPushed];
    groupBuyingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:groupBuyingVC animated:YES];
    
    [groupBuyingVC release];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groupBuyingArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *reuser = @"reuse";
    GroupBuyingCell *cell = [tableView dequeueReusableCellWithIdentifier:reuser];
    if (cell== nil) {
        cell = [[[GroupBuyingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuser] autorelease];
    }
    [cell configurationGroupBuyingCell:[_groupBuyingArr objectAtIndex:indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106;
    
}
-(void)dealloc
{
    [_groupBuyingArr release];
    //-----------------------
    [_request release];
    [_city release];
    //    [_dropDown release];
    //    [_dropDown2 release];
    //    [_dropDown3 release];
    [_LeftItemBtn release];
    [_areaBtn removeObserver:self forKeyPath:@"titleLabel.text"];
    [_areaBtn release];
    [_cityDic release];////请求分区得到当前城市字典（包含所有分区和街道）传往2级列表
    [_regionArr release];//地区列表
    [_region release];//所选地区
    [_classBtn removeObserver:self forKeyPath:@"titleLabel.text"];
    [_classBtn release];
    [_category release];//所选分类
    [_categoryArr release];//分类列表数组
    [_categoryDic release];//请求分类得到的所有分类字典，传往2级列表
    [_sortBtn removeObserver:self forKeyPath:@"titleLabel.text"];
    [_sortBtn release];
    [_sortDic release];
    [_shadeView release];
    [_cityRequest release];//城市定位请求
    [_dicIn release];

    [super dealloc];
    
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
