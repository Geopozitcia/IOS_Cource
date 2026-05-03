import Foundation

final class AuthService {

    private enum Keys {
        static let login = "auth.login"
        static let password = "auth.password"
    }

    private enum Validation {
        static let minLength = 4
    }

    static let shared = AuthService()
    private init() {}

    var isRegistered: Bool {
        return UserDefaults.standard.string(forKey: Keys.login) != nil
    }

    func register(login: String, password: String) -> Bool {
        guard isValid(login: login, password: password) else { return false }
        UserDefaults.standard.set(login, forKey: Keys.login)
        UserDefaults.standard.set(password, forKey: Keys.password)
        return true
    }

    func login(login: String, password: String) -> Bool {
        guard isValid(login: login, password: password) else { return false }
        let savedLogin = UserDefaults.standard.string(forKey: Keys.login)
        let savedPassword = UserDefaults.standard.string(forKey: Keys.password)
        return login == savedLogin && password == savedPassword
    }

    func logout() {
        // we keep credentials - user can log back in
    }
}

private extension AuthService {

    func isValid(login: String, password: String) -> Bool {
        return login.count >= Validation.minLength && password.count >= Validation.minLength
    }
}
