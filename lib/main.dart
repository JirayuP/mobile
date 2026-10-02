import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'quote.dart';
import 'api_service.dart';

void main() => runApp(const MyApp());

// แม่พิมพ์บันทึก
class Diary {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final String? quote;
  Diary({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.quote,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'quote': quote,
    };
  }

  factory Diary.fromMap(Map<String, dynamic> map) => Diary(
    id: map['id'],
    title: map['title'],
    content: map['content'],
    date: map['date'],
    mood: map['mood'] ?? 'เฉยๆ',
    quote: map['quote'], // << เพิ่มใน fromMap (?? กันค่าเก่าไม่มี mood)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDiary',
      theme: ThemeData(colorSchemeSeed: Colors.indigo), // ธีมสีคราม
      home: const MainPage(),
    );
  }
}

// หน้ารายการบันทึก
class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});
  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<Diary> diaries = []; // เริ่มจากว่าง (จะโหลดจาก DB)
  late Future<Quote> _quoteFuture;
  Quote? _currentQuote;
  bool _isSearching = false; // กำลังเปิดโหมดค้นหาอยู่หรือไม่
  final TextEditingController _searchController =
      TextEditingController(); // คอนโทรลเลอร์ช่องค้นหา
  String _searchQuery = ''; // ข้อความที่ใช้ค้นหา

  @override
  void initState() {
    super.initState();
    _quoteFuture = ApiService.fetchQuote();
    _loadDiaries(); // โหลดข้อมูลตอนเปิดหน้า
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // โหลดจาก DB
  Future<void> _loadDiaries() async {
    final data = await DatabaseHelper.getAll();
    setState(() {
      diaries = data;
    });
  }

  // กรองรายการบันทึกตามคำค้นหา (ค้นจากชื่อเรื่อง, เนื้อหา, หรืออารมณ์)
  List<Diary> get _filteredDiaries {
    if (_searchQuery.trim().isEmpty) {
      return diaries;
    }
    final query = _searchQuery.trim().toLowerCase();
    return diaries.where((diary) {
      return diary.title.toLowerCase().contains(query) ||
          diary.content.toLowerCase().contains(query) ||
          diary.mood.toLowerCase().contains(query);
    }).toList();
  }

  // เพิ่ม: เขียน DB แล้วโหลดใหม่
  Future<void> _addDiary(Diary diary) async {
    await DatabaseHelper.insert(diary);
    await _loadDiaries();
  }

  Future<void> _updateDiary(Diary diary) async {
    await DatabaseHelper.update(diary);
    await _loadDiaries();
  }

  // ลบ: เขียน DB แล้วโหลดใหม่
  Future<void> _deleteDiary(int id) async {
    await DatabaseHelper.delete(id);
    await _loadDiaries();
  }

  @override
  Widget build(BuildContext context) {
    // ข้อมูลตัวอย่าง (พิมพ์ไว้ในโค้ดก่อน)

    final List<Color> colors = [
      Colors.indigo,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.green,
    ];

    final displayList = _filteredDiaries;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'ค้นหาบันทึก...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : Text('บันทึกของฉัน (${diaries.length})'),
        actions: [
          if (_isSearching) ...[
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'ล้างคำค้นหา',
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'ปิดการค้นหา',
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            ),
          ] else ...[
            // ปุ่มค้นหา
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'ค้นหาบันทึก',
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'โหลดคำคมใหม่',
              onPressed: () {
                setState(() {
                  _quoteFuture =
                      ApiService.fetchQuote(); // สร้าง Future ใหม่ = โหลดใหม่ (ตั้งใจ)
                });
              },
            ),
          ],
        ],
      ),

      body: Column(
        children: [
          // ── กล่องคำคมประจำวัน (ซ่อนเมื่อเปิดค้นหา เพื่อความสบายตา) ──
          if (!_isSearching)
            FutureBuilder<Quote>(
              future: _quoteFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text(
                          'กำลังโหลดคำคม...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'โหลดคำคมไม่ได้',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _quoteFuture = ApiService.fetchQuote(); // โหลดใหม่
                            });
                          },
                          child: const Text('ลองใหม่'),
                        ),
                      ],
                    ),
                  );
                } else {
                  _currentQuote = snapshot.data!;
                  final quote = _currentQuote!;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '"${quote.text}"',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '— ${quote.author}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddDiaryPage(
                                      quote:
                                          '"${quote.text}" — ${quote.author}',
                                    ),
                                  ),
                                );
                                if (result != null && result is Diary) {
                                  await _addDiary(result);
                                }
                              },
                              label: const Text('บันทึกคำคม'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

          // ── รายการบันทึกเดิม ยัดใน Expanded เพื่อไม่ให้ล้นหน้าจอ ──
          Expanded(
            child: diaries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'ยังไม่มีบันทึก',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'กดปุ่ม + เพื่อเขียน',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : displayList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ไม่พบบันทึกที่ตรงกับ "$_searchQuery"',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: displayList.length,
                    itemBuilder: (context, i) {
                      final diary = displayList[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.book,
                            color: colors[i % colors.length],
                          ),
                          title: Text(diary.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${diary.mood} • ${diary.date}'),
                              if (diary.quote != null &&
                                  diary.quote!.isNotEmpty)
                                Text(
                                  '💡 ${diary.quote}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DiaryDetailPage(diary: diary),
                              ),
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddDiaryPage(existing: diary),
                                    ),
                                  );
                                  if (result != null && result is Diary) {
                                    await _updateDiary(result);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('ลบบันทึก?'),
                                      content: Text(
                                        'ต้องการลบ "${diary.title}" ใช่ไหม',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('ยกเลิก'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text(
                                            'ลบ',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    _deleteDiary(diary.id!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // async เพราะต้องรอค่ากลับ
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDiaryPage()),
          );
          if (result != null && result is Diary) {
            // ถ้าได้บันทึกกลับมา
            _addDiary(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DiaryDetailPage extends StatefulWidget {
  final Diary diary; // รับบันทึกที่ถูกแตะเข้ามา
  const DiaryDetailPage({super.key, required this.diary});
  @override
  State<DiaryDetailPage> createState() => _DiaryDetailPage();
}

// หน้ารายละเอียดบันทึก
class _DiaryDetailPage extends State<DiaryDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียด')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
          children: [
            Text(
              widget.diary.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.diary.date,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ), // << วันที่
            if (widget.diary.quote != null &&
                widget.diary.quote!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'คำคมเด็ดๆ:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.diary.quote!,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 32), // เว้นระยะ
            Text(widget.diary.content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// เพิ่ม class นี้
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // หน้าที่เลือกอยู่ (0=บันทึก, 1=ออนไลน์, 2=เกี่ยวกับ)

  // รายการหน้า
  final List<Widget> _pages = [
    const DiaryListPage(), // SQLite เดิม
    const ApiDiaryPage(), // แท็บใหม่
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // แสดงหน้าที่เลือก
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            // เปลี่ยนหน้า + วาดจอใหม่
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'บันทึก'),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'ออนไลน์'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'เกี่ยวกับ'),
        ],
      ),
    );
  }
}

// หน้าเกี่ยวกับ (ง่ายๆ)
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับ')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, size: 80, color: Colors.indigo),
              SizedBox(height: 16),
              Text(
                'MyDiary',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('บันทึกไดอารี่', style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text('สร้างโดย จิรายุ จำปา'), // << ใส่ชื่อตัวเอง
              Text('รหัสนักศึกษา 67011212082'), // << ใส่รหัส
              SizedBox(height: 16),
              Text('เวอร์ชัน 1.0', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class AddDiaryPage extends StatefulWidget {
  final Diary? existing;
  final String? quote;
  const AddDiaryPage({super.key, this.existing, this.quote});
  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>(); // กุญแจคุมฟอร์ม
  final _titleController = TextEditingController(); // อ่านค่าช่องชื่อเรื่อง
  final _contentController = TextEditingController(); // อ่านค่าช่องเนื้อหา
  String _selectedMood = 'มีความสุข'; // ค่าเริ่มต้น
  final List<String> _moods = [
    'มีความสุข',
    'เฉยๆ',
    'เศร้า',
    'เหนื่อย',
    'ตื่นเต้น',
  ];
  DateTime _selectedDate = DateTime.now();
  @override
  void dispose() {
    _titleController.dispose(); // คืนทรัพยากรตอนปิดหน้า
    _contentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      // โหมดแก้ไข: เติมค่าเดิม
      _titleController.text = widget.existing!.title;
      _contentController.text = widget.existing!.content;
      _selectedMood = widget.existing!.mood;
      _selectedDate = DateTime.parse(widget.existing!.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'แก้ไขบันทึก' : 'เขียนบันทึก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if ((widget.quote ?? widget.existing?.quote) != null) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.format_quote,
                        color: Colors.indigo,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.quote ?? widget.existing!.quote!,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.indigo.shade900,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อเรื่อง',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อเรื่อง';
                  }
                  return null; // null = ผ่าน
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5, // ช่องเนื้อหาสูง 5 บรรทัด
                decoration: const InputDecoration(
                  labelText: 'เนื้อหา',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกเนื้อหา';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedMood,
                decoration: const InputDecoration(
                  labelText: 'อารมณ์วันนี้',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.mood),
                ),
                items: _moods.map((mood) {
                  return DropdownMenuItem(value: mood, child: Text(mood));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    //  เลือกค่าเลือกต้อง setState เอง
                    _selectedMood = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'วันที่: ${_selectedDate.toString().substring(0, 10)}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final picked = await showDatePicker(
                    // เปิดปฏิทินให้เลือก
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020), // เลือกได้ตั้งแต่ปี 2020
                    lastDate: DateTime(2030), // ถึงปี 2030
                  );
                  if (picked != null) {
                    // ถ้าเลือก (ไม่กดยกเลิก)
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // validate เช็คแค่ TextFormField
                      final newDiary = Diary(
                        id: widget.existing?.id,
                        title: _titleController.text.trim(),
                        content: _contentController.text.trim(),
                        date: _selectedDate.toString().substring(
                          0,
                          10,
                        ), // วันที่ที่เลือก
                        mood: _selectedMood, // อารมณ์ที่เลือก
                        quote: widget.quote ?? widget.existing?.quote,
                      );

                      Navigator.pop(context, newDiary);
                    }
                  },
                  child: const Text('บันทึก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── หน้าบันทึกบน Cloud (REST API) ──
class ApiDiaryPage extends StatefulWidget {
  const ApiDiaryPage({super.key});
  @override
  State<ApiDiaryPage> createState() => _ApiDiaryPageState();
}

class _ApiDiaryPageState extends State<ApiDiaryPage> {
  late Future<List<dynamic>> _diariesFuture;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  void _loadDiaries() {
    setState(() {
      _diariesFuture = ApiService.getDiaries();
    });
  }

  // เพิ่มแล้วโหลดใหม่ (พร้อม try-catch จาก Lab 4)
  Future<void> _addDiary(
    String title,
    String content,
    String mood,
    String date,
  ) async {
    try {
      await ApiService.createDiary(title, content, mood, date);
      _loadDiaries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต')),
        );
      }
    }
  }

  Future<void> _deleteDiary(dynamic id) async {
    try {
      await ApiService.deleteDiary(id);
      _loadDiaries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต')),
        );
      }
    }
  }

  // แก้ไขแล้วโหลดใหม่
  Future<void> _updateDiary(
    dynamic id,
    String title,
    String content,
    String mood,
    String date,
  ) async {
    try {
      await ApiService.updateDiary(id, title, content, mood, date);
      _loadDiaries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('แก้ไขไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกบน Cloud (REST API)')),
      body: FutureBuilder<List<dynamic>>(
        future: _diariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('ผิดพลาด: ${snapshot.error}'));
          }
          final diaries = snapshot.data!;
          if (diaries.isEmpty) {
            return const Center(child: Text('ยังไม่มีบันทึก กดปุ่ม +'));
          }
          return ListView.builder(
            itemCount: diaries.length,
            itemBuilder: (context, i) {
              final obj = diaries[i];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(obj['title'] ?? ''),
                  subtitle: Text(
                    '${obj['mood'] ?? ''} • ${obj['date'] ?? ''} • ${obj['content'] ?? ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // ให้ Row กว้างเท่าที่จำเป็น
                    children: [
                      // ── ปุ่มแก้ไข: เปิดฟอร์มโหมดแก้ (ส่ง obj เดิมไป) ──
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApiFormPage(existing: obj), // โหมดแก้
                            ),
                          );
                          if (result is Map) {
                            await _updateDiary(
                              obj['id'],
                              result['title'],
                              result['content'],
                              result['mood'],
                              result['date'],
                            );
                          }
                        },
                      ),
                      // ── ปุ่มลบ + ยืนยันก่อนลบ ──
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('ลบบันทึก?'),
                              content: Text('ต้องการลบ "${obj['title']}" ใช่ไหม'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'ลบ',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _deleteDiary(obj['id']);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // ── ปุ่มเพิ่ม: เปิดฟอร์มโหมดเพิ่ม แล้วรับค่ากลับมา createDiary ──
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ApiFormPage(), // โหมดเพิ่ม
            ),
          );
          if (result is Map) {
            await _addDiary(
              result['title'],
              result['content'],
              result['mood'],
              result['date'],
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── ฟอร์มเพิ่ม/แก้ไขบันทึก Cloud (ApiFormPage) ──
class ApiFormPage extends StatefulWidget {
  final Map? existing; // ส่ง obj เดิมมา = โหมดแก้ / null = เพิ่มใหม่
  const ApiFormPage({super.key, this.existing});
  @override
  State<ApiFormPage> createState() => _ApiFormPageState();
}

class _ApiFormPageState extends State<ApiFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _mood = 'มีความสุข';
  final List<String> _moods = [
    'มีความสุข',
    'เฉยๆ',
    'เศร้า',
    'เหนื่อย',
    'ตื่นเต้น',
  ];
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      // โหมดแก้: เติมค่าเดิมลงฟอร์ม
      _titleController.text = widget.existing!['title'] ?? '';
      _contentController.text = widget.existing!['content'] ?? '';
      _mood = widget.existing!['mood'] ?? 'มีความสุข';
      _date =
          DateTime.tryParse(widget.existing!['date'] ?? '') ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'เพิ่มบันทึก' : 'แก้ไขบันทึก'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อเรื่อง',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'กรุณากรอกชื่อเรื่อง'
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'เนื้อหา',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'กรุณากรอกเนื้อหา'
                          : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _mood,
                  decoration: const InputDecoration(
                    labelText: 'อารมณ์',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moods
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _mood = v!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text('วันที่: ${_date.toString().substring(0, 10)}'),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // ส่งค่ากลับเป็น Map ให้หน้ารายการเอาไปเรียก API
                        Navigator.pop(context, {
                          'title': _titleController.text.trim(),
                          'content': _contentController.text.trim(),
                          'mood': _mood,
                          'date': _date.toString().substring(0, 10),
                        });
                      }
                    },
                    child: const Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

