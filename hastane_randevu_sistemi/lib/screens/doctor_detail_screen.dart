// doctor_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment_screen.dart'; // Bu satır eklendi

class DoctorDetailScreen extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSurname;
  final String doctorSpeciality;
  final String hospitalName; // Hastane adını da alalım

  const DoctorDetailScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSurname,
    required this.doctorSpeciality,
    required this.hospitalName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$doctorName $doctorSurname Detayları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$doctorName $doctorSurname',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              doctorSpeciality,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Çalıştığı Hastane: $hospitalName',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Detaylar:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection(
                        'doktorlar') // Doğrudan 'doktorlar' koleksiyonuna gidiyoruz
                    .doc(doctorId) // Seçilen doktorun ID'sini kullanıyoruz
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Detayları alırken bir hata oluştu!'));
                  }
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      !snapshot.data!.exists) {
                    return const Text('Bu doktora ait detay bulunmuyor.');
                  }
                  final doctorData =
                      snapshot.data!.data() as Map<String, dynamic>?;
                  final biography = doctorData?['biyografi'] ??
                      'Biyografi bilgisi bulunmuyor.';
                  final String? imageUrl = doctorData?[
                      'resim_url']; // Doktorun resmini de alabiliriz

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Center(
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60.0),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.person, size: 60),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Text(biography),
                        // Diğer detayları buraya ekleyebilirsiniz
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentScreen(
                      doctorId: doctorId,
                      doctorName: doctorName,
                      doctorSurname: doctorSurname,
                      doctorSpeciality: doctorSpeciality,
                      hospitalName: hospitalName,
                    ),
                  ),
                );
              },
              child: const Text('Randevu Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
