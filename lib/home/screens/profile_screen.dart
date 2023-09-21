import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/auth/models/user_model.dart';
import 'package:mediaplex/auth/service/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Profile data;
  bool _isLoading = false;
  late Future<Profile> _profile;
  final UserService _service = UserService();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _profile = _service.fetchProfile(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(context, screen: 'ProfileScreen', child: Expanded(child: Text('My Profile', overflow: TextOverflow.ellipsis, style: MyTheme.appText()))),
    body: Container(
      padding: const EdgeInsets.all(10),
      decoration: MyTheme.boxDecoration(),
      child: FutureBuilder<Profile>(
        future: _profile,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString(), style: MyTheme.appText(size: 20)));
          // if (snapshot.hasError) return Center(child: Text('Something went wrong...', style: MyTheme.appText(size: 20)));

          if (snapshot.hasData) {
            data = snapshot.data!;

            return data.toJson().isEmpty
              ? Center(child: Text('No profile found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
              : Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Profile', style: MyTheme.appText(size: 36, weight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text('Only you can see it', style: MyTheme.appText(weight: FontWeight.w500)),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            autofocus: true,
                            controller: usernameController,
                            autofillHints: const ['Username'],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) => TextInputAction.next,
                            style: MyTheme.appText(weight: FontWeight.normal),
                            decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'Username', prefixIcon: Icons.person),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Username is required.';
                              if (value.length < 3) return 'Username should be at least 3 characters long.';
                              return null;
                            }
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
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
                              if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) return 'Password should contain at least one uppercase letter, one lowercase letter, one number & one special character.';
                              return null;
                            }
                          ),
                          Text('Password must be 8 or more characters long and contain a mix of uppercase & lower case letters, numbers and symbols.',
                            textAlign: TextAlign.justify,
                            style: MyTheme.appText(size: 12 , weight: FontWeight.w400)
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

                                  _service.update(context, model: Profile(
                                    email: emailController.text,
                                    // password: passwordController.text,
                                    username: usernameController.text
                                  )).then((value) {
                                    if (value is Profile) MyTheme.showSnackBar(context, text: 'Profile updated successfully.');
                                    Timer(const Duration(seconds: 2), () => MyTheme.showSnackBar(context, text: value.toString()));
                                  }).catchError((error) {
                                    MyTheme.showSnackBar(context, text: 'Something went wrong... Please try again later.');
                                  }).whenComplete(() => setState(() => _isLoading = false));
                                }
                              },
                              child: _isLoading
                                ? Center(child: LoadingAnimationWidget.staggeredDotsWave(size: 20, color: Colors.white))
                                : Text('Sign Up', style: MyTheme.appText())
                            )
                          )
                        ])
                      )
                    )
                  ]
                ))
              );
          } else { return Center(child: MyTheme.loadingAnimation()); }
        }
      )
    )
  );
}