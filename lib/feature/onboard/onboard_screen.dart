import 'package:flutter/material.dart';
import 'package:water_tracker/feature/onboard/onboard_controller.dart';
import 'package:water_tracker/shared_widget/primary_button/primary_button.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

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
      'title': 'Lembretes inteligentes personalizados para si.',
      'subtitle':
          'Rápido e fácil de definir a sua meta de hidratação e acompanhar o progresso da sua ingestão diária de água.',
    },
    {
      'image': 'assets/img/onboard_3.png',
      'title': 'Fácil de usar.\nBeba, toque, repita.',
      'subtitle':
          'Manter-se hidratado todos os dias é fácil com o Drops Water Tracker.',
    },
  ];
  int _currentPage = 0;
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xFF5DCCFC)),
                onPressed: () {
                  _controller.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  );
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: onBoardList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (_, index) {
                return Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      onBoardList[index]['image']!,
                      width: 300,
                      height: 300,
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        onBoardList[index]['title']!,
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
                        onBoardList[index]['subtitle']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7C7C7C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onBoardList.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 24,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Color(0xFF5DCCFC)
                              : Color(0xFFD8D8D8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                  primaryButton(
                    text: (_currentPage == onBoardList.length - 1)
                        ? 'Começar'
                        : 'Próximo',
                    onPressed: () {
                      OnboardController.nextPage(
                        _currentPage,
                        onBoardList.length,
                        _controller,
                        () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      );
                    },
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    backgroundColor: Color(0xFF5DCCFC),
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
