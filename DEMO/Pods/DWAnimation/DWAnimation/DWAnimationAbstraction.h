//
//  DWAnimationAbstraction.h
//  DWAnimation
//
//  Created by Wicky on 16/10/26.
//  Copyright © 2016年 Wicky. All rights reserved.
//


/**
 DWAnimationAbstraction
 
 DWAnimation抽象类，为DWAnimation及DWAniamtionGroup提供公共接口
 其中DWAnimation与DWAnimationGroup均对各属性方法进行重写
 
 version 1.0.0
 抽象出基础属性beginTime，duration
 抽象出基础方法，动画操作方法
 */
#import <UIKit/UIKit.h>

@interface DWAnimationAbstraction : NSObject
///动画时长
@property (nonatomic ,assign) CGFloat duration;

///动画延时时长
/*
 注：所有构造方法，包括构造方法中含有参数beginTime都不影响本属性。
 本属性仅作为编辑动画时要延时某个动画时调整属性，其他情况下请勿修改本属性。
 默认值为0。手动修改本属性后，将会使本动画再原有基础上再延时一段时间执行。
 */
@property (nonatomic ,assign) CGFloat beginTime;

#pragma mark ---动画控制方法---

///开始播放动画
-(void)start;

///暂停动画
-(void)suspend;

///恢复动画
-(void)resume;

///移除动画
/**
 若要移除，请确保初始化时animationKey正确
 移除仅移除调用移除方法的动画实例，将返回动画的上一状态
 */
-(void)remove;
@end
