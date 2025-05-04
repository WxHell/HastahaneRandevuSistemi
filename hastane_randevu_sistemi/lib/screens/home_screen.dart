import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'hospital_list_screen.dart'; // Yeni ekranı içe aktar

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hoş Geldiniz!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HospitalListScreen()),
                );
              },
              child: const Text('Hastaneleri Görüntüle'),
            ),
            // Diğer butonlar veya içerikler buraya eklenebilir
          ],
        ),
      ),
    );
  }
}
