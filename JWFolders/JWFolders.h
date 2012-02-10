/* 
 Copyright (c) 2011, Jonathan Willing
 All rights reserved.
 Licensed under the BSD License.
 http://www.opensource.org/licenses/bsd-license
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
@class JWFolderSplitView, CAMediaTimingFunction;

typedef void (^JWFoldersCompletionBlock)(void);
typedef void (^JWFoldersCloseBlock)(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction);
typedef void (^JWFoldersOpenBlock)(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction);

@interface JWFolders : NSObject

/*
 Description:       The following are convenience methods that will create 
                    a JWFolders object which will handle the folder animation 
                    and removal for you.  All you are responsible for, as the 
                    sender, is to pass in (at minimum) the content view, position, 
                    and container view.  The rest are optional.
 
 ****Required Parameters****
 Content View:      This is the view that you wish to be embedded in between 
                    two folder-style panels.
 
 Container View:    This is the view in which you wish the folders to be added 
                    as a subview of. Behaviour when the container view is 
                    smaller than the content view is undefined.
 
 Position:          The position is used to determine where the folders should
                    be opened.  In later updates the x-coordinate will be used 
                    to create a "notch", similar to the iOS Springboard. The 
                    position should be relative to the container view.
 
 ****Optional Parameters****
 Sender:            The sender is currently not used, although in the future
                    it could be used for delegate callbacks, which have been
                    replaced by blocks in this version.
 
 Open Block:        The open block will be run when the animation of opening
                    the folder is about to be performed.  Use this opportunity
                    to perform animations and other custom behaviour on the
                    content view. Use the passed-in reference to the content view.
 
 Close Block:       The close block will be run when the animation of closing
                    the folder is about to be performed.  Use this opportunity
                    to perform animations and other custom behaviour on the
                    content view. Use the passed-in reference to the content veiw.
 
 Completion Block:  The completion block is called when the folder has been 
                    closed, and all views have been removed from the container
                    view.  Use this opportunity to perform updates in your UI
                    if needed.
 
 */

+ (void)openFolderWithContentView:(UIView *)contentView 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock
                       closeBlock:(JWFoldersCloseBlock)closeBlock
                  completionBlock:(JWFoldersCompletionBlock)completionBlock;

+ (void)openFolderWithContentViewController:(UIViewController *)viewController
                                   position:(CGPoint)position
                              containerView:(UIView *)containerView
                                     sender:(id)sender;

+ (void)openFolderWithContentView:(UIView *)view
                         position:(CGPoint)position
                    containerView:(UIView *)containerView
                           sender:(id)sender;

+ (void)openFolderWithContentView:(UIView *)view 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                       closeBlock:(JWFoldersCloseBlock)closeBlock;

+ (void)openFolderWithContentView:(UIView *)view 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock;

+ (void)openFolderWithContentView:(UIView *)view 
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                           sender:(id)sender 
                        openBlock:(JWFoldersOpenBlock)openBlock
                       closeBlock:(JWFoldersCloseBlock)closeBlock;

/* This attempts to close the folder that is currently displaying. */
+ (void)closeCurrentFolder;



/* Removed methods - will be completely eliminated in next release */
+ (void)openFolderWithView:(UIView *)view 
                atPosition:(CGPoint)position 
           inContainerView:(UIView *)containerView 
                    sender:(id)sender UNAVAILABLE_ATTRIBUTE;
+ (void)openFolderWithViewController:(UIViewController *)viewController 
                          atPosition:(CGPoint)position 
                     inContainerView:(UIView *)containerView 
                              sender:(id)sender UNAVAILABLE_ATTRIBUTE;
+ (void)closeFolderWithCompletionBlock:(void (^)(void))block UNAVAILABLE_ATTRIBUTE;
+ (void)folderWillClose:(id)aSender UNAVAILABLE_ATTRIBUTE;


@end


/* For light highlight on folder buttons */
@interface JWFolderSplitView : UIControl
@property(nonatomic)BOOL isTop;
@property(nonatomic)CGPoint position;
@end
