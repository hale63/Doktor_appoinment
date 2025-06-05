import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'model/booking.dart';

class DoctorRequestsPage extends StatefulWidget {
  const DoctorRequestsPage({super.key});

  @override
  State<DoctorRequestsPage> createState() => _DoctorRequestsPageState();
}

class _DoctorRequestsPageState extends State<DoctorRequestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase =
  FirebaseDatabase.instance.ref().child('Requests');
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      await _requestDatabase
          .orderByChild('receiver')
          .equalTo(currentUserId)
          .once()
          .then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> bookingMap =
          event.snapshot.value as Map<dynamic, dynamic>;
          _bookings.clear();
          bookingMap.forEach((key, value) {
            _bookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
          });
        }
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'kabul edildi':
        return Colors.green;
      case 'rejected':
      case 'reddedildi':
        return Colors.red;
      case 'completed':
      case 'tamamlandı':
        return Colors.blue;
      case 'pending':
      case 'beklemede':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'kabul edildi':
        return Icons.check_circle;
      case 'rejected':
      case 'reddedildi':
        return Icons.cancel;
      case 'completed':
      case 'tamamlandı':
        return Icons.task_alt;
      case 'pending':
      case 'beklemede':
      default:
        return Icons.pending;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Kabul Edildi';
      case 'rejected':
        return 'Reddedildi';
      case 'completed':
        return 'Tamamlandı';
      case 'pending':
        return 'Beklemede';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text(
          'Randevu İstekleri',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6B46C1),
        ),
      )
          : _bookings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz randevu isteği bulunmuyor',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _bookings.length,
          itemBuilder: (context, index) {
            final booking = _bookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: 4,
                shadowColor: const Color(0xFF6B46C1).withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        const Color(0xFF6B46C1).withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.description,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(booking.status)
                                    .withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(booking.status),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(booking.status),
                                    size: 16,
                                    color: _getStatusColor(booking.status),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getStatusDisplayText(booking.status),
                                    style: TextStyle(
                                      color: _getStatusColor(booking.status),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B46C1)
                                    .withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Color(0xFF6B46C1),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              booking.date,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B46C1)
                                    .withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                color: Color(0xFF6B46C1),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              booking.time,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showStatusDialog(
                                booking.id, booking.status),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B46C1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Durumu Güncelle',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStatusDialog(String requestId, String currentStatus) {
    List<String> statuses = ['Accepted', 'Rejected', 'Completed'];
    List<String> statusLabels = ['Kabul Et', 'Reddet', 'Tamamlandı'];
    String selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Randevu Durumu Güncelle',
                style: TextStyle(
                  color: Color(0xFF6B46C1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bu randevu için durum seçiniz:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    children: List.generate(statuses.length, (index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedStatus == statuses[index]
                                ? const Color(0xFF6B46C1)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          color: selectedStatus == statuses[index]
                              ? const Color(0xFF6B46C1).withOpacity(0.1)
                              : Colors.transparent,
                        ),
                        child: RadioListTile<String>(
                          title: Text(
                            statusLabels[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: selectedStatus == statuses[index]
                                  ? const Color(0xFF6B46C1)
                                  : const Color(0xFF374151),
                            ),
                          ),
                          value: statuses[index],
                          groupValue: selectedStatus,
                          activeColor: const Color(0xFF6B46C1),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'İptal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _updateRequestStatus(requestId, selectedStatus);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Güncelle',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    await _requestDatabase.child(requestId).update({
      'status': status,
    });
    await _fetchBookings();
  }
}