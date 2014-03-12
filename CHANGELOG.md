# gom-client-objc CHANGELOG

## X.X.X

- Added methods to `GOMClientDelegate` protocol:

    ```objective-c
    - (BOOL)gomClientShouldReconnect:(GOMClient *)gomClient;
    - (BOOL)gomClient:(GOMClient *)gomClient shouldReRegisterObserverWithBinding:(GOMBinding *)binding;
    ```

which get called when the client loses connection to the GOM through its websocket.

- Improved unit tests


## 0.3.7

- Changed date properties on `GOMAttribute` and `GOMNode` classes from `NSString` to `NSDate`.
- Added `XSDDateTime` category on `NSDate` to parse XSD date time.
- Added unit tests for `NSDate+XSDDateTime`, `GOMAttribute` and `GOMNode`

## 0.3.6

- Using KVC to map NSDictionaries to `GOMNode` and `GOMAttribute`.
- Keypath search works as well.

## 0.3.5

- Added simple keypath search to `GOMNode`.
- Corrected typos on method name.

## 0.3.4

- Added `GOMAttribute` and `GOMNode` classes to map attributes and nodes.

## 0.3.3

- Updated project structure to cocoa pods convention.
