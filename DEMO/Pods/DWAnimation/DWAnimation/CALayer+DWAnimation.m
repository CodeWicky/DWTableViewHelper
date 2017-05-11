//
//  CALayer+DWAnimation.m
//  DWAnimation
//
//  Created by Wicky on 16/10/8.
//  Copyright © 2016年 Wicky. All rights reserved.
//


#import "DWAnimation.h"
#import "DWAnimationManager.h"
@implementation CALayer (DWAnimation)

-(DWAnimation *)dw_CreateAnimationWithKey:(NSString *)animationKey animationCreater:(void (^)(DWAnimationMaker *))animationCreater
{
    return [[DWAnimation alloc] initAnimationWithLayer:self animationKey:animationKey animationCreater:animationCreater];
}

-(DWAnimation *)dw_CreateAnimationWithAnimationKey:(NSString *)animationKey
                                         beginTime:(CGFloat)beginTime
                                          duration:(CGFloat)duration
                                        animations:(__kindof NSArray<CAAnimation *> *)animations
{
    return [[DWAnimation alloc] initAnimationWithLayer:self animationKey:animationKey beginTime:beginTime duration:duration animations:animations];
}

-(DWAnimation *)dw_CreateAnimationWithAnimationType:(DWAnimationType)animationType
                                       animationKey:(NSString *)animationKey
                                          beginTime:(CGFloat)beginTime
                                             values:(NSArray *)values
                                      timeIntervals:(NSArray *)timeIntervals
                                         transition:(BOOL)transition
{
    return [[DWAnimation alloc] initAnimationWithLayer:self animationType:animationType animationKey:animationKey beginTime:beginTime values:values timeIntervals:timeIntervals transition:transition];
}

-(DWAnimation *)dw_CreateAnimationWithAnimationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration bezierPath:(UIBezierPath *)bezierPath autoRotate:(BOOL)autoRotate
{
    return [[DWAnimation alloc] initAnimationWithLayer:self animationKey:animationKey beginTime:beginTime duration:duration bezierPath:bezierPath autoRotate:autoRotate];
}

-(DWAnimation *)dw_CreateAnimationWithAnimationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration arcCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise autoRotate:(BOOL)autoRotate
{
    return [[DWAnimation alloc] initAnimationWithLayer:self animationKey:animationKey beginTime:beginTime duration:duration arcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise autoRotate:autoRotate];
}

-(DWAnimation *)dw_CreateAnimationWithAnimationKey:(NSString *)animationKey springingType:(DWAnimationSpringType)springingType beginTime:(CGFloat)beginTime fromValue:(id)fromValue toValue:(id)toValue mass:(CGFloat)mass stiffness:(CGFloat)stiffness damping:(CGFloat)damping initialVelocity:(CGFloat)initialVelocity
{
    return [[DWAnimation alloc] initAnimationWithLayer:self animationKey:animationKey springingType:springingType beginTime:beginTime fromValue:fromValue toValue:toValue mass:mass stiffness:stiffness damping:damping initialVelocity:initialVelocity];
}

-(DWAnimation *)dw_CreateAnimationWithKeyPath:(NSString *)keyPath animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration fromValue:(id)fromValue toValue:(id)toValue timingFunctionName:(NSString *)timingFunctionName
{
    return [[DWAnimation alloc] initAnimationWithLayer:self keyPath:keyPath animationKey:animationKey beginTime:beginTime duration:duration fromValue:fromValue toValue:toValue timingFunctionName:timingFunctionName];
}

-(DWAnimation *)dw_CreateAnimationWithAnimationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration rotateStartAngle:(CGFloat)startAngle rotateEndAngle:(CGFloat)endAngle rotateAxis:(Axis)rotateAxis deep:(CGFloat)deep
{
    return [[DWAnimation alloc] initAnimationWithLayer:self animationKey:animationKey beginTime:beginTime duration:duration rotateStartAngle:startAngle rotateEndAngle:endAngle rotateAxis:rotateAxis deep:deep];
}

-(DWAnimation *)dw_CreateAnimationWithLayer:(CALayer *)layer animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration rotateStartAngle:(CGFloat)startAngle rotateEndAngle:(CGFloat)endAngle simulateChangeAnchor:(CGPoint)anchor
{
    return [[DWAnimation alloc] initAnimationWithLayer:self animationKey:animationKey beginTime:beginTime duration:duration rotateStartAngle:startAngle rotateEndAngle:endAngle simulateChangeAnchor:anchor];
}


-(DWAnimation *)dw_CreateResetAnimationWithAnimationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration
{
    return [DWAnimation createResetAnimationWithLayer:self animationKey:animationKey beginTime:beginTime duration:duration];
}

+(void)dw_StartAnimations:(__kindof NSArray<DWAnimation *> *)animations playMode:(DWAnimationPlayMode)playMode
{
    [DWAnimationManager startAnimations:animations playMode:playMode];
}
@end
