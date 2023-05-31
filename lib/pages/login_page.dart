import 'package:chatonline/function/validate.dart';
import 'package:chatonline/pages/pages.dart';
import 'package:chatonline/widget/textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool show = false;
  String? isEmailValidation;
  String? isPWValidation;

  Future<void> signIn(String email, String pass) async {
    try {
      await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: pass)
          .then((value) {
        showSnackBar(context, Colors.green, "Sign in successfully");
        nextScreenRemove(context, NavigationPage());
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, Colors.red, e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.blue,
    ));
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                TextFieldWidget.base(
                  controller: emailController,
                  textInputType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    errorText: isEmailValidation,
                  onChanged: (text) {},
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFieldWidget.base(
                    controller: passwordController,
                    obscureText: !show,
                    textInputType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.send,
                      prefixIcon: const Icon(Icons.lock),
                      hintText: "Password",
                      errorText:
                          isPWValidation,
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              show = !show;
                            });
                          },
                          child: !show
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off)),
                    onChanged: (text) {},
                    ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                        onTap: () {
                          nextScreen(context, const ResetPassword());
                        },
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(color: Colors.blue),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEmailValidation = validateEmail(emailController.text);
                        isPWValidation = validatePassword(passwordController.text);
                      });
                      if(isEmailValidation == null && isPWValidation == null){
                        print('login');
                        signIn(emailController.text, passwordController.text);
                      }
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 32,
                      height: 48,
                      child: const Center(
                          child: Text(
                        "Login",
                        style: TextStyle(fontSize: 16),
                      )),
                    )),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          nextScreen(context, const RegisterPage());
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
