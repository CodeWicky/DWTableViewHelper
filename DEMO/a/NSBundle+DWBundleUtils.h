//
//  NSBundle+DWBundleUtils.h
//  a
//
//  Created by Wicky on 2017/5/6.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWBundleUtils
 NSBundle工具类，提供一些日常开发可能用到的方法
 
 */

#import <Foundation/Foundation.h>

@interface NSBundle (DWBundleSourceUtils)

///是否可以从本地加载指定资源
-(BOOL)canLoadSourceWithName:(NSString *)name ofType:(NSString *)type;

///是否可以从本地加载xib文件
-(BOOL)canLoadNibWithName:(NSString *)name;
@end
