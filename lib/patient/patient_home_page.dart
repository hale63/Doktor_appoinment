import 'package:doktor_randevu/doctor/doctor_home_page.dart';
import 'package:flutter/material.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child:Center(
          child:Text('patient Page'),
        ),
      ),
    );
  }
}

