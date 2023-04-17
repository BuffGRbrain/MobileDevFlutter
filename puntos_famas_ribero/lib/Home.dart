import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puntos_famas_ribero/controller/FamaController.dart';
import 'package:puntos_famas_ribero/guessNumber.dart';

class MyHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomeState();
}
class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    FamaController controller = Get.find();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Puntos y Famas',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Puntos y Famas'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: '0 solitario y 1 Multi ',
                  labelText: 'Modo de Juego',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,//limitamos input a numero
                onChanged: (String value)  {controller.setMode(int.parse(value));},
                maxLength: 1,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ingrese 3,4 o 5 ',
                  labelText: 'Dificultad',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,//limitamos input a numero
                onChanged:(String value) { controller.modoJuego.value == 0 ? controller.setDificultySol(int.parse(value)) : controller.setDificultyMult(int.parse(value))  ; } ,//Si es multijugador almacenamos el valor.
                maxLength: 1,
              ),
              ElevatedButton(onPressed: () => controller.multSol(), child: Text('Que inicie el juego'),)
            ],
          )
        ),
      ),
    );
  }

}