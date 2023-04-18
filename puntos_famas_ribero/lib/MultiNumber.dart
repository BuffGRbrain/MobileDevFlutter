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
    int numControllers = controller.getDificultyMult();
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
                children: [
                  Row(
                    children: [
                      Text('Ingresando numero a adivinar el Jugador: ${ controller.getJugadorActual()==1 ? '1' : '2'  }'),
                    ],
                  ),
                  Column(
                      children: [...List.generate( numControllers , (index) => TextField(
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
                              value); //equivale a reemplazar esa pose por el valor
                        },
                        maxLength: 1,
                        controller: controllers[index] ,
                      ),
                      ),
                        ElevatedButton(onPressed: (){//debe modificar el jugador actual con cada press del boton
                          tmp = '?' * (numControllers + 1);
                          for (int i = 0; i < controllers.length; i++) {
                            //voy guardando esto en un string y en cada iteracion lo concateno
                            tmp2 = tmp2 + controllers[i].text;
                          }
                          //Aqui meto los inputs a los numeros de cada jugador
                          if(controller.letal == false){
                            if(controller.getnumPlayer11() ==0){
                              controller.setnumPlayer11(int.parse(tmp2));
                            }
                            else{
                              controller.setnumPlayer2(int.parse(tmp2));
                            }
                          }else{//letal mode
                            if(controller.getnumPlayer11Letal() == ''){//si no esta seteado
                              controller.setnumPlayer11Letal(tmp2);
                            }
                            else{
                              controller.setnumPlayer2Letal(tmp2);
                            }
                          }
                          //Aqui meto los inputs a los numeros de cada jugador

                          tmp2 = '';
                          //Ahora debemos borrar los valores de los controllers
                          for (int i = 0; i < controllers.length; i++) {
                            controllers[i].clear();
                          }
                          controller.changePlayer();
                          setState(() {});
                          if(controller.letal==false){
                            if(controller.getnumPlayer11() != 0 && controller.getnumPlayer2() != 0){
                              //si ya ambos jugadores ingresaron su numero entonces go to guessNumber
                              Get.to(() => guessNumber());
                            }
                          }else{
                            if(controller.getnumPlayer11Letal() != '' && controller.getnumPlayer2Letal() != ''){
                              //si ya ambos jugadores ingresaron su numero entonces go to guessNumber
                              Get.to(() => guessNumber());
                            }
                          }

                        }, child: Text('Pasele el telefono al otro jugador'))//si ya tiene valor para 11 y 2 entonces go to guess Number
                      ]
                  )
                ],
            )
        ),
      ),
    );
  }

}