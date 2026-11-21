
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_setup_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  static const green = Color(0xFF27843B);
  static const darkGreen = Color(0xFF164D2A);
  static const cream = Color(0xFFFFFDF4);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // FIREBASE SIGNUP
  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // VALIDATION
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      showMessage('Passwords do not match.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // CREATE FIREBASE ACCOUNT
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw Exception('Account creation failed.');
      }

      // SAVE USER NAME
      await user.updateDisplayName(name);
      await user.reload();

      if (!mounted) return;

      // NAVIGATE TO PROFILE SETUP
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileSetupPage(),
        ),
        (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered. Please log in.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;

        case 'operation-not-allowed':
          message = 'Email registration is not enabled in Firebase.';
          break;

        default:
          message = e.message ?? 'Registration failed.';
      }

      if (mounted) {
        showMessage(message);
      }

    } catch (e) {
      if (mounted) {
        showMessage('Something went wrong: $e');
      }

    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // SNACKBAR
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // REUSABLE INPUT FIELD
  Widget inputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool password = false,
    bool confirmPassword = false,
  }) {
    final hidden = password
        ? hidePassword
        : confirmPassword
            ? hideConfirmPassword
            : false;

    return TextField(
      controller: controller,
      obscureText: hidden,
      keyboardType: password || confirmPassword
          ? TextInputType.text
          : controller == emailController
              ? TextInputType.emailAddress
              : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF929292),
        ),
        prefixIcon: Icon(
          icon,
          color: green,
        ),
        suffixIcon: password || confirmPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    if (password) {
                      hidePassword = !hidePassword;
                    } else {
                      hideConfirmPassword = !hideConfirmPassword;
                    }
                  });
                },
                icon: Icon(
                  hidden
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color(0xFFE5E5E5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: green,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // FIELD LABEL
  Widget fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: darkGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // BACK BUTTON
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: darkGreen,
                  size: 28,
                ),
              ),

              const SizedBox(height: 15),

              // APP LOGO AND NAME
              Row(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF52B34B),
                          Color(0xFF18752F),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pushti Bondhu',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: darkGreen,
                        ),
                      ),
                      Text(
                        'Your AI nutrition companion',
                        style: TextStyle(
                          fontSize: 14,
                          color: green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // PAGE TITLE
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Join Pushti Bondhu and start your journey '
                'towards healthier living.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF555555),
                ),
              ),

              const SizedBox(height: 30),

              // FULL NAME
              fieldLabel('Full name'),

              const SizedBox(height: 10),

              inputField(
                hint: 'Enter your full name',
                icon: Icons.person,
                controller: nameController,
              ),

              const SizedBox(height: 22),

              // EMAIL
              fieldLabel('Email address'),

              const SizedBox(height: 10),

              inputField(
                hint: 'Enter your email',
                icon: Icons.email,
                controller: emailController,
              ),

              const SizedBox(height: 22),

              // PASSWORD
              fieldLabel('Password'),

              const SizedBox(height: 10),

              inputField(
                hint: 'Create a password',
                icon: Icons.lock,
                controller: passwordController,
                password: true,
              ),

              const SizedBox(height: 22),

              // CONFIRM PASSWORD
              fieldLabel('Confirm password'),

              const SizedBox(height: 10),

              inputField(
                hint: 'Re-enter your password',
                icon: Icons.lock_outline,
                controller: confirmPasswordController,
                confirmPassword: true,
              ),

              const SizedBox(height: 30),

              // CREATE ACCOUNT BUTTON
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: isLoading ? null : signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 25),

              // LOGIN LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 15),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        color: green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // FOOTER
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade400,
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Color(0xFFF59E0B),
                      size: 24,
                    ),
                  ),

                  const Text(
                    'Made for a healthier you',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}