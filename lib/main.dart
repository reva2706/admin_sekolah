import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                          // LOGO UTUH ASLI TANPA BINGKAI DAN TANPA PEMOTONG BENTUK
                          Image.asset(
                            'assets/logo_sekolah.png',
                            width: 75,
                            height: 75,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.shield,
                                size: 50,
                                color: Colors.indigo,
                              );
                            },
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
                            style: const TextStyle(color: Colors.black87),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Email Administrator',
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            style: const TextStyle(color: Colors.black87),
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: const TextStyle(color: Colors.grey),
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
                    textAlign: TextAlign.center,
                  )
                ],
              ),
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
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String selectedFilter = 'Semua'; 
  
  String selectedPeriode = 'Semua'; 
  DateTime? startDate;
  DateTime? endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-';
    if (timestamp is Timestamp) {
      DateTime dt = timestamp.toDate();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }

  String _getLokasi(Map<String, dynamic> data) {
    String kat = data['kategori'] ?? '';
    String lok = data['lokasi'] ?? '';
    if (kat.isNotEmpty && lok.isNotEmpty) {
      return '$kat ($lok)';
    }
    return lok.isNotEmpty ? lok : (kat.isNotEmpty ? kat : '-');
  }

  String _getKeterangan(Map<String, dynamic> data) {
    return data['keterangan'] ??
        data['detail'] ??
        data['isi'] ??
        data['ket'] ??
        data['deskripsi'] ??
        '-';
  }

  String? _getFotoSiswa(Map<String, dynamic> data) {
    return data['fotoUrl'] ??
        data['imageUrl'] ??
        data['fotoUrlSiswa'] ??
        data['foto'] ??
        data['image'];
  }

  void _aturFilterPeriode(String periode) {
    setState(() {
      selectedPeriode = periode;
      DateTime now = DateTime.now();

      if (periode == 'Minggu Ini') {
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
      } else if (periode == 'Bulan Ini') {
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
      } else if (periode == 'Semua') {
        startDate = null;
        endDate = null;
      }
    });
  }

  Future<void> _pilihRentangTanggalCustom(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        selectedPeriode = 'Custom';
        startDate = picked.start;
        endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
    }
  }

  void _cetakLaporan(List<QueryDocumentSnapshot> filteredDocs) {
    String rowsHtml = '';
    int no = 1;
    for (var doc in filteredDocs) {
      var data = doc.data() as Map<String, dynamic>;
      String tanggal = _formatTimestamp(data['createdAt'] ?? data['timestamp']);
      String nis = data['nis'] ?? data['nisn'] ?? '-';
      String kelas = data['kelas'] ?? '';
      String nisKelas = kelas.isNotEmpty ? '$nis / $kelas' : nis;
      String nama = data['nama'] ?? 'Tanpa Nama';
      String lokasi = _getLokasi(data);
      String ket = _getKeterangan(data);
      String status = data['status'] ?? 'Menunggu';

      rowsHtml += '''
        <tr>
          <td>$no</td>
          <td>$tanggal</td>
          <td>$nisKelas</td>
          <td>$nama</td>
          <td>$lokasi</td>
          <td>$ket</td>
          <td>$status</td>
        </tr>
      ''';
      no++;
    }

    String htmlContent = '''
      <html>
        <head>
          <title>Laporan Aspirasi Siswa - SMKN 1 Sanden</title>
          <style>
            body { font-family: Arial, sans-serif; padding: 20px; color: #333; }
            h2, h4 { text-align: center; margin: 4px 0; }
            table { width: 100%; border-collapse: collapse; margin-top: 20px; }
            th, td { border: 1px solid #999; padding: 8px 12px; font-size: 12px; text-align: left; }
            th { background-color: #0F1D38; color: white; }
            tr:nth-child(even) { background-color: #f9f9f9; }
            .footer { margin-top: 30px; text-align: right; font-size: 12px; }
          </style>
        </head>
        <body>
          <h2>PEMERINTAH DAERAH ISTIMEWA YOGYAKARTA</h2>
          <h2>DINAS PENDIDIKAN, PEMUDA, DAN OLAHRAGA</h2>
          <h2>SMK NEGERI 1 SANDEN</h2>
          <h4>Laporan Aspirasi & Pengaduan Siswa</h4>
          <p style="text-align:center; font-size: 13px; color: #555;">Periode Filter: <b>$selectedPeriode</b> | Status: <b>$selectedFilter</b></p>
          
          <table>
            <thead>
              <tr>
                <th>No</th>
                <th>Tanggal</th>
                <th>NIS / Kelas</th>
                <th>Nama Siswa</th>
                <th>Kategori / Lokasi</th>
                <th>Keterangan</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              $rowsHtml
            </tbody>
          </table>

          <div class="footer">
            <p>Dicetak otomatis dari Portal Admin SMKN 1 Sanden</p>
          </div>

          <script>
            window.onload = function() { window.print(); }
          </script>
        </body>
      </html>
    ''';

    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
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

          var filteredDocs = docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String status = data['status'] ?? 'Menunggu';
            String nama = (data['nama'] ?? data['namaSiswa'] ?? '').toString().toLowerCase();
            String nis = (data['nis'] ?? data['nisn'] ?? '').toString().toLowerCase();
            String query = searchQuery.toLowerCase().trim();

            bool matchesFilter = (selectedFilter == 'Semua') || (status == selectedFilter);
            bool matchesSearch = query.isEmpty || nama.contains(query) || nis.contains(query);

            bool matchesDate = true;
            if (startDate != null && endDate != null) {
              dynamic rawTs = data['createdAt'] ?? data['timestamp'];
              if (rawTs is Timestamp) {
                DateTime docDate = rawTs.toDate();
                matchesDate = docDate.isAfter(startDate!.subtract(const Duration(seconds: 1))) &&
                    docDate.isBefore(endDate!.add(const Duration(seconds: 1)));
              } else {
                matchesDate = false;
              }
            }

            return matchesFilter && matchesSearch && matchesDate;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = constraints.maxWidth > 800
                        ? (constraints.maxWidth - 48) / 4
                        : (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildClickableStatCard('Total Laporan', total.toString(), Colors.blue, cardWidth, 'Semua'),
                        _buildClickableStatCard('Menunggu', menunggu.toString(), Colors.orange, cardWidth, 'Menunggu'),
                        _buildClickableStatCard('Diproses', diproses.toString(), Colors.purple, cardWidth, 'Diproses'),
                        _buildClickableStatCard('Selesai', selesai.toString(), Colors.green, cardWidth, 'Selesai'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 12,
                        spacing: 12,
                        children: [
                          const Text(
                            'Filter Detail Laporan Berdasarkan Waktu:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F1D38)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            icon: const Icon(Icons.print, size: 18),
                            label: Text(
                              'Cetak Laporan ($selectedPeriode)',
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: filteredDocs.isEmpty ? null : () => _cetakLaporan(filteredDocs),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ChoiceChip(
                            label: const Text('Semua Waktu'),
                            selected: selectedPeriode == 'Semua',
                            onSelected: (selected) => _aturFilterPeriode('Semua'),
                            selectedColor: Colors.amber.shade200,
                          ),
                          ChoiceChip(
                            label: const Text('Laporan Minggu Ini'),
                            selected: selectedPeriode == 'Minggu Ini',
                            onSelected: (selected) => _aturFilterPeriode('Minggu Ini'),
                            selectedColor: Colors.amber.shade200,
                          ),
                          ChoiceChip(
                            label: const Text('Laporan Bulan Ini'),
                            selected: selectedPeriode == 'Bulan Ini',
                            onSelected: (selected) => _aturFilterPeriode('Bulan Ini'),
                            selectedColor: Colors.amber.shade200,
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.date_range, size: 16),
                            label: Text(selectedPeriode == 'Custom' && startDate != null && endDate != null
                                ? 'Custom: ${_formatTimestamp(Timestamp.fromDate(startDate!)).split(' ')[0]} - ${_formatTimestamp(Timestamp.fromDate(endDate!)).split(' ')[0]}'
                                : 'Pilih Rentang Tanggal'),
                            onPressed: () => _pilihRentangTanggalCustom(context),
                            backgroundColor: selectedPeriode == 'Custom' ? Colors.amber.shade200 : Colors.grey.shade200,
                          ),
                          if (selectedPeriode != 'Semua')
                            TextButton.icon(
                              onPressed: () => _aturFilterPeriode('Semua'),
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Reset Filter Waktu'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan NIS atau Nama Siswa...',
                      hintStyle: const TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0F1D38), size: 22),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0F1D38), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
                if (selectedFilter != 'Semua') ...[
                  const SizedBox(height: 12),
                  Chip(
                    label: Text('Filter Status: $selectedFilter', style: const TextStyle(color: Colors.white)),
                    backgroundColor: const Color(0xFF0F1D38),
                    deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                    onDeleted: () {
                      setState(() {
                        selectedFilter = 'Semua';
                      });
                    },
                  ),
                ],
                const SizedBox(height: 24),

                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 8,
                          spacing: 12,
                          children: [
                            Text(
                              'Daftar Laporan Aspirasi (Status: $selectedFilter | Periode: $selectedPeriode)',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text('${filteredDocs.length} Data Ditampilkan',
                                style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        filteredDocs.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(child: Text('Data tidak ditemukan pada filter/pencarian ini.')),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Tanggal')),
                                    DataColumn(label: Text('NIS / Kelas')),
                                    DataColumn(label: Text('Nama Siswa')),
                                    DataColumn(label: Text('Kategori / Lokasi')),
                                    DataColumn(label: Text('Keterangan')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Aksi')),
                                  ],
                                  rows: filteredDocs.map((doc) {
                                    var data = doc.data() as Map<String, dynamic>;
                                    String tanggal = _formatTimestamp(data['createdAt'] ?? data['timestamp']);
                                    String nis = data['nis'] ?? data['nisn'] ?? '-';
                                    String kelas = data['kelas'] ?? '';
                                    String nisKelas = kelas.isNotEmpty ? '$nis ($kelas)' : nis;
                                    String nama = data['nama'] ?? 'Tanpa Nama';
                                    String lokasi = _getLokasi(data);
                                    String ket = _getKeterangan(data);
                                    String status = data['status'] ?? 'Menunggu';

                                    return DataRow(cells: [
                                      DataCell(Text(tanggal)),
                                      DataCell(Text(nisKelas)),
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
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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

  void _showDetailDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    String selectedStatus = data['status'] ?? 'Menunggu';
    final feedbackController = TextEditingController(text: data['feedbackAdmin'] ?? '');

    String? base64ImageString;
    Uint8List? selectedImageBytes;
    String? selectedFileName;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void pickGalleryImage() {
              final html.FileUploadInputElement input = html.FileUploadInputElement();
              input.accept = 'image/*';
              input.click();

              input.onChange.listen((event) {
                final file = input.files?.first;
                if (file != null) {
                  final reader = html.FileReader();
                  reader.readAsDataUrl(file);
                  reader.onLoadEnd.listen((event) {
                    setDialogState(() {
                      base64ImageString = reader.result as String?;
                      final readerBytes = html.FileReader();
                      readerBytes.readAsArrayBuffer(file);
                      readerBytes.onLoadEnd.listen((e) {
                        setDialogState(() {
                          selectedImageBytes = readerBytes.result as Uint8List?;
                          selectedFileName = file.name;
                        });
                      });
                    });
                  });
                }
              });
            }

            String ketSiswa = _getKeterangan(data);
            String? fotoSiswaUrl = _getFotoSiswa(data);

            return AlertDialog(
              title: Text('Detail Laporan - ID: $docId'),
              content: SizedBox(
                width: 620,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tanggal: ${_formatTimestamp(data['createdAt'] ?? data['timestamp'])}',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo)),
                            const SizedBox(height: 4),
                            Text('Nama Siswa: ${data['nama'] ?? 'Tanpa Nama'} | Kelas: ${data['kelas'] ?? '-'} | NIS: ${data['nis'] ?? '-'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('Kategori / Lokasi: ${_getLokasi(data)}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('Keterangan / Rincian dari Siswa:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ketSiswa.isEmpty ? '-' : ketSiswa,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 12),

                      const Text('Foto Bukti dari Siswa:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      (fotoSiswaUrl != null && fotoSiswaUrl.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: fotoSiswaUrl.startsWith('data:image')
                                  ? Image.memory(
                                      base64Decode(fotoSiswaUrl.split(',').last),
                                      height: 180,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      fotoSiswaUrl,
                                      height: 180,
                                      fit: BoxFit.cover,
                                    ),
                            )
                          : const Text('Siswa tidak melampirkan foto.', style: TextStyle(color: Colors.grey, fontSize: 13)),

                      const Divider(height: 32),

                      const Text('Form Tanggapan Administrator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),

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

                      TextField(
                        controller: feedbackController,
                        style: const TextStyle(color: Colors.black87),
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Feedback / Catatan Admin ke Siswa',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('Kirim Foto Balasan ke Siswa:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: pickGalleryImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pilih Foto dari Galeri'),
                      ),
                      const SizedBox(height: 12),

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
                              child: data['fotoUrlAdmin'].toString().startsWith('data:image')
                                  ? Image.memory(
                                      base64Decode(data['fotoUrlAdmin'].toString().split(',').last),
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(data['fotoUrlAdmin'], height: 120, fit: BoxFit.cover),
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

                          String? finalPhotoAdmin = data['fotoUrlAdmin'];
                          if (base64ImageString != null) {
                            finalPhotoAdmin = base64ImageString;
                          }

                          try {
                            await FirebaseFirestore.instance
                                .collection('aspirasi')
                                .doc(docId)
                                .update({
                              'status': selectedStatus,
                              'feedbackAdmin': feedbackController.text,
                              if (finalPhotoAdmin != null)
                                'fotoUrlAdmin': finalPhotoAdmin,
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tanggapan & Status Berhasil Diperbarui!')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal memperbarui database: $e')),
                              );
                            }
                          } finally {
                            setDialogState(() => isUploading = false);
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
