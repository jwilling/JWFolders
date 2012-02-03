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
+ (JWFolderSplitView *)buttonForRect:(CGRect)aRect andScreen:(UIImage *)screen top:(BOOL)isTop position:(CGPoint)position;
@end

@implementation JWFolders

static CGPoint folderPoint;
static JWFolderSplitView *top = nil;
static JWFolderSplitView *bottom = nil;
static id sender = nil;

+ (void)folderWillClose:(id)aSender {
    if ([sender respondsToSelector:@selector(folderWillClose:)])
        [sender folderWillClose:self];
    else [self closeFolderWithCompletionBlock:nil];
}

+ (void)openFolderWithViewController:(UIViewController *)viewController 
                          atPosition:(CGPoint)position 
                     inContainerView:(UIView *)containerView 
                              sender:(id)aSender {
    [self openFolderWithView:viewController.view atPosition:position inContainerView:containerView sender:aSender];
}

+ (void)openFolderWithView:(UIView *)view 
                atPosition:(CGPoint)position 
           inContainerView:(UIView *)containerView 
                    sender:(id)aSender {
    sender = aSender;
    UIImage *screenshot = [containerView screenshot];
    CGFloat width = containerView.frame.size.width;
    CGFloat height = containerView.frame.size.height;
    
    CGRect upperRect = CGRectMake(0, 0, width, position.y);
    CGRect lowerRect = CGRectMake(0, position.y, width, height - position.y);
    
    top = [self buttonForRect:upperRect andScreen:screenshot top:YES position:position];
    bottom = [self buttonForRect:lowerRect andScreen:screenshot top:NO position:position];
    
    [top addTarget:self action:@selector(folderWillClose:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addTarget:self action:@selector(folderWillClose:) forControlEvents:UIControlEventTouchUpInside];
    
    /* Todo: Create a "notch", similar to SpringBoard's folders
    UIImageView *notch = nil;
    notch.center = CGPointMake(position.x, position.y + 7.0);
     */
    
    [containerView addSubview:view];
    [containerView addSubview:top];
    [containerView addSubview:bottom];
    
    CGRect viewFrame = view.frame;
    CGFloat heightPosition = (height - position.y);
    viewFrame.origin.y = height - viewFrame.size.height - heightPosition;
    view.frame = viewFrame;
    
    folderPoint = top.layer.position;
    CGPoint toPoint = CGPointMake(folderPoint.x, folderPoint.y-view.frame.size.height);    
    CABasicAnimation *moveUp = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveUp setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    moveUp.fromValue = [NSValue valueWithCGPoint:folderPoint];
    moveUp.toValue = [NSValue valueWithCGPoint:toPoint];
    moveUp.duration = 0.4f;
    
    [top.layer addAnimation:moveUp forKey:nil];
    top.layer.position = toPoint;
}

+ (JWFolderSplitView *)buttonForRect:(CGRect)aRect andScreen:(UIImage *)screen top:(BOOL)isTop position:(CGPoint)position {
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

+ (void)closeFolderWithCompletionBlock:(void (^)(void))block {
    [CATransaction setCompletionBlock:^{
        if (block) {
            block();
        }
        [top removeFromSuperview];
        [bottom removeFromSuperview];
        if (top) top = nil;
        if (bottom) bottom = nil;
        if (sender) sender = nil;
    }];
    CABasicAnimation *moveDown = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveDown setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    moveDown.fromValue = [NSValue valueWithCGPoint:[[top.layer presentationLayer] position]];
    moveDown.toValue = [NSValue valueWithCGPoint:folderPoint];
    moveDown.duration = 0.4f;
    [top.layer addAnimation:moveDown forKey:nil];
    top.layer.position = folderPoint;
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
