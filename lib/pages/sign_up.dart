import 'package:chat_app/firebase_auth_service.dart';
import 'package:chat_app/pages/sign_in.dart';
import 'package:custom_form_w/custom_form_w.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;
  
  @override
  void dispose() {
    widget.emailController.dispose();
    widget.passwordController.dispose();
    widget.nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Create Account',
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
            'assets/images/undraw_access-account_aydp.png',
            width: 300.w,
            height: 300.h,
          ),
          CustomFormW(
            showValidationSnackBar: true,
            spacing: 20.h,
            buttonText: isLoading ? 'Creating Account...' : 'Create Account',
            onSubmit: isLoading ? null : () async {
              if (widget.nameController.text.trim().isEmpty ||
                  widget.emailController.text.trim().isEmpty ||
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
                await FirebaseAuthService().createAccount(
                  widget.emailController.text,
                  widget.passwordController.text,
                  widget.nameController.text,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Account created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Account creation failed: ${e.toString()}'),
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
                controller: widget.nameController,
                label: 'Name',
                hint: 'Enter your name',
                suffixIcon: Icon(Icons.person),
              ),
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
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(fontSize: 16.sp),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                  );
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
