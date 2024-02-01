// ignore_for_file: use_build_context_synchronously, nullable_type_in_catch_clause
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lechat/components/customsnackbar.dart';
import 'package:lechat/screens/cadastre_screen.dart';
import 'package:lechat/screens/login_screen.dart';
import 'package:lechat/service/auth.dart';
import 'package:lechat/utils/couleurs.dart';
import 'package:lechat/widgets/leChatLogin.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  static String id = 'Registration_screen';
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  late String email;  
  late String password;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //Size? size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Couleurs.blackCat,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Hero(
                      tag: 'logo',
                      child: SizedBox(
                        width: 200,
                        child: LeChatLogo(textVisible: false,)
                      ),
                    ),
                     Text("Register",  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Couleurs.white
                        ,fontFamily: 'Glass Antiqua'
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                style: const TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),                                
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                    email = value;                  
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),                                        
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },   
                decoration: const InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),                                        
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
              ),
              const SizedBox(
                height: 24.0,
              ),
              _isLoading ? const CircularProgressIndicator():
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Material(
                  color: Couleurs.greyVeryLight,                
                  borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  elevation: 5.0,
                  child: MaterialButton(
                    onPressed: () async{
                      try {
                        if(_formKey.currentState!.validate()){
                          setState(() {
                            _isLoading = true;
                          });
                          await ref.read(authentication).createUserWithEmailAndPassword(email: email, password: password).then((value) => Navigator.pushNamed(context, CadastreScreen.id));                                                                    
                        }
                      } on FirebaseAuthException catch (e) {
                        var message = Authentication.getErrorAuth(e.code);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating,elevation: 0, backgroundColor: Colors.transparent,content: SnackBarCustom(title: message, cor: Colors.lightBlueAccent)));                            
                      } finally{
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    minWidth: 200.0,
                    height: 42.0,
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white,fontFamily: 'Glass Antiqua'),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?", style: TextStyle(color: Couleurs.white,fontFamily: 'Glass Antiqua'),),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, LoginScreen.id),
                    child: const Text('Login now', style: TextStyle(color: Couleurs.primaryColor,fontFamily: 'Glass Antiqua'),)
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}