class OnboardController {
  static int nextPage(int currentPage, int totalPages) {
    return currentPage + 1 % totalPages;
  }
}
