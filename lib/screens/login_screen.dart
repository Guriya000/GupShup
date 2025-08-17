import 'package:chat/screens/chat_home.dart';
import 'package:chat/screens/forget_password_screen.dart';
import 'package:chat/screens/signup.dart';
import 'package:chat/services/database.dart';
import 'package:chat/services/shared_pref.dart';
import 'package:chat/widgets/mybutton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";
  String name = "";
  String photo = "";
  String username = "";
  String id = "";

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userlogin() async {
    try {
      print("Logging in with email: $email");
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      print("Auth success! UID: ${userCredential.user?.uid}");

      QuerySnapshot querySnapshot = await DatabaseMethod().getuserbyemail(
        email.trim().toLowerCase(),
      );
      print("Firestore docs found: ${querySnapshot.docs.length}");

      if (querySnapshot.docs.isEmpty) {
        throw Exception(
          "User data not found in database. Check if the email exists and Firestore rules allow read access.",
        );
      }

      // Update local variables
      name = "${querySnapshot.docs[0]["name"]}";
      username = "${querySnapshot.docs[0]["username"]}";
      photo = "${querySnapshot.docs[0]["photoUrl"]}";
      id = querySnapshot.docs[0].id;

      // Save to SharedPreferences
      await SharedPreferenceHelper().saveDisplayName(name);
      await SharedPreferenceHelper().saveUserEmail(email);
      await SharedPreferenceHelper().saveUserId(id);
      await SharedPreferenceHelper().saveUserName(username);
      await SharedPreferenceHelper().saveUserPhotoUrl(photo);
      print("Data saved to SharedPreferences");

      // Navigate
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatHome()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed.";
      if (e.code == "user-not-found") {
        errorMessage = "User not found.";
      } else if (e.code == "wrong-password") {
        errorMessage = "Incorrect password!";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text(
            errorMessage,
            style: GoogleFonts.oxanium(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      );
      print("Auth error: ${e.code}");
    } on FirebaseException catch (e) {
      print("Firestore error: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,

          content: Text(
            "Database error: ${e.message}",
            style: GoogleFonts.oxanium(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      );
    } catch (e) {
      print("Unexpected error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          content: Text(
            "Login failed. Try again.",
            style: GoogleFonts.oxanium(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
  }

  bool obscureText = true;

  /// password hidden by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    MediaQuery.of(context).size.width,
                    105,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Text(
                          'Glad to see you again!',
                          style: GoogleFonts.oxanium(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Login to your account',
                          style: GoogleFonts.oxanium(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Add more widgets for login functionality here
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 180, horizontal: 30),
              height: MediaQuery.of(context).size.height / 2.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),

                child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your e-mail";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),

                          prefixIcon: Icon(
                            Icons.email,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          constraints: BoxConstraints(maxHeight: 60),
                        ),
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        obscureText: obscureText,
                        obscuringCharacter: "•",
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter you password";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                            child: Icon(
                              obscureText
                                  ? CupertinoIcons.eye_slash
                                  : Icons.remove_red_eye,

                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),

                          prefixIcon: Icon(
                            Icons.lock,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade500),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          constraints: BoxConstraints(maxHeight: 60),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Text(
                            "Forgot Password?",
                            style: GoogleFonts.oxanium(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 5),
                          GestureDetector(
                            child: Text(
                              "Reset",
                              style: GoogleFonts.oxanium(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryFixed,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgetPasswordScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      MyButton(
                        buttonname: 'Login',
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          email = emailController.text.trim();
                          password = passwordController.text.trim();
                          if (_formkey.currentState!.validate()) {
                            if (email.isNotEmpty && password.isNotEmpty) {
                              await userlogin();
                              await SharedPreferenceHelper().saveUserName(
                                username,
                              ); // Ensure this runs!
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  content: Text(
                                    "Logged in successfully",
                                    style: GoogleFonts.oxanium(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  content: Text(
                                    "Please enter both email and password.",
                                    style: GoogleFonts.oxanium(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 100,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: GoogleFonts.oxanium(
                      letterSpacing: 1,
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    child: Text(
                      " Sign Up",
                      style: GoogleFonts.oxanium(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Signup()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
