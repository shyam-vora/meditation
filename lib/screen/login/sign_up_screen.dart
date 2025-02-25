import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meditation/common/color_extension.dart';
import 'package:meditation/common/common_widget/round_button.dart';
import 'package:meditation/common/common_widget/round_text_field.dart';
import 'package:meditation/screen/main_tabview/main_tabview_screen.dart';
import 'package:meditation/services/auth/auth_repository.dart';

class SignUpScreen extends StatefulWidget {
  final bool isFromLogin;
  const SignUpScreen({super.key, this.isFromLogin = true});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isTrue = false;
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: context.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.asset(
                    "assets/img/login_top.png",
                    width: double.maxFinite,
                    fit: BoxFit.fitWidth,
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                context.pop();
                              },
                              child: Image.asset(
                                "assets/img/back.png",
                                width: 55,
                                height: 55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Text(
                        "Create your account",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MaterialButton(
                          onPressed: () {},
                          minWidth: double.maxFinite,
                          elevation: 0,
                          color: const Color(0xff8E97FD),
                          height: 60,
                          shape: RoundedRectangleBorder(
                              side: BorderSide.none,
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              Image.asset(
                                'assets/img/fb.png',
                                width: 25,
                                height: 25,
                              ),
                              const Expanded(
                                child: Text(
                                  "CONTINUE WITH FACEBOOK",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: MaterialButton(
                          onPressed: () async {
                            await AuthRepository()
                                .signInWithGoogle(widget.isFromLogin);
                            context.push(const MainTabViewScreen());
                          },
                          minWidth: double.maxFinite,
                          elevation: 0,
                          color: Colors.white,
                          height: 60,
                          shape: RoundedRectangleBorder(
                              side:
                                  BorderSide(color: TColor.tertiary, width: 1),
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              Image.asset(
                                'assets/img/google.png',
                                width: 25,
                                height: 25,
                              ),
                              Expanded(
                                child: Text(
                                  "CONTINUE WITH GOOGLE",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Text(
                "OR LOG IN WITH EMAIL",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 35,
              ),
              RoundTextField(
                hintText: "Username",
                controller: userNameController,
              ),
              const SizedBox(
                height: 20,
              ),
              RoundTextField(
                hintText: "Email address",
                controller: emailController,
              ),
              const SizedBox(
                height: 20,
              ),
              RoundTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "i have read the ",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: TColor.secondaryText, fontSize: 14),
                    ),
                    Text(
                      "Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isTrue = !isTrue;
                        });
                      },
                      icon: Icon(
                        isTrue
                            ? Icons.check_box
                            : Icons.check_box_outline_blank_rounded,
                        color: isTrue ? TColor.primary : TColor.secondaryText,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              RoundButton(
                  title: "GET STARTED",
                  onPressed: () async {
                    if (emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        userNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('All fields are required'),),);
                      return;
                    }
                    final bool isSignUp = await AuthRepository().signupUser(
                      emailController.text,
                      passwordController.text,
                      userNameController.text,
                      context,
                    );
                    if (isSignUp) {
                      context.push(const MainTabViewScreen());
                    }
                  }),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
