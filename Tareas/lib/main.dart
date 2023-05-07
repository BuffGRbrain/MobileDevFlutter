import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'idk but its working'),
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
  var ogLatitude;
  var ogLongitude;
  var modifiedPosition = [0.1,0.1,0.1];
  Future<String> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.denied) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      ogLatitude = position.latitude;
      ogLongitude = position.longitude;
      return '(${position.latitude}, ${position.longitude})';
    } else {
      return 'permission denied';
    }
  }


  List<double> _getCurrentLocation(value, ogLatitude,ogLongitude) {
    List position = [ogLatitude,ogLongitude];
    print("Entre al while");
    int a = 0;
    double b = 0;
    var rng = Random();
    print("Entre al while");
    //find a and b such that a^2 + b^2 = c^2 where c^2 is value
    a = -value + rng.nextInt((2*value).floor());
    b = sqrt(pow(value,2) - pow(a,2)) ;
    b = -b + rng.nextInt((2*b).floor());

    print("Sali del while");
    print(position.toString());
    var positionModLong = position[1] + a;
    var positionModLat = position[0] + b;
    List<double> newPosition = [positionModLat,positionModLong,sqrt(pow(a,2) + pow(b,2))];

    print("Distancia entre puntos");

    print(sqrt(pow(a,2) + pow(b,2)));
    print("a y b encontrados:");
    print(a);
    print(b);
    print("Posicion original");
    print(position.toString());
    print("Posicion modificada");
    print(newPosition.toString());
    return newPosition;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ingrese el radio de la circunferencia',
              ),
              maxLength: 3,
              controller: controller,
              keyboardType: TextInputType.number,
              onSubmitted: (String value) async {
                modifiedPosition = _getCurrentLocation( double.parse(value), ogLatitude,ogLongitude );
                setState(() {});
              },
            ),
            Text(
              'Posicion original',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Center(
              child: FutureBuilder<String>(
                  future: getLocation(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!,
                        style: Theme.of(context).textTheme.headlineMedium,
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        "${snapshot.error}",
                        style: Theme.of(context).textTheme.headlineMedium,
                      );
                    }
                    return CircularProgressIndicator();
                  }),
            ),
            Text(
              'Posicion modificada',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Center(
              child: Text(
                "Latitud: ${modifiedPosition[0]} Longitud: ${modifiedPosition[1]}",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Text(
              'Distancia entre puntos ${modifiedPosition[2]}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
