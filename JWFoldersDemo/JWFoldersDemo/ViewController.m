#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "JWFolders.h"

@implementation ViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wallpaper"]];
}

#pragma mark - Folder Example

- (IBAction)openFolder:(id)sender {
    NSLog(@"Folder will open.");
    sampleFolder = [[FolderViewController alloc] initWithNibName:NSStringFromClass([FolderViewController class]) bundle:nil];
    CGPoint openPoint = CGPointMake(40.0f, 250.0f); //arbitrary point
    [JWFolders openFolderWithContentView:sampleFolder.view
                                position:openPoint 
                           containerView:self.view 
                                  sender:self 
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
     ];
}


@end
