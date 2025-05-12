import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSurname;
  final String doctorSpeciality;
  final String hospitalName;

  const AppointmentScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSurname,
    required this.doctorSpeciality,
    required this.hospitalName,
  }) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedReason;
  final TextEditingController _reasonController = TextEditingController();
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _createAppointment() async {
    if (selectedDate == null || selectedTime == null || selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturumu bulunamadı');
      }

      final appointmentDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      // Aynı doktor için aynı tarih ve saatte randevu var mı kontrol et
      final existingAppointments = await FirebaseFirestore.instance
          .collection('hastahaneler')
          .doc('randevular')
          .collection('randevular')
          .where('doktor_id', isEqualTo: widget.doctorId)
          .where('randevu_tarihi', isEqualTo: appointmentDateTime)
          .get();

      if (existingAppointments.docs.isNotEmpty) {
        throw Exception('Bu tarih ve saat için randevu dolu! Lütfen başka bir zaman seçin.');
      }

      // Kullanıcının aynı tarih ve saatte başka randevusu var mı kontrol et
      final userAppointments = await FirebaseFirestore.instance
          .collection('hastahaneler')
          .doc('randevular')
          .collection('randevular')
          .where('kullanici_id', isEqualTo: user.uid)
          .where('randevu_tarihi', isEqualTo: appointmentDateTime)
          .get();

      if (userAppointments.docs.isNotEmpty) {
        throw Exception('Bu tarih ve saatte başka bir randevunuz bulunuyor!');
      }

      await FirebaseFirestore.instance
          .collection('hastahaneler')
          .doc('randevular')
          .collection('randevular')
          .add({
        'kullanici_id': user.uid,
        'doktor_id': widget.doctorId,
        'doktor_adi': widget.doctorName,
        'doktor_soyadi': widget.doctorSurname,
        'doktor_uzmanlik': widget.doctorSpeciality,
        'hastane_adi': widget.hospitalName,
        'randevu_tarihi': appointmentDateTime,
        'randevu_sebebi': selectedReason,
        'durum': 'beklemede',
        'olusturma_tarihi': FieldValue.serverTimestamp(),
      }).then((docRef) {
        // 5 saniye sonra randevu durumunu güncelle
        Future.delayed(const Duration(seconds: 5), () {
          docRef.update({'durum': 'onaylandı'});
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Randevu başarıyla oluşturuldu'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Randevu Oluştur',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doktor Bilgi Kartı
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
                            Icon(Icons.person, size: 24, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dr. ${widget.doctorName} ${widget.doctorSurname}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.medical_services,
                                size: 20, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              widget.doctorSpeciality,
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
                            Icon(Icons.local_hospital,
                                size: 20, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              widget.hospitalName,
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

              // Tarih Seçici
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
                  child: ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.blue.shade700),
                    title: Text(
                      selectedDate == null
                          ? 'Tarih Seçin'
                          : DateFormat('dd/MM/yyyy').format(selectedDate!),
                      style: TextStyle(
                        color: selectedDate == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _selectDate(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Saat Seçici
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
                  child: ListTile(
                    leading: Icon(Icons.access_time, color: Colors.blue.shade700),
                    title: Text(
                      selectedTime == null
                          ? 'Saat Seçin'
                          : selectedTime!.format(context),
                      style: TextStyle(
                        color: selectedTime == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () => _selectTime(context),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Randevu Sebebi
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note_add, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Randevu Sebebi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Randevu sebebinizi yazın...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedReason = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

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
                  onPressed: isLoading ? null : _createAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Randevuyu Onayla',
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
