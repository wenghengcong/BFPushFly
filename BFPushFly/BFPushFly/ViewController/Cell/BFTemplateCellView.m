//
//  NSTemplateCellView.m
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/20.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import "BFTemplateCellView.h"

@implementation BFTemplateCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    if (backgroundStyle == NSBackgroundStyleDark) {
        _nameLabel.textColor = NSColor.whiteColor;
        _descLabel.textColor = NSColor.whiteColor;
        _IDLabel.textColor = NSColor.whiteColor;
    } else if (backgroundStyle == NSBackgroundStyleLight) {
        _IDLabel.textColor = [NSColor colorWithRed:52.0/255.0 green:125.0/255.0 blue:236.0/255.0 alpha:1.0];
        _nameLabel.textColor = NSColor.blackColor;
        _descLabel.textColor = [NSColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)setWithModel:(BFTemplateModel *)model
{
    self.nameLabel.stringValue = model.title;
    self.descLabel.stringValue = model.desc;
    self.IDLabel.stringValue = [NSString stringWithFormat:@"%lu", (unsigned long)model.iden];
}

@end
