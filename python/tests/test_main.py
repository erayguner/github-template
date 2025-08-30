"""
Tests for the main module.
"""

from unittest.mock import MagicMock, patch

import pytest

from src.main import main, parse_arguments


class TestParseArguments:
    """Test cases for argument parsing."""

    def test_default_arguments(self):
        """Test parsing with no arguments."""
        args = parse_arguments([])
        assert args.verbose is False
        assert args.config is None
        assert args.dry_run is False

    def test_verbose_flag(self):
        """Test verbose flag parsing."""
        args = parse_arguments(["--verbose"])
        assert args.verbose is True

        args = parse_arguments(["-v"])
        assert args.verbose is True

    def test_config_argument(self):
        """Test config argument parsing."""
        args = parse_arguments(["--config", "/path/to/config.yml"])
        assert args.config == "/path/to/config.yml"

    def test_dry_run_flag(self):
        """Test dry-run flag parsing."""
        args = parse_arguments(["--dry-run"])
        assert args.dry_run is True


class TestMain:
    """Test cases for the main function."""

    @patch("src.main.setup_logging")
    @patch("src.main.Settings")
    def test_main_success(self, mock_settings, mock_setup_logging):
        """Test successful main execution."""
        mock_settings.return_value = MagicMock()

        result = main([])

        assert result == 0
        mock_setup_logging.assert_called_once()
        mock_settings.assert_called_once()

    @patch("src.main.setup_logging")
    @patch("src.main.Settings")
    def test_main_with_verbose(self, mock_settings, mock_setup_logging):
        """Test main with verbose flag."""
        mock_settings.return_value = MagicMock()

        result = main(["--verbose"])

        assert result == 0
        # Verify that debug logging level was used
        mock_setup_logging.assert_called_once()
        call_args = mock_setup_logging.call_args
        assert call_args[1]["level"] == 10  # logging.DEBUG = 10, INFO = 20

    @patch("src.main.setup_logging")
    @patch("src.main.Settings")
    def test_main_with_config(self, mock_settings, mock_setup_logging):
        """Test main with config file."""
        mock_settings.return_value = MagicMock()

        result = main(["--config", "/path/to/config.yml"])

        assert result == 0

    @patch("src.main.setup_logging")
    @patch("src.main.Settings")
    def test_main_with_dry_run(self, mock_settings, mock_setup_logging):
        """Test main with dry-run flag."""
        mock_settings.return_value = MagicMock()

        result = main(["--dry-run"])

        assert result == 0

    @patch("src.main.setup_logging")
    @patch("src.main.Settings")
    def test_main_keyboard_interrupt(self, mock_settings, mock_setup_logging):
        """Test main handling KeyboardInterrupt."""
        mock_settings.side_effect = KeyboardInterrupt()

        result = main([])

        assert result == 1

    @patch("src.main.setup_logging")
    @patch("src.main.Settings")
    def test_main_exception(self, mock_settings, mock_setup_logging):
        """Test main handling general exception."""
        mock_settings.side_effect = Exception("Test error")

        result = main([])

        assert result == 1

    @patch("src.main.setup_logging")
    @patch("src.main.Settings")
    def test_main_exception_verbose(self, mock_settings, mock_setup_logging):
        """Test main handling exception with verbose output."""
        mock_settings.side_effect = Exception("Test error")

        result = main(["--verbose"])

        assert result == 1


class TestIntegration:
    """Integration test cases."""

    @pytest.mark.integration
    def test_full_application_flow(self):
        """Test the complete application flow."""
        import os
        # Set DEBUG=True to avoid SECRET_KEY requirement
        old_debug = os.environ.get("DEBUG")
        os.environ["DEBUG"] = "true"
        try:
            result = main(["--dry-run", "--verbose"])
            assert result == 0
        finally:
            if old_debug:
                os.environ["DEBUG"] = old_debug
            else:
                os.environ.pop("DEBUG", None)
