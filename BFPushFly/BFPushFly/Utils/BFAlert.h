//
//  BFAlert.h
//  BFPushFly
//
//  Created by WengHengcong on 2018/9/22.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFAlert : NSObject

+ (void)showAlertInWindow:(NSWindow *)window message: (NSString * __nullable)message info:(NSString * __nullable)info style: (NSAlertStyle)style  completionHandler:(void (^ __nullable)(NSModalResponse returnCode))handler;

+ (NSAlert *)alertWithmessage:(NSString * __nullable)message info:(NSString * __nullable)info style: (NSAlertStyle)style;
@end

NS_ASSUME_NONNULL_END
