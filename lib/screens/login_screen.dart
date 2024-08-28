import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidio_attendance_project/screens/home_screen.dart';
import 'package:zidio_attendance_project/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();
  double screenheight = 0;
  double screenwidth = 0;
  Color primary = const Color(0xFFB333FF);

  SharedPreferences? sharedPreferences;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    screenheight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 35),
            height: 280,
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
                    size: 180,
                  ),
                ),
                Container(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: screenwidth / 12,
                      fontFamily: "Nexa Bold",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(vertical: 20,
              horizontal: screenwidth / 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                fieldTitle("Employee ID"),
                customField("Enter your Employee ID", idController, false, "person"),
                const SizedBox(height: 25),
                fieldTitle("Password"),
                customField("Enter your Password", passController, true, "key"),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    String id = idController.text.trim();
                    String pass = passController.text.trim();

                    if (id.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Employee ID cannot be empty!")),
                      );
                      return;
                    }
                    if (pass.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Password cannot be empty!")),
                      );
                      return;
                    }

                    try {
                      QuerySnapshot snap = await FirebaseFirestore.instance
                          .collection("Employee")
                          .where('id', isEqualTo: id)
                          .get();

                      if (snap.docs.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Employee does not exist!")),
                        );
                        return;
                      }

                      final doc = snap.docs[0];
                      final data = doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
                      final password = data['password']; // Access the password field

                      if (password == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password data is missing!")),
                        );
                        return;
                      }

                      if (pass == password) {
                        if (sharedPreferences != null) {
                          await sharedPreferences!.setString("emp_id", id);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                                (route) => false, // Remove all previous routes
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("SharedPreferences not initialized!")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password is incorrect!")),
                        );
                      }
                    } catch (e) {
                      print("error -> ${e.toString()}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("An error occurred!")),
                      );
                    }
                  },
                  child: Container(
                    height: 60,
                    width: screenwidth,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: Center(
                      child: Text(
                        "LOGIN",
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
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "Register Now",
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
                                  builder: (_) => const RegisterScreen(),
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

  Widget fieldTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenwidth / 26,
          fontFamily: "Nexa Bold",
        ),
      ),
    );
  }

  Widget customField(String hint, TextEditingController controller, bool obsText, String iconText) {
    return Container(
      width: screenwidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          iconText == "person"
              ? Container(
            width: screenwidth / 6,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenwidth / 15,
            ),
          )
              : Container(
            width: screenwidth / 6,
            child: Icon(
              Icons.key,
              color: primary,
              size: screenwidth / 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: screenwidth / 10),
              child: TextFormField(
                controller: controller,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: screenheight / 35),
                  border: InputBorder.none,
                  hintText: hint,
                ),
                maxLines: 1,
                obscureText: obsText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
