//
//  TerminalController.m
//  XTerminal
//
//  Created by Peter on 2019/10/31.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "TerminalController.h"
#import "CCPProject.h"
#import "XUtils.h"
#import "JBShellView.h"
#import "PipeTask.h"
#import "ProfileUtils.h"
#import "XTerminalConstants.h"

@interface TerminalController ()<NSTextFieldDelegate>

@property (nonatomic, copy) NSString* projectPath;

@property (nonatomic, strong) PipeTask* task;
@end

@implementation TerminalController


- (void)dealloc
{
    [_task cancel];
}

- (instancetype)initWithProjectPath:(NSString *)path
{
    self = [super initWithWindowNibName:@"TerminalController"];
    if (self) {
        self.projectPath = path;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
   
    CGRect rect = self.window.contentView.bounds;
    
    NSString* path = [self.projectPath copy];
    if (path.length > 60) {
        path = [NSString stringWithFormat:@"%@...%@", [path substringToIndex:20], [path substringFromIndex:path.length - 40]];
    }
    NSString* prompt = [NSString stringWithFormat:@"👍👍👍%@🌟", path];

    __weak typeof(self) wself = self;
    self.shellView = [[JBShellContainerView alloc] initWithFrame:rect shellViewClass:nil prompt:prompt shellInputProcessingHandler:^(NSString *input, JBShellView *sender) {
        if (input) {
            [wself execute:[self cmdCompatible:[wself cmdAliasable:input]]];
        } else {
            [wself.task cancel];
        }
    }];
    self.shellView.shellView.exitHandler = ^{
        [wself.window orderOut:nil];
        [wself.window resignKeyWindow];
    };
    [self.window.contentView addSubview:self.shellView];
    [self.window makeFirstResponder:self.shellView.shellView];

    [[ProfileUtils shared] loadProfile:^{
    }];
}

- (void)execute:(NSString *)cmd {
    _task = [[PipeTask alloc] initWithRootPath:self.projectPath];

    [self.shellView.shellView beginDelayedOutputMode];
    
    __weak typeof(self) wself = self;
    [_task execute:[NSString stringWithFormat:@"source ~/.bash_profile;%@",cmd] completion:^(NSString * _Nonnull text) {
        [wself appendText:text];
    } finish:^{
        [wself.shellView.shellView endDelayedOutputMode];
        wself.task = nil;
    }];
}


- (void)appendText:(NSString *)text {

    NSMutableAttributedString* textAttr = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSArray<NSString *>* list = [text componentsSeparatedByString:@"\n"];
    [list enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj != nil) {
            if ([obj hasPrefix:@"+"] && ![obj hasPrefix:@"++"]) {
                NSRange range = [text rangeOfString:obj];
                [textAttr addAttribute:NSForegroundColorAttributeName value:XTerimalDiffAddTextColor range:range];
            } else if ([obj hasPrefix:@"-"] && ![obj hasPrefix:@"--"]) {
                NSRange range = [text rangeOfString:obj];
                [textAttr addAttribute:NSForegroundColorAttributeName value:XTerimalDiffRemoveTextColor range:range];
            }
        }
        
    }];
    
    [self.shellView.shellView appendOutputWithNewlines:textAttr];
}


#pragma mark - cmd
- (NSString *)cmdAliasable:(NSString *)cmd {
    if (![cmd containsString:@" "]) {
        return [[ProfileUtils shared] getAliasByName:cmd];
    }
    
    NSArray* list = [cmd componentsSeparatedByString:@" "];
    NSString* name = list[0];
    NSString* nameAliased = [[ProfileUtils shared] getAliasByName:name];
    
    NSMutableArray* mList = [NSMutableArray arrayWithArray:list];
    [mList removeObjectAtIndex:0];
    [mList insertObject:nameAliased atIndex:0];
    
    return [mList componentsJoinedByString:@" "];
}

- (NSString *)cmdCompatible:(NSString *)cmd {
    if ([[cmd lowercaseString] hasPrefix:@"pod"]) {
        return [NSString stringWithFormat:@"/usr/local/bin/%@", cmd];
    }
    return cmd;
}
@end
