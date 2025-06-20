import 'package:event_booking/views/user/LandingPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:event_booking/views/user/RegisterPage.dart';
import 'package:event_booking/controller/AuthController.dart'; // Google Sign-In
import 'package:event_booking/controller/UserController.dart'; // Email/Password Login

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void login() async {
    final userController = Get.find<UserController>();

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Email and password are required");
      return;
    }

    await userController.loginUser(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1F),
      body: SafeArea(
        child: Stack(
          children: [
            // Back Button in top-left
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LandingPage()),
                  );
                },
              ),
            ),

            // Centered Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Centered Gradient Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF4C5DAA), Color(0xFFF687FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Text Fields
                      buildTextField("Email", emailController, Icons.email),
                      const SizedBox(height: 16),
                      buildTextField("Password", passwordController, Icons.lock,
                          obscure: true),
                      const SizedBox(height: 24),

                      // Login Button
                      Obx(() {
                        return ElevatedButton(
                          onPressed:
                              userController.isLoading.value ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: userController.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.black)
                              : const Text("Login",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black)),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Google Sign-In
                      Obx(() {
                        return ElevatedButton.icon(
                          onPressed: authController.isLoading.value
                              ? null
                              : authController.signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F8FFF),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: authController.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.login, color: Colors.white),
                          label: Text(
                            authController.isLoading.value
                                ? 'Signing in...'
                                : 'Continue with Google',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Register Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()));
                        },
                        child: const Text(
                          "Don't have an account? Register",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1C2233),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
