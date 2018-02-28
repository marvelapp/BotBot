import FluentProvider
import MySQLProvider
import LeafProvider
import Sessions

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        try setupMiddleware()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(SlackToken.self)
        preparations.append(MarvelToken.self)
    }

    private func setupMiddleware() throws {

        let memory = MemorySessions()
        
        let sessionsMiddleware = SessionsMiddleware(memory)
        self.addConfigurable(middleware: sessionsMiddleware, name: "session")

    }

}
