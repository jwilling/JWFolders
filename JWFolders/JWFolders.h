/* 
 Copyright (c) 2011, Jonathan Willing
 All rights reserved.
 Licensed under the BSD License.
 http://www.opensource.org/licenses/bsd-license
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>

@class CAMediaTimingFunction;

typedef void (^JWFoldersCompletionBlock)(void);
typedef void (^JWFoldersCloseBlock)(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction);
typedef void (^JWFoldersOpenBlock)(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction);

enum JWFoldersOpenDirection {
    JWFoldersOpenDirectionUp = 1,
    JWFoldersOpenDirectionDown = 2
};
typedef NSInteger JWFoldersOpenDirection;


@interface JWFolders : NSObject

/* The view to be embedded between 
 * two folder-style panels. 
 *
 * REQUIRED */
@property (nonatomic, strong) UIView *contentView;


/* This is the view in which you wish the folders to be 
 * added as a subview of. Behaviour when the container 
 * view is smaller than the content view is undefined. 
 *
 * REQUIRED */
@property (nonatomic, strong) UIView *containerView;


/* The position is used to determine where the folders should
 * be opened.  In later updates the x-coordinate will be used
 * to create a "notch", similar to the iOS Springboard. The
 * position should be relative to the container view. 
 *
 * REQUIRED*/
@property (nonatomic, readwrite) CGPoint position;

/* The key of the shared instance
 * REQUIRED*/
@property (nonatomic, strong) NSString *key;

/* Set the direction for the slide.
 * Default is to slide upwards. */
@property (nonatomic, readwrite) JWFoldersOpenDirection direction;


/* The following blocks are called at specific
 * times during the lifetime of the folder.
 * 
 * The open & close blocks are called immediately before
 * the folder is about to open or close, respectively.
 *
 * The completion block is called when all views
 * have been removed, and the folder is completely closed.
 */
@property (nonatomic, copy) JWFoldersOpenBlock openBlock;
@property (nonatomic, copy) JWFoldersCloseBlock closeBlock;
@property (nonatomic, copy) JWFoldersCompletionBlock completionBlock;


/* Convenience method for singleton instance. */
+ (id)folderForKey:(NSString*) key;


/* Opens the folder.  Be sure the required properties are set! */
- (void)open;


/* Closes the currently open folder. */
+ (void)closeFolderForKey:(NSString*) key;


/* Convenience method to open a folder without
 * the hassle of setting properties. */
+ (void)openFolderWithContentView:(UIView *)contentView
                           forKey:(NSString*)key
                         position:(CGPoint)position 
                    containerView:(UIView *)containerView 
                        openBlock:(JWFoldersOpenBlock)openBlock
                       closeBlock:(JWFoldersCloseBlock)closeBlock
                  completionBlock:(JWFoldersCompletionBlock)completionBlock
                        direction:(JWFoldersOpenDirection)direction;

@end