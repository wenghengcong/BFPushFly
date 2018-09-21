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

#define BFTemplateFileUpdateSuccessful       @"BFTemplateFileUpdateSuccessful"

#define BFTemplateFileUpdateFial            @"BFTemplateFileUpdateSuccessful"

#define BFInputTokenList                   @"BFInputTokenList"


NS_ASSUME_NONNULL_BEGIN

@interface BFConst : NSObject

@end

NS_ASSUME_NONNULL_END
