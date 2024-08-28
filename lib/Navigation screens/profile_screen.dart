import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidio_attendance_project/model/user.dart';
import 'package:zidio_attendance_project/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenheight = 0;
  double screenwidth = 0;

  Color primary = const Color(0xFFB333FF);
  Color secondary = const Color(0xFF6200EA);
  String birth = "Date of Birth";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Employee").doc(User_info.id).get();
      if (doc.exists) {
        return {
          'firstName': doc['firstName'] ?? '',
          'lastName': doc['lastName'] ?? '',
          'birthDate': doc['birthDate'] ?? 'Date of Birth',
          'address': doc['address'] ?? '',
          'profilePic': doc['profilePic'] ?? '',
        };
      } else {
        return {};
      }
    } catch (e) {
      throw Exception("Error fetching profile data: ${e.toString()}");
    }
  }

  void picUploadProfilePic() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 512,
        maxWidth: 512,
        imageQuality: 90,
      );

      if (image == null) {
        showSnackBar("No image selected.");
        return;
      }

      Reference ref = FirebaseStorage.instance.ref().child("${User_info.employeeId.toLowerCase()}_profilepic.jpg");
      await ref.putFile(File(image.path));
      String downloadURL = await ref.getDownloadURL();

      setState(() {
        User_info.profilePicLink = downloadURL;
      });

      await FirebaseFirestore.instance.collection("Employee").doc(User_info.id).update({
        'profilePic': downloadURL,
      });

    } catch (e) {
      showSnackBar("An error occurred: ${e.toString()}");
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Clear SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      // Navigate to the login screen
    } catch (e) {
      showSnackBar("An error occurred during logout: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    screenheight = MediaQuery.of(context).size.height;
    screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            final profilePicLink = data['profilePic'] as String? ?? '';
            final firstName = data['firstName'] as String? ?? '';
            final lastName = data['lastName'] as String? ?? '';
            final birthDate = data['birthDate'] as String? ?? 'Date of Birth';
            final address = data['address'] as String? ?? '';

            firstNameController.text = firstName;
            lastNameController.text = lastName;
            addressController.text = address;
            birth = birthDate;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      picUploadProfilePic();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 50, bottom: 20),
                      height: 150,
                      width: 150,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: primary,
                      ),
                      child: Center(
                        child: profilePicLink == "" ? const Icon(
                          Icons.person_outline_outlined,
                          color: Colors.white,
                          size: 80,
                        ) : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(profilePicLink)
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Employee ${User_info.employeeId}",
                      style: const TextStyle(
                        fontFamily: "Nexa Bold",
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  User_info.canEdit ? textFields("First Name", "First Name", firstNameController) : field("First Name", firstName),
                  User_info.canEdit ? textFields("Last Name", "Last Name", lastNameController) : field("Last Name", lastName),
                  User_info.canEdit ? GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        setState(() {
                          birth = DateFormat("dd MMMM, yyyy").format(value!);
                        });
                      });
                    },
                    child: field("Date of Birth", birth),
                  ) : field("Date of Birth", birthDate),
                  User_info.canEdit ? textFields("Address", "Address", addressController) : field("Address", address),
                  User_info.canEdit ? GestureDetector(
                    onTap: () async {
                      String firstName = firstNameController.text;
                      String lastName = lastNameController.text;
                      String birthDate = birth;
                      String address = addressController.text;

                      if (User_info.canEdit) {
                        if (firstName.isEmpty) {
                          showSnackBar("Please enter your first name");
                        } else if (lastName.isEmpty) {
                          showSnackBar("Please enter your last name");
                        } else if (birthDate.isEmpty) {
                          showSnackBar("Please enter your birth date");
                        } else if (address.isEmpty) {
                          showSnackBar("Please enter your address");
                        } else {
                          await FirebaseFirestore.instance.collection("Employee").doc(User_info.id).update({
                            "firstName": firstName,
                            "lastName": lastName,
                            "birthDate": birthDate,
                            "address": address,
                            "canEdit": false,
                          }).then((value) {
                            setState(() {
                              User_info.canEdit = false;
                              User_info.firstName = firstName;
                              User_info.lastName = lastName;
                              User_info.birthDate = birthDate;
                              User_info.address = address;
                            });
                          });
                        }
                      } else {
                        showSnackBar("You cannot edit anymore, kindly contact the support team.");
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: kToolbarHeight,
                      width: screenwidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: primary,
                      ),
                      child: Center(
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                            fontFamily: "Nexa Bold",
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ) : const SizedBox(),

                  // Logout Button
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary, // Background color
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: "Nexa Bold",
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
    );
  }

  Widget field(String title, String text) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "Nexa Bold",
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: kToolbarHeight,
          width: screenwidth,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: "Nexa Regular",
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget textFields(String title, String hint, TextEditingController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "Nexa Bold",
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: kToolbarHeight,
          width: screenwidth,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFECECEC),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
