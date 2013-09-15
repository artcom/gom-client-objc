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

### RESTful operations

* GET/retrieve

    * Attribute retrieval:
    
    ```objective-c
    [gomClient retrieveAttribute:@"/areas/home/audio:volume" completionBlock:^(NSDictionary *result) {

        // result will be nil here when retrieving a non-existing attribute
        
    }];
    ```
    
    * Node retrieval:
  
    ```objective-c
    [gomClient retrieveNode:@"/areas/home/audio" completionBlock:^(NSDictionary *result) {
    
        // result will be nil here when retrieving a non-existing node

    }];

    ```

* POST/create
 
    * Create empty node:
    
    ```objective-c
    [gomClient createNode:@"/areas/home/audio" completionBlock:^(NSDictionary *result) {
        
    }];
    ```

    * Create node with attributes:
    
    ```objective-c
    NSDictionary *attributes = […];
    gomClient createNode:@"/areas/home/audio" withAttributes:attributes completionBlock:^(NSDictionary *result) {
        
    }];
    ```
    
* PUT/update
 
    * Attribute update:
    
    ```objective-c
    [gomClient updateAttribute:@"/areas/home/audio:volume" withValue:@"50" completionBlock:^(NSDictionary *result) {
        
    }];
    ```
    
    * Node update:
    
    ```objective-c
    NSDictionary *attributes = […];
    [gomClient updateNode:@"/areas/home/audio" withAttributesValue:attributes completionBlock:^(NSDictionary *result) {
        
    }];
    ```

* DELETE/destroy

    * Destroy existing node:
    
    ```objective-c
    [gomClient createNode:@"/areas/home/audio" completionBlock:completionBlock:^(NSDictionary *result) {
        
        // result will be nil here when destroying a non-existing attribute
        
    }];
    ```
    
    * Destroy non-existent node
    
    ```objective-c
    NSDictionary *attributes = […];
    [gomClient createNode:@"/areas/home/audio" withAttributes:attributes completionBlock:^(NSDictionary *result) {
        
        // result will be nil here when destroying a non-existing node
        
    }];
    ```

### Handling observers

* Register an observer:

    ```objective-c
    [gomClient registerGOMObserverForPath:@"/areas/home/audio:volume" options:nil clientCallback:^(NSDictionary *dict) {    

    }];
    ```

* Unregister an observer:

    ```objective-c
    [gomClient unregisterGOMObserverForPath:@"/areas/home/audio:volume" options:nil];
    ```

## TODO

* document content of response dictionaries.

## Demo app

* document usage of demo app.