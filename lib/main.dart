import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB3_BlZbLyD1HeNZyZPDsAlNhlBqWDeUhU",
      authDomain: "pengaduansekolah-eb875.firebaseapp.com",
      projectId: "pengaduansekolah-eb875",
      storageBucket: "pengaduansekolah-eb875.firebasestorage.app",
      messagingSenderId: "265155033945",
      appId: "1:265155033945:web:87b10e00993670c2922a48",
    ),
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Admin Aspirasi - SMKN 1 Sanden',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFFD97706),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// ==================================================================
// AUTH WRAPPER
// ==================================================================
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            ),
          );
        }
        if (snapshot.hasData) {
          return const AdminDashboardPage();
        }
        return const AdminLoginPage();
      },
    );
  }
}

// ==================================================================
// 1. HALAMAN LOGIN ADMIN
// ==================================================================
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  Future<void> _loginAdmin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Email dan Password wajib diisi!', Colors.orange.shade800);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        _showSnackBar(
            'Akses Ditolak! Kredensial tidak valid.', Colors.red.shade700);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF090D16),
                  Color(0xFF0F172A),
                  Color(0xFF1E293B)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    )
                  ],
                  border: Border.all(
                      color: const Color(0xFFD97706).withOpacity(0.3),
                      width: 1.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFF59E0B), width: 2),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded,
                          size: 38, color: Color(0xFFF59E0B)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'PORTAL ADMIN ASPIRASI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sistem Pengaduan Aspirasi SMKN 1 Sanden',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Administrator',
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Color(0xFF1E3A8A)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: Color(0xFF1E3A8A)),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginAdmin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: const Color(0xFFF59E0B),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                              color: Color(0xFFD97706), width: 1),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Color(0xFFF59E0B), strokeWidth: 2),
                              )
                            : const Text(
                                'MASUK KE CONTROL PANEL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// 2. DASHBOARD ADMIN
// ==================================================================
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _searchQuery = '';
  String _selectedFilterStatus = 'Semua';

  Future<void> _sendNotification({
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    if (fcmToken.isEmpty) return;

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY_HERE',
        },
        body: jsonEncode({
          'to': fcmToken,
          'priority': 'high',
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'updated',
          },
        }),
      );
    } catch (e) {
      debugPrint("Gagal kirim notifikasi: $e");
    }
  }

  Future<void> _updateStatus(
      String docId, String statusBaru, String fcmToken, String lokasi) async {
    await FirebaseFirestore.instance
        .collection('aspirasi')
        .doc(docId)
        .update({'status': statusBaru});

    if (fcmToken.isNotEmpty) {
      await _sendNotification(
        fcmToken: fcmToken,
        title: 'Status Laporan Diperbarui 📢',
        body: 'Laporan kamu di "$lokasi" telah diubah menjadi: $statusBaru',
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Status diperbarui menjadi: $statusBaru & Notifikasi dikirim!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showFeedbackDialog(
      String docId, String currentFeedback, String fcmToken, String lokasi) {
    TextEditingController feedbackController =
        TextEditingController(text: currentFeedback);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.rate_review_rounded, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text('Tanggapan Admin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Berikan feedback/balasan tindak lanjut untuk laporan ini:',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: AC sudah diperbaiki oleh teknisi...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                String feedbackText = feedbackController.text.trim();

                await FirebaseFirestore.instance
                    .collection('aspirasi')
                    .doc(docId)
                    .update({
                  'feedback': feedbackText,
                  'feedback_date': FieldValue.serverTimestamp(),
                });

                if (fcmToken.isNotEmpty && feedbackText.isNotEmpty) {
                  await _sendNotification(
                    fcmToken: fcmToken,
                    title: 'Tanggapan Baru dari Admin 💬',
                    body:
                        'Admin memberi feedback untuk laporan "$lokasi": $feedbackText',
                  );
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Feedback berhasil disimpan & Notifikasi terkirim!'),
                      backgroundColor: Color(0xFF1E3A8A),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Simpan & Kirim'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF090D16), Color(0xFF0F172A), Color(0xFF1E3A8A)],
            ),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: Color(0xFFF59E0B), size: 22),
            SizedBox(width: 8),
            Text(
              'Admin Control Center',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('aspirasi').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data aspirasi masuk dari siswa.',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            );
          }

          var allDocs = snapshot.data!.docs;

          int total = allDocs.length;
          int pending = allDocs
              .where((d) => (d.data() as Map)['status'] == 'Menunggu')
              .length;
          int proses = allDocs
              .where((d) => (d.data() as Map)['status'] == 'Proses')
              .length;
          int selesai = allDocs
              .where((d) => (d.data() as Map)['status'] == 'Selesai')
              .length;

          var filteredDocs = allDocs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String nama = (data['nama'] ?? '').toString().toLowerCase();
            String nis = (data['nis'] ?? '').toString().toLowerCase();
            String lokasi = (data['lokasi'] ?? '').toString().toLowerCase();
            String status = data['status'] ?? 'Menunggu';

            bool matchesSearch = nama.contains(_searchQuery.toLowerCase()) ||
                nis.contains(_searchQuery.toLowerCase()) ||
                lokasi.contains(_searchQuery.toLowerCase());

            bool matchesFilter = _selectedFilterStatus == 'Semua' ||
                status == _selectedFilterStatus;

            return matchesSearch && matchesFilter;
          }).toList();

          return Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard('TOTAL', total.toString(),
                          Icons.analytics_outlined, const Color(0xFF0F172A)),
                      _buildStatCard('MENUNGGU', pending.toString(),
                          Icons.hourglass_top_rounded, Colors.grey.shade700),
                      _buildStatCard(
                          'PROSES',
                          proses.toString(),
                          Icons.precision_manufacturing_rounded,
                          const Color(0xFFD97706)),
                      _buildStatCard('SELESAI', selesai.toString(),
                          Icons.verified_rounded, const Color(0xFF16A34A)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: const TextStyle(
                          color: Colors.black, // Warna teks hitam pekat
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        cursorColor: Colors.black, // Kursor hitam agar terlihat
                        decoration: InputDecoration(
                          hintText: 'Cari Nama, NIS, Lokasi...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Color(0xFF0F172A), size: 20),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilterStatus,
                          isDense: true,
                          items: const [
                            DropdownMenuItem(
                                value: 'Semua',
                                child: Text('Semua',
                                    style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(
                                value: 'Menunggu',
                                child: Text('⏳ Menunggu',
                                    style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(
                                value: 'Proses',
                                child: Text('⚙️ Proses',
                                    style: TextStyle(fontSize: 12))),
                            DropdownMenuItem(
                                value: 'Selesai',
                                child: Text('✅ Selesai',
                                    style: TextStyle(fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedFilterStatus = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredDocs.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada data laporan yang cocok.',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          var data = filteredDocs[index].data()
                              as Map<String, dynamic>;
                          String docId = filteredDocs[index].id;

                          String nama = data['nama'] ?? 'Siswa';
                          String nis = data['nis'] ?? '-';
                          String kelas = data['kelas'] ?? '-';
                          String kategori = data['id_kategori'] ?? 'Umum';
                          String lokasi = data['lokasi'] ?? '-';
                          String ket = data['ket'] ?? '-';
                          String status = data['status'] ?? 'Menunggu';
                          String feedback = data['feedback'] ?? '';
                          String fcmToken =
                              data['fcmToken'] ?? data['fcm_token'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.grey.shade200, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: const Color(0xFFBFDBFE)),
                                        ),
                                        child: Text(
                                          kategori,
                                          style: const TextStyle(
                                            color: Color(0xFF1D4ED8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: [
                                              'Menunggu',
                                              'Proses',
                                              'Selesai'
                                            ].contains(status)
                                                ? status
                                                : 'Menunggu',
                                            isDense: true,
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'Menunggu',
                                                child: Text('⏳ Menunggu',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Proses',
                                                child: Text('⚙️ Proses',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFFD97706),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              DropdownMenuItem(
                                                value: 'Selesai',
                                                child: Text('✅ Selesai',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF16A34A),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) {
                                                _updateStatus(docId, val,
                                                    fcmToken, lokasi);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$nama ($kelas)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'NIS: $nis',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded,
                                          size: 14, color: Colors.redAccent),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'Lokasi: $lokasi',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Text(
                                      '💬 Keterangan: $ket',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (feedback.isNotEmpty)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFFDE68A)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.admin_panel_settings,
                                              size: 16,
                                              color: Color(0xFFD97706)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Tanggapan Admin: $feedback',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF92400E),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () => _showFeedbackDialog(
                                          docId, feedback, fcmToken, lokasi),
                                      icon: const Icon(
                                          Icons.rate_review_outlined,
                                          size: 14,
                                          color: Color(0xFF1E3A8A)),
                                      label: Text(
                                        feedback.isEmpty
                                            ? 'Beri Tanggapan'
                                            : 'Edit Tanggapan',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String count, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
