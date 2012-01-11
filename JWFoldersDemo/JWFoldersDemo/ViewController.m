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
    [JWFolders openFolderWithViewController:sampleFolder atPosition:openPoint inContainerView:self.view sender:self];    
}

- (void)folderWillClose:(id)sender {
    NSLog(@"Folder will close.");
    [JWFolders closeFolderWithCompletionBlock:^{
        if (sampleFolder)
            [sampleFolder.view removeFromSuperview], sampleFolder = nil;
        NSLog(@"Folder closed.");
    }];
    
}


@end
