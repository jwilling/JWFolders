/* 
 Copyright (c) 2011, Jonathan Willing
 All rights reserved.
 Licensed under the BSD License.
 http://www.opensource.org/licenses/bsd-license
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "JWFolders.h"
#import "UIView+Screenshot.h"
#import "UIScreen+Scale.h"
#import <QuartzCore/QuartzCore.h>

/* For light highlight on folder buttons */
@interface JWFolderSplitView : UIControl
@property (nonatomic) BOOL isTop;
@property (nonatomic) CGPoint position;
@end

@interface JWFolders ()
- (JWFolderSplitView *)buttonForRect:(CGRect)aRect andScreen:(UIImage *)screen top:(BOOL)isTop position:(CGPoint)position;
- (void)openFolderWithContentView:(UIView *)view 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock 
                       closeBlock:(JWFoldersCloseBlock)closeBlock 
                  completionBlock:(JWFoldersCompletionBlock)completionBlock
                        direction:(JWFoldersOpenDirection)direction;
@property (nonatomic, readwrite) JWFoldersOpenDirection direction;
@property (nonatomic, strong) JWFolderSplitView *top;
@property (nonatomic, strong) JWFolderSplitView *bottom;
@property (nonatomic, assign) CGPoint folderPoint;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) id sender;
@property (nonatomic, copy) JWFoldersCompletionBlock completionBlock;
@property (nonatomic, copy) JWFoldersCloseBlock closeBlock;
@property (nonatomic, copy) JWFoldersOpenBlock openBlock;
@end


@implementation JWFolders

@synthesize top = _top;
@synthesize bottom = _bottom;
@synthesize folderPoint = _folderPoint;
@synthesize contentView = _contentView;
@synthesize sender = _sender;
@synthesize completionBlock = _completionBlock;
@synthesize closeBlock = _closeBlock;
@synthesize openBlock = _openBlock;


static JWFolders *sharedInstance = nil;
+ (JWFolders *)sharedInstance {
	static dispatch_once_t pred;
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

+ (void)openFolderWithContentViewController:(UIViewController *)viewController
                                   position:(CGPoint)position
                              containerView:(UIView *)containerView
                                     sender:(id)sender {
    [self openFolderWithContentView:viewController.view 
                           position:position 
                      containerView:containerView
                             sender:sender
                          openBlock:nil 
                         closeBlock:nil 
                    completionBlock:nil
                          direction:JWFoldersOpenDirectionUp];
}

+ (void)openFolderWithContentView:(UIView *)contentView
                         position:(CGPoint)position
                    containerView:(UIView *)containerView
                           sender:(id)sender {
    [self openFolderWithContentView:contentView 
                           position:position 
                      containerView:containerView
                             sender:sender
                          openBlock:nil 
                         closeBlock:nil 
                    completionBlock:nil
                          direction:JWFoldersOpenDirectionUp];
}

+ (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                       closeBlock:(JWFoldersCloseBlock)closeBlock {
    [self openFolderWithContentView:contentView 
                           position:position 
                      containerView:containerView
                             sender:sender
                          openBlock:nil 
                         closeBlock:closeBlock 
                    completionBlock:nil
                          direction:JWFoldersOpenDirectionUp];
}

+ (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock {
    [self openFolderWithContentView:contentView 
                           position:position 
                      containerView:containerView
                             sender:sender
                          openBlock:openBlock 
                         closeBlock:nil 
                    completionBlock:nil
                          direction:JWFoldersOpenDirectionUp];
}

+ (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock
                       closeBlock:(JWFoldersCloseBlock)closeBlock {
    [self openFolderWithContentView:contentView 
                           position:position 
                      containerView:containerView
                             sender:sender
                          openBlock:openBlock 
                         closeBlock:closeBlock 
                    completionBlock:nil
                          direction:JWFoldersOpenDirectionUp];
}

+ (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock
                       closeBlock:(JWFoldersCloseBlock)closeBlock
                  completionBlock:(JWFoldersCompletionBlock)completionBlock
                        direction:(JWFoldersOpenDirection)direction {
    
    [[self sharedInstance] openFolderWithContentView:contentView
                                          position:position 
                                     containerView:containerView 
                                            sender:sender 
                                         openBlock:openBlock 
                                        closeBlock:closeBlock 
                                     completionBlock:completionBlock
                                           direction:direction];
}

- (void)openFolderWithContentView:(UIView *)contentView
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock 
                       closeBlock:(JWFoldersCloseBlock)closeBlock 
                  completionBlock:(JWFoldersCompletionBlock)completionBlock
                        direction:(JWFoldersOpenDirection)direction {
    
    self.sender = sender;
    self.contentView = contentView;
    self.openBlock = openBlock;
    self.closeBlock = closeBlock;
    self.completionBlock = completionBlock;
    self.direction = direction;

    UIImage *screenshot = [containerView screenshot];
    CGFloat width = containerView.frame.size.width;
    CGFloat height = containerView.frame.size.height;
    
    CGRect upperRect = CGRectMake(0, 0, width, position.y);
    CGRect lowerRect = CGRectMake(0, position.y, width, height - position.y);
    
    self.top = [self buttonForRect:upperRect andScreen:screenshot top:YES position:position];
    self.bottom = [self buttonForRect:lowerRect andScreen:screenshot top:NO position:position];
    
    [self.top addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    
    //Todo: Create a "notch", similar to SpringBoard's folders
    //UIImageView *notch = nil;
    //notch.center = CGPointMake(position.x, position.y + 7.0);
    
    [containerView addSubview:self.contentView];
    [containerView addSubview:self.top];
    [containerView addSubview:self.bottom];
    
    BOOL up = (direction == JWFoldersOpenDirectionUp);
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
        self.sender = nil;
        
        if (self.completionBlock) self.completionBlock();
    }
}

- (JWFolderSplitView *)buttonForRect:(CGRect)aRect andScreen:(UIImage *)screen top:(BOOL)isTop position:(CGPoint)position {
    CGFloat scale = [UIScreen screenScale]; 
    CGFloat width = aRect.size.width;
    CGFloat height = aRect.size.height;
    CGPoint origin = aRect.origin;
    
    CGRect r1 = CGRectMake(origin.x*scale, origin.y*scale, width*scale, height*scale);
    CGRect u1 = CGRectMake(origin.x, origin.y, width, height);
    CGImageRef ref1 = CGImageCreateWithImageInRect([screen CGImage], r1);
    UIImage *img = [UIImage imageWithCGImage:ref1 scale: scale orientation: UIImageOrientationUp];
    CGImageRelease(ref1);
    
    JWFolderSplitView *b1 = [[JWFolderSplitView alloc] initWithFrame:u1];
    b1.isTop = isTop;
    b1.position = position;
    [b1 setBackgroundColor:[UIColor colorWithPatternImage:img]];
    return b1;
}

+ (void)closeCurrentFolder {
    if (sharedInstance)
        [[self sharedInstance] performClose:nil];
}

@end



@implementation JWFolderSplitView
@synthesize isTop, position;

- (void)drawRect:(CGRect)rect {    
    CGContextRef ctx = UIGraphicsGetCurrentContext(); 
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.2); //light color
    if (self.isTop)
        CGContextFillRect(ctx, CGRectMake(0, rect.size.height-1, rect.size.width, 1));
    else 
        CGContextFillRect(ctx, CGRectMake(0, 0, rect.size.width, 1));
    [super drawRect:rect];
}

@end
