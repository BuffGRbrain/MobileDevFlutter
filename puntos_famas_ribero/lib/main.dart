import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:puntos_famas_ribero/Home.dart';
import 'package:puntos_famas_ribero/controller/FamaController.dart';

void main() {
  Get.lazyPut<FamaController>( () => FamaController()  );
  runApp(MyHome());
}

