#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "JWFolders.h"

@implementation ViewController
@synthesize sampleFolder = _sampleFolder;

- (void)viewDidLoad {
    self.sampleFolder = [[FolderViewController alloc] initWithNibName:nil bundle:nil];
}

#pragma mark - Folder Example

- (IBAction)openFolderUp:(id)sender {
    CGPoint openPoint = CGPointMake(CGRectGetWidth(self.view.frame) / 2, [sender frame].origin.y - 20);
    
    JWFolders *folder = [JWFolders folder];
    folder.contentView = self.sampleFolder.view;
    folder.containerView = self.view;
    folder.position = openPoint;
    folder.direction = JWFoldersOpenDirectionUp;
    folder.contentBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise"]];
    folder.shadowsEnabled = YES;
    folder.darkensBackground = NO;
    folder.showsNotch = YES;
    [folder open];
    
}

- (IBAction)openFolderUpColoredShadow:(id)sender {
    CGPoint openPoint = CGPointMake(CGRectGetWidth(self.view.frame) / 2, [sender frame].origin.y - 20);

    JWFolders *folder = [JWFolders folder];
    folder.contentView = self.sampleFolder.view;
    folder.containerView = self.view;
    folder.position = openPoint;
    folder.direction = JWFoldersOpenDirectionUp;
    folder.contentBackgroundColor = [UIColor colorWithWhite:0.90 alpha:1.0];
    folder.shadowsEnabled = YES;
    folder.shadowColor = [UIColor redColor];
    folder.darkensBackground = NO;
    folder.showsNotch = YES;
    [folder open];
}

- (IBAction)openFolderDown:(id)sender {
    CGPoint openPoint = CGPointMake(0, CGRectGetHeight(self.view.frame) / 2); //arbitrary point
    
    self.sampleFolder.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise"]];
    
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
