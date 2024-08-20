import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../model/user.dart';

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

  String checkIn = "--/--";
  String checkOut = "--/--";

  @override
  void initState() {
    super.initState();
    _getRecord();
  }

  void _getRecord () async {
    try{

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection("Employee")
          .where('id', isEqualTo: User.employeeId)
          .get();

      DocumentSnapshot snap2 = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(snap.docs[0].id)
          .collection("Records")
          .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
          .get();

      setState(() {
        checkIn = snap2['checkIn'];
        checkOut = snap2['checkOut'];
      });

    } catch(e) {
      setState(() {
        checkIn = "--/--";
        checkOut = "--/--";
      });
    }
  }

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
                    "Welcome,",
                    style: TextStyle(
                      fontFamily: "Nexa Light",
                      fontSize: screenWidth / 20,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    "Employee ${User.employeeId}",
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
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary.withOpacity(0.8), secondary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Check In",
                            style: TextStyle(
                              fontSize: screenWidth / 24,
                              fontFamily: "Cambria",
                              color: Colors.lightGreen,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            checkIn,
                            style: TextStyle(
                              fontSize: screenWidth / 16,
                              fontFamily: "Nexa Bold",
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 60,
                    color: Colors.white.withOpacity(0.6),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Check Out",
                            style: TextStyle(
                              fontSize: screenWidth / 24,
                              fontFamily: "Cambria",
                              color: Colors.redAccent,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            checkOut,
                            style: TextStyle(
                              fontSize: screenWidth / 16,
                              fontFamily: "Nexa Bold",
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Date and Time
            RichText(
              text: TextSpan(
                text: DateTime.now().day.toString(),
                style: TextStyle(
                  color: primary,
                  fontSize: screenWidth / 18,
                  fontFamily: "Nexa Bold",
                ),
                children: [
                  TextSpan(
                    text: DateFormat(' MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth / 20,
                      fontFamily: "Nexa Bold",
                    ),
                  )
                ],
              ),
            ),
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                return Text(
                  DateFormat("hh:mm:ss a").format(DateTime.now()),
                  style: TextStyle(
                    fontSize: screenWidth / 20,
                    color: Colors.black54,
                  ),
                );
              }
            ),

            // Slide to Check Out Button
            checkOut == "--/--" ? Container(
              margin: const EdgeInsets.symmetric(vertical: 140),
              child: Builder(
                builder: (context) {
                  final GlobalKey<SlideActionState> key = GlobalKey();

                  return SlideAction(
                    text: checkIn == "--/--" ? "Slide to Check In" : "Slide to Check Out",
                    textStyle: TextStyle(
                      fontFamily: "Nexa Bold",
                      fontSize: screenWidth / 18,
                      color: Colors.black54,
                    ),
                    innerColor: primary,
                    outerColor: Colors.white,
                    key: key,
                    onSubmit: () async {
                      QuerySnapshot snap = await FirebaseFirestore.instance
                          .collection("Employee")
                          .where('id', isEqualTo: User.employeeId)
                          .get();

                      DocumentSnapshot snap2 = await FirebaseFirestore.instance
                          .collection("Employee")
                          .doc(snap.docs[0].id)
                          .collection("Records")
                          .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
                          .get();

                      try{
                        String checkIn = snap2['checkIn'];
                        setState(() {
                          checkOut = DateFormat("hh:mm a").format(DateTime.now());
                        });

                        await FirebaseFirestore.instance
                            .collection("Employee")
                            .doc(snap.docs[0].id)
                            .collection("Records")
                            .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
                            .set({
                          "date": Timestamp.now(),
                          "checkIn": checkIn,
                          "checkOut": DateFormat("hh:mm a").format(DateTime.now()),
                        });

                      } catch(e){
                        setState(() {
                          checkIn = DateFormat("hh:mm a").format(DateTime.now());
                        });

                        await FirebaseFirestore.instance
                            .collection("Employee")
                            .doc(snap.docs[0].id)
                            .collection("Records")
                            .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
                            .set({
                          "date": Timestamp.now(),
                          "checkIn": DateFormat("hh:mm a").format(DateTime.now()),
                          "checkOut": "--/--"
                        });
                      }

                      key.currentState!.reset();
                    },
                  );
                },
              ),
            ) : Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 140),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(5, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.greenAccent,
                    size: screenWidth / 12,
                  ),
                  const SizedBox(width:8),
                  Expanded(
                    child: Text(
                      "Attendance Completed for Today!",
                      style: TextStyle(
                        fontSize: screenWidth / 24,
                        fontFamily: "Nexa Bold",
                        color: Colors.greenAccent,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2, 5),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
