import 'package:doktor_randevu/doctor/doctor_home_page.dart';
import 'package:doktor_randevu/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:location/location.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final  FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String userType = 'Patient';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String city = 'Bursa';
  String profileImageUrl = '';
  String category = 'Dentist';
  String qualification = '';
  String yearsOfExperience = '';
  double latitude = 0.0;
  double longitude = 0.0;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final Location _location = Location();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kaydol'),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, left: 16, right: 16, bottom: 20),
            child: Form(
              key: _formKey,
              child: Column(
            children: [
              DropdownButtonFormField(
                value: userType,
                items: ['Patient', 'Doctor'].map((String type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    userType = val as String;
                  });
                },
                decoration: InputDecoration(labelText: 'Kullanıcı Türü'),),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) => email = val,
                validator: (val) =>
                val!.isEmpty
                    ? 'Lütfen email adresinizi girin'
                    : null,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                keyboardType: TextInputType.text,
                onChanged: (val) => password = val,
                validator: (val) =>
                val!.length < 6
                    ? 'Şifreniz en az 6 karakter olmalıdır'
                    : null,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
                onChanged: (val) => phoneNumber = val,
                validator: (val) =>
                val!.isEmpty
                    ? 'Lütfen telefon numaranızı girin'
                    : null,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Ad'),
                keyboardType: TextInputType.text,
                onChanged: (val) => firstName = val,
                validator: (val) =>
                val!.isEmpty
                    ? 'Lütfen adınızı girin'
                    : null,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Soyad'),
                keyboardType: TextInputType.text,
                onChanged: (val) => lastName = val,
                validator: (val) => val!.isEmpty ? 'Lütfen soyad girin' : null,
              ),

              DropdownButtonFormField(
                value: city,
                items: ['İstanbul', 'Ankara', 'İzmir', 'Bursa'].map((
                    String city) {
                  return DropdownMenuItem(value: city, child: Text(city));
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    city = val as String;
                  });
                },
                decoration: InputDecoration(labelText: 'Şehir'),
                validator: (val) => val == null ? 'Şehir seçin' : null,),
              ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Profil Fotoğrafı yükle')),
              _imageFile != null
                  ? Image.file(File(_imageFile!.path))
                  : Container(),
              if(userType == 'Doctor') ... [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vasıf'),
                  onChanged: (val) => qualification = val,
                  validator: (val) =>
                  val!.isEmpty
                      ? 'Lütfen vasfınızı girin'
                      : null,
                ),
                DropdownButtonFormField(
                  value: category,
                  items: ['Dentist', 'Kardiyoloji', 'Onkoloji', 'Cerrahi'].map((
                      String category) {
                    return DropdownMenuItem(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      category = val as String;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Kategori'),
                  validator: (val) => val == null ? 'Kategori seçin' : null,),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Deneyim yılı'),
                  onChanged: (val) => yearsOfExperience = val,
                  validator: (val) =>
                  val!.isEmpty
                      ? 'Lütfen deneyim girin'
                      : null,
                ),
              ],
              ElevatedButton(onPressed: _getLocation, child: Text('Lütfen konum almak için tıklayın')),
              if(latitude != 0.0 && longitude != 0.0)
                Text('Konum: ($latitude, $longitude)'),
              ElevatedButton(onPressed: () {

              }, child: Text('Kaydol')),
            ],
          )),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _getLocation() async {
    final locationData = await _location.getLocation();
    setState(() {
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
    });
  }

}

