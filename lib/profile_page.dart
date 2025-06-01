import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/notifications_page.dart';
import 'auth/login_page.dart';
import 'pages/privacy_security_page.dart';
import 'pages/help_page.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  void _navigateToUpcomingAppointments() {
    // Yaklaşan randevular sayfasına yönlendirme
    print("Yaklaşan Randevularım sayfasına git");
  }
  void _navigateToHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpPage()),
    );
  }

  void _navigateToPasswordChange() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswordChangePage()),
    );
  }

  void _navigateToEditProfile() {
    // Profili düzenle sayfasına yönlendirme
    print("Profili Düzenle sayfasına git");
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;
    String userName = currentUser?.displayName ?? 'Kullanıcı';
    String userEmail = currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section with User Info
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6B46C1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: Colors.white,
                          backgroundImage: currentUser?.photoURL != null
                              ? NetworkImage(currentUser!.photoURL!)
                              : null,
                          child: currentUser?.photoURL == null
                              ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFF6B46C1),
                          )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // User Name
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // User Email
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Edit Button
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Bildirimler
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      iconColor: const Color(0xFFFF9500),
                      title: 'Bildirimler',
                      onTap: _navigateToNotifications,
                    ),

                    const SizedBox(height: 16),

                    // Yaklaşan Randevularım
                    _buildMenuItem(
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'Yaklaşan Randevularım',
                      onTap: _navigateToUpcomingAppointments,
                    ),

                    const SizedBox(height: 16),

                    // Gizlilik ve Güvenlik
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      iconColor: const Color(0xFFE91E63),
                      title: 'Gizlilik ve Güvenlik',
                      onTap: _navigateToPasswordChange,
                    ),

                    const SizedBox(height: 16),

                    // Profili Düzenle
                    _buildMenuItem(
                      icon: Icons.palette_outlined,
                      iconColor: const Color(0xFF00BCD4),
                      title: 'Profili Düzenle',
                      onTap: _navigateToEditProfile,
                    ),

                    const SizedBox(height: 16),

// Yardım
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      iconColor: Color(0xFF2196F3),
                      title: 'Yardım',
                      onTap: _navigateToHelp,
                    ),
                    const SizedBox(height: 16),


                    // Çıkış
                    _buildMenuItem(
                      icon: Icons.logout_outlined,
                      iconColor: const Color(0xFF9E9E9E),
                      title: 'Çıkış',
                      onTap: _logout,
                      showArrow: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B46C1).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),

                // Arrow Icon
                if (showArrow)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}