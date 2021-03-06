//
//  AppDelegate.m
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/14.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//
#import "AppDelegate.h"
#import "BFConst.h"
#import "BFTemplateFileManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [BFTemplateFileManager createDefaultTemplate];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    for (NSWindow *window in sender.windows) {
        if ([[window className] isEqualToString:@"NSComboBoxWindow"]) {
            NSLog(@"BFPushTokenComboBoxIdentifier window don't open");
        } else {
            [window makeKeyAndOrderFront:self];
        }
    }
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return NO;
}

@end
