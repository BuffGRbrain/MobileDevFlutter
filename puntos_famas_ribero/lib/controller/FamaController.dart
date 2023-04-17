import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puntos_famas_ribero/Home.dart';
import 'package:puntos_famas_ribero/MultiNumber.dart';
import 'dart:math';

import '../guessNumber.dart';

class FamaController extends GetxController {
  var dificultadSolitario = 0.obs;
  var dificultadMulti = 0
      .obs; //se almacena para garantizar que el numero ingresado tenga el mismo lenght para ambos
  var modoJuego = 1.obs; //1 indica multijugador y 0 solitario
  var numIntentos = 0.obs;
  var numPlayer1 = 0;
  var numPlayer11 = 0;
  var numPlayer2 = 0;
  int currentPlayer = 0;//1 o 2 para multijugador
  String guess = '';
  List famas = [];
  List puntos = [];

  int randNumb(int dificultad) {
    var numberStr = '';
    while (numberStr.length != dificultad) {
      var actualRand = Random();
      int candidate = 0 +
          actualRand
              .nextInt(10); //pues toma hasta el seed-1 para los que genera
      numberStr.contains(candidate.toString())
          ? print('repeated number generated, recalculating...')
          : numberStr += candidate.toString();
    }
    print(numberStr);
    return int.parse(numberStr);
  }

  String pftotal() {
    //retorna un string con 2 si es fama, 1 si es punto y 0 si es fallo en cada posicion, ademas de vacio si hay algun numero repetido para poder identificarlo
    print('Valores recibidos${guess} y ${numPlayer1}');
    String total = '';
    String randomAux = numPlayer1.toString();

    //Ahora veamos que jugador esta activo
    if (currentPlayer==1) {//esto debo resetearlo de alguna forma para que no se quede en 2 cuando pase a eso, debe retornar a 1
      randomAux = numPlayer11.toString();
      print('randomAux: $randomAux de player 1');
    }
    else if(currentPlayer==2) {
      randomAux = numPlayer2.toString();
      print('randomAux: $randomAux de player 2');
    }
    print("Comparando $guess con $randomAux");
    for (int i = 0; i < guess.length; i++) {
      //uso que guess y randomAux tienen el mismo length
      if (randomAux.contains(guess[i])) {
        // si cumple por lo menos es punto y debo ver si es fama
        if (randomAux[i] == guess[i]) {
          total = '${total}2'; //entonces es fama
        } else {
          total = '${total}1';
        }
      } //si no lo contiene entonces no es ni punto ni fama
      else {
        total = '${total}0';
      }
    }
    return total;
  }

  void helperPF(BuildContext context, List controllers) {
    setIntentos(numIntentos.value + 1);
    String checkedGuess = pftotal();//indica si hay un numero repetido y donde estan los puntos y famas
    print('checkedGuess: $checkedGuess');
    setFamasPuntos(checkedGuess);
    //reviso si gano
    if ('2'*guess.length  == checkedGuess){//si el numero de famas es igual al numero de digitos entonces gano pues 2 representa fama
      showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
        title: Text('Ganaste'),
        content: Text('En :${numIntentos.value}Intentos'),
          actions: [TextButton(onPressed: () {
            if (modoJuego.value==0){
              Get.offAllNamed('/');
            }
            else{
              if(currentPlayer==1){
                resetFamasPuntos();
                changePlayer();
                Get.back();
              }
              else{
                resetFamasPuntos();
                changePlayer();
                Get.offAllNamed('/');
              }
            }
          }
           , child: Text('ok'))], //get.back() es para cerrar el dialogo
      ); } );
    }
    //Ahora borramos el input de la pantalla usando los controllers de los textfields y el de la variable guess
    guess = '';
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].clear();//check si sirve esto o mejor modifico el texto a vacio
    }

  }

  void multSol(){
    print('entro a multSol ${modoJuego.value}');
    if (modoJuego==0){//esta en modo solitario quiero que genere un numero aleatorio y ademas lo mande a guessNumber
      print('previo a generar numero');
      setnumPlayer1();
      print('numero generado ${numPlayer1}');
      resetFamasPuntos();
      Get.to(() => guessNumber() );
    }
    else{//esta en multijugador PENDIENTE ALMACENAR LOS NUMEROS DE CADA JUGADOR usando los setters e inputs de cada uno
      currentPlayer=1;//Lo inicializa en 1 para que empiece el jugador 1
      resetFamasPuntos();
      { Get.to(() => MultiNumber() );}
    }
  }

  void setMode(int num) {
    modoJuego.value = num;
  }

  void setDificultyMult(int num) {
    dificultadMulti.value = num;
  }

  void setDificultySol(int num) {
    dificultadSolitario.value = num;
  }

  void setguess(String g) {
    print(guess);
    guess = guess + g; //concatenate the strings
  }

  void setnumPlayer1() {
    numPlayer1 = randNumb(getDificultySol());
  }

  void setnumPlayer11(int num) {
    numPlayer11= num;
  }

  void setnumPlayer2(int num) {
    numPlayer2 = num;
  }

  void setIntentos(int num) {
    numIntentos.value = num;
  }

  void setFamasPuntos(String checkedGuess) {//si es 2 entonces es fama dlc no lo es, ademas uso guess
    //var guessed = guess; //guardo el valor de guess en una variable auxiliar
    famas = List.filled(checkedGuess.length, '_');
    puntos = List.filled(checkedGuess.length, '_');
    for (int i = 0; i < checkedGuess.length; i++) {
      //debo poner un _ si no es ni fama ni punto en famas y puntos
      if (checkedGuess[i] == '2') {
        famas[i] = guess[i];
      } else if (checkedGuess[i] == '1') {
        puntos[i] = guess[i];
      }
    }
  }

  void resetFamasPuntos(){
    famas = [];
    puntos = [];
    numIntentos.value = 0;
  }

  int getMode() {
    return modoJuego.value;
  }

  int getIntentos() {
    return numIntentos.value;
  }

  int getDificultyMult() {
    return dificultadMulti.value;
  }

  int getDificultySol() {
    return dificultadSolitario.value;
  }

  int getnumPlayer1() {
    return numPlayer1;
  }

  List getFamas(){
    return famas;
  }
  List getPuntos(){
    return puntos;
  }

  int getnumPlayer11() {
    return numPlayer11;
  }

  int getnumPlayer2() {
    return numPlayer2;
  }

  changePlayer() {
    if (currentPlayer == 1) {
      currentPlayer = 2;
    } else {
      currentPlayer = 1;
    }
  }

  getJugadorActual() {
    return currentPlayer;
  }

}
