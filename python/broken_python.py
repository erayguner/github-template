# broken_comprehensive_example.py

# --- Syntax Error ---
def greet(name: str) -> str:   # Missing colon - should trigger auto-fix
    return f"Hello, {name}"


# --- Import Error ---
# import non_existent_module  # Commented out - module doesn't exist


# --- Runtime Error ---
def divide(a: float, b: float) -> float:
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

result = divide(10, 2)  # Fixed: changed from divide(10, 0) to avoid ZeroDivisionError


# --- Logic Error (test will fail) ---
def multiply(a: float, b: float) -> float:
    return a * b  # Fixed: changed from a - b to a * b


# --- Fake test function ---
def test_multiply() -> None:   # Missing colon - should trigger auto-fix
    assert multiply(3, 4) == 12  # Will fail

# Test comment to trigger enhanced auto-fix workflow
