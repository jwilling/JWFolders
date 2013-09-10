`JWFolders` is a class that attempts to mimic the folder animation present on the iOS SpringBoard.

##Preview
`JWFolders` is being used in my commercial application, [QuickWeather](http://itunes.apple.com/us/app/quickweather/id414898317?mt=8). Depicted here is a beta version of the app:

![ExampleFolder](http://www.appjon.com/assets/github/jwfolders_quickweather.png)

##Usage
Just include the entire folder, `JWFolders`, in your project. Import `JWFolders.h` in the class in which you wish to create the folder.

  #import "JWFolders.h"

Here's a quick example of how to create a new folder and open it upwards.

```objective-c
JWFolders *folder = [JWFolders folder];
folder.contentView = self.sampleFolder.view;
folder.containerView = self.view;
folder.position = openPoint;
folder.direction = JWFoldersOpenDirectionUp;
folder.contentBackgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"noise"]];
folder.shadowsEnabled = YES;
folder.showsNotch = YES;
[folder open]; // opens the folder.
```

An issue can arise if the folder is set to show the notch, and the `position` is set to a point with an x-coordinate of 0. The notch will appear to be cut off on the left side of the screen. This can be simply resolved by providing a non-zero x-coordinate. Most likely this will be the center of the item from which you present the folder.

**Please check the header file for complete documentation.**


##ARC
The project currently uses [Automatic Reference Counting](http://clang.llvm.org/docs/AutomaticReferenceCounting.html), which means that if your project does not use ARC there will be memory leaks. There are no plans to create a non-ARC branch at this time.

##Important note

This library makes use of `CALayer`'s `renderInContext:` method to render the current state of your view into an image. Unfortunately, `renderInContext:` does not take 3D transforms into account. If you would like this to be fixed, please [file a radar](https://bugreport.apple.com).

##License
`JWFolders` is licensed under the [BSD License](http://www.opensource.org/licenses/bsd-license).

##Todo
- Finish implementing the animated notch content to complete the effect.
- Optimize the `renderInContext:` call. I fear this is impossible.

 Please feel free to fork the project and improve it as much as possible!

##About Me
I'm a developer and designer with a passion for great interface design and detail. See my [applications](http://appjon.com/applications.html), learn more [about me](http://appjon.com/about.html), or [get in touch](http://appjon.com/support.html). I'm on Twitter as well: [@willing](http://twitter.com/willing).
