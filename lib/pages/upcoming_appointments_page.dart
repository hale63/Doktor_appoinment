import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../doctor/model/booking.dart';

class UpcomingAppointmentsPage extends StatefulWidget {
  const UpcomingAppointmentsPage({super.key});

  @override
  State<UpcomingAppointmentsPage> createState() => _UpcomingAppointmentsPageState();
}

class _UpcomingAppointmentsPageState extends State<UpcomingAppointmentsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _requestDatabase = FirebaseDatabase.instance.ref().child('Requests');
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
          .orderByChild('sender')
          .equalTo(currentUserId)
          .once()
          .then((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic> bookingMap =
          event.snapshot.value as Map<dynamic, dynamic>;
          List<Booking> tempBookings = [];
          bookingMap.forEach((key, value) {
            tempBookings.add(Booking.fromMap(Map<String, dynamic>.from(value)));
          });
          setState(() {
            _bookings = tempBookings;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  IconData _getBookingIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
      case 'onaylandı':
        return Icons.check_circle_outline;
      case 'pending':
      case 'beklemede':
        return Icons.access_time;
      case 'rejected':
      case 'cancelled':
      case 'iptal':
        return Icons.cancel_outlined;
      default:
        return Icons.calendar_today;
    }
  }

  Color _getBookingColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
      case 'onaylandı':
        return Colors.green;
      case 'pending':
      case 'beklemede':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
      case 'iptal':
        return Colors.red;
      default:
        return const Color(0xFF6B46C1);
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'confirmed':
        return 'Onaylandı';
      case 'pending':
        return 'Beklemede';
      case 'rejected':
      case 'cancelled':
        return 'Reddedildi';
      case 'onaylandı':
      case 'beklemede':
      case 'iptal':
      case 'reddedildi':
        return status;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          'Yaklaşan Randevularım',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B46C1),
              Color(0xFFF8F7FF),
            ],
            stops: [0.0, 0.15],
          ),
        ),
        child: Column(
          children: [
            // Randevu Sayısı Kartı
            if (!_isLoading && _bookings.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B46C1).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF4CAF50),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Toplam ${_bookings.length} randevunuz var',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),

            // Randevu Listesi
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6B46C1),
                ),
              )
                  : _bookings.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return _buildBookingCard(booking);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shadowColor: const Color(0xFF6B46C1).withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFFAF9FF),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF6B46C1).withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Durum İkonu
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getBookingColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getBookingIcon(booking.status),
                    color: _getBookingColor(booking.status),
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.description,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getBookingColor(booking.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(booking.status),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getBookingColor(booking.status),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.date,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.time,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            'Henüz randevunuz yok',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni randevular burada görünecek',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}