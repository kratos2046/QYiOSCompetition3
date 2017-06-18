//
//  ZPRecommendNewViewController.m
//  PlayDemo
//
//  Created by HZP on 2017/6/16.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPRecommendNewViewController.h"
#import "ZPChannelInfo.h"
#import "ZPVideoInfo.h"
#import "ZPPlayerViewController.h"
#import "ZYBannerView.h"
#import "ZPSearchPageViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RecommentCollectionViewCellDataModel.h"
#import "RecommentCollectionViewCell.h"
#import "CollectionReusableHeadView.h"
#import "CollectionReusableBannerHeaderView.h"
#import "CollectionReusableFooterView.h"
#import "MBProgressHUD.h"


static const CGFloat kSearchBarHeight = 40.0f;
static const CGFloat kCycleViewHeight = 180.0f;
static const CGFloat kViewMargin = 10.0f;
static NSString* const kRecommendURL = @"http://iface.qiyi.com/openapi/batch/recommend?app_k=f0f6c3ee5709615310c0f053dc9c65f2&app_v=8.4&app_t=0&platform_id=12&dev_os=10.3.1&dev_ua=iPhone9,3&dev_hw=%7B%22cpu%22%3A0%2C%22gpu%22%3A%22%22%2C%22mem%22%3A%2250.4MB%22%7D&net_sts=1&scrn_sts=1&scrn_res=1334*750&scrn_dpi=153600&qyid=87390BD2-DACE-497B-9CD4-2FD14354B2A4&secure_v=1&secure_p=iPhone&core=1&req_sn=1493946331320&req_times=1";

@interface ZPRecommendNewViewController () <ZYBannerViewDataSource, ZYBannerViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CollectionReusableFooterViewDelegate, UISearchBarDelegate> {
    CGFloat ImforMationCellwidth;
    CGFloat TVCellwidth;
    
}

/**
 *  频道列表
 */
@property (nonatomic, strong) NSArray *channelsInfos;
/**
 *  上方的搜索框
 */
@property (nonatomic, weak) UISearchBar *searchBar;
/**
 *  上方的轮播图
 */
@property (nonatomic, weak) ZYBannerView *cycleScrollView;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ZPRecommendNewViewController

#pragma mark - Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setWidth];
    [self setupSubView];
    [self requestUrl];
    
    // Do any additional setup after loading the view.
}

- (void)setWidth {
    ImforMationCellwidth = (self.view.frame.size.width - 30)/2;
    TVCellwidth = (self.view.frame.size.width - 40)/3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  创建子控件
 */
-(void)setupSubView {
    [self setupSearchBar];
    //[self setupCycleView];
}

/**
 *  创建搜索框
 */
-(void)setupSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    CGFloat searchBarH = kSearchBarHeight;
    CGFloat searchBarW = self.view.bounds.size.width;
    CGFloat searchBarX = 0;
    CGFloat searchBarY = 0;
    searchBar.frame = CGRectMake(searchBarX, searchBarY, searchBarW, searchBarH);
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    self.searchBar = searchBar;
}

/**
 *  创建轮播图
 */
-(void)setupCycleView {
//    ZYBannerView *banner = [[ZYBannerView alloc]init];
//    banner.dataSource = self;
//    banner.delegate = self;
//    //是否需要循环滚动
//    banner.shouldLoop = YES;
//    //是否需要自动滚动
//    banner.autoScroll = YES;
//    banner.scrollInterval = 5.0f;
//    
//    // 设置frame
//    CGFloat bannerX = 0;
//    CGFloat bannerY = CGRectGetMaxY(self.searchBar.frame);
//    CGFloat bannerW = self.view.bounds.size.width;
//    CGFloat bannerH = kCycleViewHeight;
//    banner.frame = CGRectMake(bannerX, bannerY, bannerW, bannerH);
//    
//    [self.view addSubview:banner];
//    self.cycleScrollView = banner;
}

/**
 *  创建collection view
 */
-(void)setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    //  flowLayout.itemSize = CGSizeMake(120, 160);
    flowLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 20);
    flowLayout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, 40);
    
    CGFloat colleViewX = kViewMargin;
    CGFloat colleViewY = CGRectGetMaxY(self.searchBar.frame)+kViewMargin;
    CGFloat colleViewW = self.view.frame.size.width - 2 * kViewMargin;
    CGFloat colleViewH = self.view.frame.size.height - colleViewY;
    
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(colleViewX, colleViewY, colleViewW, colleViewH) collectionViewLayout:flowLayout];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[RecommentCollectionViewCell class] forCellWithReuseIdentifier:@"RecommentCollectionViewCell"];
    [_collectionView registerClass:[CollectionReusableHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeadView"];
    [_collectionView registerClass:[CollectionReusableBannerHeaderView class] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:@"BannerHeaderView"];
    [_collectionView registerClass:[CollectionReusableFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FootView"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = YES;
    _collectionView.backgroundColor = [UIColor whiteColor];
}

#pragma network request
/**
 *  请求网络数据
 */
-(void)requestUrl
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //1.创建请求
    NSURL *url = [NSURL URLWithString:kRecommendURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //2.创建连接
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *sesson = [NSURLSession sessionWithConfiguration:configuration];
    
    //3.创建任务
    NSURLSessionDataTask *dataTask = [sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self requestFailed];
            });
        } else {
            NSDictionary *tmpDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *data = [tmpDic objectForKey:@"data"];
            
            NSMutableArray *dataArr = [NSMutableArray array];
            for (NSDictionary *dict in data) {
                [dataArr addObject:[ZPChannelInfo channelInfoWithDict:dict]];
            }
            self.channelsInfos = dataArr;
            
            NSNumber* resultCode = [tmpDic valueForKey:@"code"];
            if (resultCode.integerValue == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    [self showDataMessage:data];
                    [self reloadData];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupCollectionView];
            });
            
            
        }
    }];
    
    //4.执行任务
    [dataTask resume];
}

/**
 *  网络请求失败
 */
- (void)requestFailed {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"网络请求失败");
}

/**
 *  刷新数据
 */
- (void)reloadData {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.cycleScrollView reloadData];
}



#pragma mark - ZYBannerViewDataSource
/**
 *  返回Banner需要显示Item(View)的个数
 */
- (NSInteger)numberOfItemsInBanner:(ZYBannerView *)banner
{
    ZPChannelInfo *channelCycle = [self.channelsInfos firstObject];
    if ([channelCycle.title isEqualToString:@"轮播图"]) {
        return channelCycle.video_list.count;
    }
    return 0;
}

// 返回Banner在不同的index所要显示的View
- (UIView *)banner:(ZYBannerView *)banner viewForItemAtIndex:(NSInteger)index
{
    ZPChannelInfo *cycleChannel = [self.channelsInfos firstObject];
    ZPVideoInfo *video = cycleChannel.video_list[index];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    [imageView setImageWithURL:[NSURL URLWithString:video.img]placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    
    return imageView;
}

-(void)banner:(ZYBannerView *)banner didSelectItemAtIndex:(NSInteger)index {
    ZPChannelInfo *cycleChannel = [self.channelsInfos firstObject];
    ZPVideoInfo *video = cycleChannel.video_list[index];
    ZPPlayerViewController *playVC = [[ZPPlayerViewController alloc]init];
    playVC.videoInfo = video;
    [self presentViewController:playVC animated:YES completion:nil];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _channelsInfos.count-1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecommentCollectionViewCell" forIndexPath:indexPath];
    ZPChannelInfo *channelInfo = _channelsInfos[indexPath.section+1];
    ZPVideoInfo *videoInfo = channelInfo.video_list[indexPath.row];
    RecommentCollectionViewCellDataModel *model = [[RecommentCollectionViewCellDataModel alloc] initWithDict:videoInfo];
    cell.dataModel = model;
    return cell;
    
}

#pragma mark - UICollectionView Delegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(ImforMationCellwidth, ImforMationCellwidth*7/10+20);
    }
    return CGSizeMake(TVCellwidth,TVCellwidth*4/3+20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return CGSizeMake(self.view.frame.size.width, 185);
            break;
            
        default:
            return CGSizeMake(self.view.frame.size.width, 20);
            break;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header;
        
        ZPChannelInfo *info = _channelsInfos[indexPath.section + 1];
        switch (indexPath.section) {
            case 0:
                
                header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"BannerHeaderView" forIndexPath:indexPath];
                _cycleScrollView = ((CollectionReusableBannerHeaderView*)header).bannerView;
                ((CollectionReusableBannerHeaderView*)header).bannerView.delegate = self;
                ((CollectionReusableBannerHeaderView*)header).bannerView.dataSource = self;
                ((CollectionReusableBannerHeaderView*)header).lable.text = info.title;
                break;
                
            default:
                header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeadView" forIndexPath:indexPath];
                ((CollectionReusableHeadView*)header).lable.text = info.title;
                break;
        }
        return header;
        
    }
    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        CollectionReusableFooterView *foot= [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FootView" forIndexPath:indexPath];
        foot.delegate = self;
        foot.btn.tag = indexPath.section;
        return foot;
        
    }
    return nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ZPChannelInfo *cycleChannel = self.channelsInfos[indexPath.section + 1];
    ZPVideoInfo *video = cycleChannel.video_list[indexPath.row];
    ZPPlayerViewController *playVC = [[ZPPlayerViewController alloc]init];
    playVC.videoInfo = video;
    [self presentViewController:playVC animated:YES completion:nil];
}

#pragma mark - CollectionReusableFooterViewDelegate
-(void)CollectionReusableFooterViewBtnClick:(UIButton *)btn {
    ZPChannelInfo *channel = self.channelsInfos[btn.tag + 1];
    if ([self.delegate respondsToSelector:@selector(moreVideoButtonDidClick:)]) {
        [self.delegate performSelector:@selector(moreVideoButtonDidClick:) withObject:channel.title];
    }
    NSLog(@"%@", btn);
}

#pragma mark - UISearchBarDelegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    ZPSearchPageViewController *vc = [[ZPSearchPageViewController alloc]init];
    [self presentViewController:vc animated:YES completion:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

