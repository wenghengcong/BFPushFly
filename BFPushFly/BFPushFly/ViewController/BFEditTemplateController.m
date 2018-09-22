//
//  TemplateFileController.m
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/20.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import "BFEditTemplateController.h"
#import "BFTemplateModel.h"
#import "BFTemplateFileManager.h"
#import "BFAlert.h"

@interface BFEditTemplateController ()<NSTextFieldDelegate>
{
    BFTemplateModel *_orignalTemplateModel;
}

@end

@implementation BFEditTemplateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self setupView];
}

- (void)setupView
{
    _payloadTextField.font = [NSFont fontWithName:@"Monaco" size:10];
    _payloadTextField.enabledTextCheckingTypes = 0;
    _payloadTextField.delegate = self;
    
    if (_editState == BFTemplateEditStateEdited) {
        _orignalTemplateModel = [_templateModel copy];
        _titleTextField.stringValue = _templateModel.title;
        _descTextField.stringValue = _templateModel.desc;
        [[_payloadTextField textStorage] setAttributedString:_templateModel.payloadAttributedString];
    }
}


- (IBAction)dismissPage:(id)sender {
    [self dismissViewController:self];
}

- (IBAction)saveTemplate:(id)sender {
    
    if (![self checkCorrectBeforeSave]) {
        return;
    }
    long long currentTime =  ([[NSDate date] timeIntervalSince1970] * 1000);

    if (_templateModel == nil) {
        _templateModel = [[BFTemplateModel alloc] init];
    }

    _templateModel.title = _titleTextField.stringValue;
    _templateModel.desc = _descTextField.stringValue;
    
    _templateModel.creator = BFTemplateModelCreatorUser;
    _templateModel.version = 1;
    
    if (_editState == BFTemplateEditStateCreated) {
        _templateModel.createdTime = currentTime;
        _templateModel.updatedTime = currentTime;
    }
    if (_editState == BFTemplateEditStateEdited) {
        _templateModel.updatedTime = currentTime;
    }
    _templateModel.payloadAttributedString = _payloadTextField.attributedString;
    
    BOOL didWriteToFile = NO;
    if (_editState == BFTemplateEditStateEdited) {
        didWriteToFile = [BFTemplateFileManager updateTemplate: _templateModel];
    } else {
        didWriteToFile = [BFTemplateFileManager insertTempate: _templateModel];
    }
    
    if (didWriteToFile) {
        NSLog(@"成功保存推送模板文件！");
        if (_editState == BFTemplateEditStateEdited) {
            if (![_orignalTemplateModel.title isEqualToString:_templateModel.title]) {
                //title不一样
                [BFTemplateFileManager deleteTemplate:_orignalTemplateModel];
            }
        }
        [self dismissViewController:self];
    } else {
        NSLog(@"保存失败");
        [BFAlert showAlertInWindow:self.view.window message:NSLocalizedString(@"Save failure", nil) info:NSLocalizedString(@"File system error,Please try aggin", nil) style:NSWarningAlertStyle completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
}

#pragma mark - Utils

- (BOOL)checkCorrectBeforeSave
{
    NSString *title = _titleTextField.stringValue;
    if (title == nil || title.length == 0) {
        [BFAlert showAlertInWindow:self.view.window message:NSLocalizedString(@"Save failure", nil)  info:NSLocalizedString(@"Title can't empty", nil) style:NSWarningAlertStyle completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return NO;
    }
    NSString *payload = _payloadTextField.string;
    BOOL isJSON = !![NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if (!isJSON) {
        [BFAlert showAlertInWindow:self.view.window message:NSLocalizedString(@"Save failure", nil) info:NSLocalizedString(@"Payload is empty or malformed, chek it", nil) style:NSWarningAlertStyle completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return NO;
    }
    return YES;
}

- (void)textDidChange:(NSNotification *)notification
{
    if (notification.object == _payloadTextField) [self updatePayloadCounter];
}

- (void)updatePayloadCounter
{
    NSString *payload = _payloadTextField.string;
    BOOL isJSON = !![NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    _countLabel.stringValue = [NSString stringWithFormat:@"%@  %lu", isJSON ? @"" : NSLocalizedString(@"malformed", nil) , payload.length];
    _countLabel.textColor = payload.length > 256 || !isJSON ? NSColor.redColor : NSColor.darkGrayColor;
}

@end
