# File with basic syntax errors to test core functionality
# import non_existent_module   # Import error - commented out

def missing_colon_function(name):  # Missing colon fixed
    return f"Hello {name}"

def another_broken_function(a, b):  # Missing colon fixed
    result = a + b   # Fixed assignment syntax
    return result

# Function with missing type annotations (ANN001, ANN201)
def calculate_sum(numbers):
    '''calculate sum of numbers'''  # D401: Should be imperative
    total = 0
    for num in numbers:
        total += num
    return total

# Long line that needs formatting (E501)  
def very_long_function_name_that_exceeds_character_limits(parameter_one, parameter_two, parameter_three, parameter_four):
    return parameter_one + parameter_two + parameter_three + parameter_four

class TestClass:
    def __init__(self, value):  # Missing colon fixed
        self.value = value
    def process(self, data):  # Missing annotations (ANN001, ANN201)
        if data is None:
            return None
        # Logic that can be simplified (SIM201)
        if not data == "empty":
            return data
        else:
            return ""

# Missing newline at end of file (W292)
