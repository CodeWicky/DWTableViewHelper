//
//  DWAnimationMaker.h
//  DWHUD
//
//  Created by Wicky on 16/8/20.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/*
 DWAnimationMaker
 
 简介：生成所需动画的DWAnimation对象
 
 version 1.0.0
 提供移动动画的工厂模式
 提供链式语法结构
 
 version 1.0.1
 完成基本动画的添加
 修改动画装载逻辑，实现多动画集合
 
 version 1.0.2
 添加恢复原状的api
 
 version 1.0.3
 添加透明度动画api
 
 version 1.0.4
 添加圆角动画api
 
 version 1.0.5
 添加边框相关动画api
 添加阴影相关动画api
 添加背景图片动画api
 
 version 1.0.6
 添加背景颜色动画api
 优化恢复动画逻辑
 
 version 1.1.0
 更改所有api中参数将UIView对象改为更加广泛适合的CALayer对象
 
 version 1.1.1
 按照需求修改make方法将数组进行排序。
 
 version 1.1.2
 增加缩放动画换轴模式
 */

#import <UIKit/UIKit.h>
#import "DWAnimationHeader.h"
@class DWAnimation;
@interface DWAnimationMaker : NSObject

#pragma mark ---方法属性---

///移动终点，移动动画必须实现方法，参数必须为非CGPointNull
@property (nonatomic ,copy) DWAnimationMaker * (^moveTo)(CGPoint);

///移动起点，移动动画非必须实现方法，参数可为CGPointNull，若不实现默认当前位置为移动起点
@property (nonatomic ,copy) DWAnimationMaker * (^moveFrom)(CGPoint);

///缩放结束比例，缩放动画必须实现方法，参数必须为非MAXFLOAT
@property (nonatomic ,copy) DWAnimationMaker * (^scaleTo)(CGFloat);

///缩放初始比例，缩放动画非必须实现方法，参数可为MAXFLOAT，若不实现默认当前比例为缩放初始比例
@property (nonatomic ,copy) DWAnimationMaker * (^scaleFrom)(CGFloat);

///旋转终止角度，旋转动画必须实现方法，参数必须为非MAXFlOAT
@property (nonatomic ,copy) DWAnimationMaker * (^rotateTo)(CGFloat);

///旋转初始角度，旋转动画非必须实现方法，参数可为MAXFLOAT，若不实现默认当前角度为旋转初始角度
@property (nonatomic ,copy) DWAnimationMaker * (^rotateFrom)(CGFloat);

///动画轴，动画非必须实现方法，参数为Axis枚举类型（X、Y、Z），若不实现默认旋转轴为Z轴
/**
 注：当一条语句（以install方法为一条语句结束）中含有动画轴时，则所有支持换轴的动画均将换轴，若不想所有支持换轴的动画都换轴，请以短语句方式书写
 */
@property (nonatomic ,copy) DWAnimationMaker * (^axis)(Axis);

///终止透明度，透明度动画必须实现方法，参数必须为非MAXFlOAT
@property (nonatomic ,copy) DWAnimationMaker * (^alphaTo)(CGFloat);

///初始透明度，透明度动画非必须实现方法，参数可为MAXFLOAT，若不实现默认当前比例为缩放初始比例
@property (nonatomic ,copy) DWAnimationMaker * (^alphaFrom)(CGFloat);

///终止圆角，圆角动画必须实现方法，参数必须为非MAXFlOAT
/*
 注：当实现圆角动画时，view.layer.masksToBounds会被设置为YES
 */
@property (nonatomic ,copy) DWAnimationMaker * (^cornerRadiusTo)(CGFloat);

///初始圆角，圆角动画非必须实现方法，参数可为MAXFLOAT，若不实现默认当前圆角为初始圆角
@property (nonatomic ,copy) DWAnimationMaker * (^cornerRadiusFrom)(CGFloat);

///边框终止宽度，边框宽度动画必须实现方法，参数必须为非MAXFlOAT
@property (nonatomic ,copy) DWAnimationMaker * (^borderWidthTo)(CGFloat);

///边框初始宽度，边框宽度动画非必须实现方法，参数可为MAXFLOAT，若不实现默认当前边框宽度为初始宽度
@property (nonatomic ,copy) DWAnimationMaker * (^borderWidthFrom)(CGFloat);

///边框终止颜色，边框颜色动画必须实现方法，参数必须为非nil
@property (nonatomic ,copy) DWAnimationMaker * (^borderColorTo)(UIColor *);

///边框初始颜色，边框颜色动画非必须实现方法，参数可为nil，若不实现默认当前边框颜色为初始颜色
@property (nonatomic ,copy) DWAnimationMaker * (^borderColorFrom)(UIColor *);

///阴影终止颜色，阴影颜色动画必须实现方法，参数必须为非nil
/*
 所有阴影效果均依托于view.layer.masksToBounds = NO;
 又当实现圆角动画时view.layer.masksToBounds = YES;
 故圆角动画不能不阴影动画同时实现，否则阴影动画显示异常。
 这是CALayer特性造成的。
 若要实现圆角动画与阴影动画的效果，请使用两个图层叠加效果
 */
@property (nonatomic ,copy) DWAnimationMaker * (^shadowColorTo)(UIColor *);

///阴影初始颜色，阴影颜色动画非必须实现方法，参数可为nil，若不实现默认当前边框颜色为初始颜色
@property (nonatomic ,copy) DWAnimationMaker * (^shadowColorFrom)(UIColor *);

///阴影终止偏移量，阴影偏移量动画必须实现方法，参数必须为非CGSizeNull
@property (nonatomic ,copy) DWAnimationMaker * (^shadowOffsetTo)(CGSize);

///阴影初始偏移量，阴影偏移量动画非必须实现方法，参数可为CGSizeNull，若不实现默认当前阴影偏移量为初始偏移量
@property (nonatomic ,copy) DWAnimationMaker * (^shadowOffsetFrom)(CGSize);

///阴影终止透明度，阴影透明度动画必须实现方法，参数必须为非MAXFLOAT
@property (nonatomic ,copy) DWAnimationMaker * (^shadowAlphaTo)(CGFloat);

///阴影初始透明度，阴影透明度动画非必须实现方法，参数可为MAXFLOAT，若不实现默认当前阴影透明度为初始透明度
@property (nonatomic ,copy) DWAnimationMaker * (^shadowAlphaFrom)(CGFloat);

///阴影终止圆角，阴影圆角动画必须实现方法，参数必须为非MAXFLOAT
@property (nonatomic ,copy) DWAnimationMaker * (^shadowRadiusTo)(CGFloat);

///阴影初始圆角，阴影圆角动画非必须实现方法，参数可为MAXFLOAT，若不实现默认当前阴影圆角为初始透圆角
@property (nonatomic ,copy) DWAnimationMaker * (^shadowRadiusFrom)(CGFloat);

///阴影终止圆角，阴影圆角动画必须实现方法，参数可为nil，若为nil，以UIBezierNull()为初始路径
@property (nonatomic ,copy) DWAnimationMaker * (^shadowPathTo)(UIBezierPath *);

///阴影初始路径，阴影路径动画非必须实现方法，参数可为nil，若不实现默认当前UIBezierNull()为初始路径
@property (nonatomic ,copy) DWAnimationMaker * (^shadowPathFrom)(UIBezierPath *);

///终止背景图，背景图动画必须实现方法，参数可为nil，若为nil，以UIImageNull为初始背景图
@property (nonatomic ,copy) DWAnimationMaker * (^backgroundImageTo)(UIImage *);

///初始背景图，背景图动画非必须实现方法，参数可为nil，若不实现默认当前UIImageNull为初始背景图
@property (nonatomic ,copy) DWAnimationMaker * (^backgroundImageFrom)(UIImage *);

///终止背景色，背景色动画必须实现方法，参数必须为非nil
@property (nonatomic ,copy) DWAnimationMaker * (^backgroundColorTo)(UIColor *);

///初始背景色，背景色动画非必须实现方法，参数可为nil，若不实现默认当前背景颜色为初始颜色
@property (nonatomic ,copy) DWAnimationMaker * (^backgroundColorFrom)(UIColor *);

///恢复原状（注：特殊属性动画不在恢复动画范围内，请自行恢复。）
@property (nonatomic ,strong) DWAnimationMaker * reset;

///动画时长，所有动画必须实现方法，否则默认动画时长为0
@property (nonatomic ,copy) DWAnimationMaker * (^duration)(CGFloat);

///动画延迟时间，所有动画非必须实现方法，默认为0
@property (nonatomic ,copy) DWAnimationMaker * (^beginTime)(CGFloat);

///动画生成，所有动画必须实现方法，且最后实现
@property (nonatomic ,copy) DWAnimationMaker * (^install)();

#pragma mark ---中间属性---
@property (nonatomic ,strong) CAAnimationGroup * animation;
@property (nonatomic ,strong) CALayer * layer;
@property (nonatomic ,assign) CGFloat totalDuration;

#pragma mark ---中间方法---
///生成animationGroup对象
-(void)make;
@end
