import 'package:flutter/material.dart';
import 'package:water_tracker/feature/onboard/onboard_controller.dart';
import 'package:water_tracker/shared_widget/primary_button/primary_button.dart';

class OnboardScreen extends StatefulWidget {
  OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final onBoardList = [
    {
      'image': 'assets/img/onboard_1.png',
      'title': 'Acompanhe a sua ingestão diária de água connosco.',
      'subtitle':
          'Atinja os seus objetivos de hidratação com um simples toque!',
    },
    {
      'image': 'assets/img/onboard_2.png',
      'title': 'Defina metas diárias personalizadas de consumo de água.',
      'subtitle':
          'Mantenha-se motivado e alcance seus objetivos de hidratação com facilidade.',
    },
    {
      'image': 'assets/img/onboard_3.png',
      'title': 'Receba lembretes amigáveis para beber água regularmente.',
      'subtitle':
          'Nunca mais se esqueça de se manter hidratado ao longo do dia.',
    },
  ];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _onPageChanged();
  }

  void _onPageChanged() {
    setState(() {
      _currentPage = OnboardController.nextPage(
        _currentPage,
        onBoardList.length,
      );
      if (_currentPage < onBoardList.length - 1) {
        Future.delayed(const Duration(seconds: 3), _onPageChanged);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(onBoardList[0]['image']!, width: 300, height: 300),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    onBoardList[0]['title']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF000000),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    onBoardList[0]['subtitle']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7C7C7C),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onBoardList.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Color(0XFF5DCCFC)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 0,
              child: primaryButton(
                text: 'Próximo',
                onPressed: () {
                  setState(() {
                    _currentPage = OnboardController.nextPage(
                      _currentPage,
                      onBoardList.length,
                    );
                  });
                },
                width: MediaQuery.of(context).size.width,
                height: 60,
                backgroundColor: Color(0xFF5DCCFC),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
