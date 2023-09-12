// ignore_for_file: unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/home/home.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/register/register.dart';
import 'package:mediaplex/login/models/login_model.dart';
import 'package:mediaplex/login/models/session_model.dart';
import 'package:mediaplex/login/service/login_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  LoginService service = LoginService();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async => false,
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: LinearGradient(
          stops: [0, 1],
          tileMode: TileMode.clamp,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [MyTheme.darkBlue, MyTheme.slightBlue]
        ))),
        Padding(
          padding: const EdgeInsets.all(30),
          child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset('logo.svg', height: MediaQuery.of(context).size.width > 500 ? 50 : MediaQuery.of(context).size.width * .1),
                  const SizedBox(height: 20),
                  Text('Sign in to continue', style: MyTheme.appText(size: 21, isShadow: true, weight: FontWeight.w500)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .7,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            autofocus: true,
                            controller: emailController,
                            autofillHints: const ['Email'],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) => TextInputAction.next,
                            style: MyTheme.appText(size: 14, weight: FontWeight.normal),
                            decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'Email Address', prefixIcon: Icons.mail),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email address is required.';
                              if (!RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(value)) return 'Email address is invalid.';
                              return null;
                            }
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (value) => TextInputAction.done,
                            style: MyTheme.appText(size: 14, weight: FontWeight.normal),
                            decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'Password', prefixIcon: Icons.lock),
                            validator: (value) {
                            if (value == null || value.isEmpty) return 'Password is required.';
                            if (value.length < 8) return 'Password should be at least 8 characters long.';
                            return null;
                          }
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                stops: const [0, 1],
                                tileMode: TileMode.clamp,
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [MyTheme.logoDarkColor, MyTheme.logoLightColor.withOpacity(0.7)]
                              )
                            ),
                            child: ElevatedButton(
                              style: MyTheme.buttonStyle(backColor: Colors.transparent, borderColor: Colors.transparent),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);

                                  service.loginUser(
                                    context: context,
                                    model: LoginModel(password: passwordController.text, username: emailController.text)
                                  ).then((value) {
                                    if (value is SessionModel) {
                                      setState(() => _isLoading = false);
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const Home()));
                                    } else {
                                      setState(() => _isLoading = false);
                                    }
                                  });
                                }
                              },
                              child: _isLoading
                                ? Center(child: LoadingAnimationWidget.staggeredDotsWave(size: 20, color: Colors.white))
                                : Text('Sign In', style: MyTheme.appText(size: 16, weight: FontWeight.w600, color: MyTheme.whiteColor)))
                          )
                        ]
                      )
                    )
                  )
                ]
              )
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.all(30),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('No account yet? ', style: MyTheme.appText(size: 14, isShadow: true, weight: FontWeight.w500)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUp())),
                  child: Text(
                    'Register.',
                    style: MyTheme.appText(size: 14, isShadow: true, weight: FontWeight.w500, color: MyTheme.logoDarkColor)
                  )
                )
              ]
            )
          )
        )
      ])
    )
  );
}