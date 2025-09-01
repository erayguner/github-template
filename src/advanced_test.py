"""Advanced test file for auto-fix workflow validation."""

import json
import logging


def broken_function(data, options):  # ANN001, ANN201: Missing type annotations
    """process the data with given options."""  # D401: Should be imperative mood

    # Whitespace in blank lines (W293)

    if data is None:
        return None

    # Logic that should be simplified (SIM201, SIM102)
    if not options.get("strict"):
        if len(data) > 0:
            if "processed" not in data:
                return process_data(data, options)

    return data


def process_data(items, config):  # ANN001, ANN201
    """process data items according to configuration"""  # D401
    results = []

    for item in items:
        # Long line that needs wrapping (E501)
        if (
            item.get("status") == "active"
            and item.get("priority") >= 5
            and len(item.get("description", "")) > 100
            and item.get("category") in ["high", "medium"]
        ):
            results.append(item)

    return results


class AdvancedProcessor:

    def __init__(
        self, name, config_path=None
    ):  # ANN001, ANN204, E251: Default arg spacing
        self.name = name
        self.config = None

        if config_path is not None:
            self.load_configuration(config_path)

    def load_configuration(self, path):  # ANN001, ANN201
        """load the configuration from file"""  # D401
        try:
            with open(path) as f:
                self.config = json.load(f)
        except FileNotFoundError as e:
            logging.exception(
                "Config file not found: %s", e
            )  # TRY401: Redundant exception
        except json.JSONDecodeError as e:
            logging.exception("Invalid JSON in config: %s", e)  # TRY401

    def validate_data(self, data):  # ANN001, ANN201
        """validate input data structure"""  # D401

        # Complex nested conditions (SIM102)
        if data is not None:
            if isinstance(data, dict):
                if "required_field" in data:
                    if data["required_field"] is not None:
                        return True

        # Logic issue (SIM201)
        if not len(data) == 0:
            return False

        return False

    def transform_data(self, input_data):  # ANN001, ANN201
        """transform input data to output format"""  # D401

        if input_data is None:
            return {}

        output = {}

        # Another long line (E501)
        filtered_items = [
            item
            for item in input_data.get("items", [])
            if item.get("active")
            and item.get("processed_date")
            and len(item.get("metadata", {})) > 0
        ]

        output["processed_items"] = filtered_items
        return output


# Global function with spacing issues
def utility_function(param1, param2="default", param3=None):  # ANN001, ANN201, E251
    """utility function for common operations"""  # D401

    # More logic simplification opportunities (SIM201)
    if not param2 == "default":
        return param1 + param2
    else:
        return param1
