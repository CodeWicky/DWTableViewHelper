//
//  BCell.m
//  a
//
//  Created by Wicky on 2017/5/7.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "BCell.h"

@implementation BCell

-(void)setModel:(BModel *)model {
    [super setModel:model];
    self.textLabel.text = model.title;
}

@end
