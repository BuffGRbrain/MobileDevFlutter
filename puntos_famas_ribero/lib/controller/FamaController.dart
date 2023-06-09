import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puntos_famas_ribero/Home.dart';
import 'package:puntos_famas_ribero/MultiNumber.dart';
import 'dart:math';

import '../guessNumber.dart';

class FamaController extends GetxController {
  var dificultadSolitario = 0.obs;
  var dificultadMulti = 0
      .obs; //se almacena para garantizar que el numero ingresado tenga el mismo lenght para ambos EN MULTIJUGADOR
  var modoJuego = 1.obs; //1 indica multijugador y 0 solitario
  var numIntentos = 0.0.obs;//double para poder sumar 0.5 turnos con cada pista
  var numPlayer1 = 0;
  var numPlayer11 = 0;
  var numPlayer2 = 0;
  var ganador = 0;
  int currentPlayer = 0;//1 o 2 para multijugador
  String guess = '';
  List famas = [];
  List puntos = [];
  double numIntentosMulti = 0;//para comparar y ver quien gano
  List pista = [];
  List pistaLetal = [];
  bool letal = false;//se cambia a true en el modo letal
  List hexa = ['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];//para generar el numero hexa aleatorio en el modo letal
  var numPlayer1Letal = '';
  var numPlayer2Letal = '';
  var numPlayer11Letal = '';

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
    return int.parse(numberStr);
  }

  String pftotal() {
    //retorna un string con 2 si es fama, 1 si es punto y 0 si es fallo en cada posicion, ademas de vacio si hay algun numero repetido para poder identificarlo
    String total = '';
    String randomAux = numPlayer1.toString();

    //Ahora veamos que jugador esta activo
    if (currentPlayer==1) {
      randomAux = numPlayer11.toString();
      print('randomAux: $randomAux de player 1');
    }
    else if(currentPlayer==2) {
      randomAux = numPlayer2.toString();
      print('randomAux: $randomAux de player 2');
    }
    print("Comparando $guess con $randomAux");//solo se muestra en consola y hace más fácil hacer las pruebas
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
      if(modoJuego.value==0){//estamos en solitario
        showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
          title: Text('Ganaste'),
          content: Text('En :${numIntentos.value}Intentos'),
          actions: [TextButton(onPressed: () {
              pista = [];
              resetFamasPuntos();
              Get.offAllNamed('/');//vuelve al home
          }
              , child: Text('ok'))],
        ); } );
      }
      else{//estamos en multijugador
        if(currentPlayer==1){//gano el jugador 1
          numIntentosMulti=numIntentos.value;
          pista = [];
          resetFamasPuntos();
          changePlayer();
          Get.to(() => guessNumber() );//gano el 1 pero aun falta que el 2 termine para ver quien gano entre los dos
        }
        else{//Aqui es cuando hacemos el otro alert dialog pues se cual de los dos gano o si empataron
          ganador = numIntentosMulti<numIntentos.value?1:(numIntentosMulti>numIntentos.value?2:3);//3 significa que empataron
          showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
            title: Text(ganador!=3?'Ganaste jugador $ganador':'Empate'),
            content: Text(ganador!=3?( ganador==1?'En :${numIntentosMulti}Intentos':'En :${numIntentos.value}Intentos'   ) : 'En :${numIntentos.value}Intentos'),
            actions: [TextButton(onPressed: () {
              resetPlayer112();
              resetFamasPuntos();
              changePlayer();
              Get.offAllNamed('/');
            }
                , child: Text('ok'))],
          ); } );
        }
      }


    }
    //Ahora borramos el input de la pantalla usando los controllers de los textfields y el de la variable guess
    guess = '';
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].clear();//check si sirve esto o mejor modifico el texto a vacio
    }

  }

  void multSol(){
    letal=false;
    print('entro a multSol ${modoJuego.value}');
    if (modoJuego==0){//esta en modo solitario quiero que genere un numero aleatorio y ademas lo mande a guessNumber
      currentPlayer=0;//evita el error de que currentPlayer no esta inicializado luego de una partida multijugador
      print('previo a generar numero');
      setnumPlayer1();
      print('numero generado ${numPlayer1}');
      resetFamasPuntos();
      Get.to(() => guessNumber() );
    }
    else{//esta en multijugador
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
    guess = guess + g; //aprovecho que es un string y lo voy concatenando
  }

  void setnumPlayer1() {//involucra los dos casos de solitario en letal y normal
    if(letal==false){
      numPlayer1 = randNumb(getDificultySol());
    }else{
      setnumPlayer1Letal();
    }

  }

  void setnumPlayer1Letal() {
    numPlayer1Letal = randNumbLetal(getDificultySol());
  }

  void setnumPlayer11Letal(String num) {
    print('entro a setnumPlayer11Letal $num');
    numPlayer11Letal = num;
  }

  void setnumPlayer2Letal(String num) {
    print('entro a setnumPlayer2Letal $num');
    numPlayer2Letal = num;
  }

  void setnumPlayer11(int num) {
    numPlayer11= num;
  }

  void setnumPlayer2(int num) {
    numPlayer2 = num;
  }

  void setIntentos(double num) {
    numIntentos.value = num;
  }

  void setFamasPuntos(String checkedGuess) {//si es 2 entonces es fama dlc no lo es, ademas uso guess para comparar con el numero a adivinar
    //inicializa en vacio con _ para que sea facil ver la posicion de las famas
    famas = List.filled(checkedGuess.length, '_');
    puntos = List.filled(checkedGuess.length, '_');
    for (int i = 0; i < checkedGuess.length; i++) {
      if (checkedGuess[i] == '2') {
        famas[i] = guess[i];
      } else if (checkedGuess[i] == '1') {
        puntos[i] = guess[i];
      }
    }
  }

  void setPista(){
    String randomAux = numPlayer1.toString();//el randomAux es el string a adivinar
    //Ahora veamos que jugador esta activo
    if (currentPlayer==1) {
      randomAux = numPlayer11.toString();
      print('randomAux: $randomAux de player 1');
    }
    else if(currentPlayer==2) {
      randomAux = numPlayer2.toString();
      print('randomAux: $randomAux de player 2');
    }
    pista = List.filled(famas.length, '_');
    print('pista: $pista');
    for (int i = 0; i < famas.length; i++) {
      if (famas[i] == '_') {//significa que no hay fama en esa posicion y se la paso como pista
        pista[i] = randomAux[i];
        break;
      }
    }
  }

  void setPistaLetal(){
    print('entro a setPistaLetal');
    String randomAux = numPlayer1Letal;//el randomAux es el string a adivinar
    print('randomAux: $randomAux de player 1 en el modo letal');
    //Ahora veamos que jugador esta activo
    if (currentPlayer==1) {
      randomAux = numPlayer11Letal;
      print('randomAux: $randomAux de player 1');
    }
    else if(currentPlayer==2) {
      randomAux = numPlayer2Letal;
      print('randomAux: $randomAux de player 2');
    }

    pistaLetal = List.filled(famas.length, '_');
    print('pista: $pistaLetal');
    for (int i = 0; i < famas.length; i++) {
      if (famas[i] == '_') {//significa que no hay fama en esa posicion y se la paso como pista letal
        pistaLetal[i] = randomAux[i];
        break;
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

  double getIntentos() {
    return numIntentos.value;
  }

  double getIntentosMulti() {
    return numIntentosMulti;
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

  String getnumPlayer1Letal() {
    return numPlayer1Letal;
  }

  String getnumPlayer11Letal() {
    return numPlayer11Letal;
  }

  String getnumPlayer2Letal() {
    return numPlayer2Letal;
  }

  changePlayer() {
    if (currentPlayer == 1) {
      currentPlayer = 2;
    } else {
      currentPlayer = 1;//pues ya termino el juego, lo deja seteado para la siguiente partida de multijugador
    }
  }

  getJugadorActual() {
    return currentPlayer;
  }

  getpista(){
    if(letal==true){
      print('pistaLETAL: $pistaLetal');
      return pistaLetal;
    }
    else{
      print('pista: $pista');
      return pista;
    }

  }

  void resetPlayer112() {
    letal = false;
    pista = [];
    numPlayer1 = 0;
    numPlayer11 = 0;
    numPlayer2 = 0;
    numPlayer1Letal = '';
    numPlayer11Letal = '';
    numPlayer2Letal = '';
    numIntentosMulti=0;
    ganador=0;
  }

  letalmode() {
    letal = true;
    print('entro a LETAL MODE ${modoJuego.value} y letal es $letal');
    if (modoJuego==0){//esta en modo solitario quiero que genere un numero aleatorio y ademas lo mande a guessNumber
      currentPlayer=0;//evita el error de que currentPlayer no esta inicializado luego de una partida multijugador
      print('previo a generar numero');
      setnumPlayer1Letal();
      print('numero generado ${numPlayer1Letal}');
      resetFamasPuntos();
      Get.to(() => guessNumber() );
    }
    else{//esta en multijugador
      currentPlayer=1;//Lo inicializa en 1 para que empiece el jugador 1
      resetFamasPuntos();
      { Get.to(() => MultiNumber() );}
    }
  }

  String randNumbLetal(int dificultySol) {
    var letalStr = '';
    while (letalStr.length != dificultySol) {
      var actualRand = Random();
      int candidate = 0 +
          actualRand
              .nextInt(16); //16 elementos en hexa y lo usare como index

      letalStr.contains(hexa[candidate])
          ? print('repeated number generated, recalculating...')
          : letalStr += hexa[candidate];
    }
    print(letalStr);
    return letalStr;
  }

  String pftotalLetal() {
    //retorna un string con 2 si es fama, 1 si es punto y 0 si es fallo en cada posicion, ademas de vacio si hay algun numero repetido para poder identificarlo
    print('Valores recibidos${guess} y ${numPlayer1Letal}');
    String total = '';
    String randomAux = numPlayer1Letal;//el randomAux es el string a adivinar

    //Ahora veamos que jugador esta activo
    if (currentPlayer==1) {//esto debo resetearlo de alguna forma para que no se quede en 2 cuando pase a eso, debe retornar a 1
      randomAux = numPlayer11Letal;
      print('randomAux: $randomAux de player 1');
    }
    else if(currentPlayer==2) {
      randomAux = numPlayer2Letal;
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

  void helperPFLetal(BuildContext context, List controllers) {
    setIntentos(numIntentos.value + 1);
    String checkedGuess = pftotalLetal();//indica si hay un numero repetido y donde estan los puntos y famas
    print('checkedGuess: $checkedGuess');
    setFamasPuntos(checkedGuess);
    //reviso si gano
    if ('2'*guess.length  == checkedGuess){//si el numero de famas es igual al numero de digitos entonces gano pues 2 representa fama
      if(modoJuego.value==0){
        showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
          title: Text('Ganaste'),
          content: Text('En :${numIntentos.value}Intentos'),
          actions: [TextButton(onPressed: () {
            pistaLetal = [];
            resetFamasPuntos();
            Get.offAllNamed('/');
          }
              , child: Text('ok'))],
        ); } );
      }
      else{//estamos en multijugador
        if(currentPlayer==1){//gano el jugador 1
          numIntentosMulti=numIntentos.value;
          pistaLetal = [];
          resetFamasPuntos();
          changePlayer();
          Get.to(() => guessNumber() );
        }
        else{//Aqui es cuando hacemos el otro alert dialog
          ganador = numIntentosMulti<numIntentos.value?1:(numIntentosMulti>numIntentos.value?2:3);//3 significa que empataron
          showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
            title: Text(ganador!=3?'Ganaste jugador $ganador':'Empate'),
            content: Text(ganador!=3?( ganador==1?'En :${numIntentosMulti}Intentos':'En :${numIntentos.value}Intentos'   ) : 'En :${numIntentos.value}Intentos'),
            actions: [TextButton(onPressed: () {
              resetPlayer112();
              resetFamasPuntos();
              changePlayer();
              Get.offAllNamed('/');
            }
                , child: Text('ok'))],
          ); } );
        }
      }


    }
    //Ahora borramos el input de la pantalla usando los controllers de los textfields y el de la variable guess
    guess = '';
    for (int i = 0; i < controllers.length; i++) {
      controllers[i].clear();
    }
  }

}

