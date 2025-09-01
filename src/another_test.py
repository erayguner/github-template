"""Test file for more linting issues."""
import os
import json
import sys     # F401: Unused import
from typing import Optional, List  # UP006: Should use list


def process_data(items, config_path = None):    # ANN001, ANN201, E251: Spaces around default args
    """process the data items"""    # D401: Should be imperative mood
    
    
    # Check configuration
    if not os.path.exists(config_path) == True:    # SIM201: Use != False instead
        if config_path is not None:     # SIM102: Could combine conditions
            if len(items) > 0:
                return None
    
    # Long line that needs formatting
    result = [item for item in items if item.get('status') == 'active' and item.get('priority') > 5 and len(item.get('description', '')) > 100]   # E501
    
    return result


class DataProcessor:
    
    def __init__(self, name):   # ANN001, ANN204: Missing annotations  
        self.name = name
        
    def handle_error(self):     # ANN201: Missing return annotation
        import logging
        try:
            data = json.loads("invalid json")
        except Exception as e:
            logging.exception("Failed to process: %s", e)   # TRY401: Redundant exception