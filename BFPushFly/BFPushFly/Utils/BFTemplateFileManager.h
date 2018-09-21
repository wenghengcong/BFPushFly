//
//  BFTemplateFileManager.h
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/21.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFTemplateModel.h"
#import "BFConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFTemplateFileManager : NSObject

//+ (instancetype)defaultManager;

+ (void)createDefaultTemplate;

+ (NSArray <BFTemplateModel *> *)templates;

+ (BOOL)copyTemplate:(BFTemplateModel *)model;

+ (BOOL)updateTemplate:(BFTemplateModel *)model;

+ (BOOL)deleteTemplate:(BFTemplateModel *)model;

+ (BOOL)insertTempate:(BFTemplateModel *)model;

+ (NSURL *)templateDirectoryURL;
+ (NSString *)templateDirectoryPath;

@end

NS_ASSUME_NONNULL_END
