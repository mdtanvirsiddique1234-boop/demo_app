import 'signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:demo_app/firebase_options.dart';
import './home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PushtiBondhuApp());
}

class PushtiBondhuApp extends StatelessWidget {
  const PushtiBondhuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  static const green = Color(0xFF27843B);
  static const darkGreen = Color(0xFF164D2A);
  static const cream = Color(0xFFFFFDF4);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // LOGIN FUNCTION
  Future<void> login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect email or password.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget inputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool password = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: password && hidePassword,
      keyboardType:
          password ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF929292)),
        prefixIcon: Icon(icon, color: green),
        suffixIcon: password
            ? IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
      ),
    );
  }

  Widget leaf(double size, Color color) {
    return Icon(Icons.eco, size: size, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // APP LOGO
                Row(
                  children: [
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF52B34B), Color(0xFF18752F)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pushti Bondhu',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: darkGreen,
                            ),
                          ),
                          Text(
                            'Your AI nutrition companion',
                            style: TextStyle(
                              fontSize: 15,
                              color: green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // FOOD ILLUSTRATION
                Container(
                  height: 235,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFEAF6BD),
                        Color(0xFFB7DF86),
                        Color(0xFF8BCB75),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        right: 15,
                        child: leaf(60, Colors.white.withOpacity(0.35)),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 8,
                        child: leaf(65, green.withOpacity(0.25)),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 5,
                        child: leaf(50, Colors.white.withOpacity(0.4)),
                      ),

                      // FOOD BOWL
                      const Positioned(
                        left: 10,
                        bottom: 5,
                        child: SizedBox(
                          width: 205,
                          child: Column(
                            children: [
                              Text(
                                '🥬 🥕 🍅',
                                style: TextStyle(fontSize: 40),
                              ),
                              Text(
                                '🥑 🫑 🥦',
                                style: TextStyle(fontSize: 39),
                              ),
                              Text(
                                '🥣',
                                style: TextStyle(fontSize: 65),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // HEART
                      Positioned(
                        right: 18,
                        top: 28,
                        child: Icon(
                          Icons.favorite_border,
                          size: 75,
                          color: darkGreen.withOpacity(0.6),
                        ),
                      ),

                      // MESSAGE
                      Positioned(
                        right: 15,
                        bottom: 30,
                        child: Container(
                          width: 165,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cream,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Text(
                            'Eat smart.\nLive healthy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: darkGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // WELCOME
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your journey to better nutrition starts here.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF555555),
                  ),
                ),

                const SizedBox(height: 28),

                // EMAIL
                const Text(
                  'Email address',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),

                const SizedBox(height: 10),

                inputField(
                  hint: 'Enter your email',
                  icon: Icons.email,
                  controller: emailController,
                ),

                const SizedBox(height: 22),

                // PASSWORD
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),

                const SizedBox(height: 10),

                inputField(
                  hint: 'Enter your password',
                  icon: Icons.lock,
                  controller: passwordController,
                  password: true,
                ),

                const SizedBox(height: 8),

                // FORGOT PASSWORD
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
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
                            'Log In',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 22),

                // SIGN UP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // FOOTER
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade400),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFFF59E0B),
                        size: 24,
                      ),
                    ),
                    const Text(
                      'Made for a healthier you',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Divider(color: Colors.grey.shade400),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}