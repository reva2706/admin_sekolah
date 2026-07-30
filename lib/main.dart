import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
      title: 'Portal Admin Aspirasi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0F172A)),
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

  Future<void> _loginAdmin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password wajib diisi!')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Gagal! Periksa kembali email & password.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('LOGIN ADMIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Admin'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginAdmin,
                  child: _isLoading ? const CircularProgressIndicator() : const Text('MASUK'),
                ),
              ),
            ],
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
  String _filterStatus = 'Semua';

  Future<void> _updateStatus(String docId, String statusBaru) async {
    await FirebaseFirestore.instance.collection('aspirasi').doc(docId).update({'status': statusBaru});
  }

  void _showFeedbackDialog(String docId, String currentFeedback) {
    final feedbackController = TextEditingController(text: currentFeedback);
    Uint8List? webImageBytes;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Beri Tanggapan & Foto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Tulis tanggapan...'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (image != null) {
                          var bytes = await image.readAsBytes();
                          setDialogState(() => webImageBytes = bytes);
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text('Pilih Foto'),
                    ),
                    if (webImageBytes != null) const Text('Foto terpilih!', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('aspirasi').doc(docId).update({
                      'feedback': feedbackController.text.trim(),
                    });
                    if (mounted) Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text('Dashboard Admin Aspirasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('aspirasi').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          var docs = snapshot.data!.docs;
          var filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String status = data['status'] ?? 'Menunggu';
            if (_filterStatus == 'Semua') return true;
            return status == _filterStatus;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Semua', 'Menunggu', 'Proses', 'Selesai'].map((status) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(status),
                        selected: _filterStatus == status,
                        onSelected: (bool selected) {
                          setState(() => _filterStatus = status);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var data = filteredDocs[index].data() as Map<String, dynamic>;
                    String docId = filteredDocs[index].id;
                    String status = data['status'] ?? 'Menunggu';
                    String fotoSiswa = data['fotoUrl'] ?? data['imageUrl'] ?? '';

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.between,
                              children: [
                                Text('${data['nama']} (${data['kelas'] ?? '-'})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                DropdownButton<String>(
                                  value: ['Menunggu', 'Proses', 'Selesai'].contains(status) ? status : 'Menunggu',
                                  items: const [
                                    DropdownMenuItem(value: 'Menunggu', child: Text('Menunggu')),
                                    DropdownMenuItem(value: 'Proses', child: Text('Proses')),
                                    DropdownMenuItem(value: 'Selesai', child: Text('Selesai')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) _updateStatus(docId, val);
                                  },
                                ),
                              ],
                            ),
                            Text('Lokasi: ${data['lokasi'] ?? '-'}'),
                            Text('Keterangan: ${data['ket'] ?? '-'}'),
                            if (fotoSiswa.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Image.network(fotoSiswa, height: 100, width: 100, fit: BoxFit.cover),
                            ],
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _showFeedbackDialog(docId, data['feedback'] ?? ''),
                                child: const Text('Beri Tanggapan'),
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
}
