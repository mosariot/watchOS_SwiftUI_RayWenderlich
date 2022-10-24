import SwiftUI
import AuthenticationServices

struct SignInView: View {
  @AppStorage("userName") private var storedUserName = ""
  @AppStorage("userCredential") private var userCredential = ""
  @Environment(\.dismiss) private var dismiss

  let onSignedIn: (String) -> Void
  
  private let nonce = UUID().uuidString
  
  var body: some View {
    ScrollView {
      Text("This action requires you to be signed in.")
        .font(.body)
      
      SignInWithAppleButton(onRequest: onRequest, onCompletion: siwaCompletion)
        .signInWithAppleButtonStyle(.white)
      
      Divider()
        .padding()
      
      PasswordView(
        userName: storedUserName,
        completionHandler: userPasswordCompletion
      )
    }
  }

  private func userPasswordCompletion(userName: String, password: String) {
    storedUserName = userName

    var request = URLRequest(url: URL(string: "https://your.site.com/login")!)
    request.httpMethod = "POST"
    // request.httpBody = ...

    DispatchQueue.main.async {
      onSignedIn("some token here")
      dismiss()
    }
  }
  
  private func onRequest(request: ASAuthorizationAppleIDRequest) {
    request.requestedScopes = [.fullName]
    request.state = "some state string"
    request.nonce = nonce
  }
  
  private func siwaCompletion(result: Result<ASAuthorization, Error>) {
    guard
      case .success(let success) = result,
      let credential = success.credential as? ASAuthorizationAppleIDCredential
    else {
      if case .failure(let failure) = result {
        print("Failed to authenticate: \(failure.localizedDescription)")
      }
      return
    }
    if credential.fullName == nil {
      // You've logged as an existing user account
    } else {
      // The user does not exist, so register a new account
    }
    userCredential = credential.user
    DispatchQueue.main.async {
      onSignedIn("some token here")
      dismiss()
    }
  }
}

struct SignInView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView { _ in }
  }
}
