//
//  ExceptionHanlder.m
//  CoreUtil
//
//  Created by yuki on 2021/06/26.
//  Copyright © 2021 yuki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExceptionHanlder.h>

@implementation _ExceptionHandler : NSObject 
+ (void)objc_try: (nonnull __attribute__((noescape)) void(^)(void)) objc_try
      objc_catch: (nonnull __attribute__((noescape)) void(^)(NSException* _Nonnull)) objc_catch
    objc_finally: (nullable __attribute__((noescape)) void(^)(void)) objc_finally {
    @try {
        objc_try();
    } @catch (NSException* exception) {
        objc_catch(exception);
    } @finally {
        if (objc_finally) { objc_finally(); }
    }
}
@end

