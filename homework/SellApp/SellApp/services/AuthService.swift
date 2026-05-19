import Foundation
final class AuthService {
    
    private enum Keys {
        static let login = "auth.login"
        static let password = "auth.password"
        static let isAutoLoginEnabled = "auth.isAutoLoginEnabled"
        static let isLoggedIn = "auth.isLoggedIn"
    }
    
    private enum Validation {
        static let minLength = 4
    }
    
    static let shared = AuthService()
    private init() {}
    
    var isAutoLoginEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isAutoLoginEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isAutoLoginEnabled) }
    }
    
    var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isLoggedIn) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isLoggedIn) }
    }
    
    var isRegistered: Bool {
        return UserDefaults.standard.string(forKey: Keys.login) != nil
    }
    
    func register(login: String, password: String) -> Bool {
        guard isValid(login: login, password: password) else { return false }
        UserDefaults.standard.set(login, forKey: Keys.login)
        UserDefaults.standard.set(password, forKey: Keys.password)
        isLoggedIn = true
        return true
    }
    
    func login(login: String, password: String) -> Bool {
        guard isValid(login: login, password: password) else { return false }
        let savedLogin = UserDefaults.standard.string(forKey: Keys.login)
        let savedPassword = UserDefaults.standard.string(forKey: Keys.password)
        
        let success = login == savedLogin && password == savedPassword
        if success {
            isLoggedIn = true 
        }
        return success
    }
    
    func logout() {
        isLoggedIn = false
    }
}

private extension AuthService {
    func isValid(login: String, password: String) -> Bool {
        return login.count >= Validation.minLength && password.count >= Validation.minLength
    }
}
