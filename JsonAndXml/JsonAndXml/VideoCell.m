//
//  VideoCell.m
//  JSON & XML
//
//  Created by apple on 13-10-10.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

/*
 如果在自定义单元格中，修改默认对象的位置
 
 可以重写layoutSubviews方法，对视图中的所有控件的位置进行调整
 */
#pragma mark - 重新调整UITalbleViewCell中的控件布局
- (void)layoutSubviews
{
    // 千万不要忘记super layoutSubViews
    [super layoutSubviews];
    
    NSLog(@"%@", NSStringFromCGRect(self.textLabel.frame));
    
    // 将imageView的宽高设置为60
    [self.imageView setFrame:CGRectMake(10, 10, 60, 60)];
    [self.textLabel setFrame:CGRectMake(80, 10, 220, 30)];
    [self.detailTextLabel setFrame:CGRectMake(80, 50, 150, 20)];
    
    [self.textLabel setTextColor:[UIColor redColor]];
    [self.detailTextLabel setTextColor:[UIColor darkGrayColor]];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // 取消显示选中颜色
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(240, 50, 60, 20)];
        [self.contentView addSubview:label3];
        [label3 setTextColor:[UIColor darkGrayColor]];
        // 清除lable的背景颜色
        [label3 setBackgroundColor:[UIColor clearColor]];
        
        self.lengthLabel = label3;
        
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return self;
}

// 选中或者撤销选中单元格的方法
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // 选中表格行
    if (selected) {
        [self setBackgroundColor:[UIColor yellowColor]];
    } else {
        // 撤销选中表格行
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
