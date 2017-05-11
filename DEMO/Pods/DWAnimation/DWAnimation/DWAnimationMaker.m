//
//  DWAnimationMaker.m
//  DWHUD
//
//  Created by Wicky on 16/8/20.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWAnimationMaker.h"
@interface DWAnimationMaker ()

@property (nonatomic ,strong) NSMutableArray * animationsArray;

@property (nonatomic ,assign) CGPoint homePoint;
@property (nonatomic ,assign) CGPoint destinationPoint;
@property (nonatomic ,assign) CGFloat homeScale;
@property (nonatomic ,assign) CGFloat destinationScale;
@property (nonatomic ,assign) CGFloat homeAngle;
@property (nonatomic ,assign) CGFloat destinationAngle;
@property (nonatomic ,assign) Axis animationAxis;
@property (nonatomic ,assign) CGFloat homeAlpha;
@property (nonatomic ,assign) CGFloat destinationAlpha;
@property (nonatomic ,assign) CGFloat homeCornerR;
@property (nonatomic ,assign) CGFloat destinationCornerR;
@property (nonatomic ,assign) CGFloat homeBorderW;
@property (nonatomic ,assign) CGFloat destinationBorderW;
@property (nonatomic ,strong) UIColor * homeBorderColor;
@property (nonatomic ,strong) UIColor * destinationBorderColor;
@property (nonatomic ,strong) UIColor * homeShadowColor;
@property (nonatomic ,strong) UIColor * destinationShadowColor;
@property (nonatomic ,assign) CGSize homeShadowOffset;
@property (nonatomic ,assign) CGSize destinationShadowOffset;
@property (nonatomic ,assign) CGFloat homeShadowAlpha;
@property (nonatomic ,assign) CGFloat destinationShadowAlpha;
@property (nonatomic ,assign) CGFloat homeShadowRadius;
@property (nonatomic ,assign) CGFloat destinationShadowRadius;
@property (nonatomic ,strong) UIBezierPath * homeShadowPath;
@property (nonatomic ,strong) UIBezierPath * destinationShadowPath;
@property (nonatomic ,strong) UIImage * homeBgImage;
@property (nonatomic ,strong) UIImage * destinationBgImage;

@property (nonatomic ,strong) UIColor * homeBgColor;
@property (nonatomic ,strong) UIColor * destinationBgColor;

@property (nonatomic ,assign) CGFloat startTime;
@property (nonatomic ,assign) CGFloat animationDuration;

@property (nonatomic ,assign) BOOL move;
@property (nonatomic ,assign) BOOL scale;
@property (nonatomic ,assign) BOOL rotate;
@property (nonatomic ,assign) BOOL alpha;
@property (nonatomic ,assign) BOOL cornerR;
@property (nonatomic ,assign) BOOL borderW;
@property (nonatomic ,assign) BOOL borderC;
@property (nonatomic ,assign) BOOL shadowC;
@property (nonatomic ,assign) BOOL shadowO;
@property (nonatomic ,assign) BOOL shadowA;
@property (nonatomic ,assign) BOOL shadowR;
@property (nonatomic ,assign) BOOL shadowP;
@property (nonatomic ,assign) BOOL bgImage;
@property (nonatomic ,assign) BOOL bgColor;
@property (nonatomic ,assign) BOOL needReset;

@end

@implementation DWAnimationMaker

#pragma mark ---接口方法---

///生成组动画
-(void)make
{
    [self.animationsArray sortUsingComparator:^NSComparisonResult(CABasicAnimation * ani1, CABasicAnimation * ani2) {
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
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.duration = self.totalDuration;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.animations = self.animationsArray;
    group.repeatCount = 1;
    self.animation = group;
}

#pragma mark ---构造方法---

///初始化一些默认值
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.homePoint = CGPointNull;
        self.destinationPoint = CGPointNull;
        self.homeScale = MAXFLOAT;
        self.destinationScale = MAXFLOAT;
        self.homeAngle = MAXFLOAT;
        self.destinationAngle = MAXFLOAT;
        self.animationAxis = Z;
        self.homeAlpha = MAXFLOAT;
        self.destinationAlpha = MAXFLOAT;
        self.homeCornerR = MAXFLOAT;
        self.destinationCornerR = MAXFLOAT;
        self.homeBorderW = MAXFLOAT;
        self.destinationBorderW = MAXFLOAT;
        self.homeBorderColor = nil;
        self.destinationBorderColor = nil;
        self.homeShadowColor = nil;
        self.destinationShadowColor = nil;
        self.homeShadowOffset = CGSizeNull;
        self.destinationShadowOffset = CGSizeNull;
        self.homeShadowAlpha = MAXFLOAT;
        self.destinationShadowAlpha = MAXFLOAT;
        self.homeShadowRadius = MAXFLOAT;
        self.destinationShadowRadius = MAXFLOAT;
        self.homeShadowPath = nil;
        self.destinationShadowPath = nil;
        self.homeBgImage = UIImageNull;
        self.destinationBgImage = UIImageNull;
        self.homeBgColor = nil;
        self.destinationBgColor = nil;
    }
    return self;
}

#pragma mark ---中间block---

///创建不自动复原的animation实例
CABasicAnimation *(^CreateSimpleAnimation)(NSString *,CGFloat,CGFloat) = ^(NSString * key,CGFloat beginTime,CGFloat duration)
{
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:key];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAAnimationLinear];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.beginTime += beginTime;
    animation.duration = duration;
    return animation;
};

///创建移动类动画
CABasicAnimation *(^MoveAnimation)(CGPoint,CGPoint,CGFloat,CGFloat) = ^(CGPoint originalPoint ,CGPoint destinationPoint ,CGFloat beginTime ,CGFloat duration){
    CABasicAnimation * move = CreateSimpleAnimation(@"position",beginTime,duration);
    if(!CGPointIsNull(originalPoint))
    {
        move.fromValue = [NSValue valueWithCGPoint:originalPoint];
    }
    if(!CGPointIsNull(destinationPoint))
    {
        move.toValue = [NSValue valueWithCGPoint:destinationPoint];
    }
    return move;
};

///创建缩放类动画
CABasicAnimation *(^ScaleAnimation)(CGFloat,CGFloat,Axis,CGFloat,CGFloat) = ^(CGFloat originalScale ,CGFloat destinationScale,Axis scaleAxis,CGFloat beginTime,CGFloat duration){
    NSString * key = nil;
    switch (scaleAxis) {
        case X:
            key = @"transform.scale.x";
            break;
        case Y:
            key = @"transform.scale.y";
            break;
        case Z:
            key = @"transform.scale";
            break;
        default:
            key = @"transform.scale";
            break;
    }
    CABasicAnimation * scale = CreateSimpleAnimation(key,beginTime,duration);
    if(!CGFloatIsNull(originalScale)){
        scale.fromValue = @(originalScale);
    }
    if(!CGFloatIsNull(destinationScale))
    {
        scale.toValue = @(destinationScale);
    }
    return scale;
};

///创建旋转类动画
CABasicAnimation *(^RotateAnimation)(CGFloat,CGFloat,Axis,CGFloat,CGFloat) = ^(CGFloat originalAngle,CGFloat destinationAngle,Axis rotateAxis,CGFloat beginTime,CGFloat duration)
{
    NSString * key = nil;
    switch (rotateAxis) {
        case X:
            key = @"transform.rotation.x";
            break;
        case Y:
            key = @"transform.rotation.y";
            break;
        case Z:
            key = @"transform.rotation.z";
            break;
        default:
            key = @"transform.rotation.z";
            break;
    }
    CABasicAnimation * rotate = CreateSimpleAnimation(key,beginTime,duration);
    if(!CGFloatIsNull(originalAngle)){
        rotate.fromValue = @(RadianFromDegree(originalAngle));
    }
    if(!CGFloatIsNull(destinationAngle))
    {
        rotate.toValue = @(RadianFromDegree(destinationAngle));
    }
    return rotate;
};

///创建透明度动画
CABasicAnimation *(^AlphaAnimation)(CGFloat,CGFloat,CGFloat,CGFloat) = ^(CGFloat originalAlpha,CGFloat destinationAlpha,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * alpha = CreateSimpleAnimation(@"opacity",beginTime,duration);
    if(!CGFloatIsNull(originalAlpha) && (originalAlpha <= 1) && (originalAlpha >= 0)){
        alpha.fromValue = @(originalAlpha);
    }
    if(!CGFloatIsNull(destinationAlpha) && (destinationAlpha <= 1) && (destinationAlpha >= 0)){
        alpha.toValue = @(destinationAlpha);
    }
    return alpha;
};

///创建圆角动画
CABasicAnimation *(^CornerRadiusAnimation)(CGFloat,CGFloat,CGFloat,CGFloat) = ^(CGFloat originalCornerR,CGFloat destinationCornerR,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * cornerR = CreateSimpleAnimation(@"cornerRadius",beginTime,duration);
    if(!CGFloatIsNull(originalCornerR)){
        cornerR.fromValue = @(originalCornerR);
    }
    if(!CGFloatIsNull(destinationCornerR)){
        cornerR.toValue = @(destinationCornerR);
    }
    return cornerR;
};

///创建边框宽度动画
CABasicAnimation *(^BorderWidthAnimation)(CGFloat,CGFloat,CGFloat,CGFloat) = ^(CGFloat originalBorderWidth ,CGFloat destinationBorderWidth,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * borderW = CreateSimpleAnimation(@"borderWidth",beginTime,duration);
    if(!CGFloatIsNull(originalBorderWidth)){
        borderW.fromValue = @(originalBorderWidth);
    }
    if(!CGFloatIsNull(destinationBorderWidth))
    {
        borderW.toValue = @(destinationBorderWidth);
    }
    return borderW;
};

///创建边框颜色动画
CABasicAnimation *(^BorderColorAnimation)(UIColor *,UIColor *,CGFloat,CGFloat) = ^(UIColor * originalBorderColor ,UIColor * destinationBorderColor,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * borderC = CreateSimpleAnimation(@"borderColor",beginTime,duration);
    if(originalBorderColor){
        borderC.fromValue = (id)originalBorderColor.CGColor;
    }
    if(destinationBorderColor)
    {
        borderC.toValue = (id)destinationBorderColor.CGColor;
    }
    return borderC;
};

///创建阴影颜色动画
CABasicAnimation *(^ShadowColorAnimation)(UIColor *,UIColor *,CGFloat,CGFloat) = ^(UIColor * originalShadowColor ,UIColor * destinationShadowColor,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * shadowC = CreateSimpleAnimation(@"shadowColor",beginTime,duration);
    if(originalShadowColor){
        shadowC.fromValue = (id)originalShadowColor.CGColor;
    }
    if(destinationShadowColor)
    {
        shadowC.toValue = (id)destinationShadowColor.CGColor;
    }
    return shadowC;
};

///创建阴影偏移量动画
CABasicAnimation *(^ShadowOffsetAnimation)(CGSize,CGSize,CGFloat,CGFloat) = ^(CGSize originalShadowSize ,CGSize destinationShadowSize,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * shadowC = CreateSimpleAnimation(@"shadowOffset",beginTime,duration);
    if(!CGSizeIsNull(originalShadowSize)){
        shadowC.fromValue = [NSValue valueWithCGSize:originalShadowSize];
    }
    if(!CGSizeIsNull(destinationShadowSize))
    {
        shadowC.toValue = [NSValue valueWithCGSize:destinationShadowSize];
    }
    return shadowC;
};

///创建阴影透明度动画
CABasicAnimation *(^ShadowAlphaAnimation)(CGFloat,CGFloat,CGFloat,CGFloat) = ^(CGFloat originalShadowAlpha ,CGFloat destinationShadowAlpha,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * shadowAlpha = CreateSimpleAnimation(@"shadowOpacity",beginTime,duration);
    if(!CGFloatIsNull(originalShadowAlpha) && (originalShadowAlpha <= 1) && (originalShadowAlpha >= 0)){
        shadowAlpha.fromValue = @(originalShadowAlpha);
    }
    if(!CGFloatIsNull(destinationShadowAlpha) && (destinationShadowAlpha <= 1) && (destinationShadowAlpha >= 0)){
        shadowAlpha.toValue = @(destinationShadowAlpha);
    }
    return shadowAlpha;
};

///创建阴影圆角动画
CABasicAnimation *(^ShadowRadiusAnimation)(CGFloat,CGFloat,CGFloat,CGFloat) = ^(CGFloat originalShadowRadius,CGFloat destinationShadowRadius,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * shadowRadius = CreateSimpleAnimation(@"shadowRadius",beginTime,duration);
    if(!CGFloatIsNull(originalShadowRadius)){
        shadowRadius.fromValue = @(originalShadowRadius);
    }
    if(!CGFloatIsNull(destinationShadowRadius)){
        shadowRadius.toValue = @(destinationShadowRadius);
    }
    return shadowRadius;
};

///创建阴影路径动画
CABasicAnimation *(^ShadowPathAnimation)(CALayer *,UIBezierPath *,UIBezierPath *,CGFloat,CGFloat) = ^(CALayer * layer,UIBezierPath * originalShadowPath ,UIBezierPath * destinationShadowPath,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * shadowPath = CreateSimpleAnimation(@"shadowPath",beginTime,duration);
    if(originalShadowPath){
        shadowPath.fromValue = (id)originalShadowPath.CGPath;
    }
    else
    {
        shadowPath.fromValue = (id)UIBezierPathNull(layer.bounds.size.width,layer.bounds.size.height).CGPath;
    }
    if(destinationShadowPath)
    {
        shadowPath.toValue = (id)destinationShadowPath.CGPath;
    }
    else
    {
        shadowPath.toValue = (id)UIBezierPathNull(layer.bounds.size.width, layer.bounds.size.height).CGPath;
    }
    return shadowPath;
};

///创建阴影背景图动画
CABasicAnimation *(^BackgroundImageAnimation)(UIImage *,UIImage *,CGFloat,CGFloat) = ^(UIImage * originalBgImage ,UIImage * destinationBgImage,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * bgImage = CreateSimpleAnimation(@"contents",beginTime,duration);
    bgImage.fromValue = (id)originalBgImage.CGImage;
    bgImage.toValue = (id)destinationBgImage.CGImage;
    return bgImage;
};

///创建背景色动画
CABasicAnimation *(^BackgroundColorAnimation)(UIColor *,UIColor *,CGFloat,CGFloat) = ^(UIColor * originalBGColor,UIColor * destinationBGColor,CGFloat beginTime,CGFloat duration){
    CABasicAnimation * bgColor = CreateSimpleAnimation(@"backgroundColor",beginTime,duration);
    bgColor.fromValue = (id)originalBGColor.CGColor;
    bgColor.toValue = (id)destinationBGColor.CGColor;
    return bgColor;
};

#pragma mark ---工具block---

-(DWAnimationMaker *(^)(CGPoint))moveTo
{
    return ^(CGPoint destinationPoint){
        self.move = YES;
        self.destinationPoint = destinationPoint;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGPoint))moveFrom
{
    return ^(CGPoint homePoint){
        self.homePoint = homePoint;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))scaleTo
{
    return ^(CGFloat destinationScale){
        self.scale = YES;
        self.destinationScale = destinationScale;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))scaleFrom
{
    return ^(CGFloat homeScale){
        if (homeScale < 0) {
            homeScale = 0;
        }
        self.homeScale = homeScale;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))rotateTo
{
    return ^(CGFloat destinationAngle){
        self.rotate = YES;
        self.destinationAngle = destinationAngle;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))rotateFrom
{
    return ^(CGFloat homeAngle){
        self.homeAngle = homeAngle;
        return self;
    };
}

-(DWAnimationMaker *(^)(Axis))axis
{
    return ^(Axis rotateAxis){
        self.animationAxis = rotateAxis;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))alphaTo
{
    return ^(CGFloat destinationAlpha){
        self.alpha = YES;
        self.destinationAlpha = destinationAlpha;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))alphaFrom
{
    return ^(CGFloat homeAlpha){
        self.homeAlpha = homeAlpha;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))cornerRadiusTo
{
    return ^(CGFloat destinationCornerR){
        self.cornerR = YES;
        self.layer.masksToBounds = YES;
        self.destinationCornerR = destinationCornerR;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))cornerRadiusFrom
{
    return ^(CGFloat homeCornerR){
        self.homeCornerR = homeCornerR;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))borderWidthTo
{
    return ^(CGFloat destinationBorderW){
        self.borderW = YES;
        self.destinationBorderW = destinationBorderW;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))borderWidthFrom
{
    return ^(CGFloat homeBorderW){
        self.homeBorderW = homeBorderW;
        return self;
    };
}

-(DWAnimationMaker *(^)(UIColor *))borderColorTo
{
    return ^(UIColor * destinationBorderColor){
        self.borderC = YES;
        self.destinationBorderColor = destinationBorderColor;
        return self;
    };
}

-(DWAnimationMaker *(^)(UIColor *))borderColorFrom
{
    return ^(UIColor * homeBorderColor){
        self.homeBorderColor = homeBorderColor;
        return self;
    };
}

-(DWAnimationMaker *(^)(UIColor *))shadowColorTo
{
    return ^(UIColor * destinationShadowColor){
        self.shadowC = YES;
        self.destinationShadowColor = destinationShadowColor;
        return self;
    };
}

-(DWAnimationMaker *(^)(UIColor *))shadowColorFrom
{
    return ^(UIColor * homeShadowColor){
        self.homeShadowColor = homeShadowColor;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGSize))shadowOffsetTo
{
    return ^(CGSize destinationShadowOffset){
        self.shadowO = YES;
        if (CGFloatIsNull(self.destinationShadowAlpha)) {
            self.layer.shadowOpacity = 0.5;
        }
        self.destinationShadowOffset = destinationShadowOffset;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGSize))shadowOffsetFrom
{
    return ^(CGSize homeShadowOffset){
        self.homeShadowOffset = homeShadowOffset;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))shadowAlphaTo
{
    return ^(CGFloat destinationShadowAlpha){
        self.shadowA = YES;
        self.destinationShadowAlpha = destinationShadowAlpha;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))shadowAlphaFrom
{
    return ^(CGFloat homeShadowAlpha){
        self.homeShadowAlpha = homeShadowAlpha;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))shadowRadiusTo
{
    return ^(CGFloat destinationShadowRadius){
        self.shadowR = YES;
        self.destinationShadowRadius = destinationShadowRadius;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))shadowRadiusFrom
{
    return ^(CGFloat homeShadowRadius){
        self.homeShadowRadius = homeShadowRadius;
        return self;
    };
}

-(DWAnimationMaker *(^)(UIBezierPath *))shadowPathTo
{
    return ^(UIBezierPath * destinationShadowPath){
        self.shadowP = YES;
        self.destinationShadowPath = destinationShadowPath;
        return self;
    };
}

-(DWAnimationMaker *(^)(UIBezierPath *))shadowPathFrom
{
    return ^(UIBezierPath * homeShadowPath){
        self.homeShadowPath = homeShadowPath;
        return self;
    };
}

-(DWAnimationMaker *(^)(UIImage *))backgroundImageTo
{
    return ^(UIImage * destinationBgImage){
        self.bgImage = YES;
        if (destinationBgImage) {
            self.destinationBgImage = destinationBgImage;
        }
        return self;
    };
}

-(DWAnimationMaker *(^)(UIImage *))backgroundImageFrom
{
    return ^(UIImage * homeBgImage){
        if (homeBgImage) {
            self.homeBgImage = homeBgImage;
        }
        return self;
    };
}

-(DWAnimationMaker *(^)(UIColor *))backgroundColorTo
{
    return ^(UIColor * destinationBgColor){
        self.bgColor = YES;
        if (destinationBgColor) {
            self.destinationBgColor = destinationBgColor;
        }
        return self;
    };
}

-(DWAnimationMaker *(^)(UIColor *))backgroundColorFrom
{
    return ^(UIColor * homeBgColor){
        if (homeBgColor) {
            self.homeBgColor = homeBgColor;
        }
        return self;
    };
}

-(DWAnimationMaker *)reset
{
    self.needReset = YES;
    return self;
}

-(DWAnimationMaker *(^)(CGFloat))duration
{
    return ^(CGFloat duration){
        self.animationDuration = duration;
        return self;
    };
}

-(DWAnimationMaker *(^)(CGFloat))beginTime
{
    return ^(CGFloat beginTime){
        self.startTime = beginTime;
        return self;
    };
}

-(DWAnimationMaker *(^)())install
{
    return ^{
        if (self.needReset) {
            [self.animationsArray addObject:MoveAnimation(CGPointNull,self.layer.position,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:ScaleAnimation(MAXFLOAT,1,Z,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:RotateAnimation(MAXFLOAT,0,X,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:RotateAnimation(MAXFLOAT,0,Y,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:RotateAnimation(MAXFLOAT,0,Z,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:AlphaAnimation(MAXFLOAT,self.layer.opacity,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:CornerRadiusAnimation(MAXFLOAT,self.layer.cornerRadius,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:BorderWidthAnimation(MAXFLOAT,self.layer.borderWidth ,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:BorderColorAnimation(nil,[UIColor colorWithCGColor:self.layer.borderColor],self.startTime,self.animationDuration)];
            [self.animationsArray addObject:ShadowColorAnimation(nil,[UIColor colorWithCGColor:self.layer.shadowColor],self.startTime,self.animationDuration)];
            [self.animationsArray addObject:ShadowOffsetAnimation(CGSizeNull,self.layer.shadowOffset,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:ShadowAlphaAnimation(MAXFLOAT,self.layer.shadowOpacity,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:ShadowRadiusAnimation(MAXFLOAT,self.layer.shadowRadius,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:ShadowPathAnimation(self.layer,nil,self.layer.shadowPath?[UIBezierPath bezierPathWithCGPath:self.layer.shadowPath]:nil,self.startTime,self.animationDuration)];
            [self.animationsArray addObject:BackgroundImageAnimation(UIImageNull,[UIImage imageWithCGImage:(CGImageRef)self.layer.contents],self.startTime,self.animationDuration)];
            [self.animationsArray addObject:BackgroundColorAnimation(nil,[UIColor colorWithCGColor:self.layer.backgroundColor],self.startTime,self.animationDuration)];
            self.needReset = NO;
            [self resetMovePara];
            [self resetScalePara];
            [self resetRotatePara];
            [self resetAlphaPara];
            [self resetCornerRPara];
            [self resetBorderWPara];
            [self resetBorderCPara];
            [self resetShadowCPara];
            [self resetShadowOPara];
            [self resetShadowAPara];
            [self resetShadowRPara];
            [self resetShadowPPara];
            [self resetBgImagePara];
            [self resetBgColorPara];
        }
        if (self.move) {
            [self.animationsArray addObject:MoveAnimation(self.homePoint,self.destinationPoint,self.startTime,self.animationDuration)];
            [self resetMovePara];
        }
        if (self.scale) {
            [self.animationsArray addObject:ScaleAnimation(self.homeScale,self.destinationScale,self.animationAxis,self.startTime,self.animationDuration)];
            [self resetScalePara];
        }
        if (self.rotate) {
            [self.animationsArray addObject:RotateAnimation(self.homeAngle,self.destinationAngle,self.animationAxis,self.startTime,self.animationDuration)];
            [self resetRotatePara];
        }
        if (self.alpha) {
            [self.animationsArray addObject:AlphaAnimation(self.homeAlpha,self.destinationAlpha,self.startTime,self.animationDuration)];
            [self resetAlphaPara];
        }
        if (self.cornerR) {
            [self.animationsArray addObject:CornerRadiusAnimation(self.homeCornerR,self.destinationCornerR,self.startTime,self.animationDuration)];
            [self resetCornerRPara];
        }
        if (self.borderW) {
            [self.animationsArray addObject:BorderWidthAnimation(self.homeBorderW,self.destinationBorderW,self.startTime,self.animationDuration)];
            [self resetBorderWPara];
        }
        if (self.borderC) {
            [self.animationsArray addObject:BorderColorAnimation(self.homeBorderColor,self.destinationBorderColor,self.startTime,self.animationDuration)];
            [self resetBorderCPara];
        }
        if (self.shadowC) {
            [self.animationsArray addObject:ShadowColorAnimation(self.homeShadowColor,self.destinationShadowColor,self.startTime,self.animationDuration)];
            [self resetShadowCPara];
        }
        if (self.shadowO) {
            [self.animationsArray addObject:ShadowOffsetAnimation(self.homeShadowOffset,self.destinationShadowOffset,self.startTime,self.animationDuration)];
            [self resetShadowOPara];
        }
        if (self.shadowA) {
            [self.animationsArray addObject:ShadowAlphaAnimation(self.homeShadowAlpha,self.destinationShadowAlpha,self.startTime,self.animationDuration)];
            [self resetShadowAPara];
        }
        if (self.shadowR) {
            [self.animationsArray addObject:ShadowRadiusAnimation(self.homeShadowRadius,self.destinationShadowRadius,self.startTime,self.animationDuration)];
            [self resetShadowRPara];
        }
        if (self.shadowP) {
            [self.animationsArray addObject:ShadowPathAnimation(self.layer,self.homeShadowPath,self.destinationShadowPath,self.startTime,self.animationDuration)];
            [self resetShadowPPara];
        }
        if (self.bgImage) {
            [self.animationsArray addObject:BackgroundImageAnimation(self.homeBgImage,self.destinationBgImage,self.startTime,self.animationDuration)];
            [self resetBgImagePara];
        }
        if (self.bgColor) {
            [self.animationsArray addObject:BackgroundColorAnimation(self.homeBgColor,self.destinationBgColor,self.startTime,self.animationDuration)];
            [self resetBgColorPara];
        }
        self.totalDuration = MAX(self.totalDuration, self.startTime + self.animationDuration);
        self.startTime = 0;
        self.animationDuration = 0;
        return self;
    };
}

-(void)resetMovePara
{
    self.move = NO;
    self.homePoint = CGPointNull;
    self.destinationPoint = CGPointNull;
}

-(void)resetScalePara
{
    self.scale = NO;
    self.homeScale = MAXFLOAT;
    self.destinationScale = MAXFLOAT;
    if (!self.rotate) {
        self.animationAxis = Z;
    }
}

-(void)resetRotatePara
{
    self.rotate = NO;
    self.homeAngle = MAXFLOAT;
    self.destinationAngle = MAXFLOAT;
    if (!self.scale) {
        self.animationAxis = Z;
    }
}

-(void)resetAlphaPara
{
    self.alpha = NO;
    self.homeAlpha = MAXFLOAT;
    self.destinationAlpha = MAXFLOAT;
}

-(void)resetCornerRPara
{
    self.cornerR = NO;
    self.homeCornerR = MAXFLOAT;
    self.destinationCornerR = MAXFLOAT;
}

-(void)resetBorderWPara
{
    self.borderW = NO;
    self.homeBorderW = MAXFLOAT;
    self.destinationBorderW = MAXFLOAT;
}

-(void)resetBorderCPara
{
    self.borderC = NO;
    self.homeBorderColor = nil;
    self.destinationBorderColor = nil;
}

-(void)resetShadowCPara
{
    self.shadowC = NO;
    self.homeShadowColor = nil;
    self.destinationShadowColor = nil;
}

-(void)resetShadowOPara
{
    self.shadowO = NO;
    self.homeShadowOffset = CGSizeNull;
    self.destinationShadowOffset = CGSizeNull;
}

-(void)resetShadowAPara
{
    self.shadowA = NO;
    self.homeShadowAlpha = MAXFLOAT;
    self.destinationShadowAlpha = MAXFLOAT;
}

-(void)resetShadowRPara
{
    self.shadowR = NO;
    self.homeShadowRadius = MAXFLOAT;
    self.destinationShadowRadius = MAXFLOAT;
}

-(void)resetShadowPPara
{
    self.shadowP = NO;
    self.homeShadowPath = nil;
    self.destinationShadowPath = nil;
}

-(void)resetBgImagePara
{
    self.bgImage = NO;
    self.homeBgImage = UIImageNull;
    self.destinationBgImage = UIImageNull;
}

-(void)resetBgColorPara
{
    self.bgColor = NO;
    self.homeBgColor = nil;
    self.destinationBgColor = nil;
}
#pragma mark ---setter、getter---
-(NSMutableArray *)animationsArray
{
    if (!_animationsArray) {
        _animationsArray = [NSMutableArray array];
    }
    return _animationsArray;
}

@end
