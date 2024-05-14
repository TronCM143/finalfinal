import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  // Google sign in
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      return null;
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  // Apple sign in
  Future<UserCredential?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
        clientId: 'your_client_id', // Replace with your client ID
        redirectUri: Uri.parse('your_redirect_uri'), // Replace with your redirect URI
      ),
      );

      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
      final credentialFirebase = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      return await FirebaseAuth.instance
          .signInWithCredential(credentialFirebase);
    } catch (error) {
      print("Sign in with Apple failed: $error");
      return null;
    }
  }
}
