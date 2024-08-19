import 'package:flutter/material.dart';
//librería de sensores
import 'package:sensors_plus/sensors_plus.dart';
//librería de temporizadores
import 'dart:async';

void main() {
  runApp(MyApp()); 
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Juego de Giroscopio',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: JuegoScreen(),
    );
  }
}

class JuegoScreen extends StatefulWidget {
  @override
  _JuegoScreenState createState() =>
      _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  double x = 0, y = 0; //Posición inicial de la pelota
  int puntos = 0; //Variable para almacenar los puntos obtenidos.
  final int puntosLimites = 50; //Puntos necesarios para ganar el juego.
  final int tiempoLimite = 10; //Tiempo límite en segundos para completar el juego.
  Timer? _timer; //Timer para manejar el tiempo del juego.
  int _tiempoRestante = 10; //Contador de tiempo restante.
  bool juegoTerminado = false; //Variable para determinar si el juego ha terminado (no se me ocurrió otra cosa xD)

  @override
  void initState() {
    super.initState();

    _comenzarJuego();

    gyroscopeEvents.listen((GyroscopeEvent event) {
      //Escucha los eventos del giroscopio.
      if (!juegoTerminado) {
        //Solo recolecta puntos si el juego no ha terminado.
        setState(() {
          //ActualizaR las coordenadas x e y basadas en el movimiento del giroscopio.
          x += event.x * 0.02;
          y += event.y * 0.02;

          //LimitaR los valores de x e y para que la pelota no salga de la pantalla.
          if (x > 1) x = 1;
          if (x < -1) x = -1;
          if (y > 1) y = 1;
          if (y < -1) y = -1;

          //Calcula los puntos basados en la magnitud del movimiento en x, y, y z.
          int points = (event.x.abs() + event.y.abs() + event.z.abs()).round();
          puntos += points; //Suma los puntos obtenidos al total.

          //Verifica si se han alcanzado los puntos necesarios para ganar.
          if (puntos >= puntosLimites) {
            juegoTerminado = true; //Marca el juego como terminado.
            _timer?.cancel(); //Detiene el temporizador.
            _ganarJuego(); //Llama a la función para mostrar que se ha ganado.
          }
        });
      }
    });
  }

  void _comenzarJuego() {
    //Inicia un temporizador que cuenta hacia atrás de 1 en 1 segundo.
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_tiempoRestante > 0) {
          _tiempoRestante--; //Disminuir el tiempo restante.
        } else if (!juegoTerminado) {
          juegoTerminado = true; //Marcar el juego como terminado.
          _timer?.cancel(); //Detener el temporizador.
          _perderJuego(); //Llamar a la función para mostrar que se ha perdido.
        }
      });
    });
  }

  //ganar el juego
  void _ganarJuego() {
    showDialog(
      context: context,
      barrierDismissible: false, //Evitar que se cierre el diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¡Haz ganado!", style: TextStyle(color: Colors.green)),
          content: Text("Haz obtenido $puntosLimites puntos."),
          actions: [
            TextButton(
              child: Text("Volver a jugar"),
              onPressed: () {
                Navigator.of(context).pop();
                _reiniciarJuego();
              },
            ),
          ],
        );
      },
    );
  }
  //perder el juego
  void _perderJuego() {
    showDialog(
      context: context,
      barrierDismissible: false, //Evitar que se cierre el diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("¡Tu tiempo terminó!", style: TextStyle(color: Colors.red)),
          content: Text("No obtuviste $puntosLimites puntos en $tiempoLimite segundos."),
          actions: [
            TextButton(
              child: Text("Volver a jugar"),
              onPressed: () {
                Navigator.of(context).pop();
                _reiniciarJuego();
              },
            ),
          ],
        );
      },
    );
  }

  void _reiniciarJuego() {
    setState(() {
      //Reiniciar las variables para un nuevo juego.
      puntos = 0;
      x = 0;
      y = 0;
      _tiempoRestante = tiempoLimite; //Restablecer el tiempo.
      juegoTerminado = false; //Marcar el juego como no terminado.
      _comenzarJuego(); //Comenzar el juego nuevamente.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego de Giroscopio'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Align(
            alignment:
                Alignment(x, y), //Posicionar la pelota en función de x e y.
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 194, 24, 15),
                shape: BoxShape.circle, //Forma de la pelota.
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              'Puntos: $puntos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Text(
              'Segundos: $_tiempoRestante',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Text(
              'Junta $puntosLimites puntos antes de los $tiempoLimite segundos!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

//Hice lo que pude, nomás con cambiar el tiempo límite se cambia el valor de las variables
