# Objective-C GOM Client

##Requirements
 * [CocoaPods dependency manager](http://cocoapods.org)
 * Xcode 4.5 or later

### Setting up for development

To setup the project for GOM client development open the terminal and clone the repo:

```$ git clone https://github.com/artcom/gom-client-objc.git```

and install all necessary dependencies from the CocoaPods dependency manager:

```$ pod install```

You can use the demo app contained in this project to run and test your work.

All dependencies are defined in the file `Podfile`

### Using the GOM client in your own app project 

To use the Objective-C GOM client in your own project add the line

```pod 'gom-client-objc', '~> 0.0.1'```
 
to your own Podfile and install all necessary dependencies from the CocoaPods dependency manager.

All dependencies are defined in the file ```gom-client-objc.podspec```

## Usage

### Initialization
```
NSURL *gomURI = [NSURL URLWithString:@"http://<ip-or-name>:<port>"];
GOMClient *gomClient = [[GOMClient alloc] initWithGomURI:gomURI];
gomClient.delegate = <your delegate object>;
```
As soon as the GOMCLient object is initialized and completely set up the delegate will receive the message ```- (void)gomClientDidBecomeReady:(GOMClient *)gomClient``` returning a reference of the GOMClient object in question.

#### Errorhandling
Errors that occur during GOM requests are passed to the sender through the completion blocks of the respective methods.

Fundamental errors are returned to the delegate through the GOMClientDelegate message ```- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error```


### retrieve

### create

### update

### delete

### registering observers
