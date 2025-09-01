# broken_comprehensive_example.py


# --- Syntax Error ---
def greet(name: str) -> str:  # Missing colon - should trigger auto-fix
    return f"Hello, {name}"


# --- Import Error ---
# import non_existent_module  # Commented out - module doesn't exist


# --- Runtime Error ---
def divide(a: float, b: float) -> float:
    return a / b


result = divide(10, 0)  # Invalid syntax - should trigger auto-fix


# --- Logic Error (test will fail) ---
def multiply(a: float, b: float) -> float:
    return a - b  # Wrong on purpose


# --- Fake test function ---
def test_multiply() -> None:  # Missing colon - should trigger auto-fix
    assert multiply(3, 4) == 12  # Will fail


# Test comment to trigger enhanced auto-fix workflow
