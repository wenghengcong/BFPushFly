//
//  BFConst.h
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/21.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>


typedef NS_ENUM(NSUInteger, BFTemplateEditState) {
    BFTemplateEditStateCreated = 0,
    BFTemplateEditStateEdited = 1,
};

#pragma mark - Noti

#define BFTemplateFileUpdateSuccessful                @"BFTemplateFileUpdateSuccessful"
#define BFTemplateFileUpdateFial                       @"BFTemplateFileUpdateSuccessful"
#define BFTemplateEditDone                             @"BFTemplateEditDone"

#pragma mark - save key

#define BFInputTokenList                                 @"BFInputTokenList"
#define BFSaveDefaultTemplateFileCount                @"BFSaveDefaultTemplateFileCount"
#define BFDefaultTempateFileName                      @"defaultTemplate_beefun_luci"

#pragma mark - shortcut
#define NSLocalizedFormatString(fmt, ...)    [NSString stringWithFormat:NSLocalizedString(fmt, nil), __VA_ARGS__]

NS_ASSUME_NONNULL_BEGIN

@interface BFConst : NSObject

@end

NS_ASSUME_NONNULL_END
