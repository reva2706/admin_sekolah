import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      title: 'Portal Admin SMKN 1 Sanden',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
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
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const AdminDashboard();
        }
        return const AdminLogin();
      },
    );
  }
}

// -----------------------------------------------------------------------------
// LOGIN ADMIN
// -----------------------------------------------------------------------------
class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi Email dan Password')),
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
          const SnackBar(content: Text('Login Gagal! Periksa kembali Email & Password.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    width: 380,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1D38),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: const Icon(
                            Icons.shield,
                            size: 40,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'PORTAL ADMIN ASPIRASI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sistem Pengaduan Aspirasi SMKN 1 Sanden',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Email Administrator',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F1D38),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.amber)
                                : const Text(
                                    'MASUK KE CONTROL PANEL',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Portal Admin SMKN 1 Sanden • Developed by Nareva Ranov P',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DASHBOARD UTAMA
// -----------------------------------------------------------------------------
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String searchQuery = '';
  String selectedFilter = 'Semua'; // Filters: Semua, Menunggu, Diproses, Selesai

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-';
    if (timestamp is Timestamp) {
      DateTime dt = timestamp.toDate();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1D38),
        title: const Text(
          'Dashboard Admin Aspirasi - SMKN 1 Sanden',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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

          if (snapshot.hasError) {
            return Center(child: Text('Terjadi Kesalahan: ${snapshot.error}'));
          }

          var docs = snapshot.data?.docs ?? [];

          // Hitung Jumlah untuk Kartu Statistik
          int total = docs.length;
          int menunggu = docs.where((doc) {
            var st = (doc.data() as Map<String, dynamic>)['status'] ?? 'Menunggu';
            return st == 'Menunggu';
          }).length;
          int diproses = docs.where((doc) {
            var st = (doc.data() as Map<String, dynamic>)['status'] ?? '';
            return st == 'Diproses';
          }).length;
          int selesai = docs.where((doc) {
            var st = (doc.data() as Map<String, dynamic>)['status'] ?? '';
            return st == 'Selesai';
          }).length;

          // Filter Data Berdasarkan Kartu Terpilih & Query Pencarian
          var filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String status = data['status'] ?? 'Menunggu';
            String nama = (data['nama'] ?? '').toString().toLowerCase();
            String nis = (data['nis'] ?? '').toString().toLowerCase();
            String query = searchQuery.toLowerCase();

            bool matchesFilter = (selectedFilter == 'Semua') || (status == selectedFilter);
            bool matchesSearch = nama.contains(query) || nis.contains(query);

            return matchesFilter && matchesSearch;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kartu Statistik Interaktif
                LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = constraints.maxWidth > 800
                        ? (constraints.maxWidth - 48) / 4
                        : (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildClickableStatCard(
                          'Total Laporan',
                          total.toString(),
                          Colors.blue,
                          cardWidth,
                          'Semua',
                        ),
                        _buildClickableStatCard(
                          'Menunggu',
                          menunggu.toString(),
                          Colors.orange,
                          cardWidth,
                          'Menunggu',
                        ),
                        _buildClickableStatCard(
                          'Diproses',
                          diproses.toString(),
                          Colors.purple,
                          cardWidth,
                          'Diproses',
                        ),
                        _buildClickableStatCard(
                          'Selesai',
                          selesai.toString(),
                          Colors.green,
                          cardWidth,
                          'Selesai',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Bar Pencarian & Indikator Filter
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari berdasarkan NIS atau Nama Siswa...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    if (selectedFilter != 'Semua') ...[
                      const SizedBox(width: 12),
                      Chip(
                        label: Text('Kategori: $selectedFilter'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            selectedFilter = 'Semua';
                          });
                        },
                      ),
                    ]
                  ],
                ),
                const SizedBox(height: 24),

                // Tabel Laporan Masuk
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Daftar Laporan ($selectedFilter)',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text('${filteredDocs.length} Data Ditampilkan',
                                style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        filteredDocs.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(child: Text('Data tidak ditemukan / Belum ada laporan pada kategori ini.')),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Tanggal')),
                                    DataColumn(label: Text('NIS')),
                                    DataColumn(label: Text('Nama Siswa')),
                                    DataColumn(label: Text('Lokasi / Judul')),
                                    DataColumn(label: Text('Keterangan')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Aksi')),
                                  ],
                                  rows: filteredDocs.map((doc) {
                                    var data = doc.data() as Map<String, dynamic>;
                                    String tanggal = _formatTimestamp(data['timestamp'] ?? data['createdAt'] ?? data['tanggal']);
                                    String nis = data['nis'] ?? '-';
                                    String nama = data['nama'] ?? 'Tanpa Nama';
                                    String lokasi = data['lokasi'] ?? data['judul'] ?? '-';
                                    String ket = data['ket'] ?? data['isi'] ?? '-';
                                    String status = data['status'] ?? 'Menunggu';

                                    return DataRow(cells: [
                                      DataCell(Text(tanggal)),
                                      DataCell(Text(nis)),
                                      DataCell(Text(nama)),
                                      DataCell(Text(lokasi)),
                                      DataCell(Text(
                                        ket.length > 30 ? '${ket.substring(0, 30)}...' : ket,
                                      )),
                                      DataCell(_buildStatusChip(status)),
                                      DataCell(
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0F1D38),
                                          ),
                                          icon: const Icon(Icons.edit, size: 16, color: Colors.amber),
                                          label: const Text('Respon', style: TextStyle(color: Colors.white)),
                                          onPressed: () => _showDetailDialog(context, doc.id, data),
                                        ),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Portal Admin SMKN 1 Sanden • Developed by Nareva Ranov P',
                    style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // WIDGET KARTU STATISTIK INTERAKTIF
  Widget _buildClickableStatCard(String title, String count, Color color, double width, String filterKey) {
    bool isSelected = selectedFilter == filterKey;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = filterKey;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.amber, width: 2.5) : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.amber.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                if (isSelected) const Icon(Icons.check_circle, size: 18, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    switch (status) {
      case 'Diproses':
        bg = Colors.purple;
        break;
      case 'Selesai':
        bg = Colors.green;
        break;
      default:
        bg = Colors.orange;
    }

    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: bg,
    );
  }

  // DIALOG TANGGAPAN DAN PENGIRIMAN BALASAN KE SISWA
  void _showDetailDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    String selectedStatus = data['status'] ?? 'Menunggu';
    final feedbackController = TextEditingController(text: data['feedbackAdmin'] ?? '');

    Uint8List? selectedImageBytes;
    String? selectedFileName;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            // Memilih Foto Balasan Langsung dari Galeri/Folder Komputer (Tanpa Kamera)
            void pickGalleryImage() {
              final html.FileUploadInputElement input = html.FileUploadInputElement();
              input.accept = 'image/*'; // Khusus format file gambar dari Galeri
              input.click();

              input.onChange.listen((event) {
                final file = input.files?.first;
                if (file != null) {
                  final reader = html.FileReader();
                  reader.readAsArrayBuffer(file);
                  reader.onLoadEnd.listen((event) {
                    setDialogState(() {
                      selectedImageBytes = reader.result as Uint8List?;
                      selectedFileName = file.name;
                    });
                  });
                }
              });
            }

            return AlertDialog(
              title: Text('Detail Laporan - ID: $docId'),
              content: SizedBox(
                width: 620,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informasi Tanggal dan Identitas Siswa
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal Laporan: ${_formatTimestamp(data['timestamp'] ?? data['createdAt'] ?? data['tanggal'])}',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo)),
                            const SizedBox(height: 4),
                            Text('Siswa: ${data['nama'] ?? 'Tanpa Nama'} (${data['nis'] ?? '-'})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('Lokasi / Judul: ${data['lokasi'] ?? data['judul'] ?? '-'}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Keterangan dari Siswa
                      const Text('Keterangan / Rincian dari Siswa:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(data['ket'] ?? data['isi'] ?? '-', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 12),

                      // Foto dari Siswa
                      const Text('Foto Bukti dari Siswa:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      (data['fotoUrl'] != null || data['fotoUrlSiswa'] != null)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['fotoUrl'] ?? data['fotoUrlSiswa'],
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text('Gagal memuat foto dari siswa.'),
                              ),
                            )
                          : const Text('Siswa tidak melampirkan foto.', style: TextStyle(color: Colors.grey)),

                      // Feedback/Respon dari Siswa (Jika ada)
                      if (data['feedbackSiswa'] != null && data['feedbackSiswa'].toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text('Tanggapan Balik dari Siswa:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(data['feedbackSiswa'].toString()),
                        ),
                      ],

                      const Divider(height: 32),

                      // FORM BALASAN ADMIN
                      const Text('Form Tanggapan Administrator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),

                      // Dropdown Update Status
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Update Status Laporan',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Menunggu', 'Diproses', 'Selesai']
                            .map((st) => DropdownMenuItem(value: st, child: Text(st)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              selectedStatus = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Input Feedback Admin
                      TextField(
                        controller: feedbackController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Feedback / Catatan Admin ke Siswa',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Pilih Foto dari Galeri
                      const Text('Kirim Foto Balasan ke Siswa (Pilih dari Galeri):',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: pickGalleryImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pilih Foto dari Galeri'),
                      ),
                      const SizedBox(height: 12),

                      // Preview Foto Balasan Terpilih
                      if (selectedImageBytes != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('File Terpilih: ${selectedFileName ?? 'Gambar Galeri'}'),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(selectedImageBytes!, height: 120, fit: BoxFit.cover),
                            ),
                          ],
                        )
                      else if (data['fotoUrlAdmin'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Foto Balasan Terkirim Sebelumnya:'),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(data['fotoUrlAdmin'], height: 120, fit: BoxFit.cover),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F1D38)),
                  onPressed: isUploading
                      ? null
                      : () async {
                          setDialogState(() => isUploading = true);

                          String? uploadedAdminPhotoUrl = data['fotoUrlAdmin'];

                          // Upload gambar galeri ke Firebase Storage
                          if (selectedImageBytes != null) {
                            try {
                              String fileName =
                                  'admin_${DateTime.now().millisecondsSinceEpoch}.jpg';
                              Reference ref = FirebaseStorage.instance
                                  .ref()
                                  .child('balasan_admin/$fileName');

                              UploadTask uploadTask = ref.putData(
                                selectedImageBytes!,
                                SettableMetadata(contentType: 'image/jpeg'),
                              );

                              TaskSnapshot snapshot = await uploadTask;
                              uploadedAdminPhotoUrl = await snapshot.ref.getDownloadURL();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal mengunggah foto balasan: $e')),
                              );
                            }
                          }

                          // Update Firestore Data Realtime
                          await FirebaseFirestore.instance
                              .collection('aspirasi')
                              .doc(docId)
                              .update({
                            'status': selectedStatus,
                            'feedbackAdmin': feedbackController.text,
                            if (uploadedAdminPhotoUrl != null)
                              'fotoUrlAdmin': uploadedAdminPhotoUrl,
                          });

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tanggapan dan update berhasil dikirim!')),
                            );
                          }
                        },
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2),
                        )
                      : const Text('Kirim Balasan & Update', style: TextStyle(color: Colors.amber)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
