//
//  NSBundle+DWBundleUtils.m
//  a
//
//  Created by Wicky on 2017/5/6.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSBundle+DWBundleUtils.h"

@implementation NSBundle (DWBundleSourceUtils)
-(BOOL)canLoadSourceWithName:(NSString *)name ofType:(NSString *)type {
    return [self pathForResource:name ofType:type];
}

-(BOOL)canLoadNibWithName:(NSString *)name {
    return [self canLoadSourceWithName:name ofType:@"xib"];
}
@end
