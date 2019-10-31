//
//  XTerminal.m
//  XTerminal
//
//  Created by Peter on 2019/10/31.
//Copyright © 2019 Peter. All rights reserved.
//

#import "XTerminal.h"

static XTerminal *sharedPlugin;

@interface XTerminal ()<NSUserNotificationCenterDelegate>

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
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [[menuItem submenu] addItem:appMenuItem];
        
        
        NSMenu* appSubmenu = [[NSMenu alloc] init];
       
        NSMenuItem* bItem = [[NSMenuItem alloc] initWithTitle:@"Current Branch" action:@selector(getCurrentBranch) keyEquivalent:@""];
        bItem.target = self;
        [appSubmenu addItem:bItem];
        
        appMenuItem.submenu = appSubmenu;
        
        
        return YES;
    } else {
        return NO;
    }
}

// Sample Action, for menu item:
- (void)getCurrentBranch
{
//    NSUserNotification* notification = [[NSUserNotification alloc] init];
//    notification.title = @"XTerminal";
//    notification.subtitle = @"get current";
//    notification.informativeText = @"你有\(news.count)条新的任务需要处理";
//    [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
//    NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
}


#pragma mark - delegate
- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return true;
}
@end
