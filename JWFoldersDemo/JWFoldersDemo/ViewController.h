#import <UIKit/UIKit.h>
#import "FolderViewController.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) FolderViewController *sampleFolder;

- (IBAction)openFolderDown:(id)sender;
- (IBAction)openFolderUp:(id)sender;

@end
