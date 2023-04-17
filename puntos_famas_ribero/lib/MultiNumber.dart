import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/FamaController.dart';
import 'guessNumber.dart';

class MultiNumber extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MultiNumberState();
}

class _MultiNumberState extends State<MultiNumber> {
  @override
  Widget build(BuildContext context) {
    FamaController controller = Get.find();
    int numControllers = controller.getDificultyMult(); //PENDIENTE PASAR ESTO A UN GET GENERAL PARA AMBOS MODOS DE JUEGO
    String tmp = '?' * (numControllers + 1);
    String tmp2 = '';
    List<TextEditingController> controllers = List.generate( numControllers, (_) => TextEditingController());
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JUGANDO',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Jugando a Puntos y Famas'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                children: [...List.generate( numControllers , (index) => TextField(//lo pasamos a string y usamos el lenght pues queremos la cantidad de elemetos
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,//limitamos input a numero
                  onChanged: (String value) {
                    //quiero bloquear que repita un valor
                    if (tmp.contains(value)) {
                      //si el valor ya esta en la lista de controllers entonces no se puede ingresar
                      print('El valor de value es $value');
                      controllers[index].clear();
                    }
                    tmp = tmp.replaceRange(index, index + 1,
                        value); //equivale a reemplazar esa poser por el valor
                  },
                  maxLength: 1,
                  controller: controllers[index] ,
                ),
                ),
                  ElevatedButton(onPressed: (){
                    tmp = '?' * (numControllers + 1);
                    print(
                        'FUI OPRIMIDO OH QUE TRRISSSSTE ${controllers[0].text}');
                    for (int i = 0; i < controllers.length; i++) {
                      print('El valor de i es $i');
                      print(
                          'El valor de controllers[i] es ${controllers[i].text}');
                      print(
                          'El tipo de controllers[i] es ${controllers[i].text.runtimeType}'); //es un TextEditingController pero debe ser un int pq pasa esto?
                      //si el 11 no ha ingreado su valor entonces lo almacena y dlc y si ya lo hizo entonces almacena el 2
                      //voy guardando esto en un string y en cada iteracion lo concateno
                      tmp2 = tmp2 + controllers[i].text;
                    }
                    //quiero pasar lo de arriba a un if
                    if(controller.getnumPlayer11() ==0){
                    controller.setnumPlayer11(int.parse(tmp2));
                    }
                    else{
                      controller.setnumPlayer2(int.parse(tmp2));
                    }

                    tmp2 = '';
                    //Ahora debemos borrar los valores de los controllers
                    for (int i = 0; i < controllers.length; i++) {
                      controllers[i].clear();
                    }
                    //setState(() {});
                    if(controller.getnumPlayer11() != 0 && controller.getnumPlayer2() != 0){
                      //si ya ambos jugadores ingresaron su numero entonces go to guessNumber
                      Get.to(() => guessNumber());
                    }
                  }, child: Text('Pasele el telefono al otro jugador'))//si ya tiene valor para 11 y 2 entonces go to guess Number
                ]
              //meter un if aqui o una funcion que enrede a controller.clear y así que si ya ambos inresaron pase a guessNumber pero tener un active player
            )
        ),
      ),
    );
  }

}