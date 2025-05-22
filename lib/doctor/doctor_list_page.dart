import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Doctors');
  List<Map<String,dynamic>> _doctors = [];
  bool _isLoading = true;

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchDoctors();
  }
  Future<void> _fetchDoctors() async{
    await _database.once().then((DatabaseEvent event){
      DataSnapshot snapshot = event.snapshot;
      List<Map<String,dynamic>> tmpDoctors = [];
      if(snapshot.value!= null){
       Map<dynamic, dynamic> values = snapshot.value as Map<dynamic,dynamic>;
       values.forEach((key,value){
         Map<String,dynamic> doctorMap ={};
         doctorMap['uid'] =key;
         if(value is Map<dynamic,dynamic>){
           value.forEach((k,v){
             doctorMap[k as String] =v;
           });
         }
         tmpDoctors.add(doctorMap);
       });
      }
      setState(() {
        _doctors =tmpDoctors;
        _isLoading =false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(title :Text('Doctor Listsi'),),
      body:_isLoading ? Center(child: CircularProgressIndicator(),)
          :ListView.builder(
          itemCount:_doctors.length,
          itemBuilder:(context,index){
            return Card(
              elevation:4.0,
              margin:EdgeInsets.symmetric(vertical:16),
              child: ListTile(
               leading:  CircleAvatar(
                 backgroundImage:NetworkImage(_doctors[index]['profileImageUrl']),//firebase içinde realtime datebasedan aldi
               ),
                title: Text('${_doctors[index]['firstName']} ${_doctors[index]['lastName']}'),
                subtitle:Text('${_doctors[index]['category']} ${_doctors[index]['city']}'),
              ),
            );
          })
    );
  }
}
