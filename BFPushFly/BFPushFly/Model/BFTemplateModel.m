//
//  BFTemplateModel.m
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/21.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import "BFTemplateModel.h"


@implementation BFTemplateModel


+ (BFTemplateModel *)modelWithDic: (NSDictionary *)dic
{
    if (dic==nil || [dic allKeys].count == 0) return nil;
    
    BFTemplateModel *model = [[BFTemplateModel alloc] init];
    model.title = [dic objectForKey:@"title"];
    model.desc = [dic objectForKey:@"description"];
    model.createdTime = [[dic objectForKey:@"created_time"] longLongValue];
    model.updatedTime = [[dic objectForKey:@"updated_time"] longLongValue];
    model.payloadData = [dic objectForKey:@"payload"];
    model.payloadAttributedString = [NSKeyedUnarchiver unarchiveObjectWithData: model.payloadData];
    model.version = [[dic objectForKey:@"version"] unsignedIntegerValue];
    model.creator = [[dic objectForKey:@"creator"] integerValue];
    return model;
}

- (BOOL)isDefautlTemplate
{
    return self.creator == BFTemplateModelCreatorSystem;
}

- (id)copyWithZone:(NSZone *)zone
{
    BFTemplateModel *model = [[BFTemplateModel alloc] init];
    model.title = self.title;
    model.desc = self.desc;
    model.createdTime = self.createdTime;
    model.updatedTime = self.updatedTime;
    model.payloadData = self.payloadData;
    model.payloadAttributedString = self.payloadAttributedString;
    model.version = self.version;
    model.creator = self.creator;
    return model;
}

@end
