//
//  CCell.m
//  a
//
//  Created by Wicky on 2017/5/7.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "CCell.h"

@implementation CCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setModel:(__kindof BModel *)model {
    [super setModel:model];
    self.label.text = model.title;
}

@end
