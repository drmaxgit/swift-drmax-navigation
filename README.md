# DrMaxNavigation

DrMaxNavigation is a SwiftUI navigation library providing tools for modeling navigation style independent trees of destinations.

## Navigation tree

A navigation tree is a 2D collection of navigation destinations chained one after another. An Array is a tree (albeit a pretty boring one), which would represent screens pushed one after another. Multiple arrays being chained by their first and last elements is also a tree and would represent presenting multiple stacks over each other, such as using sheets or covers.

## Basic usage

An example of using the tools this library provides can be found in the [Examples](./Examples) folder.

This library ships two basic controllers:

- **RootNavigationController**
    - RootNavigationController is the entry point of your navigation. You specify the destinations it can navigate to and use the **RootNavigationControlletView** to show it on screen.
```swift
import DrMaxNavigation

enum DashboardScreen: Hashable {
    case dashboardRoot
    case productDetail
}

final class DashboardCoordinator {
    let controller = RootNavigationController<DashboardScreen>(root: .dashboardRoot)
}

struct DashboardCoordinatorView: View {
    let coordinator: DashboardCoordinator

    var body: some View {
        RootNavigationControllerView(
            controller: coordinator.controller
        ) { screen in
            switch screen {
                case .dashboardRoot: DashboardRootView()
                case .productDetail: ProductDetail()
            }
        }
    }
}
```
- **NavigationController**
    - NavigationController acts as a connector between two parts of the app which should not depend on each other. Imagine you have two Feature packages in your app with their destinations and you need to be able to push all of the destination onto the same stack without the two features knowing about each other.
    - NavigationController uses CasePaths to be able to embed smaller sub-destinations to a larger parent:
```swift
-- Login feature package
enum LoginScreen: Hashable {
    case signIn
    case forgotPassword
}

final class LoginCoordinator {
    let controller: NavigationController<LoginScreen>

    // LoginCoordinator can navigate only to its own destinations 👇

    func navigateToForgotPassword() {
        controller.navigate(to: .forgotPassword)
    }
}

// The package will generally provide Views the parent can use inside the RootNavigationControllerView screen closure:

public struct LoginCoordinatorView: View {
    let coordinator: LoginCoordinator

    // ... init

    public var body: some View {
        MenuRootView()
    }
}

public struct LoginScreenView View {
    let screen: LoginScreen

    // ... init

    public var body: some View {
        switch screen {
            case .signIn: SignInView()
            case .forgotPassword: ForgotPassword()
        }
    }
}

-- Profile feature package
enum ProfileScreen: Hashable {
    case myProfile
    case changeProfile
}

final class ProfileCoordinator {
    let controller: NavigationController<ProfileScreen>

    // ProfileCoordinator can navigate only to its own destinations 👇

    func navigateToChangeProfile() {
        controller.navigate(to: .changeProfile)
    }
}

-- Parent package, which imports both feature packages
enum MenuScreen: Hashable {
    case menu

    // You hold both the coordinator itself as well as the child screens as a case here.
    // This is to ensure that you can navigate to and retain a reference of the coordinator root, as well as scope to the child screens.

    case login(LoginCoordinator)
    case loginScreen(LoginScreen)

    case profile(ProfileCoordinator)
    case profileScreen(ProfileScreen)
}

final class MenuCoordinator {
    let controller = RootNavigationController<MenuScreen>(root: .menu)

    // MenuCoordinator can navigate to all of the MenuScreen destinations 👇

    func navigateToProfile() {
        let childController = controller.pullback(on: \.profileScreen)
        let coordinator = ProfileCoordinator(controller: childController)
        controller.navigate(to: .profile(coordinator: coordinator))
    }

    func navigateToLogin() {
        let childController = controller.pullback(on: \.loginScreen)
        let coordinator = LoginCoordinator(controller: childController)
        controller.navigate(to: .login(coordinator: coordinator), style: .sheet)
    }
}

struct MenuCoordinatorView: View {
    let coordinator: MenuCoordinator

    var body: some View {
        RootNavigationControllerView(
            controller: coordinator.controller
        ) { screen in
            switch screen {
                case .menu: MenuView()

                case let .login(coordinator): LoginCoordinatorView(coordinator: coordinator)
                case let .loginScreen(screen): LoginScreenView(screen: screen)

                ...profile destinations...
            }
        }
    }
}
```

**RootNavigationController** is designed to be used on the root of your navigation trees. Generally that will be for each tab of a TabView. **NavigationController** on the other hand is designed to be used as a connection between multiple parts of your app which want to be able to navigate to their destination.

## Navigation style independence
When working with vanilla SwiftUI navigation, you always have to know whether you have any presentation (sheet/cover/popover etc.) currently active before pushing to the stack, or you have to manually nest stacks and make sure to always push to the topmost one. This library hides this functionality so that you, as a developer, only ever have to call the `navigate` method and the desired destination will always be pushed/presented on top of current navigation.

The library is designed to shield you from having to care about the shape of you current navigation tree. It achieves this by making the state of your navigation be an implementation detail and only exposing a few methods to manipulate the navigation state, such as `navigate(to:style:animated:completion:)` or `pop{Before/To}(element:animated:completion)`.

Same goes for dismissing, where all you need to do is call the `pop{Before/To}` method and the library will search the tree and set the correct state.

## NavigationStyle

The library provides a `NavigationStyle` enum encapsulating all the styles of navigation supported. The style are `push`, `sheet`, `cover` and `popover`.

Notice the missing `alert` style. That is intended ', because presenting alerts is often a UI/UX functionality and not a proper navigation, so it is left to be handled by the View/model alone.

## Examples

The `Examples` directory contains the same demo running as two apps, showing push/sheet/popover/cover, composing independent "feature" modules via `pullback(on:)`, and pop/popToRoot/popBefore/popTo:

- `Examples/DrMaxNavigationDemoCore` — a plain Swift package with all the screens, coordinators and views. Both apps below depend on it; there's nothing platform-specific to run here directly.
- `Examples/DrMaxNavigationDemo.swiftpm` — an iOS app wrapping the demo. Open it in Xcode and run it on a simulator or device.

  Note: despite the `.swiftpm` extension (the same format Xcode uses to run Swift packages directly), this does **not** open in Apple's separate Swift Playgrounds app — that app bundles its own older Swift toolchain, incompatible with this package's `swift-tools-version`.
- `Examples/DrMaxNavigationDemoMac` — a native macOS app wrapping the same demo (no full screen cover, since that style doesn't exist on macOS). Run it with `swift run` from that directory.
