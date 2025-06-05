import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:location/location.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String city = 'İstanbul';
  String profileImageUrl = '';
  String category = 'Kardiyoloji';
  String qualification = '';
  String yearsOfExperience = '';
  double latitude = 0.0;
  double longitude = 0.0;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final Location _location = Location();
  bool _isLoading = false;
  bool _isUpdating = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mor renk paleti
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color lightPurple = Color(0xFF9F7AEA);
  static const Color darkPurple = Color(0xFF553C9A);
  static const Color accentPurple = Color(0xFFE9D5FF);
  static const Color backgroundPurple = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadDoctorData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DatabaseEvent event = await _database.child('Doctors').child(user.uid).once();
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            email = data['email'] ?? '';
            phoneNumber = data['phoneNumber'] ?? '';
            firstName = data['firstName'] ?? '';
            lastName = data['lastName'] ?? '';
            city = data['city'] ?? 'Bursa';
            profileImageUrl = data['profileImageUrl'] ?? '';
            category = data['category'] ?? 'Dentist';
            qualification = data['qualification'] ?? '';
            yearsOfExperience = data['yearsOfExperience'] ?? '';
            latitude = (data['latitude'] ?? 0.0).toDouble();
            longitude = (data['longitude'] ?? 0.0).toDouble();
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Veri yüklenirken hata oluştu: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPurple,
      appBar: AppBar(
        title: const Text(
          'Profil Güncelle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoadingWidget() : _buildProfileForm(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryPurple.withOpacity(0.1), backgroundPurple],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
              strokeWidth: 2,
            ),
            SizedBox(height: 20),
            Text(
              'Profil bilgileri yükleniyor...',
              style: TextStyle(
                color: darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryPurple.withOpacity(0.05), backgroundPurple],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildFormContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_outline,
              size: 50,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Profil Bilgilerinizi Güncelleyin',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Bilgilerinizi güncel tutarak daha iyi hizmet verin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildImageUploadSection(),
          const SizedBox(height: 25),
          _buildTextField(
            label: 'Email Adresi',
            icon: Icons.email_outlined,
            initialValue: email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => email = val,
            validator: (val) => val!.isEmpty ? 'Lütfen email adresinizi girin' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Telefon Numarası',
            icon: Icons.phone_outlined,
            initialValue: phoneNumber,
            keyboardType: TextInputType.phone,
            onChanged: (val) => phoneNumber = val,
            validator: (val) => val!.isEmpty ? 'Lütfen telefon numaranızı girin' : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Ad',
                  icon: Icons.person_outline,
                  initialValue: firstName,
                  onChanged: (val) => firstName = val,
                  validator: (val) => val!.isEmpty ? 'Lütfen adınızı girin' : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  label: 'Soyad',
                  icon: Icons.person_outline,
                  initialValue: lastName,
                  onChanged: (val) => lastName = val,
                  validator: (val) => val!.isEmpty ? 'Lütfen soyadınızı girin' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCityDropdown(),
          const SizedBox(height: 25),
          _buildDoctorFields(),
          const SizedBox(height: 25),
          _buildLocationSection(),
          const SizedBox(height: 30),
          _buildUpdateButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    String? initialValue,
    TextInputType? keyboardType,
    bool obscureText = false,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryPurple),
        labelStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: city,
        decoration: InputDecoration(
          labelText: 'Şehir',
          prefixIcon: const Icon(Icons.location_city, color: primaryPurple),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryPurple, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: ['İstanbul', 'Ankara', 'İzmir', 'Bursa'].map((String cityName) {
          return DropdownMenuItem(
            value: cityName,
            child: Text(cityName),
          );
        }).toList(),
        onChanged: (val) => setState(() => city = val!),
        validator: (val) => val == null ? 'Şehir seçin' : null,
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: accentPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryPurple.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (_imageFile != null)
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.file(
                  File(_imageFile!.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else if (profileImageUrl.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  profileImageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: primaryPurple,
                      ),
                    );
                  },
                ),
              ),
            ),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              (_imageFile != null || profileImageUrl.isNotEmpty)
                  ? 'Fotoğrafı Değiştir'
                  : 'Profil Fotoğrafı Ekle',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: lightPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doktor Bilgileri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Eğitim/Vasıf',
            icon: Icons.school_outlined,
            initialValue: qualification,
            onChanged: (val) => qualification = val,
            validator: (val) => val!.isEmpty ? 'Lütfen vasfınızı girin' : null,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonFormField<String>(
              value: category,
              decoration: InputDecoration(
                labelText: 'Uzmanlık Alanı',
                prefixIcon: const Icon(Icons.medical_services, color: primaryPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryPurple, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              items: ['Dentist', 'Kardiyoloji', 'Onkoloji', 'Cerrahi'].map((String cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (val) => setState(() => category = val!),
              validator: (val) => val == null ? 'Kategori seçin' : null,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Deneyim Yılı',
            icon: Icons.work_outline,
            initialValue: yearsOfExperience,
            keyboardType: TextInputType.number,
            onChanged: (val) => yearsOfExperience = val,
            validator: (val) => val!.isEmpty ? 'Lütfen deneyim yılınızı girin' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[600]),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Konum Bilgisi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (latitude != 0.0 && longitude != 0.0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Konum: (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Konum bilgisi alınmadı',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
            ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: _getLocation,
            icon: const Icon(Icons.my_location, color: Colors.white),
            label: const Text(
              'Konumu Güncelle',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryPurple, lightPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isUpdating ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isUpdating
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        )
            : const Text(
          'Profili Güncelle',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      _showErrorDialog('Resim seçilirken hata oluştu: ${e.toString()}');
    }
  }

  Future<void> _getLocation() async {
    try {
      final locationData = await _location.getLocation();
      setState(() {
        latitude = locationData.latitude!;
        longitude = locationData.longitude!;
      });
      _showSuccessDialog('Konum başarıyla güncellendi');
    } catch (e) {
      _showErrorDialog('Konum alınamadı: ${e.toString()}');
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUpdating = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user != null) {
          Map<String, dynamic> updateData = {
            'email': email,
            'phoneNumber': phoneNumber,
            'firstName': firstName,
            'lastName': lastName,
            'city': city,
            'qualification': qualification,
            'category': category,
            'yearsOfExperience': yearsOfExperience,
            'latitude': latitude,
            'longitude': longitude,
          };

          // Resim güncelleme - sadece yeni resim seçildiyse
          if (_imageFile != null) {
            try {
              // Önce eski resmi silmeye çalış (varsa)
              Reference storageReference = FirebaseStorage.instance
                  .ref()
                  .child('Doctors/${user.uid}/profile.jpg');

              try {
                await storageReference.delete();
              } catch (e) {
                // Eski resim yoksa hata vermez, devam eder
                print('Eski resim bulunamadı veya silinemedi: $e');
              }

              // Yeni resmi yükle
              UploadTask uploadTask = storageReference.putFile(File(_imageFile!.path));
              TaskSnapshot taskSnapshot = await uploadTask;
              String downloadUrl = await taskSnapshot.ref.getDownloadURL();
              updateData['profileImageUrl'] = downloadUrl;

              // Yerel state'i güncelle
              setState(() {
                profileImageUrl = downloadUrl;
              });
            } catch (e) {
              print('Resim yükleme hatası: $e');
              _showErrorDialog('Resim yüklenirken hata oluştu: ${e.toString()}');
              return;
            }
          }

          // Veritabanını güncelle
          await _database.child('Doctors').child(user.uid).update(updateData);

          _showSuccessDialog('Profil başarıyla güncellendi');
        }
      } catch (e) {
        _showErrorDialog('Güncelleme hatası: ${e.toString()}');
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Hata',
            style: TextStyle(
              color: darkPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tamam',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Başarılı',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tamam',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}