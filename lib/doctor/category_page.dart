import 'package:doktor_randevu/doctor/widget/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'doctor_details_page.dart';
import 'model/doctor.dart';

class CategoryPage extends StatelessWidget {
  final String categoryName;
  final List<Doctor> doctors;

  const CategoryPage({super.key, required this.categoryName, required this.doctors});

  @override
  Widget build(BuildContext context) {
    List<Doctor> filteredDoctors =
    doctors.where((doctor) => doctor.category == categoryName).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName Doktorları',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: filteredDoctors.isEmpty
          ? Center(
        child: Text(
          'Bu kategoriye ait doktor bulunamadı.',
          style: GoogleFonts.poppins(),
        ),
      )
          : ListView.builder(
        itemCount: filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = filteredDoctors[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorDetailPage(doctor: doctor),
                ),
              );
            },
            child: DoctorCard(doctor: doctor),
          );
        },
      ),
    );
  }
}
