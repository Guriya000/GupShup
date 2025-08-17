import 'package:chat/screens/chat_home.dart';
import 'package:chat/screens/login_screen.dart';
import 'package:chat/services/database.dart';
import 'package:chat/services/shared_pref.dart';
import 'package:chat/widgets/mybutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_string/random_string.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Variables to hold user input
  String _email = '';
  String _name = '';
  String _password = '';
  String _confirmPassword = '';
  // Controllers for text fields
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  // Method to handle sign up logic
  registration() async {
    try {
      // Validate input
      if (_email.isEmpty ||
          _name.isEmpty ||
          _password.isEmpty ||
          _confirmPassword.isEmpty) {
        throw Exception('All fields are required');
      }
      if (_password != _confirmPassword) {
        throw Exception('Passwords do not match');
      }

      // Here you would typically call your backend service to register the user
      // For example:
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      final String Id = randomAlphaNumeric(10);
      String username = _emailController.text.replaceAll("@gmail.com", "");
      // String updateUsername = user.replaceFirst(user[0], user[0].toUpperCase());
      String firstletter = username.substring(0, 1).toUpperCase();

      Map<String, dynamic> userinfoMap = {
        'email': _email,
        'Id': Id,
        'name': _nameController.text,
        'username': username,
        'searchkey': firstletter,
        'photoUrl':
            'https://www.gravatar.com/avatar/${_email.hashCode}?d=identicon',
      };

      // Save user details to Firestore
      await DatabaseMethod().adduserdetails(userinfoMap, Id);
      await SharedPreferenceHelper().saveUserId(Id);
      await SharedPreferenceHelper().saveUserName(username);
      await SharedPreferenceHelper().saveUserEmail(_emailController.text);
      await SharedPreferenceHelper().saveUserPhotoUrl(
        'https://www.gravatar.com/avatar/${_email.hashCode}?d=identicon',
      );
      await SharedPreferenceHelper().saveDisplayName(_nameController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,

          duration: Duration(seconds: 2),
          content: Text(
            'Registration successful!',
            style: GoogleFonts.oxanium(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );

      // Optionally, you can save the username to your database
      // For example:

      // await AuthService.register(_email, _username, _password);

      // If registration is successful, navigate to the login screen or home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors here, such as showing a dialog or snackbar
      if (e.code == "weak-password") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: Duration(seconds: 2),
            content: Text(
              'Password is too weak',
              style: GoogleFonts.oxanium(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      } else if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: Duration(seconds: 2),
            content: Text(
              'Email is already in use',
              style: GoogleFonts.oxanium(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration failed: ${e.message}',
              style: GoogleFonts.oxanium(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      // Handle any other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registration failed: $e',
            style: GoogleFonts.oxanium(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool obscureText = true; // password hidden by default

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
                  transform:
                      MediaQuery.of(context).platformBrightness ==
                          Brightness.dark
                      ? GradientRotation(2.5 * 3.14)
                      : GradientRotation(3.0),
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      'Welcome to GupShup',
                      style: GoogleFonts.oxanium(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign Up to get started',
                    style: GoogleFonts.oxanium(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 180, horizontal: 30),
              height: MediaQuery.of(context).size.height / 1.7,
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
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'Create an account',
                      style: GoogleFonts.oxanium(
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),

                          prefixIcon: Icon(
                            Icons.email,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          constraints: BoxConstraints(maxHeight: 60),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter your name'
                            : null,
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          constraints: BoxConstraints(maxHeight: 60),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        obscureText: obscureText,
                        obscuringCharacter: "•",

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          suffixIcon: GestureDetector(
                            child: Icon(
                              obscureText
                                  ? CupertinoIcons.eye_slash
                                  : Icons.remove_red_eye,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                            onTap: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          constraints: BoxConstraints(maxHeight: 60),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: TextFormField(
                        obscureText: obscureText,
                        obscuringCharacter: "•",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                          suffixIcon: GestureDetector(
                            child: Icon(
                              obscureText
                                  ? CupertinoIcons.eye_slash
                                  : Icons.remove_red_eye,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                            onTap: () {
                              setState(() {
                                obscureText = !obscureText;
                              });
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(),

                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          constraints: BoxConstraints(maxHeight: 60),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 20,
                        right: 20,
                      ),
                      child: MyButton(
                        buttonname: 'Sign Up',
                        onPressed: () {
                          // Handle sign up logic here
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              _email = _emailController.text.trim();
                              _name = _nameController.text.trim();
                              _password = _passwordController.text.trim();
                              _confirmPassword = _confirmPasswordController.text
                                  .trim();
                            });
                            registration();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.oxanium(
                      letterSpacing: 1,
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    child: Text(
                      "Login",
                      style: GoogleFonts.oxanium(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
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
