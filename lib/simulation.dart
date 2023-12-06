import 'dart:math';

import 'package:flutter/material.dart';

class AnimationTween extends StatefulWidget {
  const AnimationTween({super.key});

  @override
  State<AnimationTween> createState() => _AnimationTweenState();
}

class _AnimationTweenState extends State<AnimationTween>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  bool calculateDef = false;
  bool isHorizontal = false;

  double circleA = 40;
  double circleB = 40;

  double a = 40;
  double b = 40;

  static const double e = 0.9;
  static const double g = -9.81;

  double ticker = 0;
  double circleTiker = 0;

  double impulseAngle = 2.2;
  double fallAngle = 0;
  double acceleration = 0;
  double? previousAcceleration;

  double candidateY = 0;
  double candidateX = 0;
  double y = 0;
  double x = 0;
  double? previousX;
  double? previousY;

  double xCorrection = 0;
  double yCorrection = 0;

  double? deltaSpeed;
  double speed = 0;
  double? previousSpeed;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.9,
          height: MediaQuery.sizeOf(context).height * 0.9,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              trajectoryCalculator();

              if (calculateDef) {
                circleDeformationCalculator(isHorizontal);
              }

              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 140,
                      child: Text(
                        'speed: $speed',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 170,
                      height: 20,
                      child: Text(
                        'acceleration: $acceleration',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 20,
                          child: Text(
                            'fall angle: $fallAngle',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          height: 20,
                          child: Text(
                            'impulse angle: $impulseAngle',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment(x, y),
                    child: ClipOval(
                      child: Container(
                        height: circleA,
                        width: circleB,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 300,
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                calculateDef = false;
                isHorizontal = false;

                ticker = 0;
                circleTiker = 0;

                impulseAngle = impulseAngle + 0.3;
                fallAngle = 0;
                acceleration = 10.1;

                candidateY = 0;
                candidateX = 0;
                y = 0;
                x = 0;

                xCorrection = 0;
                yCorrection = 0;

                _animationController.forward();
              },
              child: const Text('new'),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () {
                _animationController.isAnimating
                    ? _animationController.stop()
                    : _animationController.forward();
              },
              child: Icon(
                _animationController.isAnimating
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void circleDeformationCalculator(bool isHorizontal) {
    circleTiker += 0.1;

    if (circleTiker > 5) {
      calculateDef = false;
      circleTiker = 0;
      return;
    }

    var def = deformation(1, acceleration, 2, 0.5, 3, circleTiker);

    if (isHorizontal) {
      circleA = a - def;
      circleB = b + def;
    } else {
      circleA = a + def;
      circleB = b - def;
    }
  }

  double deformation(
    double mass,
    double acceleration,
    double k,
    double beta,
    double omega,
    double time,
  ) {
    double maxDeformation = (mass * acceleration) / k;

    return maxDeformation * exp(-beta * time) * cos(omega * time);
  }

  double calculateX() =>
      ((acceleration * cos(impulseAngle) * ticker) + xCorrection);

  double calculateY() =>
      ((acceleration * sin(impulseAngle) * ticker - 0.5 * g * ticker * ticker) +
          yCorrection);

  void trajectoryCalculator() {
    ticker = ticker + 0.005;

    candidateY = calculateY();
    candidateX = calculateX();

    if (acceleration.abs() < 0.0001) {
      _animationController.stop();
    }

    if (candidateY <= -1) {
      wallDetector('bottom');
    } else if (candidateY >= 1) {
      wallDetector('top');
    } else if (candidateX < -1) {
      wallDetector('left');
    } else if (candidateX > 1) {
      wallDetector('right');
    } else {
      y = candidateY;
      x = candidateX;
      calculateAngle();
    }
  }

  void calculateAngle() {
    if (previousX != null && previousY != null) {
      double deltaX = x - previousX!;
      double deltaY = y - previousY!;
      fallAngle = atan2(deltaY, deltaX);
      calculateSpeed();
    }

    previousX = x;
    previousY = y;
  }

  void calculateSpeed() {
    speed = sqrt(pow(x - previousX!, 2) + pow(y - previousY!, 2));

    if (previousSpeed != null) {
      deltaSpeed = speed - previousSpeed!;
    }
    previousSpeed = speed;
  }

  //момент столкновения с стеной
  void wallDetector(String direction) {
    ticker = 0;
    acceleration = 0 > fallAngle ? acceleration * e : -acceleration * e;
    switch (direction) {
      case 'bottom':
        xCorrection = x;
        yCorrection = -1;
        impulseAngle = fallAngle.abs();
        calculateDef = true;
        isHorizontal = true;
        circleTiker = 0;
        break;
      case 'top':
        xCorrection = x;
        yCorrection = 1;
        impulseAngle = 6.2832 - fallAngle;
        calculateDef = true;
        isHorizontal = true;
        circleTiker = 0;
        break;
      case 'left':
        xCorrection = -1;
        yCorrection = y;
        impulseAngle = (-1.5708 > fallAngle && fallAngle > -3.1416)
            ? 3.1416 + fallAngle.abs()
            : 3.1416 - fallAngle;
        calculateDef = true;
        isHorizontal = false;
        circleTiker = 0;
        break;
      case 'right':
        xCorrection = 1;
        yCorrection = y;
        impulseAngle = (0 > fallAngle && fallAngle > -1.5708)
            ? 3.1416 + fallAngle.abs()
            : 3.1416 - fallAngle;
        calculateDef = true;
        isHorizontal = false;
        circleTiker = 0;
      default:
        throw ('Invalid direction');
    }
  }

  // void calculateAcceleration() {
  //   acceleration = deltaSpeed! / 0.0001;
  // }
}
