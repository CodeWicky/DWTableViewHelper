//
//  ACell.h
//  
//
//  Created by Wicky on 2017/5/7.
//
//

#import "DWTableViewHelper.h"
#import "AModel.h"

@interface ACell : DWTableViewHelperCell

@property (nonatomic ,strong) UILabel * label;

@property (nonatomic ,strong) AModel * model;
@end
