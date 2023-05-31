import 'package:chatonline/function/validate.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:chatonline/widget/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({ Key? key }) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();

  String? isEmailValidation;
  FirebaseAuth firebaseAuth= FirebaseAuth.instance;


  Future resetPassword(BuildContext context) async{
    try{
      await firebaseAuth.sendPasswordResetEmail(email: emailController.text);
      showSnackBar(context, Colors.green, "Check your password");
      Navigator.of(context).pop(context);

    }
    on PlatformException catch(e){
      showSnackBar(context, Colors.red, e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.blue,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Center(
              child: Text(
                "Reset Password",
                style: TextStyle(
                  color: Colors.blue, fontSize: 32, fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32,),
              TextFieldWidget.base(
                controller: emailController,
                style: const TextStyle(fontSize: 16),
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.mail),
                  hintText: "Email",
                  errorText: isEmailValidation,
                  onChanged: (text){},
                ),
                const SizedBox(height: 32,),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isEmailValidation = validateEmail(emailController.text);
                    });
                    if(isEmailValidation==null){
                      await resetPassword(context);
                    }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    height: 48,
                    child: const Center(
                        child: Text(
                          "Reset Password",
                          style: TextStyle(fontSize: 16),
                        )
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}