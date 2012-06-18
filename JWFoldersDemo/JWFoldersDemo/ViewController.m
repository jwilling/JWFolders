#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "JWFolders.h"

@implementation ViewController
@synthesize sampleFolder = _sampleFolder;

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
    self.sampleFolder = [[FolderViewController alloc] initWithNibName:NSStringFromClass([FolderViewController class]) bundle:nil];
}

#pragma mark - Folder Example

- (IBAction)openFolderUp:(id)sender {
    NSLog(@"Folder will open up.");
    CGPoint openPoint = CGPointMake(0, CGRectGetHeight(self.view.frame) / 2); //arbitrary point
    [JWFolders openFolderWithContentView:self.sampleFolder.view
                                position:openPoint 
                           containerView:self.view 
                               openBlock:^(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
                                   //perform custom animation here on contentView if you wish
                                   NSLog(@"Folder view: %@ is opening with duration: %f", contentView, duration);
                               }
                              closeBlock:^(UIView *contentView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
                                  //also perform custom animation here on contentView if you wish
                                  NSLog(@"Folder view: %@ is closing with duration: %f", contentView, duration);
                              }
                         completionBlock:^ {
                             //the folder is closed and gone, lets do something cool!
                             NSLog(@"Folder view is closed.");
                         }
                               direction:JWFoldersOpenDirectionUp
     ];
}

- (IBAction)openFolderDown:(id)sender {
    NSLog(@"Folder will open down.");
    CGPoint openPoint = CGPointMake(0, CGRectGetHeight(self.view.frame) / 2); //arbitrary point
    
    // you can also open the folder this way
    // it could be potentially easier if you don't need the blocks
    JWFolders *folder = [JWFolders folder];
    folder.contentView = self.sampleFolder.view;
    folder.containerView = self.view;
    folder.position = openPoint;
    folder.direction = JWFoldersOpenDirectionDown;
    folder.transparentPane = YES;
    [folder open];
    
    // quick demo to demonstrate how the stationary pane is see-though
    [UIView animateWithDuration:0.3f animations:^{
        [(UIButton *)sender setTransform:CGAffineTransformRotate([(UIButton *)sender transform], M_PI*0.1f)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            [(UIButton *)sender setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI*0.1f)];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f animations:^{
                [(UIButton *)sender setTransform:CGAffineTransformIdentity];
            }];
        }];
    }];
}

@end
