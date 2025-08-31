# broken_comprehensive_example.py

# --- Syntax Error ---
def greet(name)   # Missing colon

    return f"Hello, {name}"


# --- Import Error ---
import non_existent_module


# --- Runtime Error ---
def divide(a, b):
    return a / b



result divide(10, 0)  # Division by zero


# --- Logic Error (test will fail) ---
def multiply(a, b):
    return a - b  # Wrong on purpose


# --- Fake test function ---
def test_multiply()
    assert multiply(3, 4) == 12  # Will fail