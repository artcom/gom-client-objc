# Objective-C GOM Client

[![Version](http://cocoapod-badges.herokuapp.com/v/gom-client-objc/badge.png)](http://cocoadocs.org/docsets/gom-client-objc)
[![Platform](http://cocoapod-badges.herokuapp.com/p/gom-client-objc/badge.png)](http://cocoadocs.org/docsets/gom-client-objc)

##Requirements
 * [CocoaPods dependency manager](http://cocoapods.org)
 * Xcode 4.5 or later

### Using the GOM client in your app project 

To use the Objective-C GOM client in your project add the line

<pre>
pod "gom-client-objc"
</pre>
 
to your Podfile and install all necessary dependencies from the CocoaPods dependency manager.

All dependencies are defined in the file ```gom-client-objc.podspec```

## Usage

### Initialization

```objective-c
NSURL *gomURI = [NSURL URLWithString:@"http://<ip-or-name>:<port>"];
GOMClient *gomClient = [[GOMClient alloc] initWithGomURI:gomURI delegate:self];
```

As soon as the GOMClient object is initialized and completely set up it will communicate its state through the `GOMClientDelegate` protocol method ```- (void)gomClientDidBecomeReady:(GOMClient *)gomClient``` returning a reference of the GOMClient object in question.

#### Errorhandling
Errors that occur during GOM requests are passed to the sender through the completion blocks of the respective methods.

Fundamental errors are returned to the delegate through the `GOMClientDelegate` protocol method ```- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error```

### RESTful operations

* GET/retrieve

    * Attribute retrieval:
    
    ```objective-c
    [gomClient retrieve:@"/tests/node_1:attribute_1" completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here
        
    }];
    ```
    
    ```
    {attribute = {
        ctime = "2013-12-29T17:48:52+01:00";
        mtime = "2013-12-29T17:48:52+01:00";
        name = "attribute_1";
        node = "/tests/node_1";
        type = string;
        value = 100;
    }}

    ```
    
    * Retrieve a non-existing attribute:
    
    ```
    NSError Domain=de.artcom.gom-client-objc Code=404 "not found"
    ```

    * Node retrieval:
  
    ```objective-c
    [gomClient retrieve:@"/tests/node_1" completionBlock:^(NSDictionary *response, NSError *error) {
   
        // Your code here

     }];
     ```

     ```
     {node = {
        ctime = "2013-12-29T17:49:07+01:00";
        entries = (
            {
                attribute = {
                    ctime = "2013-12-29T17:48:52+01:00";
                    mtime = "2013-12-29T17:48:52+01:00";
                    name = "attribute_1";
                    node = "/tests/node_1";
                    type = string;
                    value = 100;
                };
            },
            {
                attribute = {
                    ctime = "2013-12-29T17:49:00+01:00";
                    mtime = "2013-12-29T17:49:00+01:00";
                    name = "attribute_2";
                    node = "/tests/node_1";
                    type = string;
                    value = 20;
                };
            },
            {
                attribute = {
                    ctime = "2013-12-29T17:49:07+01:00";
                    mtime = "2013-12-29T17:49:07+01:00";
                    name = "attribute_3";
                    node = "/tests/node_1";
                    type = string;
                    value = 50;
                };
            }
        );
        mtime = "2013-12-29T17:49:07+01:00";
        uri = "/tests/node_1";
    }}
    ```
    
    * Retrieve a non-existing node:
    
    ```
    NSError Domain=de.artcom.gom-client-objc Code=404 "not found"
    ```

* POST/create
 
    * Create empty node:
    
    ```objective-c
    gomClient create:@"/tests/node_1/test" withAttributes:nil completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];
    ```
    
    ```
    {node = {
        ctime = "2013-12-29T17:54:16+01:00";
        entries = (
        );
        mtime = "2013-12-29T17:54:16+01:00";
        uri = "/tests/node_1/test/75d4fb2d-6b4d-4bc0-9e12-91817f90da1d";
    }}
    ```

    * Create node with attributes:
    
    ```objective-c
    NSDictionary *attributes = @{@"attribute1": @"value1", @"attribute2" : @"value2", @"attribute3" : @"value3"};
    gomClient create:@"/tests/node_1/test" withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];
    ```
    
    ```
    {node = {
        ctime = "2013-12-29T17:56:04+01:00";
        entries = (
            {
                attribute = {
                    ctime = "2013-12-29T17:56:04+01:00";
                    mtime = "2013-12-29T17:56:04+01:00";
                    name = attribute1;
                    node = "/tests/node_1/test/b382502c-6732-46ae-bef4-31d9d77ad97b";
                    type = string;
                    value = value1;
                };
            },
            {
                attribute = {
                    ctime = "2013-12-29T17:56:04+01:00";
                    mtime = "2013-12-29T17:56:04+01:00";
                    name = attribute2;
                    node = "/tests/node_1/test/b382502c-6732-46ae-bef4-31d9d77ad97b";
                    type = string;
                    value = value2;
                };
            },
            {
                attribute = {
                    ctime = "2013-12-29T17:56:04+01:00";
                    mtime = "2013-12-29T17:56:04+01:00";
                    name = attribute3;
                    node = "/tests/node_1/test/b382502c-6732-46ae-bef4-31d9d77ad97b";
                    type = string;
                    value = value3;
                };
            }
        );
        mtime = "2013-12-29T17:56:04+01:00";
        uri = "/tests/node_1/test/b382502c-6732-46ae-bef4-31d9d77ad97b";
    }}
    ```
    
* PUT/update
 
    * Attribute update:
    
    ```objective-c
    [gomClient updateAttribute:@"/tests/node_1:attribute_1" withValue:@"50" completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];        
    ```
    
    ```
    {status = 200}
    ```
    
    * Node update:
    
    ```objective-c
    NSDictionary *attributes = @{@"attribute1": @"100", @"attribute2" : @"200", @"attribute3" : @"300"};
    [gomClient updateNode:@"/tests/node_1/test/b382502c-6732-46ae-bef4-31d9d77ad97b" withAttributesValue:attributes completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];
    ```
    
    ```
    {status = 200}
    ```

* DELETE/destroy

    * Destroy existing attribute:
    
    ```objective-c
    [gomClient destroy:@"/tests/node_1:attribute_3" completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];
    ```
    
    ```
    {"success" = 1}
    ```
    
    * Destroy existing node:
    
    ```objective-c
    [gomClient destroy:@"/tests/node_1" completionBlock:^(NSDictionary *response, NSError *error) {
        
        // Your code here

    }];
    ```
    
    ```
    {"success" = 1}
    ```
    
    * Destroy non-existing attribute:
    
    ```objective-c
    [gomClient destroy:@"/tests/node_1:attribute_x" completionBlock:^(NSDictionary *response, NSError *error) {
        
        // Your code here
        
    }];
    ```
    
    ```
    NSError Domain=de.artcom.gom-client-objc Code=404 "not found"
    ```
    
    * Destroy non-existing node:
    
    ```objective-c
    [gomClient destroy:@"/tests/node_x" completionBlock:^(NSDictionary *response, NSError *error) {
        
        // Your code here
        
    }];
    ```
    
    ```
    NSError Domain=de.artcom.gom-client-objc Code=404 "not found"
    ```

### Handling observers

* Register an observer:

    ```objective-c
    [gomClient registerGOMObserverForPath:@"/tests/node_1:attribute_2" options:nil clientCallback:^(NSDictionary *dict) {

        // Your code here

    }];
    ```
    
    The first GOM notifcation is received immediately:
    
    ```
    {attribute = {
        ctime = "2013-12-29T18:00:27+01:00";
        mtime = "2013-12-29T18:00:27+01:00";
        name = "attribute_2";
        node = "/tests/node_1";
        type = string;
        value = 20;
    }}
    ```

* Unregister an observer:

    ```objective-c
   [gomClient unregisterGOMObserverForPath:@"/tests/node_1:attribute_2" options:nil];
    ```

## Setting up for client development

To setup the project for GOM client development open the terminal and clone the repo:

<pre>
$ git clone https://github.com/artcom/gom-client-objc.git
</pre>

and install all necessary dependencies from the CocoaPods dependency manager:

<pre>
$ cd demo-projects/gom-client-demo_iOS
$ pod install
</pre>

You can use the demo app contained in this project to run and test your work.

All dependencies are defined in the file `Podfile`

## Demo app
Setting the GOM root address:

![Setting the GOM root](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/1_settings.png)

Startup - the demo app offers input fields for GOM node or attriute and a value. Four buttons below represent the commands you can send to the GOM:

 * Retrieve
 * Create
 * Update
 * Del(ete)


All responses and GNPs from the GOM will appear in the output field above:

![Startup](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/2_entry.png)


Accessing a GOM value - just enter the path to the node or attribute and tap 'Retrieve':

![Accessing GOM values](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/3_accessing_gom_values.png)

The response from the GOM will appear in the output field above:

![Retrieving GOM values](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/4_retrieving_gom_values.png)


Adding an observer - tap 'Manage Observers' to open the observer management view. Enter the path to the node or attribute and tap 'Add Observer':

![Adding a GOM observer](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/5_adding_observer.png)


List with observers - registered observers will appear in the table above. Each additional observer on the same path will only increase the number of handles, shown as the item 'Handles':

![GOM observer added](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/6_added_observer.png)


Deleting an observer - just swipe to the left and the 'Delete' button appears:

![Deleting a GOM observer](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/7_deleting_observer.png)


Receiving GNP data - when ever a GOM value changes the demo app will receive and display the GNP data:

![Displaying received GNP data](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/8_receiving_GNP_data.png)
