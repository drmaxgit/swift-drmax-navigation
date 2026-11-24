import CasePaths
import DrMaxNavigation
import Observation

/*
Every coordinator needs a parent generic to function, so that it can hold onto a NavigationController scoped to
its destinations. You always create a {Coordinator name}Destination enum (FeedDestination in this case), which lists all the destinations this coordinator
can navigate to. Besides these two files, it is also advised to create a {Coordinator name}DestinationView (FeedDestinationView) which takes in the destination
and switches over it, so that it is easy for the parent to use it inside their RootNavigationControllerView content, and  {Coordinator name}CoordinatorView (FeedCoordinatorView)
which takes in the coordinator and defines what is the appropriate start destination, in this case it is the FeedView, which gets the feedModel passed in.
*/

@Observable
final class FeedCoordinator<ParentDestination: Hashable & CasePathable & FeedDestinationProviding>: HashableObject {
    let controller: NavigationController<ParentDestination, FeedDestination>
    let feedModel: FeedModel
    
    /*
    Coordinators should not generally depend on each other, because it's very easy to create
    cyclic dependencies and a coordinator should not ever care what a different coordinator does.
    
    Therefore we let the root coordinator handle navigating between siblings.
    */
    enum DelegateAction {
        case navigateToLogin
    }
    
    var delegate: (DelegateAction) -> Void = { reportUnimplemented($0) }
    
    init(
        controller: NavigationController<ParentDestination, FeedDestination>
    ) {
        self.controller = controller
        
        self.feedModel = FeedModel()
        
        feedModel.delegate = { [weak self] action in
            self?.handleFeedModelDelegate(action: action)
        }
    }
    
    private func navigateToSourceDetail(name: String) {
        let model = SourceDetailModel(sourceName: name)
        
        model.delegate = { [weak self] action in
            self?.handleSourceDetailModelDelegate(action: action)
        }
        
        controller.navigate(to: .sourceDetail(model))
    }
    
    private func navigateToArticleDetail(article: Article) {
        let model = ArticleDetailModel(article: article)
        
        model.delegate = { [weak self] action in
            self?.handleArticleDetailModelDelegate(action: action)
        }
        
        controller.navigate(to: .articleDetail(model))
    }
    
    private func navigateToAuthorDetail(name: String) {
        let model = AuthorDetailModel(authorName: name)
        
        model.delegate = { [weak self, weak model] action in
            self?.handleAuthorDetailModelDelegate(action: action, from: model)
        }
        
        controller.navigate(to: .authorDetail(model), style: .sheet)
    }
    
    func dismissAuthorDetail(model: AuthorDetailModel) {
        controller.parent?.popBefore(.feed(.authorDetail(model)))
    }
}

// MARK: - Delegate
private extension FeedCoordinator {
    func handleFeedModelDelegate(action: FeedModel.DelegateAction) {
        switch action {
        case .navigateToArticle(let article):
            navigateToArticleDetail(article: article)
        case .navigateToSource(let name):
            navigateToSourceDetail(name: name)
        case .navigateToAuthor(let name):
            navigateToAuthorDetail(name: name)
        case .navigateToLogin:
            delegate(.navigateToLogin)
        }
    }
    
    func handleAuthorDetailModelDelegate(
        action: AuthorDetailModel.DelegateAction,
        from model: AuthorDetailModel?
    ) {
        switch action {
        case .navigateToArticle(let article):
            navigateToArticleDetail(article: article)
        case .navigateToAuthor(let name):
            navigateToAuthorDetail(name: name)
        case .navigateToSource(let name):
            navigateToSourceDetail(name: name)
        case .dismiss:
            guard let model else { return }
            dismissAuthorDetail(model: model)
        }
    }
    
    func handleArticleDetailModelDelegate(action: ArticleDetailModel.DelegateAction) {
        switch action {
        case .navigateToAuthorDetail(let name):
            navigateToAuthorDetail(name: name)
        case .navigateToSourceDetail(let name):
            navigateToSourceDetail(name: name)
        }
    }
    
    func handleSourceDetailModelDelegate(action: SourceDetailModel.DelegateAction) {
        switch action {
        case .navigateToArticle(let article):
            navigateToArticleDetail(article: article)
        case .navigateToSource(let name):
            navigateToSourceDetail(name: name)
        case .navigateToAuthor(let name):
            navigateToAuthorDetail(name: name)
        }
    }
}
