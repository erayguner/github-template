# Comprehensive auto-fix workflow test file
import json
import os


# Missing type annotations everywhere (ANN001, ANN201, ANN204)
def calculate_total(items, tax_rate):
    """Calculate total with tax."""  # D401: Should be imperative mood
    # Logic issues (SIM201, SIM102)
    if tax_rate != 0 and items is not None and len(items) > 0:
        total = sum(item["price"] for item in items)
        return total * (1 + tax_rate)

    return 0


class DataManager:

    def __init__(self, config_path) -> None:  # ANN001, ANN204: Missing annotations
        self.config = None
        self.data = []

        # Complex nested conditions (SIM102)
        if config_path is not None and os.path.exists(config_path):
            self.load_config(config_path)

    def load_config(self, path) -> None:  # ANN001, ANN201: Missing annotations
        """Load configuration from file."""  # D401: Should be imperative
        try:
            with open(path) as f:
                self.config = json.load(f)
        except Exception as e:
            import logging

            logging.exception(
                "Failed to load config: %s", e
            )  # TRY401: Redundant exception

    def process_items(self, items):  # ANN001, ANN201: Missing annotations
        """Process list of items and return filtered results."""  # D401: Should be imperative
        # Long line that exceeds 88 characters (E501)
        filtered_items = [
            item
            for item in items
            if item.get("active", False)
            and item.get("priority", 0) > 3
            and len(item.get("description", "")) > 50
        ]

        # More logic issues (SIM201)
        if len(filtered_items) != 0:
            return filtered_items
        return []


def validate_input(data) -> bool:  # ANN001, ANN201: Missing annotations
    """Validate input data structure."""  # D401: Should be imperative
    # Spacing issues (E251)
    required_fields = ["id", "name", "type"]

    if data is None:
        return False

    # More nested conditions (SIM102, SIM201)
    return bool(isinstance(data, dict) and "id" in data and data["id"] is not None)


# Function with multiple parameter annotation issues
def complex_function(
    param1, param2, param3=None, *args, **kwargs
):  # ANN001, ANN201, E251
    """Complex function with various parameters."""  # D401
    result_data = {}

    try:
        # Long line (E501)
        processed = [
            item
            for item in param1
            if item["status"] == "active"
            and item["created_date"] > "2023-01-01"
            and item["category"] in ["A", "B", "C"]
        ]

        if processed:
            result_data["items"] = processed

    except Exception as e:
        import logging

        logging.exception("Processing failed: %s", e)  # TRY401

    return result_data


# Missing newline at end of file (W292)
