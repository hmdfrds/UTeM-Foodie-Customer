import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:utem_foodie/services/user_services.dart';

import '../providers/auth_provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);
  static const String id = 'update-profile-screen';

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  final UserServices _userServices = UserServices();
  var firstNameTextEditingController = TextEditingController();
  var lastNameTextEditingController = TextEditingController();
  var phoneNumberTextEditingController = TextEditingController();
  var emailTextEditingController = TextEditingController();
  var defaultLocationTextEditingController = TextEditingController();

  @override
  void initState() {
    _userServices.getUserById(user!.uid).then((value) {
      if (mounted) {
        setState(() {
          firstNameTextEditingController.text = value!['firstName'];
          lastNameTextEditingController.text = value['lastName'];
          emailTextEditingController.text = value['email'];
          phoneNumberTextEditingController.text = value['number'];
          defaultLocationTextEditingController.text =
              value['defaultDeliveryLocation'];
        });
      }
    });
    super.initState();
  }

  updateProfile() {
    if (_formKey.currentState!.validate()) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'firstName': firstNameTextEditingController.text,
        'lastName': lastNameTextEditingController.text,
        'email': emailTextEditingController.text,
        'defaultDeliveryLocation': defaultLocationTextEditingController.text
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: const Text(
          'Update Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomSheet: InkWell(
        onTap: () {
          if (_formKey.currentState!.validate()) {
            EasyLoading.show(status: 'Updating Profile');
            updateProfile().then((value) {
              userDetails.getUserDetails();
              EasyLoading.showSuccess('Updated Successfully');
              Navigator.pop(context);
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: 56,
          color: Colors.blueGrey[900],
          child: const Center(
            child: Text(
              'Update',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstNameTextEditingController,
                      decoration: const InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.zero),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter First name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameTextEditingController,
                      decoration: const InputDecoration(
                          labelText: 'Last Name',
                          labelStyle: TextStyle(color: Colors.grey),
                          contentPadding: EdgeInsets.zero),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: phoneNumberTextEditingController,
                enabled: false,
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.zero),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Mobile Phone Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: emailTextEditingController,
                decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.zero),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: defaultLocationTextEditingController,
                decoration: const InputDecoration(
                    labelText: 'Default Delivery Location',
                    labelStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.zero),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Default Delivery Location';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
