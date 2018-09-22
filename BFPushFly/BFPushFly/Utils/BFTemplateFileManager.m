//
//  BFTemplateFileManager.m
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/21.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import "BFTemplateFileManager.h"

static NSString *templateDirectoryPathComponet = @"template";

@interface BFTemplateFileManager()

@end

@implementation BFTemplateFileManager

+ (instancetype)defaultManager
{
    static BFTemplateFileManager * shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

+ (void)createDefaultTemplate
{
    NSFileManager *fileM = [NSFileManager defaultManager];
    NSString * defaultTemplatePath = [[NSBundle mainBundle] pathForResource:@"defaultTemplate" ofType:@"plist"];
    NSString * desPath = [[self templateDirectoryPath] stringByAppendingPathComponent:@"defaultTemplate_beefun_luci.plist"];
    if ([fileM fileExistsAtPath:desPath]) {
        return;
    }

    NSError *error;
    if(![fileM copyItemAtPath:defaultTemplatePath toPath:desPath error:&error]) {
        // handle the error
        NSLog(@"Error creating the database: %@", [error description]);
    } else {
        [self postNotification:YES];
    }
}

+ (NSArray <BFTemplateModel *> *)templates
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension == 'plist'"];
    NSArray *plistPaths = [[[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self templateDirectoryURL] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil] filteredArrayUsingPredicate:predicate];
    NSMutableArray *templateModels = [NSMutableArray array];
    if (plistPaths != nil &&  plistPaths.count > 0 ) {
        for (NSURL *url in plistPaths) {
            if (url != nil) {
                NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile: [url path]];
                BFTemplateModel *model = [BFTemplateModel modelWithDic: plistDic];
                if (model != nil) {
                    if ([url.path containsString:@"defaultTemplate_beefun_luci"]) {
                        [templateModels insertObject:model atIndex:0];
                    } else {
                        [templateModels addObject:model];
                    }
                }
            }
        }
    }
    return templateModels;
}

+ (BOOL)copyTemplate:(BFTemplateModel *)model
{
    long long currentTime =  ([[NSDate date] timeIntervalSince1970] * 1000);
    model.createdTime = currentTime;
    return [self insertTempate:model];
}

+ (BOOL)updateTemplate:(BFTemplateModel *)model
{
    model.payloadData = nil;
    long long currentTime =  ([[NSDate date] timeIntervalSince1970] * 1000);
    model.updatedTime = currentTime;
    return [self insertTempate:model];
}

+ (BOOL)deleteTemplate:(BFTemplateModel *)model
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *path = [self templatePlistFilePath:model];
    if([fileManager fileExistsAtPath:path]) {
        BOOL didRemove = [fileManager removeItemAtPath:path error:nil];
        [self postNotification:didRemove];
        return didRemove;
    }
    return NO;
}

+ (BOOL)insertTempate:(BFTemplateModel *)model
{
    if (model ==  nil || model.createdTime <= 0.1) {
        return NO;
    }
    
    NSMutableDictionary *saveDic = [NSMutableDictionary dictionary];

    [saveDic setObject:model.title forKey:@"title"];
    [saveDic setObject:model.desc forKey:@"description"];
    
    [saveDic setObject:@(model.version) forKey:@"vserion"];
    [saveDic setObject:@(model.creator) forKey:@"creator"];
    if (model.createdTime >= 0.01) {
        [saveDic setObject:@(model.createdTime) forKey:@"created_time" ];
    }
    if (model.updatedTime >= 0.01) {
        [saveDic setObject:@(model.updatedTime) forKey:@"updated_time" ];
    }
    if (model.payloadData != nil) {
        //no change
        
    } else if (model.payloadAttributedString != nil) {
        NSData *payloadData = [NSKeyedArchiver archivedDataWithRootObject: model.payloadAttributedString];
        model.payloadData = payloadData;
    }
    [saveDic setObject:model.payloadData forKey:@"payload"];
    
    BOOL didWriteToFile = [saveDic writeToFile:[self templatePlistFilePath:model] atomically:YES];
    [self postNotification:didWriteToFile];
    
    return didWriteToFile;

}

#pragma mark - Path

+ (NSString *)templatePlistFilePath: (BFTemplateModel *)model
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *templatePlistsPath = [[paths objectAtIndex:0] stringByAppendingString:@"/template/"];
    
    if(![fileManager fileExistsAtPath:templatePlistsPath]) {
        [fileManager createDirectoryAtPath:templatePlistsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *plistPath = [templatePlistsPath stringByAppendingPathComponent: [self templatePlistFileName:model]];
    return plistPath;
}

+ (NSString *)templatePlistFileName: (BFTemplateModel *)model
{
    NSString *plistName = [NSString stringWithFormat:@"%@_%lld.plist", model.title, model.createdTime];;
    return plistName;
}

+ (NSURL *)templateDirectoryURL
{
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsPath = [paths objectAtIndex:0];
    NSString *tempateDirectoryCom = [NSString stringWithFormat:@"%@/", templateDirectoryPathComponet];
    NSURL *templatePath = [documentsPath URLByAppendingPathComponent:tempateDirectoryCom];
    return templatePath;
}

+ (NSString *)templateDirectoryPath
{
    return [[self templateDirectoryURL] path];
}

#pragma mark - Noti

+ (void)postNotification: (BOOL)successful
{
    if (successful) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BFTemplateFileUpdateSuccessful object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:BFTemplateFileUpdateFial object:nil];
    }
}


@end
