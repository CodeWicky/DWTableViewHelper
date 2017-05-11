//
//  DWAnimationConstant.h
//  DWAnimation
//
//  Created by Wicky on 16/10/27.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#ifndef DWAnimationConstant_h
#define DWAnimationConstant_h

typedef NS_ENUM(NSInteger , Axis) {
    Z = 0,///z轴为旋转轴
    X,///x轴为旋转轴
    Y///y轴为旋转轴
};

typedef NS_ENUM(NSInteger , DWAnimationPlayMode) {
    DWAnimationPlayModeMulti,///不同view分线处理
    DWAnimationPlayModeSingle///不区分view，按数组顺序播放
};

typedef NS_ENUM(NSInteger , DWAnimationType) {
    DWAnimationTypeMove,///移动动画
    DWAnimationTypeScale,///缩放动画
    DWAnimationTypeRotate,///旋转动画
    DWAnimationTypeAlpha,///透明度动画
    DWAnimationTypeCornerRadius,///圆角动画
    DWAnimationTypeBorderWidth,///边框宽度动画
    DWAnimationTypeBorderColor,///边框颜色动画
    DWAnimationTypeShadowColor,///阴影颜色动画
    DWAnimationTypeShadowOffset,///阴影偏移量动画
    DWAnimationTypeShadowAlpha,///阴影透明度动画
    DWAnimationTypeShadowCornerRadius,///阴影圆角动画
    DWAnimationTypeShadowPath,///阴影路径动画
    DWAnimationTypeBackgroundImage,///背景图动画
    DWAnimationTypeBackgroundColor///背景色动画
};

typedef NS_ENUM(NSInteger ,DWAnimationSpringType) {
    DWAnimationSpringTypeMove,///移动震荡动画
    DWAnimationSpringTypeScale,///缩放震荡动画
    DWAnimationSpringTypeRotate,///旋转震荡动画
    DWAnimationSpringTypeAlpha,///透明度震荡动画
    DWAnimationSpringTypeCornerRadius,///圆角震荡动画
    DWAnimationSpringTypeBorderWidth,///边框宽度震荡动画
    DWAnimationSpringTypeBorderColor,///边框颜色震荡动画
    DWAnimationSpringTypeShadowColor,///阴影颜色震荡动画
    DWAnimationSpringTypeShadowOffset,///阴影偏移量震荡动画
    DWAnimationSpringTypeShadowAlpha,///阴影透明度震荡动画
    DWAnimationSpringTypeShadowCornerRadius,///阴影圆角震荡动画
    DWAnimationSpringTypeShadowPath,///阴影路径震荡动画
    DWAnimationSpringTypeBackgroundImage,///背景图震荡动画
    DWAnimationSpringTypeBackgroundColor///背景色震荡动画
};

typedef NS_ENUM(NSInteger ,DWAnimationStatus) {
    DWAnimationStatusReadyToShow,///具备播放条件状态
    DWAnimationStatusPlay,///播放状态
    DWAnimationStatusSuspend,///暂停状态
    DWAnimationStatusFinished,///播放完成状态
    DWAnimationStatusRemoved///移除状态
};

///动画播放完成通知
#define DWAnimationPlayFinishNotification @"DWAnimationPlayFinishNotification"

///动画播放开始通知
#define DWAnimationPlayStartNotification @"DWAnimationPlayStartNotification"

///未经初始化的CGPoint
#define CGPointNull CGPointMake(MAXFLOAT, MAXFLOAT)

///是否为未经初始化的CGPoint
#define CGPointIsNull(x) CGPointEqualToPoint(CGPointNull,x)

///返回CGPoint类型的NSValue
#define PointValue(x,y) [NSValue valueWithCGPoint:CGPointMake(x, y)]

///是否为未经初始化的CGFloat
#define CGFloatIsNull(x) (x == MAXFLOAT)

///未经初始化的CGSize
#define CGSizeNull CGSizeMake(MAXFLOAT, MAXFLOAT)

///是否为未经初始化的CGSize
#define CGSizeIsNull(x) CGSizeEqualToSize(x, CGSizeNull)

///返回CGSize类型的NSValue
#define SizeValue(w,h) [NSValue valueWithCGSize:CGSizeMake(w, h)]

///角度转换成弧度
#define RadianFromDegree(x) ((x) * M_PI / 180.0)

///未经初始化的阴影路径
#define UIBezierPathNull(width,height) [UIBezierPath bezierPathWithRect:CGRectMake(0, -3,width,height)]

///未经初始化的图片
#define UIImageNull  \
({\
CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);\
UIGraphicsBeginImageContext(rect.size);\
CGContextRef context = UIGraphicsGetCurrentContext();\
\
CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);\
CGContextFillRect(context, rect);\
\
UIImage *image = UIGraphicsGetImageFromCurrentImageContext();\
UIGraphicsEndImageContext();\
\
image;\
})\

///判断版本是否在某版本之上
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:[NSString stringWithFormat:@"%f",v] options:NSNumericSearch] != NSOrderedAscending)

#endif /* DWAnimationConstant_h */
