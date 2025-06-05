import 'package:doktor_randevu/doctor/doctor_chatlist_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'doctor_profile.dart';
import 'doctor_requests_page.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {

  int _selectedIndex = 0;

  final List<Widget> _children = [
    DoctorRequestsPage(),
    DoctorChatlistPage(), // bunu geri ekle
    DoctorProfile(),
  ];
  void _onItmTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWilPop() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Emin misiniz?'),
          content: Text('Uygulamadan çıkmak istiyor musunuz?'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Hayır')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
                child: Text('Evet')),
          ],
        ));
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWilPop,
      child: Scaffold(
        body: _children.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xff951bd1),
          unselectedItemColor: Color(0xffBEBEBE),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_filled,
                ),
                label: 'Ana Sayfa'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.chat,
                ),
                label: 'Sohbet'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
                label: 'Profil'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItmTapped,
        ),
      ),
    );
  }
}