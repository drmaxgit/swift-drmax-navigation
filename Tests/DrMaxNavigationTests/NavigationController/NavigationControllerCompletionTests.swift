@_spi(Testing) @testable import DrMaxNavigation
import Testing

struct NavigationControllerCompletionTests {
    private let parent = RootNavigationController<Destination>()

    @Test
    func invokedWhenPushing() async {
        let controller = controller()
        
        await confirm { confirmation in
            controller.navigate(to: .childOne, style: .push) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingBeforeExistingElement() async {
        let controller = controller()
        controller.navigate(to: .childOne)
        
        await confirm { confirmation in
            controller.popBefore(\.childOne) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingBeforeNonExistingElement() async {
        let controller = controller()
        controller.navigate(to: .childOne)
        
        await confirm { confirmation in
            controller.popBefore(\.childTwo) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToOnlyElement() async {
        let controller = controller()
        controller.navigate(to: .childOne)
        
        await confirm { confirmation in
            controller.popTo(\.childOne) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingBeforePresentedElement() async {
        let controller = controller()
        controller.navigate(to: .childOne, style: .sheet)
        
        await confirm { confirmation in
            controller.popBefore(\.childOne) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToPresentedElement() async {
        let controller = controller()
        controller.navigate(to: .childOne, style: .sheet)
        
        await confirm { confirmation in
            controller.popTo(\.childOne) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToFirstElement() async {
        let controller = controller()
        controller.navigate(to: .childOne)
        controller.navigate(to: .childTwo)
        
        await confirm { confirmation in
            controller.popTo(\.childOne) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToNonExistingElement() async {
        let controller = controller()
        controller.navigate(to: .childOne)
        
        await confirm { confirmation in
            controller.popTo(\.childTwo) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingEmptyPath() async {
        let controller = controller()
        
        await confirm { confirmation in
            controller.pop {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingNonEmptyPath() async {
        let controller = controller()
        controller.navigate(to: .childOne, style: .push)
        controller.navigate(to: .childTwo, style: .push)
        
        await confirm { confirmation in
            controller.pop {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToRootEmptyPath() async {
        let controller = controller()
        
        await confirm { confirmation in
            controller.popToRoot {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToRootNonEmptyPath() async {
        let controller = controller()
        controller.navigate(to: .childOne, style: .push)
        controller.navigate(to: .childTwo, style: .push)
        
        await confirm { confirmation in
            controller.popToRoot {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToPresentationRootWithPresentation() async {
        let controller = controller()
        controller.navigate(to: .childOne, style: .sheet)
        
        await confirm { confirmation in
            controller.popToPresentationRoot {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToPresentationRootWithoutPresentation() async {
        let controller = controller()
        
        await confirm { confirmation in
            controller.popToPresentationRoot {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPresentingSheet() async {
        let controller = controller()
        
        await confirm { confirmation in
            controller.navigate(to: .childOne, style: .sheet) {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToPullbackRootNonExistingElement() async {
        let controller = controller()
        
        await confirm { confirmation in
            controller.popToPullbackRoot {
                confirmation()
            }
        }
    }
    
    @Test
    func invokedWhenPoppingToPullbackRootExistingElement() async {
        let controller = controller()
        controller.navigate(to: .childOne)
        
        await confirm { confirmation in
            controller.popToPullbackRoot {
                confirmation()
            }
        }
    }
    
    #if !os(macOS)
    @Test
    func invokedWhenPresentingCover() async {
        let controller = controller()
        
        await confirm { confirmation in
            controller.navigate(to: .childOne, style: .cover) {
                confirmation()
            }
        }
    }
    #endif
    
    #if !os(watchOS)
    @Test
    func invokedWhenPresentingPopover() async {
        let controller = controller()
        
        await confirm { confirmation in
            controller.navigate(to: .childOne, style: .popover) {
                confirmation()
            }
        }
    }
    #endif
    
    private func controller() -> NavigationController<Destination, ChildDestination> {
        parent.pullback(on: \.child)
    }
}
