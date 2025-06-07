import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../chat_screen.dart';
import 'model/doctor.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance
      .ref('Requests'); //  it will store appointments requests

  TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doktor Detayları'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section (Same as before)
              Row(
                children: [
                  Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      color: Color(0xffF0EFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: widget.doctor.profileImageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.doctor.profileImageUrl,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                        : Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.doctor.firstName} ${widget.doctor.lastName}',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.doctor.category,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Şehir: ${widget.doctor.city}',
                        // Example location; replace with actual data if available
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xff8813c5),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'assets/call.png',
                              width: 30,
                              height: 30,
                              color: Colors.purple,
                            ),
                            onPressed: () {
                              // Add phone call functionality
                              _makePhoneCall(widget.doctor.phoneNumber);
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                              'assets/message.png',
                              width: 30,
                              height: 30,
                              color: Colors.purple,
                            ),
                            onPressed: () {
                              // Add chat functionality
                              String currentUserId = _auth.currentUser!.uid;
                              String docName =
                                  '${widget.doctor.firstName.toString()} ${widget.doctor.lastName.toString()}';

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    doctorId: widget.doctor.uid,
                                    doctorName: docName,
                                    patientId: currentUserId,
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8813c5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Add map location functionality
                    _openMap();
                  },
                  child: Text(
                    'HARİTADA KONUMU GÖSTER',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Text(
                'Tarih ve Saat Seçin',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color(0xffF0EFFF),
                  border: Border.all(
                    color: Color(0xff8813c5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff9f7aea),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _selectDate(context),
                            child: Text(
                              _selectedDate == null
                                  ? 'Tarih Seç'
                                  : DateFormat('dd/MM/yyyy')
                                  .format(_selectedDate!),
                              style: GoogleFonts.poppins(
                                  fontSize: 15, letterSpacing: 0.6),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff9f7aea),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _selectTime(context),
                            child: Text(
                              _selectedTime == null
                                  ? 'Saat Seç'
                                  : _selectedTime!.format(context),
                              style: GoogleFonts.poppins(
                                  fontSize: 15, letterSpacing: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.black),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Açıklama',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Color(0xffF0EFFF),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8813c5),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Add appointment booking functionality
                    _bookAppointment();
                  },
                  child: Text(
                    'RANDEVU AL',
                    style: GoogleFonts.poppins(fontSize: 16, letterSpacing: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //select Date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  //select time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // open map
  void _openMap() async {
    final String googleMapUrl =
        'https://www.google.com/maps/search/?api=1&query=${widget.doctor.latitude},${widget.doctor.longitude}';
    if (await canLaunch(googleMapUrl)) {
      await launch(googleMapUrl);
    } else {
      throw 'Harita açılamadı';
    }
  }

  // phone call
  // void _makePhoneCall(String phoneNumber) async {
  //   final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
  //   if (await canLaunch(phoneUri.toString())) {
  //     await launch(phoneUri.toString());
  //   } else {
  //     throw '$phoneNumber numarasını arayamadı';
  //   }
  // }
  void _makePhoneCall(String phoneNumber) async {
    try {
      await Haptics.vibrate(HapticsType.light); // Arama başlatılırken

      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunch(phoneUri.toString())) {
        await launch(phoneUri.toString());
      } else {
        await Haptics.vibrate(HapticsType.error); // Hata durumunda
        throw '$phoneNumber numarasını arayamadı';
      }
    } catch (e) {
      await Haptics.vibrate(HapticsType.error);
      rethrow;
    }
  }

  // appointment

  // appointment fonksiyonunu güncelliyoruz
  void _bookAppointment() async {  // async ekliyoruz
    if (_selectedDate != null &&
        _selectedTime != null &&
        _descriptionController.text.isNotEmpty) {
      try {
        // 1. Randevu talebi başladığında hafif titreşim
        await Haptics.vibrate(HapticsType.light);

        String date = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        String time = _selectedTime!.format(context);
        String description = _descriptionController.text;
        String requestId = _requestDatabase.push().key!;
        String currentUserId = _auth.currentUser!.uid;
        String receiverId = widget.doctor.uid;
        String status = 'pending';

        // 2. Randevu kaydetme işlemi
        await _requestDatabase.child(requestId).set({
          'date': date,
          'time': time,
          'description': description,
          'id': requestId,
          'receiver': receiverId,
          'sender': currentUserId,
          'status': status,
        });

        // 3. Başarılı titreşim
        await Haptics.vibrate(HapticsType.success);

        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _descriptionController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Randevu başarıyla alındı')));
      } catch (error) {
        // 4. Hata titreşimi
        await Haptics.vibrate(HapticsType.error);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Randevu alınamadı, daha sonra tekrar deneyin!')));
      }
    } else {
      // 5. Eksik bilgi uyarısı titreşimi
      await Haptics.vibrate(HapticsType.warning);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Randevu için tarih, saat seçin ve açıklama ekleyin')));
    }
  }

// Telefon arama fonksiyonuna da ekleyebiliriz

}