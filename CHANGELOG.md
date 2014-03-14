# gom-client-objc CHANGELOG

## 0.5.1

- Fixed GNP handling. Response dictionaries have top-level key named after operation:
    - create
    - update
    - delete

## 0.5.0

- Added new methods to `GOMClientDelegate` protocol:

    ```objective-c
    - (BOOL)gomClientShouldReconnect:(GOMClient *)gomClient
    - (BOOL)gomClient:(GOMClient *)gomClient shouldReRegisterObserverWithBinding:(GOMBinding *)binding;
    ```

    which get called when the client's websocket fails / reconnects to the GOM.

- Private methods are public now:
    
    ```objective-c
    - (void)disconnectWebSocket
    - (void)reconnectWebSocket
    ```

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
