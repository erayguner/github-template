# Test file for comprehensive auto-fix validation
import sys
from typing import List, Any    # UP006: Should use list instead of List, F401: Any is unused

def broken_function(param1, param2):  # ANN001, ANN201: Missing type annotations
    '''docstring should be imperative''' # D401: Docstring should be imperative mood
    
    
    if not param1 == "test":     # SIM201: Should use != instead of not ==
        result = param1 + param2
        return result
    else:
        return None

def long_line_function():    # ANN201: Missing return annotation
    very_long_variable_name = "This is a very long line that exceeds the 88 character limit and should be reformatted by black"  # E501

class TestClass:
    
    def __init__(self, data):   # ANN204: Missing return annotation for __init__
        self.data = data
        
        if data is None:
            if not data:        # SIM102: Could be combined with above
                print("Error")
            
def problematic_logging():  # ANN201: Missing return annotation
    import logging
    try:
        result = 1 / 0
    except Exception as e:
        logging.exception("Error occurred: %s", e)  # TRY401: Redundant exception object

# Missing newline at end of file