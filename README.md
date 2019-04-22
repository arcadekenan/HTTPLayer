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

- [x] Easy to use and read Request / Response Methods
- [x] JSON Responses
- [x] Setting Hosts, Contexts and Headers only once and use it by a Key defined by you
- [x] GET Methods with Query and Path Parameters
- [x] POST Method with JSON Body
- [x] PUT Methods with JSON Body and/or Query and Path Parameters
- [x] DELETE Methods with JSON Body and/or Query and Path Parameters
- [X] Unit and Integration Test Coverage
- [ ] OPTION and PATCH methods
- [ ] HTTP Response Validation
- [ ] Custom Error Response
- [ ] TLS Certificate and Public Key Pinning

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

To use HTTPLayer you just need to add its import on any class you might want.
```swift
import HTTPLayer
```

It is recommended to configure all your hosts, contexts and headers on the AppDelegate file, like the example bellow:

- Inside the " func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {} " add configuration like:
```swift
//For adding Hosts and Context or Headers
HTTP.Config.add

//For setting multiplus Hosts and Context or Headers at once
HTTP.Config.set

//For changing already added Headers
HTTP.Config.change

//For removing any Header that has already been added
HTTP.Config.remove

```

These are the already implemented methods that you can choose from. All of them are accessable through "HTTP.Request" and all of them are documented and avaliable on the Xcode Autocomplete Shortcut. (E and D stands for Generic Object that conforms to Encodable for E and Decodable for D)

-  GET
```swift
//Without Parameters:
HTTP.Request.get(from: String, withHostAndContext: String, andHeaders: String, receivingObjectType: D, completion: (Result<D, Error>) -> ())

//Path Parameters:
HTTP.Request.get(from: String, usingPathParameters: [String]?, fromHostAndContext: String, andHeaders: String?, receivingObjectType: D, completion: (Result<D, Error>) -> ())

//Query Parameters:
HTTP.Request.get(from: String, usingQueryParameters: [String : String]?, fromHostAndContext: String, andHeaders: String?, receivingObjectType: D, completion: (Result<D, Error>) -> ())
```

- POST
```swift
HTTP.Request.post(to: String, withBody: Encodable, fromHostAndContext: String, andHeaders: String?, receivingObjectType: D, completion: (Result<D, Error>) -> ())
```

- PUT
```swift
//Path Parameters:
HTTP.Request.put(on: String, withBody: E, andPathParameters: [String]?, fromHostAndContext: String, andHeaders: String?, receivingObjectType: D, completion: (Result<D, Error>) -> ())

//Query Parameters:
HTTP.Request.put(on: String, withBody: E, andQueryParameters: [String : String]?, fromHostAndContext: String, andHeaders: String?, receivingObjectType: D, completion: (Result<D, Error>) -> ())
```

- DELETE
```swift
//Path Parameters
HTTP.Request.delete(from: String, withPathParameters: [String]?, fromHostAndContext: String, andHeaders: String?, receivingObjectType: D, completion: (Result<D, Error>) -> ())

//Query Parameters
HTTP.Request.delete(from: String, withQueryParameters: [String : String]?, fromHostAndContext: String, andHeaders: String?, receivingObjectType: D, completion: (Result<D, Error>) -> ())
```

## Credits

https://github.com/arcadekenan

## Disclosure

In case you believe you have found any issues and or vulnerability, feel free to reach to davibispo568@gmail.com or even submit a pull request.

## License

HTTPLayer is released under the MIT license.
