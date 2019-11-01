//
//  XUtils.m
//  XTerminal
//
//  Created by Peter on 2019/10/31.
//  Copyright © 2019 Peter. All rights reserved.
//

#import "XUtils.h"

@implementation XUtils

+ (id)execute:(NSString *)cmd {
    NSTask *shellTask = [[NSTask alloc]init];
    [shellTask setLaunchPath:@"/bin/bash"];

    NSArray *arguments = [NSArray arrayWithObjects:@"-c", cmd, nil];
    [shellTask setArguments:arguments];

    NSPipe *pipe = [[NSPipe alloc]init];
    [shellTask setStandardOutput:pipe];
    [shellTask setStandardError:pipe];
    
    NSError* error;
    [shellTask launchAndReturnError:&error];

    NSFileHandle *file = [pipe fileHandleForReading];

    [file readInBackgroundAndNotify];
    NSData *data = [file readDataToEndOfFileAndReturnError:&error];
    NSString *strReturnFromShell = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return [strReturnFromShell stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (BOOL)runProcessAsAdministrator:(NSString *)scriptPath arguments:(NSArray *)arguments isAdmin:(BOOL)isAdmin output:(NSString **)output errorDescription:(NSString **)errorDescription
{
   NSString * allArgs = [arguments componentsJoinedByString:@" "];
   NSString *isAdminPre = @"";
   if (isAdmin) {
    isAdminPre = @"with administrator privileges";
   }
   NSString * fullScript = [NSString stringWithFormat:@"%@ %@", scriptPath, allArgs];
   NSDictionary *errorInfo = [NSDictionary new];
   NSString *script = [NSString stringWithFormat:@"do shell script \"%@\" %@", fullScript,      isAdminPre];
   NSLog(@"script = %@",script);
   NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
   NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
   // Check errorInfo/var/tmp
   if (! eventResult)
   {
       // Describe common errors
       *errorDescription = nil;
       if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
       {
           NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
           if ([errorNumber intValue] == -128)
            *errorDescription = @"The administrator password is required to do this.";
       }
       // Set error message from provided message
       if (*errorDescription == nil)
       {
           if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
            *errorDescription = (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
       }
       return NO;
   }
   else
   {
       // Set output to the AppleScript's output
    *output = [eventResult stringValue];
       return YES;
   }
}

@end
