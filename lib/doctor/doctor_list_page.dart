import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doktor_randevu/doctor/doctor_details_page.dart';
import 'package:doktor_randevu/doctor/model/doctor.dart';
import 'package:doktor_randevu/doctor/widget/doctor_card.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database =
  FirebaseDatabase.instance.ref().child('Doctors');
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  final List<Map<String, String>> categories = [
    {'title': 'Cardiology', 'image': 'assets/Cardiology.png'},
    {'title': 'Dentist', 'image': 'assets/Dentistry.png'},
    {'title': 'Onco', 'image': 'assets/Orthopedics.png'},
    {'title': 'Neurology', 'image': 'assets/Neurology.png'},
    {'title': 'Dermatology', 'image': 'assets/Dermatology.png'},
    {'title': 'Radiology', 'image': 'assets/Radiology.png'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    await _database.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      List<Doctor> tmpDoctors = [];
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          Doctor doctor = Doctor.fromMap(value, key);
          tmpDoctors.add(doctor);
        });
      }
      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.0),

              // Başlık ve resim
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/doctor_icon.png',
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.medical_services, size: 50),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Find your doctor,\n and book an appointment',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),
              Text(
                'Find Doctor by Category',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 16.0),

              // Yatay kaydırılabilir kategori listesi
              SizedBox(
                height: 100, // Sabit yükseklik
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final isLastItem = index == categories.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: _buildRoundCategoryCard(
                        context,
                        categories[index]['title']!,
                        categories[index]['image']!,
                        isHighlighed: isLastItem,
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Doctors',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'VIEW ALL',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff006AFA),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Doktor listesi
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorDetailPage(doctor: _doctors[index]),
                        ),
                      );
                    },
                    child: DoctorCard(doctor: _doctors[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundCategoryCard(
      BuildContext context, String title, String imagePath,
      {bool isHighlighed = false}) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isHighlighed ? Color(0xff9f7aea) : Color(0xffF0EFFF),
            shape: BoxShape.circle,
            border: isHighlighed
                ? null
                : Border.all(color: Color(0xffC8C4FF), width: 2),
          ),
          child: Center(
            child: Image.asset(
              imagePath,
              width: 30,
              height: 30,
              color: isHighlighed ? Colors.white : null,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.medical_services,
                      size: 30,
                      color: isHighlighed ? Colors.white : Color(0xff006AFA)),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isHighlighed ? Color(0xff006AFA) : Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}