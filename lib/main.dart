import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model
class MedicineRecord {
  int keyID;
  String name;
  String description;
  String dosage;
  DateTime? dateAdministered;
  String? batchNumber;
  String? manufacturer;
  String type;

  MedicineRecord({
    required this.keyID,
    required this.name,
    required this.description,
    required this.dosage,
    this.dateAdministered,
    this.batchNumber,
    this.manufacturer,
    required this.type,
  });
}

// Provider
class MedicineRecordProvider extends ChangeNotifier {
  List<MedicineRecord> _medicineRecords = [];

  List<MedicineRecord> get medicineRecords => _medicineRecords;

  void initData() {
    // Load data from database or shared preferences
    // For now, we'll use dummy data
    _medicineRecords = [
      MedicineRecord(
          keyID: 1,
          name: 'Paracetamol',
          description: 'Pain reliever',
          dosage: '500mg',
          dateAdministered: DateTime.now(),
          type: 'Medicine'),
      MedicineRecord(
          keyID: 2,
          name: 'Influenza Vaccine',
          description: 'Annual flu shot',
          dosage: '0.5ml',
          dateAdministered: DateTime.now().subtract(Duration(days: 30)),
          type: 'Vaccine'),
    ];
  }

  void addMedicineRecord(MedicineRecord record) {
    record.keyID = _medicineRecords.length + 1;
    _medicineRecords.add(record);
    notifyListeners();
  }

  void updateMedicineRecord(MedicineRecord updatedRecord) {
    final index =
        _medicineRecords.indexWhere((record) => record.keyID == updatedRecord.keyID);
    if (index != -1) {
      _medicineRecords[index] = updatedRecord;
      notifyListeners();
    }
  }

  void deleteMedicineRecord(MedicineRecord record) {
    _medicineRecords.removeWhere((item) => item.keyID == record.keyID);
    notifyListeners();
  }
}

// Form Screen
class MedicineRecordFormScreen extends StatefulWidget {
  const MedicineRecordFormScreen({super.key});

  @override
  _MedicineRecordFormScreenState createState() =>
      _MedicineRecordFormScreenState();
}

class _MedicineRecordFormScreenState extends State<MedicineRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _dateController = TextEditingController();
  final _batchController = TextEditingController();
  final _manufacturerController = TextEditingController();
  String _type = 'Medicine';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Medicine/Vaccine Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dosage'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date Administered'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = pickedDate.toIso8601String();
                    });
                  }
                },
              ),
              TextFormField(
                controller: _batchController,
                decoration: InputDecoration(labelText: 'Batch Number'),
              ),
              TextFormField(
                controller: _manufacturerController,
                decoration: InputDecoration(labelText: 'Manufacturer'),
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Medicine', 'Vaccine']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final record = MedicineRecord(
                      keyID: 0,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      dosage: _dosageController.text,
                      dateAdministered: DateTime.tryParse(_dateController.text),
                      batchNumber: _batchController.text,
                      manufacturer: _manufacturerController.text,
                      type: _type,
                    );
                    Provider.of<MedicineRecordProvider>(context, listen: false)
                        .addMedicineRecord(record);
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Edit Screen
class MedicineRecordEditScreen extends StatefulWidget {
  final MedicineRecord item;

  const MedicineRecordEditScreen({super.key, required this.item});

  @override
  _MedicineRecordEditScreenState createState() =>
      _MedicineRecordEditScreenState();
}

class _MedicineRecordEditScreenState extends State<MedicineRecordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dosageController = TextEditingController();
  final _dateController = TextEditingController();
  final _batchController = TextEditingController();
  final _manufacturerController = TextEditingController();
  String _type = 'Medicine';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _descriptionController.text = widget.item.description;
    _dosageController.text = widget.item.dosage;
    _dateController.text = widget.item.dateAdministered?.toIso8601String() ?? '';
    _batchController.text = widget.item.batchNumber ?? '';
    _manufacturerController.text = widget.item.manufacturer ?? '';
    _type = widget.item.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Medicine/Vaccine Record')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(labelText: 'Dosage'),
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date Administered'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = pickedDate.toIso8601String();
                    });
                  }
                },
              ),
              TextFormField(
                controller: _batchController,
                decoration: InputDecoration(labelText: 'Batch Number'),
              ),
              TextFormField(
                controller: _manufacturerController,
                decoration: InputDecoration(labelText: 'Manufacturer'),
              ),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['Medicine', 'Vaccine']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final updatedRecord = MedicineRecord(
                      keyID: widget.item.keyID,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      dosage: _dosageController.text,
                      dateAdministered: DateTime.tryParse(_dateController.text),
                      batchNumber: _batchController.text,
                      manufacturer: _manufacturerController.text,
                      type: _type,
                    );
                    Provider.of<MedicineRecordProvider>(context, listen: false)
                        .updateMedicineRecord(updatedRecord);
                    Navigator.pop(context);
                  }
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main App
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) {
            return MedicineRecordProvider();
          })
        ],
        child: MaterialApp(
          title: 'Medicine/Vaccine Records',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'Medicine/Vaccine Records'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    MedicineRecordProvider provider =
        Provider.of<MedicineRecordProvider>(context, listen: false);
    provider.initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MedicineRecordFormScreen();
                }));
              },
            ),
          ],
        ),
        body: Consumer(
          builder: (context, MedicineRecordProvider provider, Widget? child) {
            int itemCount = provider.medicineRecords.length;
            if (itemCount == 0) {
              return Center(
                child: Text(
                  'No records found',
                  style: TextStyle(fontSize: 50),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, int index) {
                    MedicineRecord data = provider.medicineRecords[index];
                    return Dismissible(
                      key: Key(data.keyID.toString()),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) {
                        provider.deleteMedicineRecord(data);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: ListTile(
                            title: Text(data.name),
                            subtitle: Text(
                                'Date Administered: ${data.dateAdministered?.toIso8601String()}',
                                style: TextStyle(fontSize: 10)),
                            leading: CircleAvatar(
                              child: FittedBox(
                                child: Text(data.dosage.toString()),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content:
                                          Text('Are you sure you want to delete this record?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Delete'),
                                          onPressed: () {
                                            provider.deleteMedicineRecord(data);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return MedicineRecordEditScreen(item: data);
                              }));
                            }),
                      ),
                    );
                  });
            }
          },
        ));
  }
}
