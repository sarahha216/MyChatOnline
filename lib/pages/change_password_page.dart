import 'package:chatonline/function/validate.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:chatonline/widget/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({ Key? key }) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController oldPWController = TextEditingController();
  final TextEditingController newPWController = TextEditingController();
  final TextEditingController cfpassController = TextEditingController();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool showOldPW = false;
  bool showPW = false;
  bool showCfpass = false;
  bool checkCurrentPW = true;
  String? isOldPWValidation;
  String? isNewPWValidation;
  String? isConPassValidation;

  Future savePassword() async{
    try {
      await FirebaseAuth.instance.currentUser!.updatePassword(newPWController.text);
      Navigator.pop(context);
    }
    on FirebaseAuthException catch (e) {
      showSnackBar(context, Colors.red, e.message.toString());
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Change Password'),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              checkCurrentPW = await checkCurrentPassword(oldPWController.text);
              setState(() {
                isOldPWValidation = checkCurrentPW ? null : "Please check old password";
                isNewPWValidation = validatePassword(newPWController.text);
                isConPassValidation = conformPassword(cfpassController.text, newPWController.text);
              });
              if(checkCurrentPW && isNewPWValidation == null && isConPassValidation == null){
                await savePassword();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18),)
          ),
        ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
            TextFieldWidget.base(
                controller: oldPWController,
                obscureText: !showOldPW,
                textInputType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.send,
                prefixIcon: const Icon(Icons.lock),
                hintText: "Old Password",
                errorText: isOldPWValidation,
                suffixIcon: InkWell(
                    onTap: (){
                      setState(() {
                        showOldPW = !showOldPW;
                      });
                    },
                    child: !showOldPW ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)

                ),
                onChanged: (text){}),
            const SizedBox(height: 16,),
            TextFieldWidget.base(
              controller: newPWController,
              obscureText: !showPW,
              textInputType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.send,
                prefixIcon: const Icon(Icons.lock),
                hintText: "Password",
                errorText: isNewPWValidation,
                suffixIcon: InkWell(
                  onTap: (){
                    setState(() {
                      showPW = !showPW;
                    });
                  },
                  child: !showPW ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off)

              ),
              onChanged: (text) {},
            ),
            const SizedBox(height: 16,),
            TextFieldWidget.base(
            controller: cfpassController,
            obscureText: !showCfpass,
            textInputType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.send,
              prefixIcon: const Icon(Icons.lock),
              hintText: "ConfirmPassword",
              errorText: isConPassValidation,
              suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        showCfpass = !showCfpass;
                      });
                    },
                    child: !showCfpass
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                  ),
              onChanged: (text){},
            ),
        ]),
      ),
    
    );
  }
}