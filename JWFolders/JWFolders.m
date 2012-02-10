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

@interface JWFolders ()
- (JWFolderSplitView *)buttonForRect:(CGRect)aRect andScreen:(UIImage *)screen top:(BOOL)isTop position:(CGPoint)position;
- (void)openFolderWithContentView:(UIView *)view 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock 
                       closeBlock:(JWFoldersCloseBlock)closeBlock 
                  completionBlock:(JWFoldersCompletionBlock)completionBlock;
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


/* Singleton */
static JWFolders *sharedFolder = nil;

+ (JWFolders *)sharedFolder {
	
	if(sharedFolder == nil)
		sharedFolder = [[JWFolders alloc] init];
	
	return sharedFolder;
}


/* Class methods */
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
                    completionBlock:nil];
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
                    completionBlock:nil];
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
                    completionBlock:nil];
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
                    completionBlock:nil];
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
                    completionBlock:nil];
}

+ (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock
                       closeBlock:(JWFoldersCloseBlock)closeBlock
                  completionBlock:(JWFoldersCompletionBlock)completionBlock {
    
    [[self sharedFolder] openFolderWithContentView:contentView 
                                          position:position 
                                     containerView:containerView 
                                            sender:sender 
                                         openBlock:openBlock 
                                        closeBlock:closeBlock 
                                   completionBlock:completionBlock];
}

- (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock 
                       closeBlock:(JWFoldersCloseBlock)closeBlock 
                  completionBlock:(JWFoldersCompletionBlock)completionBlock {
    
    self.sender = sender;
    self.contentView = contentView;
    self.openBlock = openBlock;
    self.closeBlock = closeBlock;
    self.completionBlock = completionBlock;

    UIImage *screenshot = [containerView screenshot];
    CGFloat width = containerView.frame.size.width;
    CGFloat height = containerView.frame.size.height;
    
    CGRect upperRect = CGRectMake(0, 0, width, position.y);
    CGRect lowerRect = CGRectMake(0, position.y, width, height - position.y);
    
    self.top = [self buttonForRect:upperRect andScreen:screenshot top:YES position:position];
    self.bottom = [self buttonForRect:lowerRect andScreen:screenshot top:NO position:position];
    
    [self.top addTarget:self action:@selector(folderWillClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:self action:@selector(folderWillClose:) forControlEvents:UIControlEventTouchUpInside];
    
    //Todo: Create a "notch", similar to SpringBoard's folders
    //UIImageView *notch = nil;
    //notch.center = CGPointMake(position.x, position.y + 7.0);
    
    [containerView addSubview:self.contentView];
    [containerView addSubview:self.top];
    [containerView addSubview:self.bottom];
    
    CGRect viewFrame = self.contentView.frame;
    CGFloat heightPosition = (height - position.y);
    viewFrame.origin.y = height - viewFrame.size.height - heightPosition;
    self.contentView.frame = viewFrame;
    
    CFTimeInterval duration = 0.4f;
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    self.folderPoint = self.top.layer.position;
    CGPoint toPoint = CGPointMake(self.folderPoint.x, self.folderPoint.y - self.contentView.frame.size.height);    
    CABasicAnimation *moveUp = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveUp setTimingFunction:timingFunction];
    moveUp.fromValue = [NSValue valueWithCGPoint:self.folderPoint];
    moveUp.toValue = [NSValue valueWithCGPoint:toPoint];
    moveUp.duration = duration;
    
    [self.top.layer addAnimation:moveUp forKey:nil];
    if (openBlock) openBlock(self.contentView, duration, timingFunction);
    self.top.layer.position = toPoint;
}

- (void)folderWillClose:(id)sender {
    CFTimeInterval duration = 0.4f;
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CABasicAnimation *moveDown = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveDown setValue:@"moveDown" forKey:@"animationType"];
    [moveDown setDelegate:self];
    [moveDown setTimingFunction:timingFunction];
    moveDown.fromValue = [NSValue valueWithCGPoint:[[_top.layer presentationLayer] position]];
    moveDown.toValue = [NSValue valueWithCGPoint:_folderPoint];
    moveDown.duration = 0.4f;
    [self.top.layer addAnimation:moveDown forKey:nil];
    if (self.closeBlock) self.closeBlock(self.contentView, duration, timingFunction);
    self.top.layer.position = self.folderPoint;
}

// Using delegate callbacks instead of blocks in this case to avoid something terrible
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"animationType"] isEqualToString:@"moveDown"]) {        
        [self.top removeFromSuperview];
        [self.bottom removeFromSuperview];
        [self.contentView removeFromSuperview];
        self.top = nil;
        self.bottom = nil;
        self.contentView = nil;
        self.sender = nil;
        
        if (self.completionBlock) self.completionBlock();
        sharedFolder = nil;
        
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
    if (sharedFolder)
        [[self sharedFolder] folderWillClose:nil];
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
