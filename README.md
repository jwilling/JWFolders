##Information
`JWFolders` is a class that attempts to mimic the folder animation present on the iOS SpringBoard.  This is my first public repository, as well as my first open-source class.

##Preview
`JWFolders` is being used in my commercial app, [QuickWeather](http://itunes.apple.com/us/app/quickweather/id414898317?mt=8).  Depicted here is a beta version of the app:

![ExampleFolder](http://www.appjon.com/assets/QuickWeather_folder.png)

##Usage
Just include the entire folder, `JWFolders`, in your project.  Import `JWFolders.h` in the class in which you wish to create the folder.

    #import "JWFolders.h"

In the header there is complete documentation.  Alternatively, you can see the demo project for an example.

##ARC
The project currently uses [Automatic Reference Counting](http://clang.llvm.org/docs/AutomaticReferenceCounting.html), which means that if your project does not use ARC there will be memory leaks.  There are no plans to create a non-ARC branch at this time.

##License
`JWFolders` is licensed under the [BSD License](http://www.opensource.org/licenses/bsd-license).

##ToDo
- Add a "notch" at the folder position
- Optimize the speed at which the folder opens

 Please feel free to fork the project and improve it as much as possible!

##About Me
I'm an 18-year-old developer and designer with a passion for great interface design and detail.  See my [applications](http://appjon.com/applications.html), learn more [about me](http://appjon.com/about.html), or [get in touch](http://appjon.com/support.html).
