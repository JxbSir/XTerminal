//
//  JBShellContainerView.m
//  TextViewShell
//
//  Created by Jason Brennan on 12-07-14.
//  Copyright (c) 2012 Jason Brennan. All rights reserved.
//

#import "JBShellContainerView.h"
#import "JBShellView.h"

@interface JBShellContainerView ()

@property (nonatomic, strong) NSScrollView* scrollView;

@end

@implementation JBShellContainerView

- (id)initWithFrame:(NSRect)frameRect shellViewClass:(Class)shellViewClass prompt:(NSString *)prompt shellInputProcessingHandler:(JBShellViewInputProcessingHandler)inputProcessingHandler
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        NSColor* color = [NSColor colorWithRed:13.0/255.0 green:42.0/255.0  blue:53.0/255.0  alpha:1];
		CGRect bounds = [self bounds];
        _scrollView = [[NSScrollView alloc] initWithFrame:bounds];
		[_scrollView setBorderType:NSNoBorder];
		[_scrollView setHasVerticalScroller:YES];
		[_scrollView setHasHorizontalScroller:NO];
		[_scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		CGSize contentSize = [_scrollView contentSize];
		[_scrollView setBackgroundColor:color];
		
		if (shellViewClass == nil) shellViewClass = [JBShellView class];
		JBShellView *shellView = [[shellViewClass alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, contentSize.height) prompt:prompt inputHandler:inputProcessingHandler];
		[shellView setAutoresizingMask:NSViewWidthSizable];
		[shellView setMinSize:CGSizeMake(0.0f, contentSize.height)];
		[shellView setMaxSize:CGSizeMake(1e7, 1e7)];
		[shellView setVerticallyResizable:YES];
		[shellView setHorizontallyResizable:NO];
		[shellView setBackgroundColor:color];
		[[shellView textContainer] setWidthTracksTextView:YES];
        [shellView setTextColor:[NSColor colorWithRed:127/255.0 green:184/255.0 blue:14/255.0 alpha:1]];

        
		self.shellView = shellView;
		
		[_scrollView setDocumentView:shellView];
		[self addSubview:_scrollView];
		
		[self setAutoresizesSubviews:YES];
		[self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		
		[kJBShellViewErrorColor description];
    }
    
    return self;
}

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.shellView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    self.scrollView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
    self.shellView.frame = CGRectMake(0, 0, newSize.width, newSize.height);
}

- (BOOL)becomeFirstResponder {
	return [self.shellView becomeFirstResponder];
}

- (BOOL)canBecomeKeyView {
	return YES;
}


@end
