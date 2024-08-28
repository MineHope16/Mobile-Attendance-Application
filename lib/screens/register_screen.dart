import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zidio_attendance_project/screens/login_screen.dart';
import 'dart:math';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController cnfpassController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  double screenheight = 0;
  double screenwidth = 0;
  Color primary = const Color(0xFFB333FF);
  final auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    screenheight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;


    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 15),
            height: 180,
            width: screenwidth,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(25)
            ),
            child: Column(
              children: [
                const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 120,
                  ),
                ),
                Container(
                  child: Text(
                    "Register",
                    style: TextStyle(
                      fontSize: screenwidth / 14,
                      fontFamily: "Nexa Bold",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20),
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(
              horizontal: screenwidth / 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Please enter your name, email, and password to get started.",
                  style: TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 30),

                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name TextBox
                      TextFormField(
                        controller: nameController,
                        decoration:InputDecoration(
                          hintText: "Name",
                          prefixIcon: Icon(
                            Icons.person,
                            color: primary,
                            size: screenwidth / 15,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Email TextBox
                      TextFormField(
                        controller: idController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(Icons.email,color: primary,
                            size: screenwidth / 15,),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password TextBox
                      TextFormField(
                        controller: passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(Icons.lock,color: primary,
                            size: screenwidth / 15,),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: cnfpassController,
                        obscureText: false,
                        decoration: InputDecoration(
                          hintText: "Confirm password",
                          prefixIcon: Icon(Icons.lock_open,color: primary,
                            size: screenwidth / 15,),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () async{
                    if (formKey.currentState!.validate() && passController.text == cnfpassController.text) {
                      Random random = Random();
                      int min = 1111;
                      int max = 9999;
                      int randomNumber = min + random.nextInt(max - min + 1);
                      try {
                        final result = await auth.createUserWithEmailAndPassword(
                            email: idController.text, password: passController.text);
                        await result.user?.updateDisplayName(nameController.text);

                        await FirebaseFirestore.instance.collection("Employee").doc(result.user?.uid).set({
                          'id': "AU$randomNumber",
                          'password' : passController.text,
                          "address" : "",
                          "birthDate" : "",
                          "firstName" : "",
                          "lastName" : "",
                          "profilePic" : "",
                        });

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Registration Successful"),
                              content: Text("You have successfully registered, and your employee ID is AU$randomNumber"),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Close the dialog
                                    Navigator.of(context).pop();
                                    // Navigate to another screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(), // Replace with your desired screen
                                      ),
                                    );
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );

                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(e.message ?? ''),
                        ));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password does not match !"),behavior: SnackBarBehavior.floating,),
                      );
                    }
                  },

                  child: Container(
                    height: 50,
                    width: screenwidth,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: Center(
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: screenwidth / 20,
                          fontFamily: "Nexa Bold",
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30,),
                Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "Login Now",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
