//
//  PipeTask.h
//  XTerminal
//
//  Created by Peter on 2019/11/1.
//  Copyright © 2019 Peter. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TaskCompletion)(NSString *text);
typedef void(^TaskFinish)(void);

@interface PipeTask : NSObject

- (void)execute:(NSString *)cmd completion:(TaskCompletion)completion finish:(TaskFinish)finish;
- (void)cancel;
@end

NS_ASSUME_NONNULL_END
