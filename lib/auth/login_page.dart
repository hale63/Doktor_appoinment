import 'package:doktor_randevu/auth/signup_screen.dart';
import 'package:flutter/material.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? 'Lütfen Mail girin' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Şifre'),
                obscureText: true,
                keyboardType: TextInputType.text,
                validator: (val) =>
                val!.length < 6
                    ? 'Şifreniz en az 6 karakter olmaldıır'
                    : null,
              ),
              SizedBox(height: 20,),
              ElevatedButton(onPressed: () {},
                child: Text('Giriş'),
              ),
              SizedBox(height: 20,),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RegisterPage()));
                },
                child: Text('Kaydol'),
              ),

            ],
          ),
        ),

      ),

    );
  }
}
