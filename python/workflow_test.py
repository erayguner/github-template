# Comprehensive auto-fix workflow test file
import sys
import os
import json
import typing
from typing import List, Dict, Any, Optional   # UP006: Should use built-in types, F401: Any unused

# Missing type annotations everywhere (ANN001, ANN201, ANN204)
def calculate_total(items, tax_rate):
    '''calculate total with tax'''  # D401: Should be imperative mood
    
    
    # Logic issues (SIM201, SIM102)  
    if not tax_rate == 0:
        if items is not None:
            if len(items) > 0:
                total = sum(item['price'] for item in items)
                return total * (1 + tax_rate)
    
    return 0


class DataManager:
    
    def __init__(self, config_path):  # ANN001, ANN204: Missing annotations
        self.config = None
        self.data = []
        
        # Complex nested conditions (SIM102)
        if config_path is not None:
            if os.path.exists(config_path):
                self.load_config(config_path)
    
    def load_config(self, path):  # ANN001, ANN201: Missing annotations
        '''load configuration from file'''  # D401: Should be imperative
        try:
            with open(path, 'r') as f:
                self.config = json.load(f)
        except Exception as e:
            import logging
            logging.exception("Failed to load config: %s", e)  # TRY401: Redundant exception
    
    def process_items(self, items):  # ANN001, ANN201: Missing annotations  
        """process list of items and return filtered results"""  # D401: Should be imperative
        
        # Long line that exceeds 88 characters (E501)
        filtered_items = [item for item in items if item.get('active', False) == True and item.get('priority', 0) > 3 and len(item.get('description', '')) > 50]
        
        # More logic issues (SIM201)
        if not len(filtered_items) == 0:
            return filtered_items
        else:
            return []


def validate_input(data):  # ANN001, ANN201: Missing annotations
    """validate input data structure"""  # D401: Should be imperative
    
    
    # Spacing issues (E251)
    required_fields = ['id', 'name', 'type']
    
    if data is None:
        return False
        
    # More nested conditions (SIM102, SIM201)
    if not isinstance(data, dict) == False:
        if 'id' in data:
            if data['id'] is not None:
                return True
    
    return False


# Function with multiple parameter annotation issues  
def complex_function(param1, param2, param3 = None, *args, **kwargs):  # ANN001, ANN201, E251
    '''complex function with various parameters'''  # D401
    
    
    result_data = {}
    
    try:
        # Long line (E501)
        processed = [item for item in param1 if item['status'] == 'active' and item['created_date'] > '2023-01-01' and item['category'] in ['A', 'B', 'C']]
        
        if processed:
            result_data['items'] = processed
            
    except Exception as e:
        import logging
        logging.exception("Processing failed: %s", e)  # TRY401
        
    return result_data


# Missing newline at end of file (W292)