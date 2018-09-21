//
//  ViewController.m
//  BFPushFly
//
//  Created by 翁恒丛 on 2018/9/14.
//  Copyright © 2018年 翁恒丛. All rights reserved.
//

#import "BFPushViewController.h"
#import "NWHub.h"
#import "NWLCore.h"
#import "NWNotification.h"
#import "NWPushFeedback.h"
#import "NWPusher.h"
#import "NWSSLConnection.h"
#import "NWSecTools.h"
#import "BFTemplateCellView.h"
#import "BFTemplateModel.h"
#import "BFTemplateFileManager.h"
#import "BFEditTemplateController.h"


@interface BFPushViewController() <NWHubDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>
{
    NWHub *_hub;
    NSDictionary *_tokenList;
    NSArray *_certificateIdentityPairs;
    NSUInteger _lastSelectedIndex;
    NWCertificateRef _selectedCertificate;\

    dispatch_queue_t _serial;
    
    NSArray<BFTemplateModel *> *_templateFiles;
    
    NSInteger           _selecteRow;
    BFTemplateModel     *_selctedTemplate;
    BFTemplateEditState _editState;
    BFTemplateModel     *_editTemplate;
}

@end

@implementation BFPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self observeTemplateDocumentFileChange];
    [self setupView];
    [self firstLoadData];
}

- (void)setupView
{
    [self setupTemplateTableView];

    // Do any additional setup after loading the view.
    NWLAddPrinter("NWPusher", NWPusherPrinter, 0);
    NWLPrintInfo();
    _serial = dispatch_queue_create("NWAppDelegate", DISPATCH_QUEUE_SERIAL);
    
    _certificateIdentityPairs = @[];
    [self loadCertificatesFromKeychain];
    [self updateCertificatePopup];

    NSString *payload = [_tokenList valueForKey:@"payload"];
    _payloadField.string = payload.length ? payload : @"";
    _payloadField.font = [NSFont fontWithName:@"Monaco" size:10];
    _payloadField.enabledTextCheckingTypes = 0;
    _payloadField.delegate = self;
    
    _logField.enabledTextCheckingTypes = 0;
    [self updatePayloadCounter];
    [self selectOutput:nil];
    NWLogInfo(@"");
    
    self.tokenCombo.window.identifier = BFPushTokenComboBoxIdentifier;
}

- (void)firstLoadData
{
    [self loadTokenList];

    _selecteRow = 0;
    [self loadTemplateFiles];
}

- (void)observeTemplateDocumentFileChange
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTemplateFiles) name:BFTemplateFileUpdateSuccessful object:nil];
}

#pragma mark - Action

- (IBAction)copyTemplate:(id)sender {
    NSInteger row = [_templateTableView clickedRow];
    BFTemplateModel *model = [_templateFiles objectAtIndex:row];
    [BFTemplateFileManager copyTemplate:model];
}

- (IBAction)addTemplateFile:(id)sender {
    _editState = BFTemplateEditStateCreated;
    [self performSegueWithIdentifier:@"Edit Template" sender:nil];
}

- (IBAction)saveTemplateFile:(id)sender {
    _selctedTemplate.payloadAttributedString = _payloadField.attributedString;
    [BFTemplateFileManager updateTemplate:_selctedTemplate];
}

- (IBAction)editTemplateFile:(id)sender {
    
    NSInteger row = [_templateTableView clickedRow];
    BFTemplateModel *model = [_templateFiles objectAtIndex:row];
    _editTemplate = model;

    _editState = BFTemplateEditStateEdited;
    [self performSegueWithIdentifier:@"Edit Template" sender:nil];
}

- (IBAction)deleteTemplateFile:(id)sender {
    NSInteger row = [_templateTableView clickedRow];
    BFTemplateModel *model = [_templateFiles objectAtIndex:row];
    [BFTemplateFileManager deleteTemplate: model];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Table view

- (void)didSelectedLastRow
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_selecteRow];
    [_templateTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    if (_selecteRow >= 0 && _selecteRow < _templateFiles.count) {
        _selctedTemplate = [_templateFiles objectAtIndex:_selecteRow];
        [[_payloadField textStorage] setAttributedString:_selctedTemplate.payloadAttributedString];
        [self updatePayloadCounter];
    }
}

- (void)loadTemplateFiles
{
    _templateFiles = [BFTemplateFileManager templates];
    [_templateTableView reloadData];
    [self didSelectedLastRow];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Edit Template"]) {
        BFEditTemplateController *editVC = (BFEditTemplateController *)segue.destinationController;
        editVC.editState = _editState;
        
        if (_editState == BFTemplateEditStateEdited) {
            editVC.templateModel = _editTemplate;
        }
    }
}

- (void)setupTemplateTableView
{
    _templateTableView.delegate = self;
    _templateTableView.dataSource = self;
    _templateTableView.action = @selector(didSelectedTableViewRow);
}

- (void)didSelectedTableViewRow
{
    _selecteRow = _templateTableView.selectedRow;
    
    if (_selecteRow >= 0 && _selecteRow < _templateFiles.count) {
        _selctedTemplate = [_templateFiles objectAtIndex:_selecteRow];
        [[_payloadField textStorage] setAttributedString:_selctedTemplate.payloadAttributedString];
        [self updatePayloadCounter];
    }
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _templateFiles.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString * cellIden = @"Template Cell";
    BFTemplateCellView *cell = [tableView makeViewWithIdentifier:cellIden owner:nil];

    if (row < [_templateFiles count]) {
        BFTemplateModel *model = [_templateFiles objectAtIndex:row];
        if (cell != nil) {
            cell.nameLabel.stringValue = model.title;
            cell.descLabel.stringValue = model.desc;
        }
    }
    return cell;
}


#pragma mark - Events

- (IBAction)certificateSelected:(NSPopUpButton *)sender
{
    [self connectWithCertificateAtIndex:_certificatePopup.indexOfSelectedItem];
}

- (void)textDidChange:(NSNotification *)notification
{
    if (notification.object == _payloadField) [self updatePayloadCounter];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    //    if (notification.object == _tokenCombo) [self something];
}

- (IBAction)push:(NSButton *)sender
{
    [self push];
    [self upPayloadTextIndex];
    [self saveTokenList];
}

- (IBAction)reconnect:(NSButton *)sender
{
    [self reconnect];
}

- (IBAction)sanboxCheckBoxDidPressed:(NSButton *)sender
{
    if (_selectedCertificate)
    {
        [self reconnect];
    }
}

- (void)notification:(NWNotification *)notification didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"failed notification: %@ %@ %lu %lu %lu", notification.payload, notification.token, notification.identifier, notification.expires, notification.priority);
        NWLogWarn(@"Notification error: %@", error.localizedDescription);
    });
}

- (IBAction)selectOutput:(NSSegmentedControl *)sender {
    _logScroll.hidden = sender.selectedSegment != 1;
    [self didSelectedLastRow];
}

- (IBAction)readFeedback:(id)sender {
    [self feedback];
}

#pragma mark - Token

- (IBAction)tokenSelected:(NSComboBox *)sender
{
    [self selectedTokenAndUpdateCombo];
}

- (void)selectedTokenAndUpdateCombo
{
    NSMutableArray *tokens = [self tokensWithCertificate:_selectedCertificate create:YES];
    if (tokens != nil && [tokens containsObject:_tokenCombo.stringValue]) {
        //包含当前token
        [self updateTokenCombo];
    }
}

- (NSMutableArray *)tokensWithCertificate:(NWCertificateRef)certificate create:(BOOL)create
{
    NSString *identifier = [self identifierWithCertificate:certificate];
    if (!identifier) return nil;
    NSArray *result = _tokenList[identifier];
    return (NSMutableArray *)result;
}

- (void)updateTokenCombo
{
    [_tokenCombo removeAllItems];
    NSArray *tokens = [self tokensWithCertificate:_selectedCertificate create:NO];
    if (tokens.count) [_tokenCombo addItemsWithObjectValues:tokens.reverseObjectEnumerator.allObjects];
}

- (void)loadSelectedToken
{
    _tokenCombo.stringValue = [[self tokensWithCertificate:_selectedCertificate create:YES] lastObject] ?: @"";
    // _tokenCombo.stringValue = @"552fff0a65b154eb209e9dc91201025da1a4a413dd2ad6d3b51e9b33b90c977a my iphone";
}

- (void)loadTokenList
{
    _tokenList = [[NSUserDefaults standardUserDefaults] objectForKey:BFInputTokenList];
    if (_tokenList == nil) {
        _tokenList = [NSDictionary dictionary];
    }
    NWLogInfo(@"Loaded config from %@", _tokenList);
}

- (void)saveTokenList
{
    if (_tokenCombo.stringValue == nil || _tokenCombo.stringValue.length == 0) {
        return;
    }
    
    NSMutableArray *tokens = [self tokensWithCertificate:_selectedCertificate create:YES];
    if (tokens != nil && [tokens containsObject:_tokenCombo.stringValue]) {
        return;
    }
    NSMutableDictionary *mutDic = [_tokenList mutableCopy];
    if (mutDic == nil) {
        mutDic = [NSMutableDictionary dictionary];
    }
    
    NSString *identifier = [self identifierWithCertificate:_selectedCertificate];
    if (!identifier) return;
    
    //原来token数组
    NSArray *originTokenArr = mutDic[identifier];
    //将要更改的数组
    NSMutableArray *currentArr = [originTokenArr mutableCopy];
    
    NSString *currentToken = _tokenCombo.stringValue;
    if (originTokenArr != nil && [originTokenArr isKindOfClass:[NSArray class]] && originTokenArr.count > 0) {
        if ([currentArr containsObject:currentToken]) {
            [currentArr removeObject:currentToken];
            [currentArr addObject:currentToken];
        } else {
            [currentArr addObject:currentToken];
        }
    } else {
        currentArr = [NSMutableArray array];
        [currentArr addObject:currentToken];
    }
    mutDic[identifier] = currentArr;
    _tokenList = mutDic;
    if (_tokenList.count) {
        [[NSUserDefaults standardUserDefaults] setObject:_tokenList forKey:BFInputTokenList];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self updateTokenCombo];
}


#pragma mark - Certificate and Identity

- (void)loadCertificatesFromKeychain
{
    NSError *error = nil;
    NSArray *certs = [NWSecTools keychainCertificatesWithError:&error];
    if (!certs) {
        NWLogWarn(@"Unable to access keychain: %@", error.localizedDescription);
    }
    if (!certs.count) {
        NWLogWarn(@"No push certificates in keychain.");
    }
    certs = [certs sortedArrayUsingComparator:^NSComparisonResult(NWCertificateRef a, NWCertificateRef b) {
        NWEnvironmentOptions envOptionsA = [NWSecTools environmentOptionsForCertificate:a];
        NWEnvironmentOptions envOptionsB = [NWSecTools environmentOptionsForCertificate:b];
        if (envOptionsA != envOptionsB) {
            return envOptionsA < envOptionsB;
        }
        NSString *aname = [NWSecTools summaryWithCertificate:a];
        NSString *bname = [NWSecTools summaryWithCertificate:b];
        return [aname compare:bname];
    }];
    NSMutableArray *pairs = @[].mutableCopy;
    for (NWCertificateRef c in certs) {
        [pairs addObject:@[c, NSNull.null]];
    }
    _certificateIdentityPairs = [_certificateIdentityPairs arrayByAddingObjectsFromArray:pairs];
}

- (void)updateCertificatePopup
{
    NSMutableString *suffix = @" ".mutableCopy;
    [_certificatePopup removeAllItems];
    [_certificatePopup addItemWithTitle:@"Select Push Certificate"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    for (NSArray *pair in _certificateIdentityPairs) {
        NWCertificateRef certificate = pair[0];
        BOOL hasIdentity = (pair[1] != NSNull.null);
        NWEnvironmentOptions environmentOptions = [NWSecTools environmentOptionsForCertificate:certificate];
        NSString *summary = nil;
        NWCertType certType = [NWSecTools typeWithCertificate:certificate summary:&summary];
        NSString *type = descriptionForCertType(certType);
        NSDate *date = [NWSecTools expirationWithCertificate:certificate];
        NSString *expire = [NSString stringWithFormat:@"  [%@]", date ? [formatter stringFromDate:date] : @"expired"];
        // summary = @"com.example.app";
        [_certificatePopup addItemWithTitle:[NSString stringWithFormat:@"%@%@ (%@ %@)%@%@", hasIdentity ? @"imported: " : @"", summary, type, descriptionForEnvironentOptions(environmentOptions), expire, suffix]];
        [suffix appendString:@" "];
    }
    [_certificatePopup addItemWithTitle:@"Import PKCS #12 file (.p12)..."];
}

- (void)importIdentity
{
    NWLogInfo(@"");
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = YES;
    panel.allowedFileTypes = @[@"p12"];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result != NSFileHandlingPanelOKButton) {
            return;
        }
        NSMutableArray *pairs = @[].mutableCopy;
        for (NSURL *url in panel.URLs) {
            NSString *text = [NSString stringWithFormat:@"Enter password for %@", url.lastPathComponent];
            NSAlert *alert = [NSAlert alertWithMessageText:text defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
            NSSecureTextField *input = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
            alert.accessoryView = input;
            NSInteger button = [alert runModal];
            if (button != NSAlertDefaultReturn) {
                return;
            }
            NSString *password = input.stringValue;
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSError *error = nil;
            NSArray *ids = [NWSecTools identitiesWithPKCS12Data:data password:password error:&error];
            if (!ids && password.length == 0 && error.code == kNWErrorPKCS12Password) {
                ids = [NWSecTools identitiesWithPKCS12Data:data password:nil error:&error];
            }
            if (!ids) {
                NWLogWarn(@"Unable to read p12 file: %@", error.localizedDescription);
                return;
            }
            for (NWIdentityRef identity in ids) {
                NSError *error = nil;
                NWCertificateRef certificate = [NWSecTools certificateWithIdentity:identity error:&error];
                if (!certificate) {
                    NWLogWarn(@"Unable to import p12 file: %@", error.localizedDescription);
                    return;
                }
                [pairs addObject:@[certificate, identity]];
            }
        }
        if (!pairs.count) {
            NWLogWarn(@"Unable to import p12 file: no push certificates found");
            return;
        }
        NWLogInfo(@"Imported %i certificate%@", (int)pairs.count, pairs.count == 1 ? @"" : @"s");
        NSUInteger index = _certificateIdentityPairs.count;
        _certificateIdentityPairs = [_certificateIdentityPairs arrayByAddingObjectsFromArray:pairs];
        [self updateCertificatePopup];
        [self connectWithCertificateAtIndex:index + 1];
        [self updateTokenCombo];
    }];
}

#pragma mark - Expiry and Priority

- (NSDate *)selectedExpiry
{
    switch(_expiryPopup.indexOfSelectedItem) {
        case 1: return [NSDate dateWithTimeIntervalSince1970:0];
        case 2: return [NSDate dateWithTimeIntervalSinceNow:60];
        case 3: return [NSDate dateWithTimeIntervalSince1970:300];
        case 4: return [NSDate dateWithTimeIntervalSinceNow:3600];
        case 5: return [NSDate dateWithTimeIntervalSinceNow:86400];
        case 6: return [NSDate dateWithTimeIntervalSince1970:1];
        case 7: return [NSDate dateWithTimeIntervalSince1970:UINT32_MAX];
    }
    return nil;
}

- (NSUInteger)selectedPriority
{
    switch(_priorityPopup.indexOfSelectedItem) {
        case 1: return 5;
        case 2: return 10;
    }
    return 0;
}

#pragma mark - Payload

- (void)updatePayloadCounter
{
    NSString *payload = _payloadField.string;
    BOOL isJSON = !![NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    _countField.stringValue = [NSString stringWithFormat:@"%@  %lu", isJSON ? @"" : @"malformed", payload.length];
    _countField.textColor = payload.length > 256 || !isJSON ? NSColor.redColor : NSColor.darkGrayColor;
}

- (void)upPayloadTextIndex
{
    NSString *payload = _payloadField.string;
    NSRange range = [payload rangeOfString:@"\\([0-9]+\\)" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        range.location += 1;
        range.length -= 2;
        NSString *before = [payload substringToIndex:range.location];
        NSUInteger value = [payload substringWithRange:range].integerValue + 1;
        NSString *after = [payload substringFromIndex:range.location + range.length];
        _payloadField.string = [NSString stringWithFormat:@"%@%lu%@", before, value, after];
    }
}

- (NWEnvironment)selectedEnvironmentForCertificate:(NWCertificateRef)certificate
{
    return (_sanboxCheckBox.state & NSOnState) ? NWEnvironmentSandbox : NWEnvironmentProduction;
}

- (NWEnvironment)preferredEnvironmentForCertificate:(NWCertificateRef)certificate
{
    NWEnvironmentOptions environmentOptions = [NWSecTools environmentOptionsForCertificate:certificate];
    
    return (environmentOptions & NWEnvironmentOptionSandbox) ? NWEnvironmentSandbox : NWEnvironmentProduction;
}

#pragma mark - Connection

- (void)connectWithCertificateAtIndex:(NSUInteger)index
{
    if (index == 0) {
        [_certificatePopup selectItemAtIndex:0];
        _lastSelectedIndex = 0;
        [self selectCertificate:nil identity:nil environment:NWEnvironmentSandbox];
        _tokenCombo.enabled = NO;
        [self loadSelectedToken];
    } else if (index <= _certificateIdentityPairs.count) {
        [_certificatePopup selectItemAtIndex:index];
        _lastSelectedIndex = index;
        NSArray *pair = [_certificateIdentityPairs objectAtIndex:index - 1];
        NWCertificateRef certificate = pair[0];
        NWIdentityRef identity = pair[1];
        _tokenCombo.enabled = YES;
        [self selectCertificate:certificate identity:identity == NSNull.null ? nil : identity  environment:[self preferredEnvironmentForCertificate:certificate]];
        [self loadSelectedToken];
    } else {
        [_certificatePopup selectItemAtIndex:_lastSelectedIndex];
        [self importIdentity];
    }
}

- (void)disableButtons
{
    _pushButton.enabled = NO;
    _reconnectButton.enabled = NO;
    _sanboxCheckBox.enabled = NO;
}

- (void)enableButtonsForCertificate:(NWCertificateRef)certificate environment:(NWEnvironment)environment
{
    NWEnvironmentOptions environmentOptions = [NWSecTools environmentOptionsForCertificate:certificate];
    
    BOOL shouldEnableEnvButton = (environmentOptions == NWEnvironmentOptionAny);
    BOOL shouldSelectSandboxEnv = (environment == NWEnvironmentSandbox);
    
    _pushButton.enabled = YES;
    _reconnectButton.enabled = YES;
    _sanboxCheckBox.enabled = shouldEnableEnvButton;
    _sanboxCheckBox.state = shouldSelectSandboxEnv ? NSOnState : NSOffState;
}

- (void)selectCertificate:(NWCertificateRef)certificate identity:(NWIdentityRef)identity environment:(NWEnvironment)environment
{
    if (_hub) {
        [_hub disconnect]; _hub = nil;
        
        [self disableButtons];
        NWLogInfo(@"Disconnected from APN");
    }
    
    _selectedCertificate = certificate;
    [self updateTokenCombo];

    if (certificate) {
        
        NSString *summary = [NWSecTools summaryWithCertificate:certificate];
        NWLogInfo(@"Connecting to APN...  (%@ %@)", summary, descriptionForEnvironent(environment));
        
        dispatch_async(_serial, ^{
            NSError *error = nil;
            NWIdentityRef ident = identity ?: [NWSecTools keychainIdentityWithCertificate:certificate error:&error];
            NWHub *hub = [NWHub connectWithDelegate:self identity:ident environment:environment error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (hub) {
                    NWLogInfo(@"Connected  (%@ %@)", summary, descriptionForEnvironent(environment));
                    _hub = hub;
                    
                    [self enableButtonsForCertificate:certificate environment:environment];
                } else {
                    NWLogWarn(@"Unable to connect: %@", error.localizedDescription);
                    [hub disconnect];
                    [_certificatePopup selectItemAtIndex:0];
                }
//                [self updateTokenCombo];
            });
        });
    }
}

- (void)reconnect
{
    NSString *summary = [NWSecTools summaryWithCertificate:_selectedCertificate];
    NWEnvironment environment = [self selectedEnvironmentForCertificate:_selectedCertificate];
    
    NWLogInfo(@"Reconnecting to APN...(%@ %@)", summary, descriptionForEnvironent(environment));
    
    [self selectCertificate:_selectedCertificate identity:nil  environment:environment];
}

- (void)push
{
    NSString *payload = _payloadField.string;
    NSString *token = _tokenCombo.stringValue;
    NSDate *expiry =  [self selectedExpiry];
    NSUInteger priority = [self selectedPriority];
    NWLogInfo(@"Pushing..");
    dispatch_async(_serial, ^{
        NWNotification *notification = [[NWNotification alloc] initWithPayload:payload token:token identifier:0 expiration:expiry priority:priority];
        NSError *error = nil;
        BOOL pushed = [_hub pushNotification:notification autoReconnect:YES error:&error];
        if (pushed) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
            dispatch_after(popTime, _serial, ^(void){
                NSError *error = nil;
                NWNotification *failed = nil;
                BOOL read = [_hub readFailed:&failed autoReconnect:YES error:&error];
                if (read) {
                    if (!failed) NWLogInfo(@"Payload has been pushed");
                } else {
                    NWLogWarn(@"Unable to read: %@", error.localizedDescription);
                }
                [_hub trimIdentifiers];
            });
        } else {
            NWLogWarn(@"Unable to push: %@", error.localizedDescription);
        }
    });
}

- (void)feedback
{
    dispatch_async(_serial, ^{
        NWCertificateRef certificate = _selectedCertificate;
        if (!certificate) {
            NWLogWarn(@"Unable to connect to feedback service: no certificate selected");
            return;
        }
        NWEnvironment environment = [self selectedEnvironmentForCertificate:certificate];
        NSString *summary = [NWSecTools summaryWithCertificate:certificate];
        NWLogInfo(@"Connecting to feedback service..  (%@ %@)", summary, descriptionForEnvironent(environment));
        NSError *error = nil;
        NWIdentityRef identity = [NWSecTools keychainIdentityWithCertificate:_selectedCertificate error:&error];
        NWPushFeedback *feedback = [NWPushFeedback connectWithIdentity:identity environment:[self selectedEnvironmentForCertificate:certificate] error:&error];
        if (!feedback) {
            NWLogWarn(@"Unable to connect to feedback service: %@", error.localizedDescription);
            return;
        }
        NWLogInfo(@"Reading feedback service..  (%@ %@)", summary, descriptionForEnvironent(environment));
        NSArray *pairs = [feedback readTokenDatePairsWithMax:1000 error:&error];
        if (!pairs) {
            NWLogWarn(@"Unable to read feedback: %@", error.localizedDescription);
            return;
        }
        for (NSArray *pair in pairs) {
            NWLogInfo(@"token: %@  date: %@", pair[0], pair[1]);
        }
        if (pairs.count) {
            NWLogInfo(@"Feedback service returned %i device tokens, see logs for details", (int)pairs.count);
        } else {
            NWLogInfo(@"Feedback service returned zero device tokens");
        }
    });
}

#pragma mark - Config

- (NSString *)identifierWithCertificate:(NWCertificateRef)certificate
{
    NWEnvironment environment = [self selectedEnvironmentForCertificate:_selectedCertificate];
    NSString *summary = [NWSecTools summaryWithCertificate:certificate];
    NSString *identifier = summary ? [NSString stringWithFormat:@"%@%@", summary, environment == NWEnvironmentSandbox ? @"-sandbox" : @""] : nil;
    return identifier;
}

#pragma mark - Logging

- (void)log:(NSString *)message warning:(BOOL)warning
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _infoField.textColor = warning ? NSColor.redColor : NSColor.blackColor;
        _infoField.stringValue = message;
        if (message.length) {
            NSDictionary *attributes = @{NSForegroundColorAttributeName: _infoField.textColor, NSFontAttributeName: [NSFont fontWithName:@"Monaco" size:10]};
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:message attributes:attributes];
            [_logField.textStorage appendAttributedString:string];
            [_logField.textStorage.mutableString appendString:@"\n"];
            [_logField scrollRangeToVisible:NSMakeRange(_logField.textStorage.length - 1, 1)];
        }
    });
}

static void NWPusherPrinter(NWLContext context, CFStringRef message, void *info) {
    BOOL warning = context.tag && strncmp(context.tag, "warn", 5) == 0;
    BFPushViewController *pushVc = (BFPushViewController *) [NSApplication.sharedApplication.keyWindow contentViewController];
    [pushVc log:(__bridge NSString *)message warning:warning];
}
@end
