import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_list_screen.dart'; // Doktor listesi ekranını içe aktar

class HospitalListScreen extends StatelessWidget {
  const HospitalListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hastaneler'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('hastahaneler').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu!'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Henüz kayıtlı hastaneyi bulunmuyor.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document = snapshot.data!.docs[index];
              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final String hospitalName = data['ad'] ?? '';
              final String hospitalAddress = data['adres'] ?? '';
              final String hospitalPhone = data['telefon'] ?? '';
              final String? imageUrl = data['resim_url'];
              final String hospitalId = document.id; // Hastane ID'sini alıyoruz

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 80,
                    height: 80,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.local_hospital, size: 40),
                          )
                        : const Icon(Icons.local_hospital, size: 40),
                  ),
                  title: Text(hospitalName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hospitalAddress),
                      Text('Tel: $hospitalPhone'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorListScreen(
                          hospitalId:
                              hospitalId, // Seçilen hastane ID'sini gönderiyoruz
                          hospitalName: hospitalName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
