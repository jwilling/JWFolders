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

const CGFloat JWFoldersTriangleWidth = 26.f;
const CGFloat JWFoldersTriangleHeight = 12.f;
const CGFloat JWFoldersHighlightOpacity = 0.35f;
const CGFloat JWFoldersOpeningDuration = 0.4f;

@interface JWFolderSplitView : UIControl
@property (nonatomic) CGPoint position;
@property (nonatomic, strong) CAShapeLayer *highlight;
@property (nonatomic, assign) BOOL showsNotch;
@property (nonatomic, assign) BOOL top;
@property (nonatomic, assign) BOOL openingUp;
@property (nonatomic, assign) BOOL darkensBackground;
- (void)setHighlightOpacity:(CGFloat)opacity withDuration:(CFTimeInterval)duration;
@end

@interface JWFolders () {
    JWFolders *_strongSelf;
}
- (JWFolderSplitView *)buttonForRect:(CGRect)aRect
                              screen:(UIImage *)screen
                            position:(CGPoint)position
                                 top:(BOOL)isTop
                         transparent:(BOOL)isTransparent
                           openingUp:(BOOL)openingUp;

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
@property (nonatomic, strong) UIView *contentViewContainer;
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

+ (id)folder {
    return [[self alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        // keep a strong reference to self so that we don't disappear
        //when used as a local variable, much like UIAlertView.
        _strongSelf = self;
    }
    return self;
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
    [[[self alloc] init] openFolderWithContentView:contentView
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
    
    UIImage *screenshot = [containerView screenshot];
    
    self.contentView = contentView;
    self.openBlock = openBlock;
    self.closeBlock = closeBlock;
    self.completionBlock = completionBlock;
    self.direction = (direction > 0)?direction:JWFoldersOpenDirectionUp;
    
    BOOL up = (direction == JWFoldersOpenDirectionUp);
    
    // I doubt this will help performance, because the content view itself
    // isn't the one being animated.
    CGFloat scale = [[UIScreen mainScreen] scale];
    contentView.layer.shouldRasterize = self.shouldRasterizeContent;
    contentView.layer.rasterizationScale = scale;
    
    CGFloat containerWidth = containerView.frame.size.width;
    CGFloat containerHeight = containerView.frame.size.height;
    
    CGRect upperRect = CGRectMake(0, 0, containerWidth, position.y);
    CGRect lowerRect = CGRectMake(0, position.y, containerWidth, containerHeight - position.y);
    
    self.top = [self buttonForRect:upperRect screen:screenshot position:position top:YES transparent:up ? NO : self.transparentPane openingUp:up];
    self.bottom = [self buttonForRect:lowerRect screen:screenshot position:position top:NO transparent:up ? self.transparentPane : NO openingUp:up];
    [self.top addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    
    self.contentViewContainer = [[UIView alloc] initWithFrame:self.contentView.frame];
    
    [containerView addSubview:self.contentViewContainer];
    [containerView addSubview:self.top];
    [containerView addSubview:self.bottom];
    
    CGRect contentFrame = self.contentView.frame;
    // depending on whether we're opening up or down, set the orign of the container to sit flush with the stationary view
    contentFrame.origin.y = (up) ? (containerHeight - contentFrame.size.height - (containerHeight - position.y)) : (position.y);
    
    if (self.showsNotch) {
        // if there is no background color, there's really nothing to
        // put in the notch (triangle) view. So, we should make sure we
        // have a color.
        NSAssert(self.contentBackgroundColor, @"contentBackgroundColor must not be nil");
        
        // the current limitation of this is that if the background isn't repeatable
        // there really is no way to customize how this is drawn. But for now,
        // it seems to be the most flexible way without knowing implementation details.
        self.contentView.backgroundColor = nil;
        self.contentViewContainer.backgroundColor = self.contentBackgroundColor;
        
        // make the content view container fill to fit the new dimensions
        // and draw all the way through the triangle.
        contentFrame.size.height += JWFoldersTriangleHeight;
        contentFrame.origin.y -= up ? 0 : JWFoldersTriangleHeight;
    }
    self.contentViewContainer.frame = contentFrame;
    
    
    // put the real content view into the stretched (if triangle enabled) container for the content view
    [self.contentViewContainer addSubview:self.contentView];
    
    
    // position the view correctly in the container view, offset the origin when direction requires it
    CGRect newContentFrame = self.contentView.frame;
    newContentFrame.origin = CGPointMake(0, self.showsNotch ? (up ? 0 : JWFoldersTriangleHeight) : 0);
    self.contentView.frame = newContentFrame;
    
    CGFloat contentHeight = self.contentView.frame.size.height;
    self.folderPoint = (up) ? self.top.layer.position : self.bottom.layer.position;
    CGPoint toPoint = (CGPoint){ self.folderPoint.x, (up) ? (self.folderPoint.y - contentHeight) : (self.folderPoint.y + contentHeight)};
    
    if (self.shadowsEnabled) {
        // add the inner shadows using UIImageViews, which might seem heavy but in fact they're
        // rendered by the GPU, whereas a CALayer for instance is rendered by the CPU. We want
        // all the rendering speed we can get. Besides, the images will get cached for faster reloads.
        
        UIImage *topShadow = nil;
        UIImage *bottomShadow = nil;
        if (self.showsNotch) {
            topShadow = [UIImage imageNamed:up ? @"JWFolders.bundle/shadow_top" : @"JWFolders.bundle/shadow_top_notch"];
            bottomShadow = [UIImage imageNamed:up ? @"JWFolders.bundle/shadow_low_notch" : @"JWFolders.bundle/shadow_low"];
        } else {
            topShadow = [UIImage imageNamed:@"JWFolders.bundle/shadow_top"];
            bottomShadow = [UIImage imageNamed:@"JWFolders.bundle/shadow_low"];
        }

        UIImageView *topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, contentFrame.size.width, topShadow.size.height)];
        UIImageView *bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, contentFrame.size.height - (bottomShadow.size.height),
                                                                                     contentFrame.size.width, bottomShadow.size.height)];
        topImageView.image = topShadow;
        bottomImageView.image = bottomShadow;
        [self.contentViewContainer addSubview:topImageView];
        [self.contentViewContainer addSubview:bottomImageView];
    }
    
    // animate the sliding of the moveable pane upwards / downwards
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    [move setValue:@"open" forKey:@"animationKey"];
    move.delegate = self;
    move.duration = JWFoldersOpeningDuration;
    move.timingFunction = timingFunction;
    move.fromValue = [NSValue valueWithCGPoint:self.folderPoint];
    move.toValue = [NSValue valueWithCGPoint:toPoint];
    [up ? self.top.layer : self.bottom.layer addAnimation:move forKey:nil];
    
    if (openBlock) {
        openBlock(self.contentView, JWFoldersOpeningDuration, timingFunction);
    }
    
    [(up) ? self.top.layer : self.bottom.layer setPosition:toPoint];
    
    // sets the highlight on the bottom / top of the panes to fade in / out for a convincing effect
    [self.top setHighlightOpacity:1.f withDuration:JWFoldersOpeningDuration];
    [self.bottom setHighlightOpacity:1.f withDuration:JWFoldersOpeningDuration];
}

- (void)performClose:(id)sender {
    BOOL up = (self.direction == JWFoldersOpenDirectionUp);
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position"];
    [move setValue:@"close" forKey:@"animationKey"];
    [move setDelegate:self];
    [move setTimingFunction:timingFunction];
    move.fromValue = [NSValue valueWithCGPoint:[[(up) ? self.top.layer : self.bottom.layer presentationLayer] position]];
    move.toValue = [NSValue valueWithCGPoint:_folderPoint];
    move.duration = JWFoldersOpeningDuration;
    [up ? self.top.layer : self.bottom.layer addAnimation:move forKey:nil];
    if (self.closeBlock) self.closeBlock(self.contentView, JWFoldersOpeningDuration, timingFunction);
    [(up) ? self.top.layer : self.bottom.layer setPosition:self.folderPoint];
    
    [self.top setHighlightOpacity:0.f withDuration:JWFoldersOpeningDuration];
    [self.bottom setHighlightOpacity:0.f withDuration:JWFoldersOpeningDuration];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"animationKey"] isEqualToString:@"close"]) {
        if (self.shouldRasterizeContent) {
            self.contentView.layer.shouldRasterize = NO;
        }
    }
    
    if ([[anim valueForKey:@"animationKey"] isEqualToString:@"close"]) {
        [self.top removeFromSuperview];
        [self.bottom removeFromSuperview];
        [self.contentView removeFromSuperview];
        [self.contentViewContainer removeFromSuperview];
        
        if (self.completionBlock) {
            self.completionBlock();
        }
        
        _strongSelf = nil;
    }
}

- (JWFolderSplitView *)buttonForRect:(CGRect)aRect
                              screen:(UIImage *)screen
                            position:(CGPoint)position
                                 top:(BOOL)isTop
                         transparent:(BOOL)isTransparent
                           openingUp:(BOOL)openingUp {
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat width = aRect.size.width;
    CGFloat height = aRect.size.height;
    CGPoint origin = aRect.origin;
    
    CGRect scaledRect = CGRectMake(origin.x*scale, origin.y*scale, width*scale, height*scale);
    CGImageRef ref1 = CGImageCreateWithImageInRect([screen CGImage], scaledRect);
    
    JWFolderSplitView *button = [[JWFolderSplitView alloc] initWithFrame:aRect];
    button.top = isTop;
    button.position = position;
    button.layer.contents = isTransparent ? nil : (__bridge id)(ref1);
    button.layer.contentsGravity = kCAGravityCenter;
    button.layer.contentsScale = scale;
    button.highlight.opacity = 0.f;
    button.openingUp = openingUp;
    button.darkensBackground = self.darkensBackground;
    button.layer.shouldRasterize = (openingUp && !isTop) || (!openingUp && isTop);
    button.layer.rasterizationScale = screen.scale;
    button.showsNotch = self.showsNotch;
    CGImageRelease(ref1);
    
    return button;
}

- (void)closeCurrentFolder {
    [self performClose:self];
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
    
    _highlight = [CAShapeLayer layer];
    _highlight.frame = self.bounds;
    _highlight.strokeColor = [UIColor colorWithWhite:1.f alpha:JWFoldersHighlightOpacity].CGColor;
    _highlight.fillColor = nil;
    [self.layer addSublayer:_highlight];
}

- (void)setShowsNotch:(BOOL)showsNotch {
    _showsNotch = showsNotch;
    
    if (showsNotch) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.fillColor = [UIColor blackColor].CGColor;
        maskLayer.path = [self maskPath].CGPath;
        maskLayer.frame = self.bounds;
        
        // This sets mask the layer to get the shape of the notch drawn correctly.
        // Setting the layer mask is *extremely* expensive, so we double check that
        // we're not setting this on a view that is being animated. Otherwise, we can
        // kiss our good FPS goodbye.
        if ((self.openingUp && !self.top) || (!self.openingUp && self.top)) {
            self.layer.mask = maskLayer;
        }
    }
    
    self.highlight.path = [self highlightPath].CGPath;
}

- (void)setDarkensBackground:(BOOL)darkensBackground {
    _darkensBackground = darkensBackground;
    if (darkensBackground) {
        self.highlight.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    }
}

- (void)setHighlightOpacity:(CGFloat)opacity withDuration:(CFTimeInterval)duration {
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    if (opacity == 0.f) { // going to 0
        opacityAnimation.values = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:1.f],
                                   [NSNumber numberWithFloat:1.f],
                                   [NSNumber numberWithFloat:0.f], nil];
        opacityAnimation.keyTimes = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0f],
                                     [NSNumber numberWithFloat:0.7f],
                                     [NSNumber numberWithFloat:1.f], nil];
    } else { // going to 1
        opacityAnimation.values = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.f],
                                   [NSNumber numberWithFloat:1.f],
                                   [NSNumber numberWithFloat:1.f], nil];
        opacityAnimation.keyTimes = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0f],
                                     [NSNumber numberWithFloat:0.3f],
                                     [NSNumber numberWithFloat:1.f], nil];
    }
    opacityAnimation.duration = duration;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    [self.highlight addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

- (UIBezierPath *)maskPath {
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    
    [maskPath moveToPoint:CGPointZero];
    if (self.showsNotch && self.openingUp && !self.top) {
        [maskPath addLineToPoint:CGPointMake(self.position.x - (JWFoldersTriangleWidth / 2), 0)];
        [maskPath addLineToPoint:CGPointMake(self.position.x, JWFoldersTriangleHeight)];
        [maskPath addLineToPoint:CGPointMake(self.position.x + (JWFoldersTriangleWidth / 2), 0)];
    }
    [maskPath addLineToPoint:CGPointMake(width, 0)];
    [maskPath addLineToPoint:CGPointMake(width, height)];
    if (self.showsNotch && !self.openingUp && self.top) {
        [maskPath addLineToPoint:CGPointMake(self.position.x + (JWFoldersTriangleWidth / 2), height)];
        [maskPath addLineToPoint:CGPointMake(self.position.x, height - JWFoldersTriangleHeight)];
        [maskPath addLineToPoint:CGPointMake(self.position.x - (JWFoldersTriangleWidth / 2), height)];
    }
    [maskPath addLineToPoint:CGPointMake(0, height)];
    [maskPath addLineToPoint:CGPointZero];
    [maskPath closePath];
    return maskPath;
}

- (UIBezierPath *)highlightPath {
    UIBezierPath *highlightPath = [UIBezierPath bezierPath];
    
    CGSize size = self.bounds.size;
    [highlightPath moveToPoint:self.top ? CGPointMake(0, size.height - 0.5) : CGPointMake(0, 0.5)];
    
    if (self.showsNotch && self.openingUp && !self.top) {
        [highlightPath addLineToPoint:CGPointMake(self.position.x - (JWFoldersTriangleWidth / 2), 0.5)];
        [highlightPath addLineToPoint:CGPointMake(self.position.x, JWFoldersTriangleHeight + 0.5)];
        [highlightPath addLineToPoint:CGPointMake(self.position.x + (JWFoldersTriangleWidth / 2), 0.5)];
    } else if (self.showsNotch && !self.openingUp && self.top) {
        [highlightPath addLineToPoint:CGPointMake(self.position.x - (JWFoldersTriangleWidth / 2), size.height - 0.5)];
        [highlightPath addLineToPoint:CGPointMake(self.position.x, size.height - JWFoldersTriangleHeight - 0.5)];
        [highlightPath addLineToPoint:CGPointMake(self.position.x + (JWFoldersTriangleWidth / 2), size.height - 0.5)];
    }
    
    [highlightPath addLineToPoint:self.top ? CGPointMake(size.width, size.height - 0.5) : CGPointMake(size.width, 0.5)];
    [highlightPath closePath];
    
    return highlightPath;
}

@end
