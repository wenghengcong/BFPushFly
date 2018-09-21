//
//  ViewController.h
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/14.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BFPushViewController : NSViewController


@property (weak) IBOutlet NSTableView *templateTableView;

@property (weak) IBOutlet NSPopUpButton *certificatePopup;
@property (weak) IBOutlet NSComboBox *tokenCombo;
@property (unsafe_unretained) IBOutlet NSTextView *payloadField;

@property (weak) IBOutlet NSTextField *infoField;

@property (unsafe_unretained) IBOutlet NSTextView *logField;
@property (weak) IBOutlet NSTextField *countField;

@property (weak) IBOutlet NSButton *pushButton;
@property (weak) IBOutlet NSButton *reconnectButton;
@property (weak) IBOutlet NSPopUpButton *expiryPopup;

@property (weak) IBOutlet NSPopUpButton *priorityPopup;

@property (weak) IBOutlet NSScrollView *logScroll;
@property (weak) IBOutlet NSButton *sanboxCheckBox;

@property (weak) IBOutlet NSButton *addTemplateButton;
@property (weak) IBOutlet NSButton *saveTemplateButton;

@property (strong) IBOutlet NSMenu *templateRightMenu;

@end

