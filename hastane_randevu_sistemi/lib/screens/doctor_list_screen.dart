import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatelessWidget {
  final String hospitalId;
  final String hospitalName;

  const DoctorListScreen(
      {Key? key, required this.hospitalId, required this.hospitalName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$hospitalName Doktorları'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hastahaneler') // "hastaneler" olarak düzeltildi
            .doc(hospitalId)
            .collection('doktorlar')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text('Doktorları alırken bir hata oluştu!'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text(
                    '$hospitalName için henüz kayıtlı doktor bulunmuyor.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot document = snapshot.data!.docs[index];
              final Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              final String doctorName = data['ad'] ?? '';
              final String doctorSurname = data['soyad'] ?? '';
              final String doctorSpeciality = data['uzmanlik'] ?? '';
              final String? imageUrl = data['resim_url'];
              final String doctorId = document.id;

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
                                const Icon(Icons.person, size: 40),
                          )
                        : const Icon(Icons.person, size: 40),
                  ),
                  title: Text('$doctorName $doctorSurname',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(doctorSpeciality),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetailScreen(
                          doctorId: doctorId,
                          doctorName: doctorName,
                          doctorSurname: doctorSurname,
                          doctorSpeciality: doctorSpeciality,
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
