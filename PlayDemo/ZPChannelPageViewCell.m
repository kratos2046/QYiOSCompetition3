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

@interface ZPChannelPageViewCell ()

/**
 *  视频图片
 */
@property (nonatomic, weak) UIImageView *coverView;
@property (nonatomic, weak) UILabel *titleLabel;

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
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    
    CGSize contentViewSize = self.contentView.bounds.size;
    CGSize imageSize = self.coverView.image.size;
    CGFloat coverH = kCellImageHeight;
    CGFloat coverW = (imageSize.width == 0) ? 0 : coverH * imageSize.width / imageSize.height;
    CGFloat coverX = (contentViewSize.width - coverW) / 2;
    CGFloat coverY = 0;
    self.coverView.frame = CGRectMake(coverX, coverY, coverW, coverH);
    
    CGFloat titleLabelH = kCellTitleLabelHeight;
    CGFloat titleLabelW = contentViewSize.width;
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = coverH;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
}

#pragma mark - Setter

-(void)setVideoInfo:(ZPVideoInfo *)videoInfo {
    _videoInfo = videoInfo;
    self.titleLabel.text = videoInfo.title;
    
    NSURL *imgUrl = [NSURL URLWithString:videoInfo.img];
//    NSURLRequest *request = [NSURLRequest requestWithURL:imgUrl];
    [self.coverView setImageWithURL:imgUrl];
//    [self.coverView setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"placeholderImage.jpg"]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:	 animated:animated];

    // Configure the view for the selected state
}

@end
