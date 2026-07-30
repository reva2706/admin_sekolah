import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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
      ),
      home: const AuthWrapper(),
    );
  }
}

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
        _showSnackBar('Akses Ditolak! Kredensial tidak valid.', Colors.red.shade700);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF090D16), Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.admin_panel_settings_rounded, size: 48, color: Color(0xFFF59E0B)),
                  const SizedBox(height: 16),
                  const Text(
                    'PORTAL ADMIN ASPIRASI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Administrator',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isObscure = !_isObscure),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFFF59E0B))
                          : const Text('MASUK', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  String _searchQuery = '';
  String _selectedFilterStatus = 'Semua';

  Future<void> _updateStatus(String docId, String statusBaru, String lokasi) async {
    await FirebaseFirestore.instance.collection('aspirasi').doc(docId).update({'status': statusBaru});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah ke: $statusBaru'), backgroundColor: Colors.green),
      );
    }
  }

  void _showFeedbackDialog(String docId, String currentFeedback) {
    TextEditingController feedbackController = TextEditingController(text: currentFeedback);
    Uint8List? webImageBytes;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Tanggapan & Foto Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Tulis tanggapan atau solusi...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (image != null) {
                          var bytes = await image.readAsBytes();
                          setDialogState(() {
                            webImageBytes = bytes;
                          });
                        }
                      },
                      icon: const Icon(Icons.photo_camera, size: 16),
                      label: const Text('Pilih Foto Balasan'),
                    ),
                    if (webImageBytes != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('✓ Foto siap dikirim', style: TextStyle(color: Colors.green, fontSize: 12)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('aspirasi').doc(docId).update({
                      'feedback': feedbackController.text.trim(),
                      'has_admin_image': webImageBytes != null,
                    });
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tanggapan berhasil disimpan!'), backgroundColor: Colors.blue),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF090D16), Color(0xFF0F172A), Color(0xFF1E3A8A)]),
          ),
        ),
        title: const Text('Admin Control Center', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('aspirasi').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada data laporan.'));
          }

          var allDocs = snapshot.data!.docs;
          int total = allDocs.length;
          int pending = allDocs.where((d) => (d.data() as Map)['status'] == 'Menunggu').length;
          int proses = allDocs.where((d) => (d.data() as Map)['status'] == 'Proses').length;
          int selesai = allDocs.where((d) => (d.data() as Map)['status'] == 'Selesai').length;

          var filteredDocs = allDocs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String nama = (data['nama'] ?? '').toString().toLowerCase();
            String nis = (data['nis'] ?? '').toString().toLowerCase();
            String status = data['status'] ?? 'Menunggu';

            bool matchesSearch = nama.contains(_searchQuery.toLowerCase()) || nis.contains(_searchQuery.toLowerCase());
            bool matchesFilter = _selectedFilterStatus == 'Semua' || status == _selectedFilterStatus;
            return matchesSearch && matchesFilter;
          }).toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard('TOTAL', total.toString(), Colors.blue, 'Semua'),
                      _buildStatCard('MENUNGGU', pending.toString(), Colors.grey.shade700, 'Menunggu'),
                      _buildStatCard('PROSES', proses.toString(), Colors.orange, 'Proses'),
                      _buildStatCard('SELESAI', selesai.toString(), Colors.green, 'Selesai'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Cari Nama atau NIS...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var data = filteredDocs[index].data() as Map<String, dynamic>;
                    String docId = filteredDocs[index].id;
                    String status = data['status'] ?? 'Menunggu';
                    String fotoSiswaUrl = data['fotoUrl'] ?? data['imageUrl'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Text('${data['nama']} (${data['kelas']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              DropdownButton<String>(
                                value: ['Menunggu', 'Proses', 'Selesai'].contains(status) ? status : 'Menunggu',
                                items: const [
                                  DropdownMenuItem(value: 'Menunggu', child: Text('Menunggu')),
                                  DropdownMenuItem(value: 'Proses', child: Text('Proses')),
                                  DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                                ],
                                onChanged: (val) {
                                  if (val != null) _updateStatus(docId, val, data['lokasi'] ?? '');
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Lokasi: ${data['lokasi']}'),
                          Text('Keterangan: ${data['ket'] ?? data['keterangan'] ?? '-'}'),
                          if (fotoSiswaUrl.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(fotoSiswaUrl, height: 100, width: 130, fit: BoxFit.cover),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _showFeedbackDialog(docId, data['feedback'] ?? ''),
                              icon: const Icon(Icons.rate_review, size: 16),
                              label: const Text('Beri Tanggapan & Foto'),
                            ),
                          ),
                        ],
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

  Widget _buildStatCard(String title, String count, Color color, String filterValue) {
    bool isSelected = _selectedFilterStatus == filterValue;
    return InkWell(
      onTap: () => setState(() => _selectedFilterStatus = filterValue),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.3), width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
            Text(count, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
