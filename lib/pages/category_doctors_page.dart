import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doktor_randevu/doctor/model/doctor.dart';
import 'package:doktor_randevu/doctor/widget/doctor_card.dart';
import '../doctor/doctor_details_page.dart';

class CategoryDoctorsPage extends StatefulWidget {
  final List<Doctor> doctors;
  final List<String> categories;

  const CategoryDoctorsPage({
    super.key,
    required this.doctors,
    required this.categories,
  });

  @override
  State<CategoryDoctorsPage> createState() => _CategoryDoctorsPageState();
}

class _CategoryDoctorsPageState extends State<CategoryDoctorsPage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _selectedCategory == null
        ? widget.doctors
        : widget.doctors
        .where((doctor) => doctor.category == _selectedCategory)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Kategorilere Göre Doktorlar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori Seçiniz',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text('Tüm Kategoriler'),
                ),
                ...widget.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doctor = filteredDoctors[index];
                return GestureDetector(
                  onTap: () {
                    // Doktor kartına tıklanınca detay sayfasına git
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetailPage(doctor: doctor),
                      ),
                    );
                  },
                  child: DoctorCard(doctor: doctor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}