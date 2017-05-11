//
//  DWAnimation.m
//  DWHUD
//
//  Created by Wicky on 16/8/20.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWAnimation.h"
#import "DWAnimationMaker.h"
@interface DWAnimation ()<CAAnimationDelegate>

@property (nonatomic ,assign) BOOL notFirstTime;

@end

@implementation DWAnimation

#pragma mark ---接口方法---

#pragma mark ------构造方法------

///以block形式创建动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer
                        animationKey:(NSString *)animationKey
                    animationCreater:(void(^)(DWAnimationMaker * maker))animationCreater
{
    self = [super init];
    if (self) {
        self.repeatCount = 1;
        self.layer = layer;
        self.animationKey = animationKey;
        self.status = DWAnimationStatusReadyToShow;
        DWAnimationMaker * maker = [DWAnimationMaker new];
        maker.layer = layer;
        if (animationCreater) {
            animationCreater(maker);
        }
        [maker make];
        self.duration = maker.totalDuration;
        self.animation = maker.animation;
    }
    return self;
}

///以数组形式创建动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration animations:(__kindof NSArray<CAAnimation *> *)animations
{
    self = [super init];
    if (self) {
        self.repeatCount = 1;
        self.layer = layer;
        self.duration = duration + beginTime;
        self.animationKey = animationKey;
        self.status = DWAnimationStatusReadyToShow;
        NSArray * arr = [animations sortedArrayUsingComparator:^NSComparisonResult(CAAnimation * ani1, CAAnimation * ani2) {
            if (ani1.beginTime > ani2.beginTime) {
                return NSOrderedDescending;
            }else if (ani1.beginTime < ani2.beginTime)
            {
                return NSOrderedAscending;
            }else
            {
                return NSOrderedSame;
            }
        }];
        for (CAAnimation * animation in animations) {
            animation.beginTime += beginTime;
        }
        CAAnimationGroup * group = [CAAnimationGroup animation];
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
        group.removedOnCompletion = NO;
        group.fillMode = kCAFillModeForwards;
        group.duration = duration + beginTime;
        group.animations = arr;
        group.repeatCount = 1;
        self.animation = group;
    }
    return self;
}

///创建连续动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer animationType:(DWAnimationType)animationType animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime values:(NSArray *)values timeIntervals:(NSArray *)timeIntervals transition:(BOOL)transtion

{
    if ((values.count - timeIntervals.count == 1) && timeIntervals.count)
    {
        NSString * type = nil;
        switch (animationType) {
            case DWAnimationTypeMove:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSValue class])]) {
                    return nil;
                }
                type = @"position";
                break;
            }
            case DWAnimationTypeScale:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSNumber class])]) {
                    return nil;
                }
                type = @"transform.scale";
                break;
            }
            case DWAnimationTypeRotate:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSNumber class])]) {
                    return nil;
                }
                NSMutableArray * arr = [NSMutableArray array];
                for (NSNumber * number in values) {
                    [arr addObject:@RadianFromDegree(number.floatValue)];
                }
                values = [NSArray arrayWithArray:arr];
                type = @"transform.rotation";
                break;
            }
            case DWAnimationTypeAlpha:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSNumber class])]) {
                    return nil;
                }
                type = @"opacity";
                break;
            }
            case DWAnimationTypeCornerRadius:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSNumber class])]) {
                    return nil;
                }
                type = @"cornerRadius";
                break;
            }
            case DWAnimationTypeBorderColor:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([UIColor class])]) {
                    return nil;
                }
                NSMutableArray * arr = [NSMutableArray array];
                for (UIColor * color in values) {
                    [arr addObject:(id)color.CGColor];
                }
                values = [NSArray arrayWithArray:arr];
                if (!layer.borderWidth) {
                    layer.borderWidth = 3;
                }
                type = @"borderColor";
                break;
            }
            case DWAnimationTypeBorderWidth:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSNumber class])]) {
                    return nil;
                }
                type = @"borderWidth";
                break;
            }
            case DWAnimationTypeShadowColor:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([UIColor class])]) {
                    return nil;
                }
                NSMutableArray * arr = [NSMutableArray array];
                for (UIColor * color in values) {
                    [arr addObject:(id)color.CGColor];
                }
                values = [NSArray arrayWithArray:arr];
                if (!layer.shadowOpacity) {
                    layer.shadowOpacity = 0.5;
                }
                type = @"shadowColor";
                break;
            }
            case DWAnimationTypeShadowAlpha:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSNumber class])]) {
                    return nil;
                }
                type = @"shadowOpacity";
                break;
            }
            case DWAnimationTypeShadowOffset:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSValue class])]) {
                    return nil;
                }
                if (!layer.shadowOpacity) {
                    layer.shadowOpacity = 0.5;
                }
                type = @"shadowOffset";
                break;
            }
            case DWAnimationTypeShadowCornerRadius:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSNumber class])]) {
                    return nil;
                }
                if (!layer.shadowOpacity) {
                    layer.shadowOpacity = 0.5;
                }
                type = @"shadowRadius";
                break;
            }
            case DWAnimationTypeShadowPath:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([UIBezierPath class])]) {
                    return nil;
                }
                NSMutableArray * arr = [NSMutableArray array];
                for (UIBezierPath * path in values) {
                    [arr addObject:(id)path.CGPath];
                }
                values = [NSArray arrayWithArray:arr];
                if (!layer.shadowOpacity) {
                    layer.shadowOpacity = 0.5;
                }
                type = @"shadowPath";
                break;
            }
            case DWAnimationTypeBackgroundImage:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([UIImage class])]) {
                    return nil;
                }
                NSMutableArray * arr = [NSMutableArray array];
                for (UIImage * image in values) {
                    [arr addObject:(id)image.CGImage];
                }
                values = [NSArray arrayWithArray:arr];
                type = @"contents";
                break;
            }
            case DWAnimationTypeBackgroundColor:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([UIColor class])]) {
                    return nil;
                }
                NSMutableArray * arr = [NSMutableArray array];
                for (UIColor * color in values) {
                    [arr addObject:(id)color.CGColor];
                }
                values = [NSArray arrayWithArray:arr];
                type = @"backgroundColor";
                break;
            }
            default:
            {
                if (![DWAnimation allObjectsInArray:values isKindClass:NSStringFromClass([NSNumber class])]) {
                    return nil;
                }
                type = @"position";
                break;
            }
        }
        __block CGFloat duration = 0;
        [timeIntervals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            duration += [(NSNumber *)obj floatValue];
        }];
        NSMutableArray * arrTimes = [NSMutableArray arrayWithObject:@0];
        CGFloat numTemp = 0;
        for (NSNumber * number in timeIntervals) {
            numTemp += number.floatValue;
            [arrTimes addObject:[NSNumber numberWithFloat:numTemp / duration]];
        }
        CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:type];
        animation.values = values;
        animation.keyTimes = arrTimes;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        animation.beginTime += beginTime;
        animation.duration = duration;
        if (transtion) {
            animation.calculationMode = kCAAnimationCubic;
        }
        return [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey beginTime:0  duration:duration + beginTime animations:@[animation]];
    }
    else
    {
        return nil;
    }
}

///以贝尔塞曲线创建移动动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer animationKey:(NSString *)animationKey
                           beginTime:(CGFloat)beginTime duration:(CGFloat)duration bezierPath:(UIBezierPath *)bezierPath autoRotate:(BOOL)autoRotate
{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = duration;
    animation.beginTime += beginTime;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.calculationMode = kCAAnimationCubicPaced;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    animation.path = bezierPath.CGPath;
    if (autoRotate) {
        animation.rotationMode = kCAAnimationRotateAuto;
    }
    return [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey beginTime:0  duration:(beginTime + duration) animations:@[animation]];
}

///创建弧线动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration arcCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise autoRotate:(BOOL)autoRotate
{
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:RadianFromDegree(startAngle - 90) endAngle:RadianFromDegree(endAngle - 90) clockwise:clockwise];
    return [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey beginTime:beginTime duration:duration bezierPath:path autoRotate:autoRotate];
}

///创建震荡动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer animationKey:(NSString *)animationKey springingType:(DWAnimationSpringType)springingType beginTime:(CGFloat)beginTime fromValue:(id)fromValue toValue:(id)toValue mass:(CGFloat)mass stiffness:(CGFloat)stiffness damping:(CGFloat)damping initialVelocity:(CGFloat)initialVelocity
{
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(9.0)) {
        return nil;
    }
    if (!toValue) {
        return nil;
    }
    NSString * key = nil;
    switch (springingType) {
        case DWAnimationSpringTypeMove:
            key = @"position";
            break;
        case DWAnimationSpringTypeScale:
            key = @"transform.scale";
            break;
        case DWAnimationSpringTypeRotate:
            key = @"transform.rotation";
            break;
        case DWAnimationSpringTypeAlpha:
            key = @"opacity";
            break;
        case DWAnimationSpringTypeCornerRadius:
        {
            key = @"cornerRadius";
            layer.masksToBounds = YES;
            break;
        }
        case DWAnimationSpringTypeBorderColor:
            key = @"borderColor";
            break;
        case DWAnimationSpringTypeBorderWidth:
            key = @"borderWidth";
            break;
        case DWAnimationSpringTypeShadowColor:
            key = @"shadowColor";
            break;
        case DWAnimationSpringTypeShadowOffset:
            key = @"shadowOffset";
            break;
        case DWAnimationSpringTypeShadowAlpha:
            key = @"shadowOpacity";
            break;
        case DWAnimationSpringTypeShadowCornerRadius:
            key = @"shadowRadius";
            break;
        case DWAnimationSpringTypeShadowPath:
            key = @"shadowPath";
            break;
        case DWAnimationSpringTypeBackgroundImage:
            key = @"contents";
            break;
        case DWAnimationSpringTypeBackgroundColor:
            key = @"backgroundColor";
            break;
        default:
            key = @"position";
            break;
    }
    CASpringAnimation * animation = [CASpringAnimation animationWithKeyPath:key];
    animation.beginTime = beginTime;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.mass = mass;
    animation.stiffness = stiffness;
    animation.damping = damping;
    animation.initialVelocity = initialVelocity;
    animation.duration = animation.settlingDuration;
    if ((springingType == DWAnimationSpringTypeMove || springingType == DWAnimationSpringTypeShadowOffset) && ((![toValue isKindOfClass:[NSValue class]]) || ((fromValue) && (![fromValue isKindOfClass:[NSValue class]])))){
        return nil;
    }
    if ((springingType == DWAnimationSpringTypeRotate || springingType == DWAnimationSpringTypeScale || springingType == DWAnimationSpringTypeAlpha || springingType == DWAnimationSpringTypeCornerRadius || springingType == DWAnimationSpringTypeBorderWidth || springingType == DWAnimationSpringTypeShadowAlpha || springingType == DWAnimationSpringTypeShadowCornerRadius) && ((![toValue isKindOfClass:[NSNumber class]]) || ((fromValue) && (![fromValue isKindOfClass:[NSNumber class]])))){
        return nil;
    }
    if ((springingType == DWAnimationSpringTypeBorderColor || springingType== DWAnimationSpringTypeShadowColor || springingType == DWAnimationSpringTypeBackgroundColor)  && ((![toValue isKindOfClass:[UIColor class]]) || ((fromValue) && (![fromValue isKindOfClass:[UIColor class]])))){
        return nil;
    }
    if ((springingType == DWAnimationSpringTypeShadowPath)  && ((![toValue isKindOfClass:[UIBezierPath class]]) || ((fromValue) && (![fromValue isKindOfClass:[UIBezierPath class]])))) {
        return nil;
    }
    if ((springingType == DWAnimationSpringTypeBackgroundImage) && ((![toValue isKindOfClass:[UIImage class]]) || ((fromValue) && (![fromValue isKindOfClass:[UIImage class]])))) {
        return nil;
    }
    if (springingType == DWAnimationSpringTypeBackgroundImage && !fromValue) {
        fromValue = UIImageNull;
    }
    if (springingType == DWAnimationSpringTypeShadowPath && !fromValue) {
        fromValue = UIBezierPathNull(layer.bounds.size.width, layer.bounds.size.height);
    }
    if (springingType == DWAnimationSpringTypeShadowOffset && !fromValue) {
        fromValue = [NSValue valueWithCGSize:CGSizeNull];
    }
    if (fromValue) {
        if (springingType == DWAnimationSpringTypeMove || springingType == DWAnimationSpringTypeShadowOffset) {
            if (springingType == DWAnimationSpringTypeMove) {
                CGPoint point = [(NSValue *)fromValue CGPointValue];
                if (!CGPointIsNull((point))) {
                    animation.fromValue = fromValue;
                }
            }
            else
            {
                CGSize size = [(NSValue *)fromValue CGSizeValue];
                if (!CGSizeIsNull(size)) {
                    animation.fromValue = fromValue;
                }
            }
        }
        else if(springingType == DWAnimationSpringTypeRotate || springingType == DWAnimationSpringTypeScale || springingType == DWAnimationSpringTypeAlpha || springingType == DWAnimationSpringTypeCornerRadius || springingType == DWAnimationSpringTypeBorderWidth || springingType == DWAnimationSpringTypeShadowAlpha || springingType == DWAnimationSpringTypeShadowCornerRadius)
        {
            CGFloat num = [(NSNumber *)fromValue floatValue];
            if (!CGFloatIsNull(num)) {
                if (springingType == DWAnimationSpringTypeRotate) {
                    fromValue = @(RadianFromDegree(num));
                }
                if (springingType == DWAnimationSpringTypeAlpha || springingType == DWAnimationSpringTypeShadowAlpha) {
                    if (num > 1) {
                        num = 1;
                        fromValue = @(num);
                    }
                    if (num < 0) {
                        num = 0;
                        fromValue = @(num);
                    }
                }
                animation.fromValue = fromValue;
            }
        }
        else if (springingType == DWAnimationSpringTypeBorderColor || springingType== DWAnimationSpringTypeShadowColor || springingType == DWAnimationSpringTypeBackgroundColor)
        {
            UIColor * color = (UIColor *)fromValue;
            animation.fromValue = (id)color.CGColor;
        }
        else if (springingType == DWAnimationSpringTypeShadowPath)
        {
            UIBezierPath * path = (UIBezierPath *)fromValue;
            animation.fromValue = (id)path.CGPath;
        }
        else
        {
            UIImage * image = (UIImage *)fromValue;
            animation.fromValue = (id)image.CGImage;
        }
    }
    if (springingType == DWAnimationSpringTypeMove || springingType == DWAnimationSpringTypeShadowOffset) {
        if (springingType == DWAnimationSpringTypeMove) {
            CGPoint point = [(NSValue *)toValue CGPointValue];
            if (!CGPointIsNull((point))) {
                animation.toValue = toValue;
            }
            else
            {
                return nil;
            }
        }
        else
        {
            CGSize size = [(NSValue *)toValue CGSizeValue];
            if (!CGSizeIsNull(size)) {
                animation.toValue = toValue;
                if (!layer.shadowOpacity) {
                    layer.shadowOpacity = 0.5;
                }
            }
            else
            {
                return nil;
            }
        }
    }
    else if(springingType == DWAnimationSpringTypeRotate || springingType == DWAnimationSpringTypeScale || springingType == DWAnimationSpringTypeAlpha || springingType == DWAnimationSpringTypeCornerRadius || springingType == DWAnimationSpringTypeBorderWidth || springingType == DWAnimationSpringTypeShadowAlpha || springingType == DWAnimationSpringTypeShadowCornerRadius)
    {
        CGFloat num = [(NSNumber *)toValue floatValue];
        if (!CGFloatIsNull(num)) {
            if (springingType == DWAnimationSpringTypeRotate) {
                toValue = @(RadianFromDegree(num));
            }
            if (springingType == DWAnimationSpringTypeAlpha || springingType == DWAnimationSpringTypeShadowAlpha) {
                if (num > 1) {
                    num = 1;
                    toValue = @(num);
                }
                if (num < 0) {
                    num = 0;
                    toValue = @(num);
                }
            }
            if ((springingType == DWAnimationSpringTypeShadowAlpha || springingType == DWAnimationSpringTypeShadowCornerRadius) && !layer.shadowOpacity) {
                layer.shadowOpacity = 0.5;
            }
            animation.toValue = toValue;
        }
        else
        {
            return nil;
        }
    }
    else if (springingType == DWAnimationSpringTypeBorderColor || springingType== DWAnimationSpringTypeShadowColor || springingType == DWAnimationSpringTypeBackgroundColor)
    {
        UIColor * color = (UIColor *)toValue;
        animation.toValue = (id)color.CGColor;
        if (springingType == DWAnimationSpringTypeBorderColor && !layer.borderWidth) {
            layer.borderWidth = 3;
        }
        if (springingType == DWAnimationSpringTypeShadowColor && !layer.shadowOpacity) {
            layer.shadowOpacity = 0.5;
        }
    }
    else if (springingType == DWAnimationSpringTypeShadowPath)
    {
        UIBezierPath * path = (UIBezierPath *)toValue;
        animation.toValue = (id)path.CGPath;
        if (springingType == DWAnimationSpringTypeShadowPath && !layer.shadowOpacity) {
            layer.shadowOpacity = 0.5;
        }
    }
    else
    {
        UIImage * image = (UIImage *)toValue;
        animation.toValue = (id)image.CGImage;
    }
    return [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey beginTime:0  duration:(beginTime + animation.duration) animations:@[animation]];
}

///创建特殊属性动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer keyPath:(NSString *)keyPath animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration fromValue:(id)fromValue toValue:(id)toValue timingFunctionName:(NSString *)timingFunctionName
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.beginTime = beginTime;
    animation.duration = duration;
    if (fromValue) {
        animation.fromValue = fromValue;
    }
    animation.toValue = toValue;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
    return [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey beginTime:0 duration:(beginTime + duration) animations:@[animation]];
}

///创建景深旋转动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration rotateStartAngle:(CGFloat)startAngle rotateEndAngle:(CGFloat)endAngle rotateAxis:(Axis)rotateAxis deep:(CGFloat)deep
{
    if (rotateAxis == Z) {
        return [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey animationCreater:^(DWAnimationMaker *maker) {
            maker.rotateFrom(startAngle).rotateTo(endAngle).beginTime(beginTime).duration(duration).install();
        }];
    }
    else
    {
        CATransform3D fromValue = CATransform3DIdentity;
        fromValue.m34 = -1.f / deep;
        CATransform3D toValue = CATransform3DIdentity;
        toValue.m34 = -1.f / deep;
        if (rotateAxis == X) {
            fromValue = CATransform3DRotate(fromValue, RadianFromDegree(startAngle), 1, 0, 0);
            toValue = CATransform3DRotate(toValue, RadianFromDegree(endAngle), 1, 0, 0);
        }
        else
        {
            fromValue = CATransform3DRotate(fromValue, RadianFromDegree(startAngle), 0, 1, 0);
            toValue = CATransform3DRotate(toValue, RadianFromDegree(endAngle), 0, 1, 0);
        }
        return [[DWAnimation alloc] initAnimationWithLayer:layer keyPath:@"transform" animationKey:animationKey beginTime:beginTime duration:duration fromValue:[NSValue valueWithCATransform3D:fromValue] toValue:[NSValue valueWithCATransform3D:toValue] timingFunctionName:kCAMediaTimingFunctionLinear];
    }
}

///创建拟合锚点移动的旋转动画
-(instancetype)initAnimationWithLayer:(CALayer *)layer animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration rotateStartAngle:(CGFloat)startAngle rotateEndAngle:(CGFloat)endAngle simulateChangeAnchor:(CGPoint)anchor{
    DWAnimation * ro = [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey animationCreater:^(DWAnimationMaker *maker) {
        maker.rotateFrom(startAngle).rotateTo(endAngle).beginTime(beginTime).duration(duration).install();
    }];
    if (CGPointEqualToPoint(anchor, CGPointMake(0.5, 0.5)) || endAngle == startAngle) {
        return ro;
    }
    CGFloat offsetX = layer.bounds.size.width * (anchor.x - 0.5);
    CGFloat offsetY = layer.bounds.size.height * (anchor.y - 0.5);
    CGFloat radius = sqrtf(powf(offsetX, 2) + powf(offsetY, 2));
    CGPoint center = CGPointMake(layer.position.x + offsetX, layer.position.y + offsetY);
    CGFloat deltaAngle = 0;
    if (anchor.x == 0.5) {
        if (anchor.y < 0.5) {
            deltaAngle = M_PI_2;
        }
        else
        {
            deltaAngle = M_PI_2 * 3;
        }
    }
    else
    {
        deltaAngle = atan2(- offsetY, - offsetX);
    }
    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:RadianFromDegree(startAngle) + deltaAngle endAngle:RadianFromDegree(endAngle) + deltaAngle clockwise:endAngle>startAngle];
    
    DWAnimation * trans = [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey beginTime:beginTime duration:duration bezierPath:path autoRotate:NO];
    
    return [ro combineWithAnimation:trans animationKey:animationKey];
}

#pragma mark ------动画控制方法------
///开始播放动画
-(void)start
{
    if (self.repeatCount > 0) {
        if (self.status == DWAnimationStatusReadyToShow || self.status == DWAnimationStatusRemoved || self.status == DWAnimationStatusFinished) {
            self.animation.delegate = self;
            [self.layer addAnimation:self.animation forKey:self.animationKey];
        }
    }
}

///暂停动画
-(void)suspend
{
    if (self.status == DWAnimationStatusPlay) {
        CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        self.layer.speed = 0.0;
        self.layer.timeOffset = pausedTime;
        self.status = DWAnimationStatusSuspend;
    }
}

///恢复动画
-(void)resume
{
    if (self.status == DWAnimationStatusSuspend) {
        CFTimeInterval pausedTime = self.layer.timeOffset;
        self.layer.speed = 1.0;
        self.layer.timeOffset = 0.0;
        self.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.layer.beginTime = timeSincePause;
        self.status = DWAnimationStatusPlay;
    }
}

///移除动画
-(void)remove
{
    if (self.status != DWAnimationStatusRemoved) {
        self.repeatCount = 0;
        [self.layer removeAnimationForKey:self.animationKey];
        self.status = DWAnimationStatusRemoved;
    }
}

#pragma mark ------动画编辑方法------

///拼接两个动画
-(DWAnimation *)addAnimation:(DWAnimation *)animation animationKey:(NSString *)animationKey
{
    CALayer * layer = self.layer;
    if (![layer isEqual:animation.layer]) {
        return self;
    }
    CGFloat beginTime = self.duration + self.beginTime;
    if (animationKey == nil || animationKey.length == 0) {
        animationKey = [NSString stringWithFormat:@"(%@_ADD_%@)",self.animationKey,animation.animationKey];
    }
    CGFloat duration = beginTime + animation.duration;
    animation.beginTime = beginTime;
    NSMutableArray * arr = [NSMutableArray array];
    [arr addObject:self.animation];
    [arr addObject:animation.animation];
    return [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey beginTime:0  duration:duration animations:arr];
}

///按顺序拼接数组中的所有动画
+(DWAnimation *)createAnimationWithAnimations:(__kindof NSArray<DWAnimation *> *)animations animationKey:(NSString *)animationKey
{
    int count = (int)animations.count;
    if (!count) {
        return nil;
    }
    if (count == 1) {
        return animations.firstObject;
    }
    NSMutableArray * mArr = animations.mutableCopy;
    [mArr sortUsingComparator:^NSComparisonResult(DWAnimation * ani1, DWAnimation * ani2) {
        CGFloat begin1 = ani1.animation.beginTime;
        CGFloat begin2 = ani2.animation.beginTime;
        if (begin1 > begin2) {
            return NSOrderedDescending;
        }else if (begin1 < begin2)
        {
            return NSOrderedAscending;
        }else
        {
            return NSOrderedSame;
        }
    }];
    DWAnimation * animation = [mArr[0] addAnimation:mArr[1] animationKey:nil];
    [mArr removeObjectAtIndex:0];
    [mArr removeObjectAtIndex:0];
    count -= 2;
    while (count) {
        animation = [animation addAnimation:mArr[0] animationKey:nil];
        [mArr removeObjectAtIndex:0];
        count --;
    }
    if (animationKey != nil && animationKey.length != 0) {
        animation.animationKey = animationKey;
    }
    return animation;
}

-(void)startAnimationWithContent:(id)content {
    if ([content isKindOfClass:[UIView class]]) {
        self.layer = [content layer];
    } else if ([content isKindOfClass:[CALayer class]]) {
        self.layer = content;
    }
    [self start];
}

///并发组合两个动画
-(DWAnimation *)combineWithAnimation:(DWAnimation *)animaiton animationKey:(NSString *)animationKey
{
    if (![self.layer isEqual:animaiton.layer]) {
        return self;
    }
    NSMutableArray * arr = [NSMutableArray array];
    [arr addObject:self.animation];
    [arr addObject:animaiton.animation];
    CGFloat duration = MAX(self.duration, animaiton.duration);
    if (animationKey == nil || animationKey.length == 0) {
        animationKey = [NSString stringWithFormat:@"(%@_COMBINE_%@)",self.animationKey,animaiton.animationKey];
    }
    return [[DWAnimation alloc] initAnimationWithLayer:self.layer animationKey:animationKey beginTime:0 duration:duration animations:arr];
}

///并发组合数组中的动画
+(DWAnimation *)combineAnimationsInArray:(__kindof NSArray<DWAnimation *> *)animations animationKey:(NSString *)animaitonKey
{
    int count = (int)animations.count;
    if (!count) {
        return nil;
    }
    if (count == 1) {
        return animations.firstObject;
    }
    NSMutableArray * mArr = animations.mutableCopy;
    DWAnimation * animation = [mArr[0] combineWithAnimation:mArr[1] animationKey:nil];
    [mArr removeObjectAtIndex:0];
    [mArr removeObjectAtIndex:0];
    count -= 2;
    while (count) {
        animation = [animation combineWithAnimation:mArr[0] animationKey:nil];
        [mArr removeObjectAtIndex:0];
        count --;
    }
    if (animaitonKey != nil && animaitonKey.length != 0) {
        animation.animationKey = animaitonKey;
    }
    return animation;
}

///创建恢复动画
+(DWAnimation *)createResetAnimationWithLayer:(CALayer *)layer animationKey:(NSString *)animationKey beginTime:(CGFloat)beginTime duration:(CGFloat)duration
{
    if (animationKey == nil || animationKey.length == 0) {
        animationKey = @"resetAnimation";
    }
    return [[DWAnimation alloc] initAnimationWithLayer:layer animationKey:animationKey animationCreater:^(DWAnimationMaker *maker) {
        maker.reset.beginTime(beginTime).duration(duration).install();
    }];
}

///为以贝塞尔曲线创建的动画的每段子路径设置时间
-(void)setTimeIntervals:(NSArray<NSNumber *> *)timeIntervals
{
    NSMutableArray * arr = [NSMutableArray arrayWithArray:@[@0]];
    __block float duration = 0;
    [timeIntervals enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        duration += obj.floatValue;
    }];
    __block float time = 0;
    [timeIntervals enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        time += obj.floatValue;
        [arr addObject:@(time / duration)];
    }];
    CAKeyframeAnimation * animation =(CAKeyframeAnimation *)self.animation.animations.firstObject;
    animation.keyTimes = arr;
}

///判断数组中元素是否均为某种类型
+(BOOL)allObjectsInArray:(NSArray *)array
             isKindClass:(NSString *)string
{
    for (id object in array) {
        BOOL result = [object isKindOfClass:NSClassFromString(string)];
        if (!result) {
            return NO;
        }
    }
    return YES;
}

#pragma mark ---animation代理---

-(void)animationDidStart:(CAAnimation *)anim
{
    self.status = DWAnimationStatusPlay;
    if (self.animationStart) {
        self.animationStart(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DWAnimationPlayStartNotification object:@{@"animation":self}];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.status = DWAnimationStatusFinished;
    if (self.completion) {
        self.completion(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DWAnimationPlayFinishNotification object:@{@"animation":self,@"finished":@(flag)}];
}

#pragma mark ---setter、getter---

-(void)setBeginTime:(CGFloat)beginTime
{
    [super setBeginTime:beginTime];
    self.duration = self.animation.duration * self.repeatCount + beginTime;
    self.animation.beginTime += beginTime;
}

-(void)setRepeatCount:(CGFloat)repeatCount
{
    _repeatCount = repeatCount;
    self.animation.repeatCount = repeatCount;
    self.duration = self.animation.duration * repeatCount + self.beginTime;
}

-(void)setTimingFunctionName:(NSString *)timingFunctionName
{
    _timingFunctionName = timingFunctionName;
    self.animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];
}
@end
