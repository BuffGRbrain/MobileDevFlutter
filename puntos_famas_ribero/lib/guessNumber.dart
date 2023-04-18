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
    ;
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
                    if(controller.modoJuego.value==1)
                      Text('Jugando: ${ controller.getJugadorActual()==1 ? '2' : '1'  }'),
                    ElevatedButton(onPressed: ()
                        {
                          double? intentosActuales = 0.0;
                          if(controller.modoJuego==0){
                            intentosActuales = controller.numIntentos.value;
                          }
                          else{//multijugador
                            intentosActuales = controller.getIntentosMulti()>0?controller.getIntentos():controller.getIntentosMulti();
                            print('multi intentos $intentosActuales' );
                          }
                          controller.setIntentos(intentosActuales+0.5);
                          if(controller.letal == false){
                            controller.setPista();
                          }else{
                            controller.setPistaLetal();
                          }
                          setState(() {});//tras dar la pista y actualizar los intentos debemos reflejar el cambio en pantalla
                        }
                        , child: Text('Pista') ),
                    Text('Pista: ${controller.getpista()}'),//ya el getter manda la normal o la letal segun el modo
                  ],
                ),
                Column(children: [
                  ...List.generate(
                    numControllers,
                    (index) => TextField(
                      controller: controllers[index],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          TextInputType.number, //limitamos input a numeros en telefono
                      maxLength: 1, //maximo un caracter
                      onChanged: (String value) {
                        //quiero bloquear que repita un valor
                        if (tmp.contains(value)) {
                          //si el valor ya esta en la lista de textos de los controllers entonces no se puede ingresar
                          print('El valor de value es $value');
                          controllers[index].clear();//lo borra para obligar a que el usuario ingrese otro valor
                        }
                        tmp = tmp.replaceRange(index, index + 1,
                            value); //equivale a reemplazar esa pose por el valor
                      },
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        tmp = '?' * (numControllers + 1);//reiniciamos el tmp para compara en el siguiente caso
                        for (int i = 0; i < controllers.length; i++) {
                          controller.setguess(controllers[i].text);
                        }
                        //si es letal o no usamos un helper distinto
                        if(controller.letal == false){
                          controller.helperPF(context, controllers);
                        } else{
                          controller.helperPFLetal(context,controllers);
                        }

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
