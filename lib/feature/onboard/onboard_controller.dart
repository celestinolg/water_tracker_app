import 'package:flutter/widgets.dart';

class OnboardController {
  static String buttonName = 'Próximo';

  static void nextPage(
    int currentPage,
    int totalPage,
    PageController controller,
    VoidCallback onFinish, // callback para quando acabar
  ) {
    if (currentPage < totalPage - 1) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Última página → chamar a ação final
      onFinish();
    }
  }
}
