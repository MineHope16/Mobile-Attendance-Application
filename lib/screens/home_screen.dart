import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zidio_attendance_project/Navigation%20screens/calendar_screen.dart';
import 'package:zidio_attendance_project/Navigation%20screens/profile_screen.dart';
import 'package:zidio_attendance_project/Navigation%20screens/today_screen.dart';

import '../model/user.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double screenheight = 0;
  double screenwidth = 0;
  Color primary = const Color(0xFFB333FF);

  int currentIndex = 1;
  
  @override
  void initState() {
    super.initState();
    
    getId();
  }
  
  void getId() async{
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Employee")
        .where('id',isEqualTo: User.employeeId)
        .get();

    setState(() {
      User.id = snap.docs[0].id;
    });
  }

  List<IconData> navigationIcons = [
    FontAwesomeIcons.solidCalendarDays,
    FontAwesomeIcons.check,
    FontAwesomeIcons.user,
  ];

  @override
  Widget build(BuildContext context) {
    screenheight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [
          new CalendarScreen(),
          new TodayScreen(),
          new ProfileScreen(),
        ],
      ),
      
      bottomNavigationBar: Container(
        height: 70,
        margin: const EdgeInsets.only(
          left:12,
          right: 12,
          bottom: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(2,2),
            )
          ]
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              for (int i = 0; i < navigationIcons.length; i++)...<Expanded>{
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentIndex = i;
                      });
                    },
                    child: Container(
                      height: screenheight,
                      width: screenwidth,
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                navigationIcons[i],
                              color: i == currentIndex ? primary : Colors.black54,
                              size: i == currentIndex ? 30 : 25,
                            ),

                            i == currentIndex ? Container(
                              margin: EdgeInsets.only(top: 6),
                              height: 3,
                              width: 24,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.all(Radius.circular(40)),
                              ),
                            ) : const SizedBox(),

                          ],
                        ),
                      ),
                    ),
                  ),
                )
              }

            ],
          ),
        ),

      ),
    );
  }
}
