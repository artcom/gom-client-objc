# Objective-C GOM Client

##Requirements
 * [CocoaPods dependency manager](http://cocoapods.org)
 * Xcode 4.5 or later

### Using the GOM client in your app project 

To use the Objective-C GOM client in your project add the line

```pod 'gom-client-objc', '~> 0.3.1'```
 
to your Podfile and install all necessary dependencies from the CocoaPods dependency manager.

All dependencies are defined in the file ```gom-client-objc.podspec```

## Usage

### Initialization

```objective-c
NSURL *gomURI = [NSURL URLWithString:@"http://<ip-or-name>:<port>"];
GOMClient *gomClient = [[GOMClient alloc] initWithGomURI:gomURI delegate:self];
```

As soon as the GOMClient object is initialized and completely set up the delegate will receive the message ```- (void)gomClientDidBecomeReady:(GOMClient *)gomClient``` returning a reference of the GOMClient object in question.

#### Errorhandling
Errors that occur during GOM requests are passed to the sender through the completion blocks of the respective methods.

Fundamental errors are returned to the delegate through the GOMClientDelegate message ```- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error```

### RESTful operations

* GET/retrieve

    * Attribute retrieval:
    
    ```objective-c
    [gomClient retrieve:@"/areas/home/audio:volume" completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here
        
    }];
    ```
    
    ```
    {attribute = {
        ctime = "2013-09-17T20:30:45+02:00";
        mtime = "2013-09-17T20:30:45+02:00";
        name = volume;
        node = "/areas/home/audio";
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
    [gomClient retrieve:@"/areas/home/audio" completionBlock:^(NSDictionary *response, NSError *error) {
   
        // Your code here

     }];
     ```

     ```
     {node =     {
        ctime = "2013-09-16T16:34:53+02:00";
        entries = (
            {
                ctime = "2013-09-10T17:11:35+02:00";
                mtime = "2013-09-10T17:11:35+02:00";
                node = "/areas/home/audio/presets";
            },
            {
                attribute = {
                    ctime = "2013-09-15T03:24:17+02:00";
                    mtime = "2013-09-15T03:24:17+02:00";
                    name = "default_volume";
                    node = "/areas/home/audio";
                    type = string;
                    value = 15;
                };
            },
            {
                attribute = {
                    ctime = "2013-09-17T16:31:58+02:00";
                    mtime = "2013-09-17T16:31:58+02:00";
                    name = preset;
                    node = "/areas/home/audio";
                    type = string;
                    value = schweigen;
                };
            },
            {
                attribute = {
                    ctime = "2013-09-17T20:30:45+02:00";
                    mtime = "2013-09-17T20:30:45+02:00";
                    name = volume;
                    node = "/areas/home/audio";
                    type = string;
                    value = 100;
                };
            }
        );
        mtime = "2013-09-16T16:34:53+02:00";
        uri = "/areas/home/audio";
    }}
    ```
    
    * Retrieve a non-existing node:
    
    ```
    NSError Domain=de.artcom.gom-client-objc Code=404 "not found"
    ```

* POST/create
 
    * Create empty node:
    
    ```objective-c
    gomClient create:@"/areas/home/audio/test" withAttributes:nil completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];
    ```
    
    ```
    {node = {
        ctime = "2013-09-17T21:01:55+02:00";
        entries = (
        );
        mtime = "2013-09-17T21:01:55+02:00";
        uri = "/areas/home/audio/test/1b418710-4d08-493f-a89d-0e31ffbd56eb";
    }}
    ```

    * Create node with attributes:
    
    ```objective-c
    NSDictionary *attributes = @{@"attribute1": @"value1", @"attribute2" : @"value2", @"attribute3" : @"value3"};
    gomClient create:@"/areas/home/audio/test" withAttributes:attributes completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];
    ```
    
    ```
    {node = {
        ctime = "2013-09-20T20:05:57+02:00";
        entries = (
            {
                attribute = {
                    ctime = "2013-09-20T20:05:57+02:00";
                    mtime = "2013-09-20T20:05:57+02:00";
                    name = attribute1;
                    node = "/areas/home/audio/test/ef84fd8c-701c-46cf-9f3e-02cc06e62a22";
                    type = string;
                    value = value1;
                };
            },
            {
                attribute = {
                    ctime = "2013-09-20T20:05:57+02:00";
                    mtime = "2013-09-20T20:05:57+02:00";
                    name = attribute2;
                    node = "/areas/home/audio/test/ef84fd8c-701c-46cf-9f3e-02cc06e62a22";
                    type = string;
                    value = value2;
                };
            },
            {
                attribute = {
                    ctime = "2013-09-20T20:05:57+02:00";
                    mtime = "2013-09-20T20:05:57+02:00";
                    name = attribute3;
                    node = "/areas/home/audio/test/ef84fd8c-701c-46cf-9f3e-02cc06e62a22";
                    type = string;
                    value = value3;
                };
            }
        );
        mtime = "2013-09-20T20:05:57+02:00";
        uri = "/areas/home/audio/test/ef84fd8c-701c-46cf-9f3e-02cc06e62a22";
    }}
    ```
    
* PUT/update
 
    * Attribute update:
    
    ```objective-c
    [gomClient updateAttribute:@"/areas/home/audio:volume" withValue:@"50" completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];        
    ```
    
    ```
    {status = 200}
    ```
    
    * Node update:
    
    ```objective-c
    NSDictionary *attributes = @{@"attribute1": @"100", @"attribute2" : @"200", @"attribute3" : @"300"};
    [gomClient updateNode:@"/areas/home/audio/test/ef84fd8c-701c-46cf-9f3e-02cc06e62a22" withAttributesValue:attributes completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];
    ```
    
    ```
    {status = 200}
    ```

* DELETE/destroy

    * Destroy existing attribute:
    
    ```objective-c
    [gomClient destroy:@"/areas/home/audio:volume" completionBlock:^(NSDictionary *response, NSError *error) {

        // Your code here

    }];
    ```
    
    ```
    {"success" = 1}
    ```
    
    * Destroy existing node:
    
    ```objective-c
    [gomClient destroy:@"/areas/home/audio" completionBlock:^(NSDictionary *response, NSError *error) {
        
        // Your code here

    }];
    ```
    
    ```
    {"success" = 1}
    ```
    
    * Destroy non-existing attribute:
    
    ```objective-c
    [gomClient destroy:@"/areas/home/audio:volume_x" completionBlock:^(NSDictionary *response, NSError *error) {
        
        // Your code here
        
    }];
    ```
    
    ```
    NSError Domain=de.artcom.gom-client-objc Code=404 "not found"
    ```
    
    * Destroy non-existing node:
    
    ```objective-c
    [gomClient destroy:@"/areas/home/audio_x" completionBlock:^(NSDictionary *response, NSError *error) {
        
        // Your code here
        
    }];
    ```
    
    ```
    NSError Domain=de.artcom.gom-client-objc Code=404 "not found"
    ```

### Handling observers

* Register an observer:

    ```objective-c
    [gomClient registerGOMObserverForPath:@"/areas/home/audio:volume" options:nil clientCallback:^(NSDictionary *dict) {

        // Your code here

    }];
    ```
    
    The first GOM notifcation is received immediately:
    
    ```
    {attribute = {
        ctime = "2013-09-15T23:21:03+02:00";
        mtime = "2013-09-15T23:21:03+02:00";
        name = volume;
        node = "/areas/home/audio";
        type = string;
        value = 60;
    }}
    ```

* Unregister an observer:

    ```objective-c
   [gomClient unregisterGOMObserverForPath:@"/areas/home/audio:volume" options:nil];
    ```

## Setting up for Client development

To setup the project for GOM client development open the terminal and clone the repo:

```$ git clone https://github.com/artcom/gom-client-objc.git```

and install all necessary dependencies from the CocoaPods dependency manager:

```
cd demo-projects/gom-client-demo_iOS
$ pod install
```

You can use the demo app contained in this project to run and test your work.

All dependencies are defined in the file `Podfile`

## Demo app
Setting the GOM root address:

![Setting the GOM root](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/1_settings.png)

Startup - The demo app offers input fields for GOM node or attriute and a value. Four buttons below represent the commands you can send to the GOM:

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


Adding an observer - Tap 'Manage Observers' to open the observer management view. Enter the path to the node or attribute and tap 'Add Observer':

![Adding a GOM observer](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/5_adding_observer.png)


List with observers - Registered observers will appear in the table above. Each additional observer on the same path will only increase the number of handles, shown as the item 'Handles':

![GOM observer added](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/6_added_observer.png)


Deleting an observer - Just swipe to the left and the 'Delete' button appears:

![Deleting a GOM observer](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/7_deleting_observer.png)


Receiving GNP data - When ever a GOM value changes the Demo app will receive and display the GNP data:

![Displaying received GNP data](https://github.com/artcom/gom-client-objc/raw/master/documentation/images/screenshots/8_receiving_GNP_data.png)
