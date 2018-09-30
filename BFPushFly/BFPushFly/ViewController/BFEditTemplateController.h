//
//  TemplateFileController.h
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/20.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BFConst.h"

@class BFTemplateModel;

NS_ASSUME_NONNULL_BEGIN

@interface BFEditTemplateController : NSViewController

@property (weak) IBOutlet NSTextField *titleTextField;

@property (weak) IBOutlet NSTextField *descTextField;

@property (weak) IBOutlet NSTextField *idenTextField;


@property (unsafe_unretained) IBOutlet NSTextView *payloadTextField;

@property (weak) IBOutlet NSTextField *countLabel;

@property (nonatomic, assign) BFTemplateEditState editState;

@property (nonatomic, strong) BFTemplateModel *templateModel;

@end

NS_ASSUME_NONNULL_END
