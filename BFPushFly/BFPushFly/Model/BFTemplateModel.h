//
//  BFTemplateModel.h
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/21.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BFTemplateModelCreator) {
    BFTemplateModelCreatorUser = 0,
    BFTemplateModelCreatorSystem = 1,
};

@interface BFTemplateModel : NSObject<NSCopying>

@property (nonatomic, copy) NSString        *title;

@property (nonatomic, copy) NSString        *desc;

@property (nonatomic, assign) long long        createdTime;

@property (nonatomic, assign) long long        updatedTime;

@property (nonatomic, strong) NSAttributedString *payloadAttributedString;

@property (nonatomic, strong, nullable) NSData         *payloadData;

@property (nonatomic, assign) NSUInteger             version;

/**
 模板id
 */
@property (nonatomic, assign) NSUInteger             iden;

@property (nonatomic, assign) BFTemplateModelCreator     creator;

+ (BFTemplateModel *)modelWithDic: (NSDictionary *)dic;

- (BOOL)isDefautlTemplate;

@end

NS_ASSUME_NONNULL_END
