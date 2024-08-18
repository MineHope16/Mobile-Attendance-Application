import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    screenheight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;


    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: screenheight / 4,
            width: screenwidth,
            decoration: BoxDecoration(
              color: primary,
            ),

            child: const Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 150,
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.all(20),
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: screenwidth / 15,
                fontFamily: "Nexa Bold",
              ),
            ),
          ),

          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(
              horizontal: screenwidth / 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                fieldTitle("Employee ID"),
                customField("Enter your Employee ID",idController, false, "person"),

                const SizedBox(height: 25),

                fieldTitle("Password"),
                customField("Enter your Password",passController, true, "key"),

                const SizedBox(height: 25),

                Container(
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
                )

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget fieldTitle(String title){
    return Container(
      margin: const EdgeInsets.only(bottom : 12),
      child: Text(
        title,
        style: TextStyle(
            fontSize: screenwidth / 26,
            fontFamily: "Nexa Bold"
        ),
      ),
    );
  }

  Widget customField(String hint,TextEditingController controller, bool obsText,String iconText){
    return Container(
      width: screenwidth,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(2,2)
            )
          ]
      ),

      child: Row(
        children: [
          iconText == "person" ? Container(
            width: screenwidth / 6,
            child: Icon(
              Icons.person,
              color: primary,
              size: screenwidth / 15,
            ),
          ) : Container(
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
                    contentPadding: EdgeInsets.symmetric(
                        vertical: screenheight / 35
                    ),
                    border: InputBorder.none,
                    hintText: hint,
                ),
                maxLines: 1,
                obscureText: obsText,

              ),
            ),
          )
        ],
      ),
    );
  }
}

