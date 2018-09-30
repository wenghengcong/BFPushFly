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
    model.iden = [[dic objectForKey:@"id"] unsignedIntegerValue];
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
    model.iden = self.iden;
    model.creator = self.creator;
    return model;
}

- (BOOL)isEqual:(BFTemplateModel *)object {
    if (self == object) return YES;
    
    if (![self.title isEqual:object.title]) {
        return NO;
    }
    
    if (![self.desc isEqual:object.desc]) {
        return NO;
    }
    
    if (!(self.iden == object.iden)) {
        return NO;
    }
    
    if (!(self.version == object.version)) {
        return NO;
    }
    
    if (!(self.creator == object.creator)) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    // this is a very simple hash function
    NSString *createdTime = [NSString stringWithFormat:@"%lld", self.createdTime];
    NSString *version = [NSString stringWithFormat:@"%lu", (unsigned long)self.version];
    return [self.title hash] ^ [createdTime hash] ^ [version hash];
}

@end
