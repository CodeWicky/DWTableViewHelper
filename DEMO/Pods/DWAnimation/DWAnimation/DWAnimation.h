//
//  DWAnimation.h
//  DWHUD
//
//  Created by Wicky on 16/8/20.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/*
 DWAnimation
 
 简介：一句话生成CALayer动画，支持动画间任意拼接、组合
 （仅限针对同一CALayer进行操作，若layer不同，请使用DWAnimationGroup）
 
 version 1.0.0
 提供两种生成动画的构造方法
 提供动画展示方法
 提供动画组合方法
 完成平移动画的相关api
 完成平移动画组合api
 
 version 1.0.1
 修改平移动画api，按照锚点移动
 修改动画创建逻辑，一个对象可创建多段动画
 移除组合动画api
 
 version 1.0.2
 新增动画拼接api
 新增按顺序拼接数组中全部动画api
 完成旋转动画相关api
 完成缩放动画相关api
 完成恢复动画api
 
 version 1.0.3
 添加创建连续动画api
 添加以贝塞尔曲线创建动画api
 添加为贝塞尔曲线动画定制子路径时长api
 添加创建弧线动画api
 添加组合动画api
 
 version 1.0.4
 完善弧线api，添加是否自动旋转接口
 
 version 1.0.5
 添加震荡动画api
 
 version 1.0.6
 添加动画开始、结束通知
 添加动画重复api
 
 version 1.0.7
 补充连续动画的圆角动画api
 添加暂停、恢复、移除动画api
 
 version 1.0.8
 完善block创建动画种类，补全边框相关、阴影相关、背景图动画api
 震荡动画、连续动画api补全
 
 version 1.0.9
 震荡动画、连续动画新增api的bug修复
 
 version 1.0.10
 优化动画重复逻辑，完善动画拼接、组合的动画重复效果
 
 version 1.0.11
 优化以数组创建动画api，为其添加beginTime参数
 
 version 1.0.12
 修复shadowPath动画播放结束后点击崩溃问题
 
 version 1.0.13
 贝塞尔曲线动画添加是否自动旋转接口
 优化弧线动画自动旋转逻辑
 
 version 1.0.14
 修复贝塞尔曲线动画使用拼接的贝塞尔曲线中间停顿bug
 
 version 1.0.15
 添加所有动画节奏均为线性模式
 
 version 1.0.16
 添加多状态动画及震荡动画对背景色动画的支持
 
 version 1.0.17
 优化恢复动画阴影路径逻辑及恢复代码整合
 
 version 1.1.0
 更改所有api中参数将UIView对象改为更加广泛适合的CALayer对象
 添加特殊属性动画api，支持为CALayer及其子类中所有支持动画的属性生成动画。
 
 version 1.1.1
 由于动画组animationGroup中需按beginTime顺序传入animations数组，故修改所有相关代码，其中包括以数组形式生成动画、以block形式生成动画、组合一组动画。
 添加动画节奏设置选项，支持修改动画节奏。
 
 version 1.1.2
 规范化方法名
 为组合动画、拼接动画、恢复动画添加animationKey接口
 
 version 1.1.3
 改变继承关系，继承自抽象类DWAnimationAbstraction
 
 version 1.1.4
 添加动画开始回调、结束回调
 
 version 1.1.5
 block形式动画支持缩放动画换轴
 
 version 1.1.6
 支持景深旋转动画
 
 version 1.1.7
 支持拟合锚点旋转动画
 
 version 1.1.8
 支持更换Layer开始动画
 */

#import "DWAnimationAbstraction.h"
#import "DWAnimationConstant.h"
@class DWAnimationMaker;
@interface DWAnimation : DWAnimationAbstraction

///动画组对象
@property (nonatomic ,strong) CAAnimationGroup * animation;

///动画标识
@property (nonatomic ,copy) NSString * animationKey;

///展示动画的layer
@property (nonatomic ,strong) CALayer * layer;

///动画节奏类型名
@property (nonatomic ,copy) NSString * timingFunctionName;

///动画状态
@property (nonatomic ,assign) DWAnimationStatus status;

///动画播放次数
/**
 repeatCount        数值设为MAXFLOAT，为无限播放
 repeatCount        数值设为0，不播放
 repeatCount        数值设为正数，播放次数
 */
@property (nonatomic ,assign) CGFloat repeatCount;

///动画完成回调
@property (nonatomic ,copy) void (^completion) (DWAnimation *);

///动画开始回调
@property (nonatomic ,copy) void (^animationStart)(DWAnimation *);

#pragma mark ---动画构造方法---

///以block形式创建动画(移动，缩放，旋转，透明度，圆角，边框宽度，边框颜色，阴影颜色，阴影偏移量，阴影透明度，阴影路径，阴影圆角，背景图，背景色)
/**
 layer              将要展示动画的layer，不可为nil
 animationKey       动画的标识，可为nil
 animationCreater   创建动画的回调Block
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                         animationKey:(NSString *)animationKey
                     animationCreater:(void(^)(DWAnimationMaker * maker))animationCreater;

///以数组形式创建动画
/**
 layer              将要展示动画的layer，不可为nil
 duration           动画时长
 animationKey       动画的标识，可为nil
 animations         动画数组，由CAAnimation及其派生类组成
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                         animationKey:(NSString *)animationKey
                            beginTime:(CGFloat)beginTime
                             duration:(CGFloat)duration
                           animations:(__kindof NSArray<CAAnimation *> *)animations;

///以多个状态及时间间隔创建连续动画
/**
 layer              将要展示动画的layer，不可为nil
 animationType      创建的动画类型
 animationKey       动画的标识
 beginTime          动画延迟时间
 values             动画的状态值数组
 timeIntervals      动画每两个相邻状态间的时间间隔数组
 transition         各个动画状态节点间是否平滑过渡
 
 注：
 animationType的默认属性为DWAnimationTypeMove
 values中第一个数据为动画的初始状态，之后的数据为状
 态节点。timeIntervals是当前状态节点距上一节点的时
 间间隔。如：timeIntervals的第一个数据为第一个状态
 节点距初始状态的时间间隔。故timeIntervals数组元素
 个数应该比values元素个数少1。若参数不正确，则返回nil。
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                        animationType:(DWAnimationType)animationType
                         animationKey:(NSString *)animationKey
                            beginTime:(CGFloat)beginTime
                               values:(NSArray *)values
                        timeIntervals:(NSArray *)timeIntervals
                           transition:(BOOL)transition;

///以贝塞尔曲线创建移动动画
/**
 layer              将要展示动画的layer，不可为nil
 animationKey       动画的标识，可为nil
 beginTime          动画延时时长
 duration           动画时长
 bezierPath         运动轨迹，不可为nil
 autoRotate         跟随路径自动旋转
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                         animationKey:(NSString *)animationKey
                            beginTime:(CGFloat)beginTime
                             duration:(CGFloat)duration
                           bezierPath:(UIBezierPath *)bezierPath
                           autoRotate:(BOOL)autoRotate;

///创建弧线动画
/**
 layer              将要展示动画的layer，不可为nil
 animationKey       动画的标识，可为nil
 beginTime          动画延时时长
 duration           动画时长
 center             弧线圆心
 radius             弧线半径
 startAngle         弧线的起始角度
 endAngle           弧线的终止角度
 clockwise          是否为顺时针
 autoRotate         是否跟随弧线自动旋转
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                         animationKey:(NSString *)animationKey
                            beginTime:(CGFloat)beginTime
                             duration:(CGFloat)duration
                            arcCenter:(CGPoint)center
                               radius:(CGFloat)radius
                           startAngle:(CGFloat)startAngle
                             endAngle:(CGFloat)endAngle
                            clockwise:(BOOL)clockwise
                           autoRotate:(BOOL)autoRotate;

///创建震荡动画
/**
 即改变属性有震荡效果
 
 layer              将要展示动画的layer，不可为nil
 animationKey       动画的标识，可为nil
 beginTime          动画延时时长
 fromValue          起始值：可以为动画类型所对应的空类型。若为空，则默认当前状态为初始状态
 toValue            终止值：不可为nil
 mass               惯性系数：影响震荡幅度，需大于0。想实现默认效果请传1。
 stiffness          刚性系数：影响震荡速度，需大于0。想实现默认效果请传100。
 damping            阻尼系数：影响震荡停止速度，需大于0。想实现默认效果请传10。
 initialVelocity    初始速度：可正可负，负则先做反向运动，随后正向。想实现默认效果请传0。
 
 注：fromValue与toValue，均为UIKit中对象类型，如NSValue/NSNumber/UIColor/UIBezierPath/UIImage。
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                         animationKey:(NSString *)animationKey
                        springingType:(DWAnimationSpringType)springingType
                            beginTime:(CGFloat)beginTime
                            fromValue:(id)fromValue
                              toValue:(id)toValue
                                 mass:(CGFloat)mass
                            stiffness:(CGFloat)stiffness
                              damping:(CGFloat)damping
                      initialVelocity:(CGFloat)initialVelocity;

///创建特殊属性动画
/**
 即为指定属性（包括CALayer及其子类所有支持动画的属性）添加动画
 
 layer              将要展示动画的layer，不可为nil
 animationKey       动画的标识，可为nil
 keyPath            将要添加动画的属性名
 beginTime          动画延时时长
 fromValue          起始值：可以为动画类型所对应的空类型。若为空，则默认当前状态为初始状态
 toValue            终止值：不可为nil
 duration           动画时长
 timingFunctionName 动画节奏模式，可选值：@"linear", @"easeIn", @"easeOut" ,
 @"easeInEaseOut" 和 @"default"。也可使用其对应的常量形式，如kCAMediaTimingFunctionLinear
 
 注：
 1.fromValue与toValue，均为UIKit中对象类型，如NSValue/NSNumber/UIColor/UIBezierPath/UIImage等等对应的对象类型。
 2.本方法创建的非CALayer属性动画不可用恢复动画自动恢复，请自行恢复
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                              keyPath:(NSString *)keyPath
                         animationKey:(NSString *)animationKey
                            beginTime:(CGFloat)beginTime
                             duration:(CGFloat)duration
                            fromValue:(id)fromValue
                              toValue:(id)toValue
                   timingFunctionName:(NSString *)timingFunctionName;

///创建景深旋转动画
/**
 即具有透视效果的换轴旋转动画
 
 layer              将要展示动画的layer，不可为nil
 animationKey       动画的标识，可为nil
 beginTime          动画延时时长
 duration           动画时长
 rotateStartAngle   旋转起始角度
 rotateEndAngle     旋转终止角度
 rotateAxis         旋转轴
 deep               景深系数
 
 注：
 1.旋转角度为角度制
 2.旋转轴为Z轴时无景深效果
 3.deep为景深系数，数值越小，透视效果越明显，反之效果更平缓，推荐值300
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                         animationKey:(NSString *)animationKey
                            beginTime:(CGFloat)beginTime
                             duration:(CGFloat)duration
                     rotateStartAngle:(CGFloat)startAngle
                       rotateEndAngle:(CGFloat)endAngle
                           rotateAxis:(Axis)rotateAxis
                                 deep:(CGFloat)deep;

///创建拟合锚点改变动画
/**
 以曲线旋转动画拟合改变锚点后的旋转动画
 
 layer                  将要展示动画的layer，不可为nil
 animationKey           动画的标识，可为nil
 beginTime              动画延时时长
 duration               动画时长
 rotateStartAngle       旋转起始角度
 rotateEndAngle         旋转终止角度
 simulateChangeAnchor   拟合的改变后锚点
 
 注：
 1.旋转角度为角度制
 2.实际锚点不发生改变，为拟合路径
 */
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                         animationKey:(NSString *)animationKey
                            beginTime:(CGFloat)beginTime
                             duration:(CGFloat)duration
                     rotateStartAngle:(CGFloat)startAngle
                       rotateEndAngle:(CGFloat)endAngle
                 simulateChangeAnchor:(CGPoint)anchor;

#pragma mark ---动画编辑方法---

///拼接动画，在当前动画后拼接动画
/**
 animation      将要组合的DWAnimation对象
 animaitonKey   组合后的动画的Key，可为nil或空，若为nil则以默认规则生成Key
 
 注：拼接动画会改变调用对象及添加对象的beginTime，且具有累计效应。
 故参与添加动画后，仅返回的动画实例具有正确动画效果，调用对象和添加均不能正确展示。
 */
-(DWAnimation *)addAnimation:(DWAnimation *)animation
                animationKey:(NSString *)animationKey;

///按顺序拼接数组中的所有动画
/**
 animations     DWAniamtion对象组成的数组
 animaitonKey   组合后的动画的Key，可为nil或空，若为nil则以默认规则生成Key
 
 注：本方法调用-addAnimation:animationKey:,故仅返回值具有正确展示效果
 */
+(DWAnimation *)createAnimationWithAnimations:(__kindof NSArray<DWAnimation *> *)animations
                                 animationKey:(NSString *)animationKey;

///并发组合两个动画
/**
 animation      将要组合的DWAnimation对象
 animaitonKey   组合后的动画的Key，可为nil或空，若为nil则以默认规则生成Key
 
 注：组合后两动画并发执行
 若两动画中有相同动画属性且执行时间相同，则后者动作覆盖前者动作
 组合的动画的view应该为同一对象，否则返回自身
 若要实现不同view的动画并发执行，请调用DWAnimationManager中相关api
 */
-(DWAnimation *)combineWithAnimation:(DWAnimation *)animaiton
                        animationKey:(NSString *)animationKey;

///并发组合数组中的动画
/**
 animations     DWAniamtion对象组成的数组
 animaitonKey   组合后的动画的Key，可为nil或空，若为nil则以默认规则生成Key
 */
+(DWAnimation *)combineAnimationsInArray:(__kindof NSArray<DWAnimation *> *)animations
                            animationKey:(NSString *)animaitonKey;

///创建恢复原状的动画
/**
 注：特殊属性动画不在恢复动画范围内，请自行恢复。
 */
+(DWAnimation *)createResetAnimationWithLayer:(CALayer *)layer
                                 animationKey:(NSString *)animationKey
                                    beginTime:(CGFloat)beginTime
                                     duration:(CGFloat)duration;

///以content开始动画

/**
 以content开始动画

 @param content content类型可为UIView或CALayer
 
 注：可更换DWAnimation对象的执行主体。
 非必须条件下不推荐更换DWAnimaion执行主体。
 */
-(void)startAnimationWithContent:(id)content;

///为以贝塞尔曲线创建的移动动画添加时间间隔
/**
 keyTimes      时间间隔
 
 注：
 本方法非必须实现方法，若不实现，动画将按匀速执行
 若实现本方法，你需要传入正确的keyTimes，否则会造成动画显示异常。
 keyTimes元素个数为bezierPath的子路径数。
 keyTimes中每个元素即为bezierPath每条子路径的持续时间。
 keyTimes中所有元素之和应等于duration
 eg.    以
 [UIBezierPath bezierPathWithRect:CGRectMake(100, 100, 100, 100)]
 创建的动画duration为6，keyTimes可传入下列形式 @[@1,@2,@1,@2]
 */
-(void)setTimeIntervals:(NSArray<NSNumber *> *)timeIntervals;

@end
