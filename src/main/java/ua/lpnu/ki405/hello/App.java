package ua.lpnu.ki405.hello;

/**
 * Точка входу кросплатформного застосунку Hello World.
 */
public final class App {

    /** Текст, який друкує застосунок. Перевіряється тестом і скриптами ci. */
    public static final String GREETING = "Hello, World!";

    private App() {
        // утилітний клас: екземпляри не потрібні
    }

    /**
     * Повертає текст привітання.
     *
     * @return рядок "Hello, World!"
     */
    public static String greeting() {
        return GREETING;
    }

    /**
     * Друкує привітання у стандартний вивід.
     *
     * @param args аргументи командного рядка (не використовуються)
     */
    public static void main(String[] args) {
        System.out.println(greeting());
    }
}
