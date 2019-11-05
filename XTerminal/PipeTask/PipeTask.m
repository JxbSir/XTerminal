//
//  PipeTask.m
//  XTerminal
//
//  Created by Peter on 2019/11/1.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "PipeTask.h"
#import <dispatch/data.h>

@interface PipeTask ()

@property (nonatomic, strong) NSString      *rootPath;
@property (nonatomic, strong) NSTask        *task;
@property (nonatomic, strong) NSFileHandle  *file;

@property (nonatomic, copy) TaskCompletion  completion;
@property (nonatomic, copy) TaskFinish      finish;

@end

@implementation PipeTask

- (void)dealloc
{
    NSLog(@"PipeTask dealloc");
}

- (instancetype)initWithRootPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.rootPath = path;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData:) name:NSFileHandleReadCompletionNotification object:nil];
    }
    return self;
}

- (void)execute:(NSString *)cmd completion:(nonnull TaskCompletion)completion finish:(nonnull TaskFinish)finish {
    _completion = completion;
    _finish = finish;
    _task = [[NSTask alloc]init];
    _task.currentDirectoryPath = self.rootPath;
    [_task setLaunchPath:@"/bin/bash"];
    
    NSDictionary* environmentDict = [[NSProcessInfo processInfo] environment];
    [_task setEnvironment:environmentDict];

    NSArray *arguments = [NSArray arrayWithObjects:@"-c", cmd, nil];
    [_task setArguments:arguments];

    NSPipe *pipe = [[NSPipe alloc]init];
    [_task setStandardOutput:pipe];
    [_task setStandardError:pipe];
    
    NSError* error;
    [_task launchAndReturnError:&error];

    _file = [pipe fileHandleForReading];
    [_file readInBackgroundAndNotify];
}

- (void)cancel {
    [_task terminate];
}

- (void)getData:(NSNotification *)aNotification {
   
    dispatch_data_t data = aNotification.userInfo[NSFileHandleNotificationDataItem];
    const void *buffer = NULL;
    size_t size = 0;
    dispatch_data_t new_data_file = dispatch_data_create_map(data, &buffer, &size);
    if(new_data_file) {
        NSData *nsdata = [[NSData alloc] initWithBytes:buffer length:size];
        NSString* text = [[NSString alloc] initWithData:nsdata encoding:NSUTF8StringEncoding];
        if (text.length > 0) {
            self.completion(text);
            [_file readInBackgroundAndNotify];
        } else {
            if (!self.task.running) {
                self.finish();
            }
        }
    }
}
@end
