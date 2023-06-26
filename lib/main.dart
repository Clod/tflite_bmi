import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:intl/intl.dart';

late final Interpreter _interpreter;
// final dateFormat = DateFormat('yyyy-MM-dd');
final dateFormat = DateFormat('dd-MM-yyyy');

Future<void> main() async {
  debugPrint("Inicializado interpreter");

  runApp(const MyApp());
}

void _loadModel() async {
  // Enable delegates
  final options = InterpreterOptions();
  const modelFile = 'assets/model.tflite';

  if (Platform.isAndroid) {
    options.addDelegate(XNNPackDelegate());
  }

  // doesn't work on emulator
  // if (Platform.isAndroid) {
  //   options.addDelegate(GpuDelegateV2());
  // }

  if (Platform.isIOS) {
    options.addDelegate(GpuDelegate());
  }

  // Creating the interpreter using Interpreter.fromAsset
  _interpreter = await Interpreter.fromAsset(modelFile, options: options);

  debugPrint('Interpreter loaded successfully');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de IMC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Calculadora de IMC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late DateTime dateTime;
  late DateTime currentDate;
  String? _selectedOption;
  TextEditingController _textContAltura = TextEditingController();
  TextEditingController _textContKilos = TextEditingController();
  TextEditingController _textContGramos = TextEditingController();
  TextEditingController _textContAnios = TextEditingController();
  TextEditingController _textContMeses = TextEditingController();

  String _imc = "";
  String _percentil = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadModel();
    dateTime = DateTime.now();
    currentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  calcularEdad(DateTime nacimiento) {
    Duration parse = nacimiento.difference(DateTime.now()).abs();
    return "";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now());
    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        dateTime = pickedDate;
        Duration parse = pickedDate.difference(DateTime.now()).abs();
        debugPrint(
            "${parse.inDays ~/ 360} Years ${((parse.inDays % 360) ~/ 30)} Month ${(parse.inDays % 360) % 30} Days");
        _textContAnios.text = (parse.inDays ~/ 360).toString();
        _textContMeses.text = ((parse.inDays % 360) ~/ 30).toString();
      });
    }
  }

  void _incrementCounter() {
    // For ex: if input tensor shape [1,5] and type is float32
    var input = [
      [7.011268, 12.637012, 0.0, 1.0]
    ];

// if output tensor shape [1,2] and type is float32
    var output = [
      [0.00]
    ];

// inference
    _interpreter.run(input, output);
// debugPrint the output
    debugPrint(output.toString());

    input = [
      [16.000942, 20.700886, 1.0, 0.0]
    ];

    _interpreter.run(input, output);

    debugPrint(output.toString());

    input = [
      [18.017891, 24.920631, 1.0, 0.0]
    ];

    _interpreter.run(input, output);

    debugPrint(output.toString());

    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Calculadora de IMC"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Ingrese el sexo",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            Row(
              // mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 150.0,
                  child: RadioListTile(
                    title: Text('Mujer'),
                    value: 'mujer',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
                Container(
                  width: 150.0,
                  child: RadioListTile(
                    title: Text('Varón'),
                    value: 'varon',
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Text(
              "Ingrese la altura",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 10.0,
                ),
                Container(
                  width: 100.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[300],
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    controller: _textContAltura,
                    decoration: InputDecoration(
                      hintText: 'Ej: 123',
                    ),
                  ),
                ),
                Text(
                  "cm",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Ingrese el peso",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[300],
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    controller: _textContKilos,
                    decoration: InputDecoration(
                      hintText: 'Ej: 42',
                    ),
                  ),
                ),
                Text(
                  "Kg",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Container(
                  width: 100.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[300],
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.center,
                    controller: _textContGramos,
                    decoration: InputDecoration(
                      hintText: 'Ej: 300',
                    ),
                  ),
                ),
                Text(
                  "g",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              "Ingrese fecha de nacimiento \n o edad en años y meses",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: const Text(
                        'Fecha de\n nacimiento',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      dateFormat.format(dateTime),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[300],
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        controller: _textContAnios,
                        decoration: InputDecoration(
                          hintText: 'Ej: 1',
                        ),
                      ),
                    ),
                    Text(
                      "a",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Container(
                      width: 60.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[300],
                      ),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        controller: _textContMeses,
                        decoration: InputDecoration(
                          hintText: 'Ej: 10',
                        ),
                      ),
                    ),
                    Text(
                      "m",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _resetearValores(context),
                  child: const Text(
                    'Limpiar',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 15.0),
                ElevatedButton(
                  onPressed: () => _obtenerResultados(context),
                  child: const Text(
                    'Calcular',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "IMC: ",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _imc,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Text(
                  "Percentil: ",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _percentil,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _resetearValores(BuildContext context) {
    setState(() {
      _textContAltura.text = '';
      _textContKilos.text = '';
      _textContGramos.text = '';
      _textContAnios.text = '';
      _textContMeses.text = '';
      _imc = "";
      _percentil = "";
      dateTime = DateTime.now();
      _selectedOption = null;
    });
  }

  _obtenerResultados(BuildContext context) {
    // var input = [[7.011268, 12.637012, 0.0, 1.0]];
    List<List<double>> input = [
      [0.0, 0.0, 0.0, 0.0]
    ];
    var output = [
      [0.00]
    ];

    double imc = (double.parse(_textContKilos.text) +
            double.parse(_textContGramos.text) / 10.0) /
        ((double.parse(_textContAltura.text) / 100.0) *
            (double.parse(_textContAltura.text) / 100.0));
    ;
    double edad = double.parse(_textContAnios.text) +
        double.parse(_textContMeses.text) / 12.0;

    input[0][1] = imc;
    input[0][0] = edad;

    if (_selectedOption == "mujer") {
      input[0][2] = 1.0;
      input[0][3] = 0.0;
    } else {
      input[0][2] = 0.0;
      input[0][3] = 1.0;
    }

    // inference
    debugPrint(imc.toString());

    _interpreter.run(input, output);
// debugPrint the output
    debugPrint(input.toString());
    debugPrint(output.toString());
    setState(() {
      _imc = imc.toStringAsFixed(2);
      _percentil = output[0][0].truncate().toString() + ' %';
    });
  }
}
