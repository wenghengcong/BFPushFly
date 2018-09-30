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

#pragma mark - Env
/**
 证书选择
 */
@property (weak) IBOutlet NSPopUpButton *certificatePopup;

/**
 token选择
 */
@property (weak) IBOutlet NSComboBox *tokenCombo;

/**
 沙盒选择
 */
@property (weak) IBOutlet NSButton *sanboxCheckBox;

/**
 payload 输入框
 */
@property (unsafe_unretained) IBOutlet NSTextView *payloadField;

/**
 底部日志提示条
 */
@property (weak) IBOutlet NSTextField *infoField;

/**
 日志输出框，点击log
 */
@property (weak) IBOutlet NSScrollView *logScroll;
@property (unsafe_unretained) IBOutlet NSTextView *logField;

/**
 计数
 */
@property (weak) IBOutlet NSTextField *countField;

/**
 发送按钮
 */
@property (weak) IBOutlet NSButton *pushButton;

#pragma mark - Push
/**
 发送数目
 */
@property (weak) IBOutlet NSTextFieldCell *pushNumField;

/**
 重连按钮
 */
@property (weak) IBOutlet NSButton *reconnectButton;

/**
 过期时间
 */
@property (weak) IBOutlet NSPopUpButton *expiryPopup;

/**
 优先级
 */
@property (weak) IBOutlet NSPopUpButton *priorityPopup;


/**
 增加新模板
 */
@property (weak) IBOutlet NSButton *addTemplateButton;

/**
 保存当前模板
 */
@property (weak) IBOutlet NSButton *saveTemplateButton;


/**
 排序按钮
 */
@property (weak) IBOutlet NSPopUpButton *sortPop;

/**
 右键按钮
 */
@property (strong) IBOutlet NSMenu *templateRightMenu;


@end

