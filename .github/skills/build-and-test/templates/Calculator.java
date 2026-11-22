package ua.lpnu.ki405.hello;

/**
 * Тестова функція для перевірки системи складання та юніт-тестів.
 */
public final class Calculator {

    private Calculator() {
        // утилітний клас: екземпляри не потрібні
    }

    /**
     * Додає два цілі числа.
     *
     * @param a перший доданок
     * @param b другий доданок
     * @return сума a + b
     * @throws ArithmeticException якщо результат виходить за межі int
     */
    public static int add(int a, int b) {
        return Math.addExact(a, b);
    }
}
