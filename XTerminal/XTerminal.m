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
       
        NSMenuItem* bItem = [[NSMenuItem alloc] initWithTitle:@"Current Branch" action:@selector(getCurrentBranch) keyEquivalent:@"b"];
        [bItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        bItem.target = self;
        [appSubmenu addItem:bItem];
        
        NSMenuItem* openItem = [[NSMenuItem alloc] initWithTitle:@"Open XTerminal" action:@selector(openTerminalInXCode) keyEquivalent:@"t"];
        [openItem setKeyEquivalentModifierMask:NSEventModifierFlagShift];
        openItem.target = self;
        [appSubmenu addItem:openItem];
        
        appMenuItem.submenu = appSubmenu;
        
        
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)getCurrentBranch {
    CCPProject* project = [CCPProject projectForKeyWindow];
    NSString* path = project.directoryPath;
    
    NSString* cmd = [NSString stringWithFormat:@"cd %@;git branch", path];
    
    if (_task) {
        [_task cancel];
    }
    __weak typeof(self) wself = self;
    _task = [[PipeTask alloc] init];
    [_task execute:cmd completion:^(NSString * _Nonnull text) {
        
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
    } finish:^{
        wself.task = nil;
    }];
}

- (void)openTerminalInXCode {
    CCPProject* project = [CCPProject projectForKeyWindow];
    NSString* path = project.directoryPath;
    _terminalController = [[TerminalController alloc] initWithProjectPath:path];
    [_terminalController.window makeKeyAndOrderFront:nil];
}

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
