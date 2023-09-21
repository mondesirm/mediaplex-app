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
  late Profile _data;
  bool _isLoading = false;
  late Future<Profile> _profile;
  final UserService _service = UserService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

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
          if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

          if (snapshot.hasData) {
            _data = snapshot.data!;
            _emailController.text = _data.email!;
            _usernameController.text = _data.username!;

            return _data.toJson().isEmpty
              ? Center(child: Text('No profile found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
              : Align(
                alignment: Alignment.center,
                child: SingleChildScrollView(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Profile', style: MyTheme.appText(size: 36, weight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text('Update your information', style: MyTheme.appText(size: 20, weight: FontWeight.w400)),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .7,
                      child: Form(
                        key: _formKey,
                        child: Column(children: [
                          TextFormField(
                            autofocus: true,
                            controller: _usernameController,
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
                            controller: _emailController,
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
                            controller: _oldPasswordController,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) => TextInputAction.next,
                            style: MyTheme.appText(weight: FontWeight.normal),
                            decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'Old Password', prefixIcon: Icons.lock),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Old password is required.';
                              if (value.length < 8) return 'Password should be at least 8 characters long.';
                              if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) return 'Old password should contain at least one uppercase letter, one lowercase letter, one number & one special character.';
                              return null;
                            }
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            obscureText: true,
                            controller: _newPasswordController,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (value) => TextInputAction.done,
                            style: MyTheme.appText(weight: FontWeight.normal),
                            decoration: MyTheme.inputDecoration(fontSize: 15, hint: 'New Password (optional)', prefixIcon: Icons.lock),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length < 8) return 'New password should be at least 8 characters long.';
                                if (_oldPasswordController.text == value) return 'New password should be different from old password.';
                                if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) return 'New password should contain at least one uppercase letter, one lowercase letter, one number & one special character.';
                              }

                              return null;
                            }
                          ),
                          Text('New password must be 8 or more characters long and contain a mix of uppercase & lower case letters, numbers and symbols.',
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

                                  _service.updateProfile(context, model: ProfileUpdate(
                                    email: _emailController.text,
                                    username: _usernameController.text,
                                    oldPassword: _oldPasswordController.text,
                                    newPassword: _newPasswordController.text
                                  )).then((value) {
                                    if (value is Profile) { _emailController.text = value.email!; _usernameController.text = value.username!; }
                                    MyTheme.showSnackBar(context, text: 'Profile updated successfully.');
                                  }).catchError((error) {
                                    MyTheme.showSnackBar(context, text: error);
                                  }).whenComplete(() => setState(() => _isLoading = false));
                                }
                              },
                              child: _isLoading
                                ? Center(child: LoadingAnimationWidget.staggeredDotsWave(size: 20, color: Colors.white))
                                : Text('Update', style: MyTheme.appText())
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