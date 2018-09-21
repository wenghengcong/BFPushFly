//
//  NSTemplateCellView.h
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/20.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFTemplateCellView : NSTableCellView

@property (weak) IBOutlet NSTextField *nameLabel;
@property (weak) IBOutlet NSTextField *descLabel;

@end

NS_ASSUME_NONNULL_END
