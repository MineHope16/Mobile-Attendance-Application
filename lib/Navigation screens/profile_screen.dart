import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zidio_attendance_project/model/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double screenHeight = 0;
  double screenWidth = 0;

  Color primaryColor = const Color(0xFFB333FF);
  String birthDate = "Date of Birth";

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  Future<Map<String, dynamic>> fetchProfileData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Employee")
          .doc(User_info.id)
          .get();
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

  void uploadProfilePic() async {
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

      Reference ref = FirebaseStorage.instance
          .ref()
          .child("${User_info.employeeId.toLowerCase()}_profilepic.jpg");
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

  @override
  void initState() {
    super.initState();
    fetchProfileData().then((data) {
      if (data.isNotEmpty) {
        setState(() {
          firstNameController.text = data['firstName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          addressController.text = data['address'] ?? '';
          birthDate = data['birthDate'] ?? 'Date of Birth';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchProfileData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              final profilePicLink = data['profilePic'] as String? ?? '';

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      uploadProfilePic();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 80, bottom: 20),
                      height: 120,
                      width: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: primaryColor,
                      ),
                      child: Center(
                        child: profilePicLink.isEmpty
                            ? const Icon(
                          Icons.person_outline_outlined,
                          color: Colors.white,
                          size: 80,
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(profilePicLink),
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
                  User_info.canEdit
                      ? textFields("First Name", "First Name", firstNameController)
                      : field("First Name", firstNameController.text),
                  User_info.canEdit
                      ? textFields("Last Name", "Last Name", lastNameController)
                      : field("Last Name", lastNameController.text),
                  User_info.canEdit
                      ? GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          birthDate = DateFormat("dd MMMM, yyyy").format(pickedDate);
                        });
                      }
                    },
                    child: field("Date of Birth", birthDate),
                  )
                      : field("Date of Birth", birthDate),
                  User_info.canEdit
                      ? textFields("Address", "Address", addressController)
                      : field("Address", addressController.text),
                  User_info.canEdit
                      ? GestureDetector(
                    onTap: () async {
                      String firstName = firstNameController.text;
                      String lastName = lastNameController.text;
                      String birthDate = this.birthDate;
                      String address = addressController.text;

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
                          showSnackBar("Profile updated successfully!");
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: kToolbarHeight,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.red,
                      ),
                      child: const Center(
                        child: Text(
                          "SAVE",
                          style: TextStyle(
                            fontFamily: "Nexa Bold",
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  )
                      : const SizedBox(),
                ],
              );
            } else {
              return const Center(child: Text("No data available"));
            }
          },
        ),
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
          padding: const EdgeInsets.only(left: 11),
          height: kToolbarHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black54,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: "Nexa Bold",
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget textFields(String hint, String title, TextEditingController controller) {
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
          child: TextFormField(
            controller: controller,
            cursorColor: Colors.black54,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              contentPadding: const EdgeInsets.only(left: 15),
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
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
