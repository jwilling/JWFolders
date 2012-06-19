/* 
 Copyright (c) 2011, Jonathan Willing
 All rights reserved.
 Licensed under the BSD License.
 http://www.opensource.org/licenses/bsd-license
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "JWFolders.h"
#import "UIView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC.
#endif

@interface JWFolderSplitView : UIControl
@property (nonatomic) CGPoint position;
@property (nonatomic, strong) CALayer *highlight;
- (void)setIsTopView:(BOOL)isTop;
- (void)createHighlightWithFrame:(CGRect)aFrame;
@end

@interface JWFolders ()
- (JWFolderSplitView *)buttonForRect:(CGRect)aRect
                              screen:(UIImage *)screen
                            position:(CGPoint)position
                                 top:(BOOL)isTop
                         transparent:(BOOL)isTransparent;
- (void)openFolderWithContentView:(UIView *)contentView
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                        openBlock:(JWFoldersOpenBlock)openBlock 
                       closeBlock:(JWFoldersCloseBlock)closeBlock
                  completionBlock:(JWFoldersCompletionBlock)completionBlock
                        direction:(JWFoldersOpenDirection)direction;
@property (nonatomic, strong) JWFolderSplitView *top;
@property (nonatomic, strong) JWFolderSplitView *bottom;
@property (nonatomic, assign) CGPoint folderPoint;
@end


@implementation JWFolders

@synthesize top = _top;
@synthesize bottom = _bottom;
@synthesize position = _position;
@synthesize direction = _direction;
@synthesize folderPoint = _folderPoint;
@synthesize contentView = _contentView;
@synthesize completionBlock = _completionBlock;
@synthesize transparentPane = _transparentPane;
@synthesize containerView = _containerView;
@synthesize closeBlock = _closeBlock;
@synthesize openBlock = _openBlock;


static JWFolders *sharedInstance = nil;
+ (JWFolders *)sharedInstance {
	if (!sharedInstance)
        sharedInstance = [[self alloc] init];
	return sharedInstance;
}

+ (id)folder {
    return [self sharedInstance];
}

- (void)open {
    [self openFolderWithContentView:self.contentView
                           position:self.position
                      containerView:self.containerView
                          openBlock:self.openBlock
                         closeBlock:self.closeBlock
                    completionBlock:self.completionBlock
                          direction:self.direction];
}

+ (void)openFolderWithContentView:(UIView *)contentView
                         position:(CGPoint)position
                    containerView:(UIView *)containerView
                        openBlock:(JWFoldersOpenBlock)openBlock
                       closeBlock:(JWFoldersCloseBlock)closeBlock
                  completionBlock:(JWFoldersCompletionBlock)completionBlock
                        direction:(JWFoldersOpenDirection)direction {
    [[self sharedInstance] openFolderWithContentView:contentView
                                            position:position
                                       containerView:containerView
                                           openBlock:openBlock
                                          closeBlock:closeBlock
                                     completionBlock:completionBlock
                                           direction:direction];
}

- (void)openFolderWithContentView:(UIView *)contentView
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                        openBlock:(JWFoldersOpenBlock)openBlock 
                       closeBlock:(JWFoldersCloseBlock)closeBlock
                  completionBlock:(JWFoldersCompletionBlock)completionBlock
                        direction:(JWFoldersOpenDirection)direction {
    NSAssert(contentView && containerView, @"Content or container views must not be nil.");
    
    self.contentView = contentView;
    self.openBlock = openBlock;
    self.closeBlock = closeBlock;
    self.completionBlock = completionBlock;
    self.direction = (direction > 0)?direction:JWFoldersOpenDirectionUp;

    BOOL up = (direction == JWFoldersOpenDirectionUp);
    
    UIImage *screenshot = [containerView screenshot];
    CGFloat width = containerView.frame.size.width;
    CGFloat height = containerView.frame.size.height;
    
    CGRect upperRect = CGRectMake(0, 0, width, position.y);
    CGRect lowerRect = CGRectMake(0, position.y, width, height - position.y);
    
    self.top = [self buttonForRect:upperRect
                            screen:screenshot
                          position:position
                               top:YES
                       transparent:up ? NO : self.isTransparentPane];
    self.bottom = [self buttonForRect:lowerRect
                               screen:screenshot
                             position:position
                                  top:NO
                          transparent:up ? self.isTransparentPane : NO];
    
    [self.top addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    
    //Todo: Create a "notch", similar to SpringBoard's folders
    //UIImageView *notch = nil;
    //notch.center = CGPointMake(position.x, position.y + 7.0);
    
    [containerView addSubview:self.contentView];
    [containerView addSubview:self.top];
    [containerView addSubview:self.bottom];
    
    CGRect viewFrame = self.contentView.frame;
    CGFloat heightPosition = (height - position.y);
    viewFrame.origin.y = (up) ? (height - viewFrame.size.height - heightPosition) : (position.y);
    self.contentView.frame = viewFrame;
    
    CGPoint toPoint;
    CFTimeInterval duration = 0.4f;
    CGFloat contentHeight = self.contentView.frame.size.height;
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    move.duration = duration;
    move.timingFunction = timingFunction;
    
    self.folderPoint = (up) ? self.top.layer.position : self.bottom.layer.position;
    toPoint = (CGPoint){ self.folderPoint.x, (up) ? (self.folderPoint.y - contentHeight) : (self.folderPoint.y + contentHeight)};
    move.fromValue = [NSValue valueWithCGPoint:self.folderPoint];
    move.toValue = [NSValue valueWithCGPoint:toPoint];
    [up ? self.top.layer : self.bottom.layer addAnimation:move forKey:nil];

    if (openBlock) openBlock(self.contentView, duration, timingFunction);
    [(up) ? self.top.layer : self.bottom.layer setPosition:toPoint];
}

- (void)performClose:(id)sender {
    CFTimeInterval duration = 0.4f;
    BOOL up = (self.direction == JWFoldersOpenDirectionUp);
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    [move setValue:@"close" forKey:@"animationType"];
    [move setDelegate:self];
    [move setTimingFunction:timingFunction];
    move.fromValue = [NSValue valueWithCGPoint:[[(up) ? self.top.layer : self.bottom.layer presentationLayer] position]];
    move.toValue = [NSValue valueWithCGPoint:_folderPoint];
    move.duration = duration;
    [up ? self.top.layer : self.bottom.layer addAnimation:move forKey:nil];
    if (self.closeBlock) self.closeBlock(self.contentView, duration, timingFunction);
    [(up) ? self.top.layer : self.bottom.layer setPosition:self.folderPoint];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"animationType"] isEqualToString:@"close"]) {        
        [self.top removeFromSuperview];
        [self.bottom removeFromSuperview];
        [self.contentView removeFromSuperview];
        self.top = nil;
        self.bottom = nil;
        self.contentView = nil;
        
        if (self.completionBlock) self.completionBlock();
        sharedInstance = nil;
    }
}

- (JWFolderSplitView *)buttonForRect:(CGRect)aRect
                              screen:(UIImage *)screen
                            position:(CGPoint)position
                                 top:(BOOL)isTop
                         transparent:(BOOL)isTransparent {
    CGFloat scale = [[UIScreen mainScreen] scale]; 
    CGFloat width = aRect.size.width;
    CGFloat height = aRect.size.height;
    CGPoint origin = aRect.origin;
    
    CGRect scaledRect = CGRectMake(origin.x*scale, origin.y*scale, width*scale, height*scale);
    CGImageRef ref1 = CGImageCreateWithImageInRect([screen CGImage], scaledRect);
    
    JWFolderSplitView *button = [[JWFolderSplitView alloc] initWithFrame:aRect];
    [button setIsTopView:isTop];
    button.position = position;
    button.layer.contents = isTransparent ? nil : (__bridge id)(ref1);
    button.layer.contentsGravity = kCAGravityCenter;
    button.layer.contentsScale = scale;
    CGImageRelease(ref1);
    
    return button;
}

+ (void)closeCurrentFolder {
    if (sharedInstance)
        [[self sharedInstance] performClose:nil];
}

@end



@implementation JWFolderSplitView
@synthesize position = _position;
@synthesize highlight = _highlight;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self createHighlightWithFrame:frame];
    
    return self;
}

- (void)createHighlightWithFrame:(CGRect)aFrame {
    CGRect frame = aFrame;
    frame.size.height = 1.f;
    
    self.highlight = [CALayer layer];
    self.highlight.frame = frame;
    self.highlight.anchorPoint = CGPointZero;
    self.highlight.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.3f].CGColor;
    [self.layer addSublayer:self.highlight];
}

- (void)setIsTopView:(BOOL)isTop {
    self.highlight.position = CGPointMake(0, isTop ? (self.frame.size.height-1) : 0);
}

@end
