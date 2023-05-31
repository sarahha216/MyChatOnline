
import 'dart:io';
import 'package:chatonline/function/validate.dart';
import 'package:chatonline/widget/image_path.dart';
import 'package:chatonline/widget/navigator_widget.dart';
import 'package:chatonline/widget/textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({ Key? key }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cfpassController = TextEditingController();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool showPW = false;
  bool showCfpass = false;
  String? isNameValidation;
  String? isEmailValidation;
  String? isPWValidation;
  String? isConPassValidation;

  String id = "";

  File? image;

  Future pickImage() async{
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final imageTemporary = File(image.path);
      setState(()=>this.image = imageTemporary);

    } on PlatformException catch(e){
      if (kDebugMode) {
        print('Failed to pick image:  $e');
      }
    }
  }

  Future<void> register() async{
    try{
      await firebaseAuth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text)
          .then((value){
        setState(() {
          id = value.user!.uid;
        });
      });
      String imageURL = '';
      if(image != null){
        await
        FirebaseStorage.instance.ref().child('users').child(id).child(image.toString()).putFile(image!);
        imageURL = await FirebaseStorage.instance.ref().child('users').child(id).child(image.toString()).getDownloadURL();
      }
      Map<String, dynamic> map ={
        'userID' : id,
        'fullName': nameController.text,
        'email': emailController.text,
        'image': imageURL.isNotEmpty?imageURL:'',
        'token': '',
      };

      FirebaseFirestore.instance.collection('users').doc(map['userID']).set(map).then((value){
        showSnackBar(context, Colors.green, "Register successfully");
        Navigator.pop(context);
      });
    } on FirebaseAuthException catch(e){
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
            color: Colors.blue
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
              child: Text(
                "Register",
                style: TextStyle(
                  color: Colors.blue, fontSize: 36, fontWeight: FontWeight.bold,
                ),
              ),),
              const SizedBox(height: 28,),
              Center(
                child: Stack(
                  // onTap: (){
                  //   pickImage();
                  // },
                  children: [
                    ClipOval(
                      child: image != null? Image.file(
                        image!,width: 128,
                        height: 128,
                        fit: BoxFit.cover,):
                      Image.asset(
                        ImagePath.avatar,
                        width: 128,
                        height: 128,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      right: -15,
                      child: MaterialButton(
                        elevation: 1,
                        onPressed: () {
                          pickImage();
                        },
                        shape: const CircleBorder(),
                        color: Colors.white,
                        child: const Icon(Icons.edit, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32,),
              TextFieldWidget.base(
                controller: nameController,
                textInputType: TextInputType.name,
                textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person),
                  hintText: "Name",
                  errorText: isNameValidation,
                  onChanged: (text){},),
              const SizedBox(height: 12,),
              TextFieldWidget.base(
                controller: emailController,
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.mail),
                  hintText: "Email",
                  errorText: isEmailValidation,
                  onChanged: (text){},
                ),
              const SizedBox(height: 12,),
              TextFieldWidget.base(
                  controller: passwordController,
                  obscureText: !showPW,
                  textInputType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.send,
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Password",
                  errorText: isPWValidation,
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        showPW = !showPW;
                      });
                    },
                    child: !showPW
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                  ),
                  onChanged: (text) {},),
              const SizedBox(height: 12,),
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
              const SizedBox(height: 32,),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isNameValidation = validateName(nameController.text);
                      isEmailValidation = validateEmail(emailController.text);
                      isPWValidation = validatePassword(passwordController.text);
                      isConPassValidation = conformPassword(cfpassController.text, passwordController.text);
                    });
                    if(isNameValidation == null && isEmailValidation==null
                        && isPWValidation == null && isConPassValidation == null ){
                      print('register');
                      register();
                    }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    height: 48,
                    child: const Center(
                        child: Text(
                          "Register",
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