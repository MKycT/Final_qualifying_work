import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ИСС-1',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: navigatorKey,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ИСС-1'),
      ),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Приветствуем Вас в ИСС-1',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderDetailsScreen()),
                  );
                },
                child: const Text('Создать заказ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailsScreen extends StatefulWidget {
  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  String? customerName;
  String? address;
  String dropdownValue = 'Частное сооружение';
  String? phone;
  String? email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Контактная информация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'ФИО заказчика',
                errorText: customerName == null? 'Введите ФИО заказчика' : null,
              ),
              onChanged: (value) {
                setState(() {
                  customerName = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Адрес объекта',
                errorText: address == null? 'Введите адрес объекта' : null,
              ),
              onChanged: (value) {
                setState(() {
                  address = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Телефон',
                errorText: address == null? 'Введите номер телефона' : null,
              ),
              onChanged: (value) {
                setState(() {
                  phone = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: address == null? 'Введите email' : null,
              ),
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
            ),
            DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: <String>['Частное сооружение', 'Федеральный объект', 'Транспортный объект', 'Другое']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: customerName!= null && address!= null && email!= null && phone!= null? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkSelectionScreen(customerName: customerName, address: address, dropdownValue: dropdownValue, phone: phone, email: email)),
                );
              } : null,
              child: Text('Далее'),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkSelectionScreen extends StatefulWidget {
  final String? customerName;
  final String? address;
  final String dropdownValue;
  final String? phone;
  final String? email;

  WorkSelectionScreen({required this.customerName, required this.address, required this.dropdownValue, required this.phone, required this.email});

  @override
  _WorkSelectionScreenState createState() => _WorkSelectionScreenState();
}

class _WorkSelectionScreenState extends State<WorkSelectionScreen> {
  String? workInfo;
  String? fileName;
  String? fileExtension;
  String? filepath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Информация об объекте'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Введите информацию об объекте',
                  border: OutlineInputBorder(),
                  ),
                onChanged: (value) {
                  setState(() {
                    workInfo = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final status = await Permission.manageExternalStorage.request();
                  if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
                    throw "Please allow storage permission to upload files";
                  }

                  FilePickerResult? result = await FilePicker.platform.pickFiles();

                  if (result!= null) {
                    PlatformFile file = result.files.first;

                    setState(() {
                      fileName = file.name;
                      fileExtension = file.extension;
                      filepath = file.path;
                    });

                    print(file.name);
                    print(file.bytes);
                    print(file.size);
                    print(file.extension);
                    print(file.path);
                  } else {
                    print("Пользователь отменил выбор файла");
                  }
                },
                child: Text('Добавьте техническую документацию'),
              ),
              if (fileName!= null && fileExtension!= null)
                Text(
                    'Файл: $fileName\nРасширение: $fileExtension')
              else
                Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: workInfo!= null? () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                      PreviewScreen(customerName: widget.customerName,
                        address: widget.address,
                        phone: widget.phone,
                        email: widget.email,
                        dropdownValue: widget.dropdownValue,
                        workInfo: workInfo,
                        fileName: fileName,
                        fileExtension: fileExtension,
                          filepath: filepath))

                  );
                } : null,
                child: Text('Далее'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PreviewScreen extends StatelessWidget {
  final String? customerName;
  final String? address;
  final String? dropdownValue;
  final String? phone;
  final String? email;
  final String? workInfo;
  final String? fileName;
  final String? fileExtension;
  final String? filepath;

  PreviewScreen({
    this.customerName,
    this.address,
    this.dropdownValue,
    this.workInfo,
    this.fileName,
    this.fileExtension,
    this.filepath,
    this.phone,
    this.email

  });
  Future<bool> checkFileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Предпросмотр заказа'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('ФИО заказчика: $customerName'),
            Text('Адрес объекта: $address'),
            Text('Тип объекта: $dropdownValue'),
            Text('Номер телефона: $phone'),
            Text('Email: $email'),
            Text('Информация об объекте: $workInfo'),
            if (fileName!= null && fileExtension!= null)
              Text('Файл: $fileName\nРасширение: $fileExtension')
            else
              Container(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Запрос разрешения на доступ к хранилищу
                final status = await Permission.storage.request();
                if (workInfo!= null) {
                  // Передаем context в createZipFile
                  await createZipFile(context, filepath!, fileExtension!, customerName!, address!, dropdownValue!, phone!, email!, workInfo!, 'order_details.zip');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ваш заказ успешно отправлен')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Необходимо заполнить информацию об объекте')));
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
              child: Text('Отправить заказ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createZipFile(BuildContext context, String fileName, String fileExtension, String customerName, String address, String dropdownValue, String phone, String email, String workInfo, String zipFileName) async {
    // Проверяем, есть ли разрешение на доступ к хранилищу
    final hasStoragePermission = await requestStoragePermission();

    // Остальная часть метода остается без изменений
    final tempDir = await getTemporaryDirectory();
    final zipFilePath = '${tempDir.path}/$zipFileName';
    final archive = Archive();
    final textFileBytes = utf8.encode('ФИО заказчика: $customerName\nАдрес объекта: $address\nТип объекта: $dropdownValue\nНомер телефона: $phone\nEmail: $email\nИнформация об объекте: $workInfo');
    final textFile = ArchiveFile('work_info.txt', textFileBytes.length, textFileBytes );
    archive.addFile(textFile);

    if (fileName != null && fileExtension != null) {
      final fileToAdd = File(fileName);
      final fileBytes = await fileToAdd.readAsBytes();
      final archiveFile = ArchiveFile(fileName, fileBytes.length, fileBytes);
      archive.addFile(archiveFile);
    }

    final zipBytes = ZipEncoder().encode(archive);
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(zipBytes!);

    print('ZIP-файл успешно создан: $zipFilePath');
  }
}
