// doctor_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment_screen.dart'; // Bu satır eklendi

class DoctorDetailScreen extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSurname;
  final String doctorSpeciality;
  final String hospitalName;
  final String hospitalId; // Hastane ID'sini ekleyelim

  const DoctorDetailScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSurname,
    required this.doctorSpeciality,
    required this.hospitalName,
    required this.hospitalId, // Constructor'a ekleyelim
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Dr. $doctorName $doctorSurname',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('hastahaneler')
              .doc(hospitalId)
              .collection('doktorlar')
              .doc(doctorId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Detayları alırken bir hata oluştu!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(30),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Bu doktora ait detay bulunmuyor.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }

            final doctorData = snapshot.data!.data() as Map<String, dynamic>?;
            final biography = doctorData?['biyografi'] ?? 'Biyografi bilgisi bulunmuyor.';
            final String? imageUrl = doctorData?['resim_url'];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doktor Profil Kartı
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Doktor Resmi
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(75),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.person,
                                                size: 75, color: Colors.blue.shade700),
                                      )
                                    : Icon(Icons.person,
                                        size: 75, color: Colors.blue.shade700),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Dr. $doctorName $doctorSurname',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doctorSpeciality,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.local_hospital,
                                    size: 20, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  hospitalName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Biyografi Kartı
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.description,
                                    size: 24, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Biyografi',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              biography,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Randevu Oluştur Butonu
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade700, Colors.blue.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Randevu Oluştur',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
