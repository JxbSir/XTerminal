//
//  XTerminal.m
//  XTerminal
//
//  Created by Peter on 2019/10/31.
//Copyright © 2019 Peter. All rights reserved.
//

#import "XTerminal.h"
#import "TerminalController.h"
#import "NotificationController.h"
#import "CCPProject.h"
#import "PipeTask.h"

static XTerminal *sharedPlugin;

@interface XTerminal ()<NSUserNotificationCenterDelegate>

@property (nonatomic, strong) TerminalController*       terminalController;
@property (nonatomic, strong) NotificationController*   notificationController;

@property (nonatomic, strong) PipeTask* task;
@end

@implementation XTerminal

#pragma mark - Initialization

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    NSArray *allowedLoaders = [plugin objectForInfoDictionaryKey:@"me.delisa.XcodePluginBase.AllowedLoaders"];
    if ([allowedLoaders containsObject:[[NSBundle mainBundle] bundleIdentifier]]) {
        sharedPlugin = [[self alloc] initWithBundle:plugin];
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        _bundle = bundle;
        // NSApp may be nil if the plugin is loaded from the xcodebuild command line tool
        if (NSApp && !NSApp.mainMenu) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidFinishLaunching:)
                                                         name:NSApplicationDidFinishLaunchingNotification
                                                       object:nil];
            
        } else {
            [self initializeAndLog];
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [self initializeAndLog];
}

- (void)initializeAndLog
{
    NSString *name = [self.bundle objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *version = [self.bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *status = [self initialize] ? @"loaded successfully" : @"failed to load";
    NSLog(@"🔌 Plugin %@ %@ %@", name, version, status);
}

#pragma mark - Implementation

- (BOOL)initialize
{
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Window"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *appMenuItem = [[NSMenuItem alloc] initWithTitle:@"XTerminal" action:nil keyEquivalent:@""];
//        [actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [[menuItem submenu] addItem:appMenuItem];
        
        
        NSMenu* appSubmenu = [[NSMenu alloc] init];
        
        NSMenuItem* branchItem = [[NSMenuItem alloc] initWithTitle:@"Cat Branch" action:@selector(getCurrentBranch) keyEquivalent:@"b"];
        [branchItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        branchItem.target = self;
        [appSubmenu addItem:branchItem];

        [appSubmenu addItem:NSMenuItem.separatorItem];

        NSMenuItem* driveDataItem = [[NSMenuItem alloc] initWithTitle:@"Open DerivedData" action:@selector(openDriverData) keyEquivalent:@"d"];
        [driveDataItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        driveDataItem.target = self;
        [appSubmenu addItem:driveDataItem];
        
        NSMenuItem* openItermItem = [[NSMenuItem alloc] initWithTitle:@"Open iTerm2" action:@selector(openITerm2) keyEquivalent:@"i"];
        [openItermItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        openItermItem.target = self;
        [appSubmenu addItem:openItermItem];
        
        NSMenuItem* podfileItem = [[NSMenuItem alloc] initWithTitle:@"Open Podfile" action:@selector(openPodFile) keyEquivalent:@"p"];
        [podfileItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        podfileItem.target = self;
        [appSubmenu addItem:podfileItem];
        
        NSMenuItem* podlockItem = [[NSMenuItem alloc] initWithTitle:@"Open Podfile.lock" action:@selector(openPodFileLock) keyEquivalent:@"l"];
        [podlockItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        podlockItem.target = self;
        [appSubmenu addItem:podlockItem];
        
        NSMenuItem* projectDirItem = [[NSMenuItem alloc] initWithTitle:@"Open Project Directory" action:@selector(openProjectDir) keyEquivalent:@"j"];
        [projectDirItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        projectDirItem.target = self;
        [appSubmenu addItem:projectDirItem];
        
        NSMenuItem* gitWebItem = [[NSMenuItem alloc] initWithTitle:@"Open Git Webbrowser" action:@selector(openGitWebbrowser) keyEquivalent:@"g"];
        [gitWebItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        gitWebItem.target = self;
        [appSubmenu addItem:gitWebItem];

        NSMenuItem* openXterminalItem = [[NSMenuItem alloc] initWithTitle:@"Open XTerminal" action:@selector(openTerminalInXCode) keyEquivalent:@"t"];
        [openXterminalItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        openXterminalItem.target = self;
        [appSubmenu addItem:openXterminalItem];
        
        appMenuItem.submenu = appSubmenu;
        
        
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)getCurrentBranch {
    [self executeCommand:@"git branch" completion:^(NSString *text) {
        NSArray* branches = [text componentsSeparatedByString:@"\n"];
        __block NSString* branch;
        [branches enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:@"*"]) {
                branch = [[obj stringByReplacingOccurrencesOfString:@"*" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
        }];
        
        if (branch && branch.length > 0) {
            [self showNotification:branch];
        } else {
            [self showNotification:@"获取分支失败"];
        }
    }];
}

- (void)openTerminalInXCode {
    CCPProject* project = [CCPProject projectForKeyWindow];
    if (!project) {
        return;
    }
    NSString* path = project.directoryPath;
    _terminalController = [[TerminalController alloc] initWithProjectPath:path];
    [_terminalController.window makeKeyAndOrderFront:nil];
}

- (void)openITerm2 {
    [self executeCommand:@"open -a iTerm \"$pwd\"" completion:^(NSString *result) {
        
    }];
}

- (void)openPodFile {
    CCPProject* project = [CCPProject projectForKeyWindow];
    if (!project || !project.hasPodfile) {
        return;
    }
    [[NSWorkspace sharedWorkspace] openFile:project.podfilePath];
}

- (void)openPodFileLock {
    CCPProject* project = [CCPProject projectForKeyWindow];
    if (!project || !project.hasPodfile) {
        return;
    }
    NSString* path = [project.podfilePath stringByAppendingString:@".lock"];
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (void)openProjectDir {
    CCPProject* project = [CCPProject projectForKeyWindow];
    if (!project) {
        return;
    }
    
    [[NSWorkspace sharedWorkspace] openFile:project.directoryPath];
}

- (void)openDriverData {
    [self executeCommand:@"whoami" completion:^(NSString *result) {
        NSString* path = [NSString stringWithFormat:@"/Users/%@/Library/Developer/Xcode/DerivedData", [result stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet]];
        [[NSWorkspace sharedWorkspace] openFile:path];
    }];
}

- (void)openGitWebbrowser {
    [self executeCommand:@"git remote -v" completion:^(NSString *result) {
        NSArray* list = [result componentsSeparatedByString:@"\t"];
        if (list.count != 3) {
            [self showNotification:@"git remote is not exist"];
            return;
        }
        NSString* originUrl = list[1];
        BOOL isSSHUrl = [originUrl containsString:@"@"];
        if (isSSHUrl) {
            NSString* pattern = @"(?<=@).*?(?=.git)";
            NSRegularExpression* regular = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
            NSTextCheckingResult* result = [regular firstMatchInString:originUrl options:NSMatchingReportCompletion range:NSMakeRange(0, originUrl.length)];
            NSString* partialUrl = [originUrl substringWithRange:result.range];
            NSString* url = [NSString stringWithFormat:@"https://%@", [partialUrl stringByReplacingOccurrencesOfString:@":" withString:@"/"]];
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
        } else {
            NSString* url = originUrl;
            if ([originUrl containsString:@" "]) {
                url = [url componentsSeparatedByString:@" "][0];
            }
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
        }
    }];
}


#pragma mark - execute command
- (void)executeCommand:(NSString *)cmd completion:(void(^)(NSString *result))completion {
    CCPProject* project = [CCPProject projectForKeyWindow];
    if (!project) {
        return;
    }
    NSString* path = project.directoryPath;
    
    if (_task) {
        [_task cancel];
    }
    __weak typeof(self) wself = self;
    _task = [[PipeTask alloc] initWithRootPath:path];
    [_task execute:cmd completion:^(NSString * _Nonnull text) {
        completion(text);
    } finish:^{
        wself.task = nil;
    }];
}

#pragma mark - show notification
- (void)showNotification:(NSString *)text {
    
    _notificationController = [[NotificationController alloc] initWithInfo:text];
    [_notificationController.window makeKeyAndOrderFront:nil];
    [_notificationController.window center];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.notificationController.window close];
    });
}

#pragma mark - delegate
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return true;
}
@end
