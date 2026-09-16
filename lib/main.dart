import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ATMServiceApp());
}

class ATMServiceApp extends StatelessWidget {
  const ATMServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'دستیار مهندسی سرویس ATM',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  final List> brands = const [
    {
      'name': 'Hyosung',
      'icon': Icons.account_balance,
      'color': Colors.blue,
      'models': ['MoniMax 5600', 'MoniMax 7600', 'MoniMax 8000']
    },
    {
      'name': 'GRG',
      'icon': Icons.precision_manufacturing,
      'color': Colors.teal,
      'models': ['H22N', 'H38N', 'P2801']
    },
    {
      'name': 'BANQIT',
      'icon': Icons.developer_board,
      'color': Colors.orange,
      'models': ['Q-3400', 'Q-4000', 'Q-series']
    },
  ];

  List pdfNames = [];

  @override
  void initState() {
    super.initState();
    _loadPdfList();
  }

  Future _loadPdfList() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pdfNames = prefs.getStringList('uploaded_pdf_names') ?? [];
    });
  }

  void _pickGlobalPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        List currentList = prefs.getStringList('uploaded_pdf_names') ?? [];

        for (var file in result.files) {
          if (!currentList.contains(file.name)) {
            currentList.add(file.name);
          }
        }

        await prefs.setStringList('uploaded_pdf_names', currentList);
        setState(() {
          pdfNames = currentList;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فایل PDF با موفقیت اضافه شد.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در آپلود فایل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دستیار سرویس و تعمیرات ATM'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blueGrey.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'کتابخانه متمرکز PDFها',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickGlobalPDF,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('آپلود PDF'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'تعداد دفترچه‌های آپلود شده: ${pdfNames.length}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (pdfNames.isNotEmpty) ...[
                      const Divider(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: pdfNames.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                            title: Text(pdfNames[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, size: 18, color: Colors.grey),
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                setState(() {
                                  pdfNames.removeAt(index);
                                });
                                await prefs.setStringList('uploaded_pdf_names', pdfNames);
                              },
                            ),
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'انتخاب برند دستگاه:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                final IconData iconData = brand['icon'] as IconData;
                final Color colorData = brand['color'] as Color;
                final String nameData = brand['name'] as String;
                final List modelsList = List.from(brand['models'] as List);

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: colorData,
                      radius: 28,
                      child: Icon(iconData, color: Colors.white, size: 30),
                    ),
                    title: Text(
                      nameData,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('مدل‌ها: ${modelsList.join(', ')}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModelSelectionScreen(
                            brandName: nameData,
                            models: modelsList,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ModelSelectionScreen extends StatelessWidget {
  final String brandName;
  final List models;

  const ModelSelectionScreen({super.key, required this.brandName, required this.models});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مدل‌های $brandName')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: models.length,
        itemBuilder: (context, index) {
          final model = models[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.important_devices, color: Colors.blueAccent),
              title: Text(model, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardScreen(brandName: brandName, modelName: model),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final String brandName;
  final String modelName;
  const DashboardScreen({super.key, required this.brandName, required this.modelName});

  @override
  State createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State {
  List> experiences = [];

  @override
  void initState() {
    super.initState();
    _loadExperiences();
  }

  Future _loadExperiences() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '\({widget.brandName}_\){widget.modelName}_experiences';
    List? rawList = prefs.getStringList(key);
    if (rawList != null) {
      setState(() {
        experiences = rawList.map((e) {
          var parts = e.split('||');
          return {
            'title': parts.isNotEmpty ? parts[0] : '',
            'note': parts.length > 1 ? parts[1] : '',
            'image': parts.length > 2 ? parts[2] : '',
          };
        }).toList();
      });
    }
  }

  Future _saveExperiences() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '\({widget.brandName}_\){widget.modelName}_experiences';
    List rawList = experiences.map((e) => '\({e['title']}||\){e['note']}||${e['image']}').toList();
    await prefs.setStringList(key, rawList);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('\({widget.brandName} -\){widget.modelName}'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.table_chart), text: 'کدهای خطا'),
              Tab(icon: Icon(Icons.note_alt), text: 'تجربیات من'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildErrorCodesSection(),
            _buildExperienceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCodesSection() {
    final List> errorCodes = [
      {'code': '34', 'desc': 'خطای تحویل اسکناس (Dispenser Timeout)', 'fix': 'بررسی سنسورهای خروجی و مسیر تسمه‌ها'},
      {'code': 'D1', 'desc': 'عدم دریافت سیگنال مانیتور (No Signal)', 'fix': 'چک کردن کابل VGA/HDMI و منبع تغذیه مانیتور'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: errorCodes.length,
      itemBuilder: (context, index) {
        final err = errorCodes[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Text(err['code']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(err['desc']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('روش رفع: ${err['fix']}'),
          ),
        );
      },
    );
  }

  Widget _buildExperienceSection() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExperienceDialog,
        label: const Text('ثبت تجربه جدید'),
        icon: const Icon(Icons.edit),
      ),
      body: experiences.isEmpty
          ? const Center(child: Text('تجربه‌ای برای این مدل ثبت نشده است.'))
          : ListView.builder(
              itemCount: experiences.length,
              itemBuilder: (context, index) {
                final item = experiences[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(item['note'] ?? ''),
                        if (item['image'] != null && item['image']!.isNotEmpty && !kIsWeb) ...[
                          const SizedBox(height: 8),
                          Image.file(File(item['image']!), height: 180, fit: BoxFit.cover),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _addExperienceDialog() {
    String title = '';
    String note = '';
    String? imagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ثبت تجربه تعمیرات'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'عنوان خطا/مشکل'),
                  onChanged: (v) => title = v,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'توضیحات و نحوه حل مشکل'),
                  maxLines: 3,
                  onChanged: (v) => note = v,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) {
                      setDialogState(() => imagePath = img.path);
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('انتخاب عکس قطعه'),
                ),
                if (imagePath != null) const Text('عکس با موفقیت انتخاب شد.', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  experiences.add({'title': title, 'note': note, 'image': imagePath ?? ''});
                });
                _saveExperiences();
                Navigator.pop(context);
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}
