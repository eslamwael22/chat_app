import 'package:chat_app/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/pages/users.dart';
import 'package:custom_form_w/custom_form_w.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignIn extends StatefulWidget {
  SignIn({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  
  @override
  void dispose() {
    widget.emailController.dispose();
    widget.passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation:0 ,
        elevation: 0,
        title: Text(
          'Login',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 25.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
          Image.asset(
            'assets/images/undraw_login_weas.png',
            width: 250.w,
            height: 250.h,
          ),
          SizedBox(height: 60.h),
          CustomFormW(
            showValidationSnackBar: true,
            spacing: 20.h,
            buttonText: isLoading ? 'Logging in...' : 'Login',
            onSubmit: isLoading ? null : () async {
              if (widget.emailController.text.trim().isEmpty ||
                  widget.passwordController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(widget.emailController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid email'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              if (widget.passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              setState(() {
                isLoading = true;
              });
              
              try {
                await FirebaseAuthService().login(
                  widget.emailController.text,
                  widget.passwordController.text,
                );
                
                // Wait a bit for auth state to update
                await Future.delayed(const Duration(milliseconds: 500));
                
                // Verify user is logged in before navigating
                final user = FirebaseAuth.instance.currentUser;
                if (user != null && mounted) {
                  print('Login successful, navigating to Users. User: ${user.uid}');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Users()),
                  );
                } else {
                  print('Login failed: user is null after login');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login failed: Please try again'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
              }
            },
            children: [
              CustomTextField(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 15.h,
                ),
                controller: widget.emailController,
                label: 'Email',
                hint: 'Enter your email',
                suffixIcon: Icon(Icons.email),
              ),
              CustomTextField(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 15.h,
                ),
                controller: widget.passwordController,
                label: 'Password',
                prefixIcon: Icon(Icons.password),
                hint: 'Enter your password',
                type: CustomTextFieldType.password,
                maxLines: 1,
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
