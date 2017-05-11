//
//  ACell.m
//  
//
//  Created by Wicky on 2017/5/7.
//
//

#import "ACell.h"
#import <Masonry.h>

@implementation ACell
@dynamic model;
-(void)setupUI {
    [super setupUI];
    self.label = [UILabel new];
    self.label.numberOfLines = 0;
    [self.contentView addSubview:self.label];
}

-(void)setupConstraints {
    [super setupConstraints];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

-(void)setModel:(AModel *)model {
    [super setModel:model];
    self.label.text = model.title;
}

@end
