import 'package:firebase_auth/firebase_auth.dart';

String? validateName(String value){
  if(value.isEmpty){
    return 'Please enter name';
  }
  return null;
}
String? validateEmail(String value) {
  if(value.isEmpty){
    return 'Please enter email';
  }
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value)){
    return 'Enter valid email';
  }else{
    return null;
  }
}


String? validatePassword(String value){
  if(value.isEmpty){
    return 'Please enter password';
  }
  if(value.length<6){
    return 'Password should be more than 5 characters';
  }
  return null;
}

String? conformPassword(String value, String value2){
  if(value.isEmpty){
    return 'Please enter password';
  }
  if(value!=value2){
    return 'Conform password invalid';
  }
  else{
    return null;
  }
}

Future<bool> checkCurrentPassword(String password) async {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  var firebaseUser = await firebaseAuth.currentUser!;

  var authCredentials = EmailAuthProvider.credential(
      email: firebaseUser.email.toString(), password: password);
  try {
    var authResult =
    await firebaseUser.reauthenticateWithCredential(authCredentials);
    return authResult.user != null;
  } catch (e) {
    print(e);
    return false;
  }
}