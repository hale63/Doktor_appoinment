import 'package:doktor_randevu/doctor/doctor_home_page.dart';
import 'package:doktor_randevu/login_page.dart';
import 'package:doktor_randevu/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class SplashScreen extends StatefulWidget {


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkAuthUser();
  }

  Future<void> _checkAuthUser() async {
    User? user = _auth.currentUser;

    if (user == null) {
      await Future.delayed(Duration(seconds: 3));
      _navigateToLogin();
    } else {
      DatabaseReference userRef = _database.child("Doctor").child(user.uid);
      DataSnapshot snapshot = await userRef.get();


      if (snapshot.exists) {
        await Future.delayed(Duration(seconds: 3));
        _navigateToDoctorHomePage();
      } else {
        userRef = _database.child("patient").child(user.uid);
        snapshot = await userRef.get();
        if (snapshot.exists) {
          await Future.delayed(Duration(seconds: 3));
          _navigateToPatientHomePage();
        } else {
          await Future.delayed(Duration(seconds: 3));
          _navigateToLogin();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SingleChildScrollView(
        child: Container(
        
          width:MediaQuery.of(context).size.width,
          height:MediaQuery.of(context).size.height,
          color:Color(0xFF9933FF),
          child:SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               Padding(
                 padding: const EdgeInsets.only(top:50.0,right:10.0),
                 child: Text(
                   textAlign:TextAlign.end,
                   'Welcome\n to our app',
                   style: GoogleFonts.poppins(fontSize:28,color: Colors.white,fontWeight:FontWeight.bold),
                 ),
               ),
            Image.asset('assets/images/intro_women.png',width:MediaQuery.of(context).size.width,height:650,),

             ],

            ),
          ),
        
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LoginPage()));
  }

  void _navigateToDoctorHomePage() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => DoctorHomePage()));
  }


  void _navigateToPatientHomePage() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => PatientHomePage()));
  }
}



