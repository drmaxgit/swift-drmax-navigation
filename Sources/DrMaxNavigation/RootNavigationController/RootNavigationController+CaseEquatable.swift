extension RootNavigationController where Screen: CaseEquatable {
    public func navigate(
        to screen: Screen,
        style: NavigationStyle = .push,
        animated: Bool = true,
        allowsSameScreenNesting: Bool = true,
        completion: @escaping () -> Void = {}
    ) {
        if !allowsSameScreenNesting, let first = completePath.first(where: { $0.wrapped.equals(screen) }) {
            popBefore(first.wrapped) { [weak self] in
                self?.navigate(
                    to: screen,
                    style: style,
                    animated: animated,
                    completion: completion
                )
            }
        } else {
            navigate(
                to: screen,
                style: style,
                animated: animated,
                completion: completion
            )
        }
    }
}
