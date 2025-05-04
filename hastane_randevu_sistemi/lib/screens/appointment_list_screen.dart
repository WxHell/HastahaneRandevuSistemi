import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Listesi'),
      ),
      body: userId == null
          ? const Center(
              child: Text('Randevuları görmek için lütfen giriş yapın.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('randevular')
                  .where('hastaId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Bir hata oluştu: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Henüz randevunuz bulunmamaktadır.'));
                }

                final List<QueryDocumentSnapshot> appointments =
                    snapshot.data!.docs;

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    final DateTime randevuTarihi =
                        (appointment['randevuTarihi'] as Timestamp).toDate();

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doktor: ${appointment['doktorAdiSoyadi']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Hastane: ${appointment['hastaneAdi']}'),
                            Text('Uzmanlık: ${appointment['doktorUzmanlik']}'),
                            Text(
                              'Tarih: ${randevuTarihi.day}/${randevuTarihi.month}/${randevuTarihi.year}',
                            ),
                            Text(
                              'Saat: ${randevuTarihi.hour}:${randevuTarihi.minute.toString().padLeft(2, '0')}',
                            ),
                            Text('Not: ${appointment['not']}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
