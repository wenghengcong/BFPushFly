//
//  BFAlert.m
//  BFPushFly
//
//  Created by WengHengcong on 2018/9/22.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import "BFAlert.h"

@implementation BFAlert

+ (void)showAlertInWindow:(NSWindow *)window message: (NSString * __nullable)message info:(NSString * __nullable)info style: (NSAlertStyle)style  completionHandler:(void (^ __nullable)(NSModalResponse returnCode))handler
{
    NSAlert *alert = [[NSAlert alloc] init];
    if (message != nil) alert.messageText = message;
    if (info != nil) alert.informativeText = info;
    alert.alertStyle = style;
    [alert beginSheetModalForWindow:window completionHandler:handler];
}

+ (NSAlert *)alertWithmessage:(NSString * __nullable)message info:(NSString * __nullable)info style: (NSAlertStyle)style
{
    NSAlert *alert = [[NSAlert alloc] init];
    if (message != nil) alert.messageText = message;
    if (info != nil) alert.informativeText = info;
    alert.alertStyle = style;
    return alert;
}

@end
