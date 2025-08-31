"""Main application module."""

import argparse
import logging
import os
from typing import Any, List, Optional


def setup_logging(level: int = logging.INFO) -> None:
    """Set up logging configuration."""
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )


class Settings:
    """Application settings."""
    
    def __init__(self, config_path: Optional[str] = None, dry_run: bool = False):
        """Initialize settings."""
        self.config_path = config_path
        self.dry_run = dry_run
        
        # Check for required SECRET_KEY unless in DEBUG mode
        if not os.environ.get("DEBUG", "").lower() == "true":
            if not os.environ.get("SECRET_KEY"):
                raise ValueError("SECRET_KEY environment variable is required")


def parse_arguments(args: Optional[List[str]] = None) -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Main application")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose logging")
    parser.add_argument("--config", type=str, help="Configuration file path")
    parser.add_argument("--dry-run", action="store_true", help="Run in dry-run mode")
    
    return parser.parse_args(args)


def main(argv: Optional[List[str]] = None) -> int:
    """Main application entry point."""
    try:
        args = parse_arguments(argv)
        
        # Setup logging
        log_level = logging.DEBUG if args.verbose else logging.INFO
        setup_logging(level=log_level)
        
        # Initialize settings
        settings = Settings(config_path=args.config, dry_run=args.dry_run)
        
        logging.info("Application started successfully")
        return 0
        
    except KeyboardInterrupt:
        logging.info("Application interrupted by user")
        return 1
    except Exception as e:
        if argv and "--verbose" in argv:
            logging.exception("Application error: %s", e)
        else:
            logging.error("Application error: %s", e)
        return 1


if __name__ == "__main__":
    import sys
    sys.exit(main())