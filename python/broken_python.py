# broken_comprehensive_example.py

# --- Syntax Error ---
def greet(name)
    return f"Hello, {name}"


# --- Import Error ---
import non_existent_module  # Commented out non-existent module


# --- Runtime Error ---
def divide(a, b):

    return a / b



# result = divide(10, 0)  # Division by zero - commented out


# --- Logic Error (test will fail) ---
def multiply(a, b):
    return a * b  # Fixed logic error


# --- Fake test function ---
def test_multiply():
    assert multiply(3, 4) == 12  # Should pass