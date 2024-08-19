import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double screenHeight = 0;
  double screenWidth = 0;
  Color primary = const Color(0xFFB333FF);
  Color secondary = const Color(0xFF6200EA);

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Welcome and Employee Text
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontFamily: "Nexa Light",
                      fontSize: screenWidth / 20,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Employee",
                    style: TextStyle(
                      fontFamily: "Nexa Bold",
                      fontSize: screenWidth / 18,
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ),

            // Today's Status
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                "Today's Status",
                style: TextStyle(
                  fontFamily: "Nexa Bold",
                  fontSize: screenWidth / 18,
                  color: Colors.black87,
                ),
              ),
            ),

            // Check-in/out Card
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 32),
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary.withOpacity(0.8), secondary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  )
                ],
                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check In",
                          style: TextStyle(
                            fontSize: screenWidth / 20,
                            fontFamily: "Nexa Light",
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "09:30",
                          style: TextStyle(
                            fontSize: screenWidth / 18,
                            fontFamily: "Nexa Bold",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Check Out",
                          style: TextStyle(
                            fontSize: screenWidth / 20,
                            fontFamily: "Nexa Light",
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          "--/--",
                          style: TextStyle(
                            fontSize: screenWidth / 18,
                            fontFamily: "Nexa Bold",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Date and Time
            RichText(
              text: TextSpan(
                text: "20",
                style: TextStyle(
                  color: primary,
                  fontSize: screenWidth / 18,
                  fontFamily: "Nexa Bold",
                ),
                children: [
                  TextSpan(
                    text: " August 2024",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth / 20,
                      fontFamily: "Nexa Bold",
                    ),
                  )
                ],
              ),
            ),
            Text(
              "15:00:01 PM",
              style: TextStyle(
                fontSize: screenWidth / 20,
                color: Colors.black54,
              ),
            ),

            // Slide to Check Out Button
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: Builder(
                builder: (context) {
                  final GlobalKey<SlideActionState> key = GlobalKey();

                  return SlideAction(
                    text: "Slide to Check Out",
                    textStyle: TextStyle(
                      fontFamily: "Nexa Bold",
                      fontSize: screenWidth / 18,
                      color: Colors.black54,
                    ),
                    innerColor: primary,
                    outerColor: Colors.white,
                    key: key,
                    onSubmit: () {
                      key.currentState!.reset();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
