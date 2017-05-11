//
//  DWAnimationGroup.h
//  DWAnimation
//
//  Created by Wicky on 16/10/27.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/**
 DWAnimationGroup
 
 组动画实例
 支持不同layer动画组合播放
 
 version 1.0.0
 继承自DWAnimationAbstraction。可修改beginTime，自动计算duration。可实现动画的操作，即开始，暂停，恢复，移除
 */

#import "DWAnimationAbstraction.h"
@class DWAnimation;
@interface DWAnimationGroup : DWAnimationAbstraction

///动画数组，将要展示的动画集合源
@property (nonatomic ,strong) NSMutableArray <DWAnimation *>* animations;

///以动画数组初始化实例
-(instancetype)initWithAnimations:(__kindof NSArray <DWAnimation *>*)animations;

@end
