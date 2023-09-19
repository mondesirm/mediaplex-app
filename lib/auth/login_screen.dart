import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'register_screen.dart';
import 'models/login_model.dart';
import 'models/session_model.dart';
import 'service/login_service.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: false,
    body: Container(
      decoration: MyTheme.boxDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset('logo.svg', height: MediaQuery.of(context).size.width > 500 ? 50 : MediaQuery.of(context).size.width * .1),
                  const SizedBox(height: 20),
                  Text('Enter your credentials to continue', style: MyTheme.appText(weight: FontWeight.w500)),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .7,
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        TextFormField(
                          autofocus: true,
                          controller: emailController,
                          autofillHints: const ['Email'],
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (value) => TextInputAction.next,
                          style: MyTheme.appText(weight: FontWeight.normal),
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
                          style: MyTheme.appText(weight: FontWeight.normal),
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
                          decoration: MyTheme.boxDecoration(radius: 30, colors: [MyTheme.logoDark, MyTheme.logoLight.withOpacity(0.7)]),
                          child: ElevatedButton(
                            style: MyTheme.buttonStyle(bgColor: Colors.transparent, borderColor: Colors.transparent),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);

                                service.login(
                                  context: context,
                                  model: LoginModel(password: passwordController.text, username: emailController.text)
                                ).then((value) {
                                  if (value is SessionModel) {
                                    setState(() => _isLoading = false);
                                    MyTheme.push(context, widget: const HomeScreen());
                                  } else { setState(() => _isLoading = false); }
                                });
                              }
                            },
                            child: _isLoading
                              ? Center(child: LoadingAnimationWidget.staggeredDotsWave(size: 20, color: Colors.white))
                              : Text('Sign In', style: MyTheme.appText())
                          )
                        )
                      ])
                    )
                  )
                ]
              ))
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('No account yet? ', style: MyTheme.appText()),
                  GestureDetector(
                    onTap: () => MyTheme.push(context, widget: const RegisterScreen()),
                    child: MouseRegion(cursor: SystemMouseCursors.click, child: Text('Register.', style: MyTheme.appText(color: MyTheme.logoDark)))
                  )
                ]
              )
            )
          ]
        )
      )
    )
  );
}