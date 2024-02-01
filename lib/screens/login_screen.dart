// ignore_for_file: use_build_context_synchronously, nullable_type_in_catch_clause


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lechat/components/customsnackbar.dart';
import 'package:lechat/screens/home_screen.dart';
import 'package:lechat/screens/registration_screen.dart';
import 'package:lechat/service/auth.dart';
import 'package:lechat/utils/couleurs.dart';
import 'package:lechat/widgets/leChatLogin.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String id = 'Login_screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late String email;
  late String password;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Couleurs.blackCat,
      body: SingleChildScrollView(        
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.2),
                    const Hero(
                      tag: 'logo',
                      child: LeChatLogo()
                    ),
                    TextFormField(                      
                      style: const TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),                                
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        email = value;
                      },                  
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),                                        
                        hintStyle: TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    TextFormField(            
                      style: const TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),                                
                      obscureText: true,
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        password = value;
                      },
                      decoration: const InputDecoration(   
                        hintText: 'Enter your password',
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),                    
                        hintStyle: TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        ),                   
                      ),     
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },             
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Material(
                        color: Couleurs.greyVeryLight,                
                        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                        elevation: 5.0,
                        child: _isLoading ? const CircularProgressIndicator():
                        MaterialButton(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30.0)),
                          ),     
                          color: Couleurs.greyVeryLight,                      
                          onPressed: () async{
                            try {
                              setState(() {
                                _isLoading = true;
                              });
                              if(!_formKey.currentState!.validate()) return;
                              await ref.read(authentication).signInWithEmailAndPassword(email: email, password: password).then(
                                (value) {
                                  Navigator.pushReplacementNamed(context, HomeScreen.id);
                                }
                              );                          
                            } on FirebaseAuthException catch (e) {
                              var message = Authentication.getErrorAuth(e.code);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,elevation: 0, backgroundColor: Colors.transparent,content: SnackBarCustom(title: message, cor: Couleurs.greyVeryLight)));                            
                            } finally{
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          minWidth: 200.0,
                          height: 42.0,
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              color: Couleurs.white
                              ,fontFamily: 'Glass Antiqua'
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Not a member?", style: TextStyle(
                          color: Couleurs.white
                          ,fontFamily: 'Glass Antiqua'
                          ),),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, RegistrationScreen.id),
                          child: const Text('Register now', style: TextStyle(color: Couleurs.primaryColor,fontFamily: 'Glass Antiqua'),)
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

