import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Lütfen giriş yapın'),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Randevularım',
          style: TextStyle(
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
              .doc('randevular')
              .collection('randevular')
              .where('kullanici_id', isEqualTo: user.uid)
              .orderBy('randevu_tarihi', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Firestore Hatası: ${snapshot.error}');
              print('Kullanıcı ID: ${user.uid}');
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Randevuları alırken bir hata oluştu!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lütfen daha sonra tekrar deneyin.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                        Icons.event_busy,
                        size: 80,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Henüz randevunuz bulunmuyor.',
                        style: TextStyle(
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
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                
                // Timestamp kontrolü ve dönüşümü
                final appointmentDate = data['randevu_tarihi'] is Timestamp
                    ? (data['randevu_tarihi'] as Timestamp).toDate()
                    : DateTime.now();
                
                final status = data['durum'] as String? ?? 'beklemede';
                final reason = data['randevu_sebebi'] as String? ?? 'Belirtilmemiş';

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 24,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Dr. ${data['doktor_adi'] ?? ''} ${data['doktor_soyadi'] ?? ''}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.medical_services,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data['doktor_uzmanlik'] ?? 'Belirtilmemiş',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.local_hospital,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data['hastane_adi'] ?? 'Belirtilmemiş',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(appointmentDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.note,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'beklemede'
                                  ? Colors.orange.shade100
                                  : status == 'onaylandı'
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: status == 'beklemede'
                                    ? Colors.orange.shade900
                                    : status == 'onaylandı'
                                        ? Colors.green.shade900
                                        : Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
