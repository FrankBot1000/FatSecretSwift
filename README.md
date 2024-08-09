# FatSecretSwift
A framework built to help connect to the FatSecret REST api. Originally built by Nicholas Bellucci with support for `foods.search` and `food.get`. It is extended here with support for 'recipe.search' and 'recipe.get'. You can find the original version here: https://github.com/NicholasBellucci/FatSecretSwift.git.

### Disclaimer

This framework is mainly a demonstration of how to use OAuth1 with FatSecret. More functionality will probably not be added but feel free to contribute.

## Requirements
Xcode 15.x or a Swift 5.x toolchain with Swift Package Manager.

## Installation

For use with an Xcode project, FatSecretSwift can be added by navigating to `File > Swift Packages > Add Package Dependency...` and adding `https://github.com/FrankBot1000/FatSecretSwift.git`

Xcode will give a few options when it comes to the rules. Feel free to choose between using the latest release or master as both should align.

FatSecretSwift can also be added through a `Package.swift` file. Just include `.package(url: "https://github.com/FrankBot1000/FatSecretSwift.git", from: "0.1.0")` as a dependency.


## Usage

First step is to initialize your personal credentials. In the example this is done in the AppDelegate but this can be done wherever so long as it is done before any API request.

``` swift
import FatSecretSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    enum Constants {
        static let apiKey = ""
        static let apiSecret = ""
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FatSecretCredentials.setConsumerKey(Constants.apiKey)
        FatSecretCredentials.setSharedSecret(Constants.apiSecret)

        return true
    }
}
```

Once this has been done requests can be made by initializing the FatSecretClient.

``` Swift
let fatSecretClient = FatSecretClient()
```

### Search Food/Recipe

``` Swift
fatSecretClient.searchFood(name: "Hotdog") { search in
    print(search.foods)
}
```

``` Swift
fatSecretClient.searchRecipe(name: "Hotdog") { search in
    print(search.recipes)
}
```

### Get Food/Recipe

``` Swift
fatSecretClient.getFood(id: "16758") { food in
    print(food)
}
```

``` Swift
fatSecretClient.getRecipe(id: "16758") { recipe in
    print(recipe)
}
```

## License

MIT licensed. See [LICENSE](LICENSE) for details.
