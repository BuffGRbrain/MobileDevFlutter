//esta tiene una ventana con 3,4 o 5 widgets que reciben el input del usuario y usa controller para puntos
//esta pagina tiene dos estados una para adivinar el numero y otra para ingresarlo, así se puede utilizar
//en ambos modos de juego multijugador y solitario.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'controller/FamaController.dart';

class guessNumber extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _guessNumberState();
}

class _guessNumberState extends State<guessNumber> {
  @override
  Widget build(BuildContext context) {
    FamaController controller = Get.find();
    int numControllers = (controller.modoJuego.value==0)? controller
        .getDificultySol():controller.getDificultyMult()
    ; //PENDIENTE PASAR ESTO A UN GET GENERAL PARA AMBOS MODOS DE JUEGO
    List<TextEditingController> controllers =
        List.generate(numControllers, (_) => TextEditingController());
    int difiMult = controller.getDificultyMult();
    int difiSol = controller.getDificultySol();
    int auxTmp = (controller.modoJuego.value==0)? difiSol:difiMult;
    String tmp = '?' * (auxTmp + 1);
    print('Dificultad Multijugador $difiMult');
    print('Dificultad Solitario $difiSol');
    return MaterialApp(
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
                    Text('Intento: ${controller.getIntentos()}'),
                    Text('Puntos: ${controller.getPuntos()}'),
                    Text('Famas: ${controller.getFamas()}'),
                    Text('Jugando: ${ controller.getJugadorActual()==1 ? '2' : '1'  }'),
                  ],
                ),
                Column(children: [
                  ...List.generate(
                    numControllers,
                    (index) => TextField(
                      //lo pasamos a string y usamos el lenght pues queremos la cantidad de elemetos
                      controller: controllers[index],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.number, //limitamos input a numero
                      // onSubmitted: (String value) {
                      //   print('El valor de value es $value');
                      //   controller.setguess(value);},//to string pq hay un error y creo que lo esta tomando como entero
                      maxLength: 1, //maximo un caracter
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
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        tmp = '?' * (numControllers + 1);
                        print(
                            'FUI OPRIMIDO OH QUE TRRISSSSTE ${controllers[0].text}');
                        for (int i = 0; i < controllers.length; i++) {
                          print('El valor de i es $i');
                          print(
                              'El valor de controllers[i] es ${controllers[i].text}');
                          print(
                              'El tipo de controllers[i] es ${controllers[i].text.runtimeType}'); //es un TextEditingController pero debe ser un int pq pasa esto?
                          controller.setguess(controllers[i].text);
                        }
                        controller.helperPF(context, controllers);
                        setState(() {});
                      },
                      child: Text('Compararar'))
                ]),
              ],
            )),
      ),
    );
  }
}