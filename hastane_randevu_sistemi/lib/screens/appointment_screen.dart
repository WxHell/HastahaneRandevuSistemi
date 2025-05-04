import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

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
  TextEditingController noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form doğrulama için GlobalKey

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
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
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _createAppointment() async {
    if (_formKey.currentState!.validate()) {
      // Form doğrulamasını kontrol et
      if (selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tarih ve saat seçin!')),
        );
        return;
      }

      try {
        // Get the current user.
        final User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // Handle the case where the user is not logged in.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Randevu oluşturmak için lütfen giriş yapın.')),
          );
          return; // Stop the appointment creation.
        }

        await FirebaseFirestore.instance.collection('randevular').add({
          'doktorId': widget.doctorId,
          'hastaId': user.uid, // Use the user's ID here.
          'randevuTarihi': Timestamp.fromDate(DateTime(
            selectedDate!.year,
            selectedDate!.month,
            selectedDate!.day,
            selectedTime!.hour,
            selectedTime!.minute,
          )),
          'not': noteController.text.trim(),
          'olusturmaZamani': Timestamp.now(),
          'hastaneAdi': widget.hospitalName,
          'doktorAdiSoyadi': '${widget.doctorName} ${widget.doctorSurname}',
          'doktorUzmanlik': widget.doctorSpeciality,
          // İhtiyaç duyabileceğiniz diğer bilgileri de ekleyebilirsiniz.
        });

        // Randevu başarıyla oluşturulduğunda kullanıcıya geri bildirim göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Randevunuz başarıyla oluşturuldu!')),
        );

        // Randevu oluşturulduktan sonra kullanıcıyı başka bir sayfaya yönlendirebilirsiniz.
        Navigator.pop(context); // Önceki sayfaya dön
        // Veya:
        // Navigator.pushReplacement(...); // Başka bir sayfaya gider ve geri dönmeyi engeller
      } catch (e) {
        // Hata oluşursa kullanıcıya bilgi ver
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Randevu oluşturulurken bir hata oluştu: $e')),
        );
        print('Randevu oluşturma hatası: $e');
      }
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Randevu Oluştur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Form widget'ı eklendi
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.doctorName} ${widget.doctorSurname} (${widget.doctorSpeciality})',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Hastane: ${widget.hospitalName}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text('Tarih Seçin:'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      selectedDate == null
                          ? 'Tarih Seçilmedi'
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('Saat Seçin:'),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: Text(
                      selectedTime == null
                          ? 'Saat Seçilmedi'
                          : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                // TextFormField kullanıldı
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Ek Not (İsteğe Bağlı)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  // Form doğrulama
                  if (value == null || value.isEmpty) {
                    return null; // Not alanı boş olabilir, hata vermiyoruz.
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createAppointment,
                child: const Text('Randevuyu Onayla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
