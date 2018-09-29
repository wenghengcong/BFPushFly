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
#import "PRHTask.h"
#import "GCDTask.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [BFTemplateFileManager createDefaultTemplate];
    [self doCommand];
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

- (void)doCommand
{
    //https://bitbucket.org/boredzo/prhtask/wiki/Home
    PRHTask *task = [PRHTask taskWithProgramName:@"ls" arguments:@"-l", nil];
    task.accumulatesStandardOutput = YES;
    
    task.successfulTerminationBlock = ^(PRHTask *completedTask) {
        NSLog(@"Completed task: %@ with exit status: %i", completedTask, completedTask.terminationStatus);
        NSLog(@"Accumulated output: %@", [task outputStringFromStandardOutputUTF8]);
    };
    task.abnormalTerminationBlock = ^(PRHTask *completedTask) {
        NSLog(@"Task exited abnormally: %@ with exit status: %i", completedTask, completedTask.terminationStatus);
    };
    
//    [task launch];
    
    GCDTask* pingTask = [[GCDTask alloc] init];
    //                [pingTask setArguments:@[@"-i", [[IPAInstallerHelper payloadExtractedPath] stringByAppendingPathComponent:appFile]]];
    [pingTask setLaunchPath:@"/bin/ls"];
    [pingTask setArguments:@[@"-l"]];
    
//    [pingTask setLaunchPath:@"ideviceinstaller"];
//    [pingTask setArguments:@[@"-l"]];

    [pingTask launchWithOutputBlock:^(NSData *stdOutData) {
        NSString* output = [[NSString alloc] initWithData:stdOutData encoding:NSUTF8StringEncoding];
        NSLog(@"OUT: %@", output);
        dispatch_async(dispatch_get_main_queue(), ^{
           
        });
    } andErrorBlock:^(NSData *stdErrData) {
        NSString* output = [[NSString alloc] initWithData:stdErrData encoding:NSUTF8StringEncoding];
        NSLog(@"ERR: %@", output);
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    } onLaunch:^{
        NSLog(@"Task has started running.");
    } onExit:^{
        NSLog(@"Task has now quit.");
    }];
}

@end
