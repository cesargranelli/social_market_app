// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;

//   Future<void> _signInWithEmailAndPassword() async {
//     setState(() => _isLoading = true);
//     try {
//       await _auth.signInWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       // Navegar para a tela principal após o login
//       // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return;

//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//       await _auth.signInWithCredential(credential);
//     } on FirebaseAuthException catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Erro no Google Login: ${e.message}")),
//       );
//     }
//   }

//   Future<void> _signInWithFacebook() async {
//     setState(() => _isLoading = true);
//     try {
//       final LoginResult result = await FacebookAuth.instance.login();
//       final OAuthCredential credential = FacebookAuthProvider.credential(
//         result.accessToken!.token,
//       );
//       await _auth.signInWithCredential(credential);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Erro no Facebook Login: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Ofertaço - Login'), centerTitle: true),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                 labelText: 'E-mail',
//                 prefixIcon: Icon(Icons.email),
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'Senha',
//                 prefixIcon: Icon(Icons.lock),
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 30),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isLoading ? null : _signInWithEmailAndPassword,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                 ),
//                 child:
//                     _isLoading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text('Entrar'),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Navegar para tela de cadastro
//                 // Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
//               },
//               child: const Text('Criar conta'),
//             ),
//             const SizedBox(height: 20),
//             const Text('Ou entre com:'),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   onPressed: _isLoading ? null : _signInWithGoogle,
//                   icon: Image.asset('assets/images/google.png', height: 30),
//                 ),
//                 IconButton(
//                   onPressed: _isLoading ? null : _signInWithFacebook,
//                   icon: Image.asset('assets/images/facebook.png', height: 30),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
