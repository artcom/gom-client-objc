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

```pod 'gom-client-objc', '~> 0.0.2'```
 
to your own Podfile and install all necessary dependencies from the CocoaPods dependency manager.

All dependencies are defined in the file ```gom-client-objc.podspec```

## Usage

### Initialization

```objective-c
NSURL *gomURI = [NSURL URLWithString:@"http://<ip-or-name>:<port>"];
GOMClient *gomClient = [[GOMClient alloc] initWithGomURI:gomURI];
gomClient.delegate = <your delegate object>;
```

As soon as the GOMClient object is initialized and completely set up the delegate will receive the message ```- (void)gomClientDidBecomeReady:(GOMClient *)gomClient``` returning a reference of the GOMClient object in question.

#### Errorhandling
Errors that occur during GOM requests are passed to the sender through the completion blocks of the respective methods.

Fundamental errors are returned to the delegate through the GOMClientDelegate message ```- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error```

### RESTful operations

* GET/retrieve

    * Attribute retrieval:
    
    ```objective-c
    [gomClient retrieve:@"/areas/home/audio:volume" completionBlock:^(NSDictionary *response) {

        // response will be nil here when retrieving a non-existing attribute
        
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
    (null)
    ```

    * Node retrieval:
  
    ```objective-c
    [gomClient retrieve:@"/areas/home/audio" completionBlock:^(NSDictionary *response) {
   
        // response will be nil here when retrieving a non-existing node
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
    (null)
    ```

* POST/create
 
    * Create empty node:
    
    ```objective-c
    gomClient create:@"/areas/home/audio" withAttributes:nil completionBlock:^(NSDictionary *response) {
        
    }];
    ```
    
    ```
    {node = {
        ctime = "2013-09-17T21:01:55+02:00";
        entries = (
        );
        mtime = "2013-09-17T21:01:55+02:00";
        uri = "/areas/home/audio_test/1b418710-4d08-493f-a89d-0e31ffbd56eb";
    }}
    ```

    * Create node with attributes:
    
    Currently not supported
    
    ```objective-c
    NSDictionary *attributes = […];
    gomClient create:@"/areas/home/audio" withAttributes:attributes completionBlock:^(NSDictionary *response) {
        
    }];
    ```
    
* PUT/update
 
    * Attribute update:
    
    ```objective-c
    [gomClient updateAttribute:@"/areas/home/audio:volume" withValue:@"50" completionBlock:^(NSDictionary *response) {
        
    }];        
    ```
    
    ```
    {status = 200}
    ```
    
    * Node update:
    
    Currently not supported
    
    ```objective-c
    NSDictionary *attributes = […];
    [gomClient updateNode:@"/areas/home/audio" withAttributesValue:attributes completionBlock:^(NSDictionary *response) {
        
    }];
    ```

* DELETE/destroy

    * Destroy existing attribute:
    
    ```objective-c
    [gomClient destroy:@"/areas/home/audio:volume" completionBlock:^(NSDictionary *response) {
        
    }];
    ```
    
    ```
    {"success" = 1}
    ```
    
    * Destroy existing node:
    
    ```objective-c
    [gomClient destroy:@"/areas/home/audio" completionBlock:^(NSDictionary *response) {
        
    }];
    ```
    
    ```
    {"success" = 1}
    ```
    
    * Destroy non-existing attribute:
    
    ```objective-c
    [gomClient destroy:@"/areas/home/audio_x:volume" completionBlock:^(NSDictionary *response) {
        
        // response will be nil here when retrieving a non-existing node
        
    }];
    ```
    
    ```
    (null)
    ```
    
    * Destroy non-existing node:
    
    ```objective-c
    [gomClient destroy:@"/areas/home/audio" completionBlock:^(NSDictionary *response) {
        
        // response will be nil here when retrieving a non-existing node
        
    }];
    ```
    
    ```
    (null)
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

## Demo app
Setting the GOM root address

![Setting the GOM root](https://github.com/artcom/gom-client-objc/raw/master/Documentation/images/screenshots/2_settings.png)

Startup

![Startup](https://github.com/artcom/gom-client-objc/raw/master/Documentation/images/screenshots/3_entry.png)

Accessing a GOM value

![Accessing GOM values](https://github.com/artcom/gom-client-objc/raw/master/Documentation/images/screenshots/4_accessing_gom_values.png)

Adding an observer

![Adding a GOM observer](https://github.com/artcom/gom-client-objc/raw/master/Documentation/images/screenshots/5_adding_observer.png)

List with observers

![GOM observer added](https://github.com/artcom/gom-client-objc/raw/master/Documentation/images/screenshots/6_added_observer.png)

Deleting an observer

![Deleting a GOM observer](https://github.com/artcom/gom-client-objc/raw/master/Documentation/images/screenshots/7_deleting_observer.png)

Receiving GNP data

![Displaying received GNP data](https://github.com/artcom/gom-client-objc/raw/master/Documentation/images/screenshots/8_receiving_GNP_data.png)
