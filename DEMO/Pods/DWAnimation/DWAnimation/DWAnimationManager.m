//
//  DWAnimationManager.m
//  DWHUD
//
//  Created by Wicky on 16/8/21.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWAnimationManager.h"
#import "DWAnimation.h"

@implementation DWAnimationManager

///按顺序执行一组动画
+(void)startSingleAnimations:(__kindof NSArray<DWAnimation *> *)animations
{
    int count = (int)animations.count;
    if (!count) {
        return;
    }
    float startTime = 0;
    CFTimeInterval time = CACurrentMediaTime();
    for (int i = 0; i < count; i++) {
        DWAnimation * animation = animations[i];
        animation.animation.beginTime = time + startTime + animation.beginTime;
        startTime += animation.duration;
        [animation start];
    }
}

///并发执行不同view的动画
+(void)startMultiAnimations:(__kindof NSArray<DWAnimation *> *)animations
{
    NSMutableArray * arr = [NSMutableArray array];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    for (DWAnimation * animation in animations) {
        CALayer * layer = animation.layer;
        if (![arr containsObject:layer]) {
            [arr addObject:layer];
        }
        NSString * key = [NSString stringWithFormat:@"%lu",(unsigned long)[arr indexOfObject:layer]];
        NSMutableArray * array = dic[key];
        if (!array) {
            array = [NSMutableArray array];
            [dic setValue:array forKey:key];
        }
        [array addObject:animation];
    }
    for (NSMutableArray * arrValue in dic.allValues) {
        [[DWAnimation createAnimationWithAnimations:arrValue animationKey:nil] start];
    }
}

///根据不同的模式播放动画
+(void)startAnimations:(__kindof NSArray<DWAnimation *> *)animations playMode:(DWAnimationPlayMode)playMode
{
    switch (playMode) {
        case DWAnimationPlayModeSingle:
            [DWAnimationManager startSingleAnimations:animations];
            return;
            break;
        case DWAnimationPlayModeMulti:
            [DWAnimationManager startMultiAnimations:animations];
            return;
            break;
        default:
            [DWAnimationManager startSingleAnimations:animations];
            break;
    }
}
@end
