# HTTPLayer
Straight to the Point HTTP Networking for JSON Services in Swift

![Platform](https://img.shields.io/cocoapods/p/HTTPLayer.svg)

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Credits](#credits)
- [Disclosure](#disclosure)
- [License](#license)

## Features

- [x] Easily to use and read Request / Response Methods
- [x] JSON Responses
- [x] Setting Hosts, Contexts and Headers only once and use it by Key Strings
- [x] GET Methods with Query and Path Parameters
- [x] POST Method with JSON Body
- [x] PUT Methods with JSON Body and/or Query and Path Parameters
- [x] DELETE Methods with JSON Body and/or Query and Path Parameters
- [ ] OPTION, HEAD, TRACE, CONNECT and PATCH methods
- [ ] HTTP Response Validation
- [ ] TLS Certificate and Public Key Pinning
- [ ] Unit and Integration Test Coverage

## Requirements

- iOS 10.0+ 
- Xcode 10.2+
- Swift 5+

## Installation

### CocoaPods

CocoaPods is a dependency manager for projects. For its documentation on Usage and Installation, visit this [site](https://cocoapods.org).

On your Podfile add:

```ruby
pod 'HTTPLayer'
```
On your Terminal, navigate to your project folder and run this command:

```bash
$ pod install
```

## Usage
### Configuration

On your AppDelegate file add:

```
import HTTPLayer

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    HTTP.config.{Configure any Hosts, Contexts and Headers you might use throughout your application}
    return true
}
```

On any class you might want, use the methods as bellow:

```
HTTP.request.get(...)
HTTP.request.post(...)
HTTP.request.put(...)
HTTP.request.delete(...)
```

## Credits

https://github.com/arcadekenan

## Disclosure

In case you believe you have found any issues and or vulnerability, feel free to reach to davibispo568@gmail.com or even submit a pull request.

## License

HTTPLayer is released under the MIT license.
