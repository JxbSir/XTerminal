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
            [wself execute:[wself cmdCompatible:input]];
        } else {
            [wself.task cancel];
        }
    }];
    [self.window.contentView addSubview:self.shellView];
    [self.window makeFirstResponder:self.shellView.shellView];

}

- (void)execute:(NSString *)cmd {
    _task = [[PipeTask alloc] init];
    
    NSString* cmdString = [NSString stringWithFormat:@"cd %@; %@", self.projectPath, cmd];
    
    [self.shellView.shellView beginDelayedOutputMode];
    
    __weak typeof(self) wself = self;
    [_task execute:cmdString completion:^(NSString * _Nonnull text) {
        [wself.shellView.shellView appendOutputWithNewlines:text];
    } finish:^{
        [wself.shellView.shellView endDelayedOutputMode];
        wself.task = nil;
    }];
}

- (NSString *)cmdCompatible:(NSString *)cmd {
    if ([[cmd lowercaseString] hasPrefix:@"pod"]) {
        return [NSString stringWithFormat:@"/usr/local/bin/%@", cmd];
    }
    return cmd;
}
@end
