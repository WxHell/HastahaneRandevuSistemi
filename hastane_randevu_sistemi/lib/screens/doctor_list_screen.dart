import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatelessWidget {
  final String hospitalId;
  final String hospitalName;

  const DoctorListScreen({
    Key? key,
    required this.hospitalId,
    required this.hospitalName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '$hospitalName Doktorları',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('hastahaneler')
              .doc(hospitalId)
              .collection('doktorlar')
              .snapshots(),
          builder: (context, snapshot) {
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
                    'Doktorları alırken bir hata oluştu!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 80,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$hospitalName için henüz kayıtlı doktor bulunmuyor.',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot document = snapshot.data!.docs[index];
                final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                final String doctorName = data['ad'] ?? '';
                final String doctorSurname = data['soyad'] ?? '';
                final String doctorSpeciality = data['uzmanlik'] ?? '';
                final String? imageUrl = data['resim_url'];
                final String doctorId = document.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
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
                            hospitalId: hospitalId,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Doktor Resmi
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.person,
                                                size: 50, color: Colors.blue.shade700),
                                      )
                                    : Icon(Icons.person,
                                        size: 50, color: Colors.blue.shade700),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Doktor Bilgileri
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$doctorName $doctorSurname',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.medical_services,
                                          size: 16, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          doctorSpeciality,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
