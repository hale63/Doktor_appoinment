eski register
import 'package:doktor_randevu/doctor/doctor_home_page.dart';
import 'package:doktor_randevu/patient/patient_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:location/location.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  String userType = 'Patient';
  String email = '';
  String password = '';
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundPurple,
      body: SafeArea(
        child: _isLoading ? _buildLoadingWidget() : _buildRegisterForm(),
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
              'Hesabınız oluşturuluyor...',
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

  Widget _buildRegisterForm() {
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
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
              Icons.medical_services,
              size: 50,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Hesap Oluştur',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sağlık hizmetlerine erişim için kayıt olun',
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
  Widget _buildAreadyHaveAccountButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Şifre sıfırlama işlemi
        },
        child: Text(
          'I have account?',
          style: TextStyle(
            color: primaryPurple,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
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
          _buildUserTypeSelector(),
          const SizedBox(height: 25),
          _buildTextField(
            label: 'Email Adresi',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (val) => email = val,
            validator: (val) => val!.isEmpty ? 'Lütfen email adresinizi girin' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Şifre',
            icon: Icons.lock_outline,
            obscureText: true,
            onChanged: (val) => password = val,
            validator: (val) => val!.length < 6 ? 'Şifreniz en az 6 karakter olmalıdır' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Telefon Numarası',
            icon: Icons.phone_outlined,
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
                  onChanged: (val) => firstName = val,
                  validator: (val) => val!.isEmpty ? 'Lütfen adınızı girin' : null,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildTextField(
                  label: 'Soyad',
                  icon: Icons.person_outline,
                  onChanged: (val) => lastName = val,
                  validator: (val) => val!.isEmpty ? 'Lütfen soyadınızı girin' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCityDropdown(),
          const SizedBox(height: 25),
          _buildImageUploadSection(),
          if (userType == 'Doctor') ...[
            const SizedBox(height: 25),
            _buildDoctorFields(),
          ],
          const SizedBox(height: 25),
          _buildLocationSection(),
          const SizedBox(height: 30),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: accentPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => userType = 'Patient'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: userType == 'Patient' ? primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Hasta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: userType == 'Patient' ? Colors.white : darkPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => userType = 'Doctor'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: userType == 'Doctor' ? primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Doktor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: userType == 'Doctor' ? Colors.white : darkPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
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
            ),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              _imageFile != null ? 'Fotoğrafı Değiştir' : 'Profil Fotoğrafı',
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
              items: ['Dentist', 'Kardiyoloji', 'Onkoloji', 'Cerrahi' ].map((String cat) {
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
                      'Konum alındı: (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
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
              'Konumu Al',
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

  Widget _buildRegisterButton() {
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
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Hesap Oluştur',
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
    } catch (e) {
      _showErrorDialog('Konum alınamadı: ${e.toString()}');
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (latitude == 0.0 || longitude == 0.0) {
        _showErrorDialog('Lütfen konum bilgisini alın');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          String userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients';

          // 2. ÖNE Resmi yükle ve URL'yi al
          String finalImageUrl = '';
          if (_imageFile != null) {
            try {
              Reference storageReference = FirebaseStorage.instance
                  .ref()
                  .child('$userTypePath/${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');

              UploadTask uploadTask = storageReference.putFile(File(_imageFile!.path));
              TaskSnapshot taskSnapshot = await uploadTask;
              finalImageUrl = await taskSnapshot.ref.getDownloadURL();

              print('✅ Resim başarıyla yüklendi: $finalImageUrl');

              // State'i güncelle
              setState(() {
                profileImageUrl = finalImageUrl;
              });

            } catch (e) {
              print('❌ Resim yükleme hatası: $e');
              // Resim yüklenemese bile kayıt işlemi devam etsin
              finalImageUrl = '';
            }
          }


          Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': email,
            'phoneNumber': phoneNumber,
            'firstName': firstName,
            'lastName': lastName,
            'city': city,
            //'profileImageUrl': profileImageUrl,
            'profileImageUrl': finalImageUrl, // ← Artık doğru URL burada
            'latitude': latitude,
            'longitude': longitude,
          };

          if (userType == 'Doctor') {
            userData['qualification'] = qualification;
            userData['category'] = category;
            userData['yearsOfExperience'] = yearsOfExperience;
            userData['totalReviews'] = 0;
            userData['averageRating'] = 0.0;
            userData['numberOfReviews'] = 0;
          }

          await _database.child(userTypePath).child(user.uid).set(userData);

          if (_imageFile != null) {
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('$userTypePath/${user.uid}/profile.jpg');
            UploadTask uploadTask = storageReference.putFile(File(_imageFile!.path));
            TaskSnapshot taskSnapshot = await uploadTask;

            String downloadUrl = await taskSnapshot.ref.getDownloadURL();
            await _database.child(userTypePath).child(user.uid).update({
              'profileImageUrl': downloadUrl,
            });
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
              userType == 'Doctor' ? DoctorHomePage() : PatientHomePage(),
            ),
          );
        }
      } catch (e) {
        _showErrorDialog(e.toString());
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
}