/* 
 Copyright (c) 2011, Jonathan Willing
 All rights reserved.
 Licensed under the BSD License.
 http://www.opensource.org/licenses/bsd-license
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

@interface JWFolders : NSObject

/* 
 Description - Call this method to open the folder with the specified parameters.
 
 View: The view that you wish to add in the folder area.
 Position: The point where you wish to open the folder.
 Container: The view in which you are adding the folder.
 Sender: The class to which you wish to recieve notifications. 
 */
+ (void)openFolderWithView:(UIView *)view 
                atPosition:(CGPoint)position 
           inContainerView:(UIView *)containerView 
                    sender:(id)sender;

/* 
 Description - Call this method to open the folder with the specified parameters.
 
 View Controller: The view controller that you wish to add in the folder area.
 Position: The point where you wish to open the folder.
 Container: The view in which you are adding the folder.
 Sender: The class to which you wish to recieve notifications. 
 */
+ (void)openFolderWithViewController:(UIViewController *)viewController 
                          atPosition:(CGPoint)position 
                     inContainerView:(UIView *)containerView 
                              sender:(id)sender;


/* 
 Description - Call this method to close the folder with a completion block passed as the parameter.
 
 By default, the view contained in the folder is not removed.  During the completion block, the
 added view should be removed from the superview.
 */
+ (void)closeFolderWithCompletionBlock:(void (^)(void))block;

/*
 Description - Called when the top or bottom buttons trigger the -closeFolderWithCompletionBlock method.
 
 If the sender was passed in during one of the open folder methods, -folderWillClose will be called on the sender.
 If the sender implements this method, it is required to call the +closeFolderWithCompletionBlock manually.
 */
+ (void)folderWillClose:(id)aSender;

@end



/* For light highlight on folder buttons */
@interface JWFolderSplitView : UIControl
@property(nonatomic)BOOL isTop;
@property(nonatomic)CGPoint position;
@end
