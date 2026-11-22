package ua.lpnu.ki405.hello;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class AppTest {

    @Test
    @DisplayName("GreetingText")
    void GreetingText() {
        assertEquals("Hello, World!", App.greeting());
    }

    @Test
    @DisplayName("MainPrintsGreeting")
    void MainPrintsGreeting() {
        PrintStream original = System.out;
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        try {
            System.setOut(new PrintStream(buffer, true, StandardCharsets.UTF_8));
            App.main(new String[0]);
        } finally {
            System.setOut(original);
        }
        assertEquals("Hello, World!", buffer.toString(StandardCharsets.UTF_8).strip());
    }
}
