package ua.lpnu.ki405.hello;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class CalculatorTest {

    @Test
    @DisplayName("BasicAddition")
    void BasicAddition() {
        assertEquals(5, Calculator.add(2, 3));
        assertEquals(0, Calculator.add(0, 0));
    }

    @Test
    @DisplayName("NegativeAddition")
    void NegativeAddition() {
        assertEquals(-1, Calculator.add(2, -3));
        assertEquals(-7, Calculator.add(-4, -3));
    }

    @Test
    @DisplayName("OverflowThrows")
    void OverflowThrows() {
        assertThrows(ArithmeticException.class, () -> Calculator.add(Integer.MAX_VALUE, 1));
    }
}
