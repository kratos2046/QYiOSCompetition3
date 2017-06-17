//
//  ZPChannelPageTableViewCell.m
//  PlayDemo
//
//  Created by HZP on 2017/6/13.
//  Copyright © 2017年 liuxiaodan. All rights reserved.
//

#import "ZPChannelPageViewCell.h"
#import "ZPVideoInfo.h"
#import "UIImageView+AFNetworking.h"




const CGFloat kCellImageHeight = 100;
const CGFloat kCellTitleLabelHeight = 20;
const CGFloat kCellMargin = 5;
static const CGFloat kVipViewSize = 12;

@interface ZPChannelPageViewCell ()

/**
 *  视频封面
 */
@property (nonatomic, weak) UIImageView *coverView;
/**
 *  视频标题
 */
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *isVipView;
@end

@implementation ZPChannelPageViewCell

#pragma mark - Init Method
/**
 *  快速构造方法
 */
+(instancetype)cellWithTableView:(UITableView*) tableView {
    static NSString *cellID = @"ChannelPageCellID";
    ZPChannelPageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[ZPChannelPageViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}

/**
 *  指定构造方法
 */
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self removeOriginalSubView];
        [self createSubView];
    }
    return self;
}
-(void) removeOriginalSubView {
//    self.coverView removeFromSuperview
    [self.coverView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - Create Subview
-(void)createSubView {
//    self.contentView.backgroundColor = [UIColor yellowColor];
    UIImageView *coverView = [[UIImageView alloc]init];
//    coverView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:coverView];
    self.coverView = coverView;
    
    UILabel *titleLabel = [[UILabel alloc]init];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
//    titleLabel.backgroundColor = [UIColor greenColor];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIImageView *isVipView = [[UIImageView alloc]init];
    isVipView.image = [UIImage imageNamed:@"vip"];
    [self.coverView addSubview:isVipView];
    self.isVipView = isVipView;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self setCellFrame];
}

#pragma mark - Setter

-(void)setVideoInfo:(ZPVideoInfo *)videoInfo {
    _videoInfo = videoInfo;
    [self setCellData:videoInfo];
    [self setCellFrame];
}

/**
 *  设置cell显示数据
 */
-(void)setCellData:(ZPVideoInfo*)info {
    
    self.titleLabel.text = info.title;
    [self.coverView setImageWithURL:[NSURL URLWithString:info.img]];
    if ([info.isVip isEqualToString:@"1"]) {
        self.isVipView.hidden = NO;
    } else {
        self.isVipView.hidden = YES;
    }
}

/**
 *  设置cell布局
 */
-(void)setCellFrame {
    CGSize contentViewSize = self.contentView.bounds.size;
    CGSize imageSize = self.coverView.image.size;
    
    
    CGFloat coverX = kCellMargin;
    CGFloat coverY = kCellMargin;
    CGFloat coverH = kCellImageHeight;
    CGFloat coverW = (self.coverView.image) ?  coverH * imageSize.width / imageSize.height : 0;
    self.coverView.frame = CGRectMake(coverX, coverY, coverW, coverH);
    
    CGFloat vipW = kVipViewSize;
    CGFloat vipH = kVipViewSize;
    CGFloat vipX = CGRectGetMaxX(self.coverView.frame) + kCellMargin;
    CGFloat vipY = kCellMargin;
    self.isVipView.frame = CGRectMake(vipX, vipY, vipW, vipH);
    
    
    CGFloat titleLabelH = kCellTitleLabelHeight;
    CGFloat titleLabelW = contentViewSize.width - coverW - vipW - 3 * kCellMargin;
    CGFloat titleLabelX = CGRectGetMaxX(self.isVipView.frame) + kCellMargin;
    CGFloat titleLabelY = (contentViewSize.height - titleLabelH) / 2;
    
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
}

@end
