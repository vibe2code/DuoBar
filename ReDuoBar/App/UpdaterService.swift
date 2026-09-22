import Foundation
import Sparkle

/// Wraps SPUStandardUpdaterController so the rest of the app
/// stays decoupled from Sparkle's API surface.
@MainActor
final class UpdaterService: NSObject, ObservableObject {
    private let updaterController: SPUStandardUpdaterController

    @Published private(set) var canCheckForUpdates = false

    override init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        super.init()
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .receive(on: RunLoop.main)
            .assign(to: &$canCheckForUpdates)
    }

    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
