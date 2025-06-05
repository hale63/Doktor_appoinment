import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:location/location.dart';

class PatientUpdatePage extends StatefulWidget {
  const PatientUpdatePage({super.key});

  @override
  State<PatientUpdatePage> createState() => _PatientUpdatePageState();
}

class _PatientUpdatePageState extends State<PatientUpdatePage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String email = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String city = 'İstanbul';
  String profileImageUrl = '';
  double latitude = 0.0;
  double longitude = 0.0;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  final Location _location = Location();
  bool _isLoading = false;
  bool _isDataLoaded = false;

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
    _loadPatientData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DatabaseEvent event = await _database.child('Patients').child(user.uid).once();
        if (event.snapshot.exists) {
          Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);

          setState(() {
            email = data['email'] ?? '';
            phoneNumber = data['phoneNumber'] ?? '';
            firstName = data['firstName'] ?? '';
            lastName = data['lastName'] ?? '';
            city = data['city'] ?? 'İstanbul';
            profileImageUrl = data['profileImageUrl'] ?? '';
            latitude = (data['latitude'] ?? 0.0).toDouble();
            longitude = (data['longitude'] ?? 0.0).toDouble();
            _isDataLoaded = true;
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Veriler yüklenirken hata oluştu: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPurple,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        title: const Text(
          'Bilgilerimi Güncelle',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoadingWidget() : _buildUpdateForm(),
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
              'Bilgileriniz yükleniyor...',
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

  Widget _buildUpdateForm() {
    if (!_isDataLoaded) {
      return const Center(
        child: Text(
          'Bilgiler yüklenemedi',
          style: TextStyle(color: darkPurple, fontSize: 16),
        ),
      );
    }

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
              Icons.person,
              size: 50,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hasta Bilgileri',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kişisel bilgilerinizi güncelleyin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
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
            keyboardType: TextInputType.emailAddress,
            initialValue: email,
            onChanged: (val) => email = val,
            validator: (val) => val!.isEmpty ? 'Lütfen email adresinizi girin' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Telefon Numarası',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            initialValue: phoneNumber,
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
    TextInputType? keyboardType,
    bool obscureText = false,
    String? initialValue,
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
              (_imageFile != null || profileImageUrl.isNotEmpty) ? 'Fotoğrafı Değiştir' : 'Profil Fotoğrafı Ekle',
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
                      'Konum mevcut: (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
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
        onPressed: _updatePatientInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Bilgileri Güncelle',
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = pickedFile;
    });
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

  Future<void> _updatePatientInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = _auth.currentUser;
        if (user != null) {
          String finalImageUrl = profileImageUrl;

          // Yeni resim seçilmişse önce yükle
          if (_imageFile != null) {
            try {
              Reference storageReference = FirebaseStorage.instance
                  .ref()
                  .child('Patients/${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');

              UploadTask uploadTask = storageReference.putFile(File(_imageFile!.path));
              TaskSnapshot taskSnapshot = await uploadTask;
              finalImageUrl = await taskSnapshot.ref.getDownloadURL();

              print('✅ Resim başarıyla güncellendi: $finalImageUrl');
            } catch (e) {
              print('❌ Resim güncelleme hatası: $e');
              _showErrorDialog('Resim güncellenirken hata oluştu, diğer bilgiler güncellendi');
            }
          }

          Map<String, dynamic> updateData = {
            'email': email,
            'phoneNumber': phoneNumber,
            'firstName': firstName,
            'lastName': lastName,
            'city': city,
            'profileImageUrl': finalImageUrl,
            'latitude': latitude,
            'longitude': longitude,
            'lastUpdated': DateTime.now().toIso8601String(),
          };

          await _database.child('Patients').child(user.uid).update(updateData);

          _showSuccessDialog('Bilgileriniz başarıyla güncellendi');
        }
      } catch (e) {
        _showErrorDialog('Güncelleme sırasında hata oluştu: ${e.toString()}');
      } finally {
        setState(() {
          _isLoading = false;
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