# Install OpenNebula CLI

This script is designed to simplify the installation and configuration of the OpenNebula CLI on macOS, Debian, or Ubuntu systems. The OpenNebula CLI is a powerful tool that allows users to manage their OpenNebula cloud infrastructure directly from the command line.

## Supported Platforms

- macOS
- Debian-based distributions (Debian, Ubuntu)

## Prerequisites

- `curl` must be installed on your system.
- Administrative (sudo) privileges are required for some installations.

## Installation

Run the following command in your terminal:

```bash
curl -fsSL -o setup_opennebula_cli.sh https://raw.githubusercontent.com/toolleap/setup-opennebula-cli/refs/heads/main/setup_opennebula_cli.sh
chmod +x setup_opennebula_cli.sh
./setup_opennebula_cli.sh
```

## What is OpenNebula CLI?

The OpenNebula Command-Line Interface (CLI) provides a set of commands to manage virtual machines, networks, datastores, and other OpenNebula resources. It is ideal for system administrators and developers who prefer managing their infrastructure programmatically or via scripts.

Learn more about the OpenNebula CLI in the [official documentation](https://docs.opennebula.io/6.10/management_and_operations/references/cli.html).

## Features of the Script

- Verifies the correct Ruby version is installed (minimum 3.0.0).
- Installs or updates RVM (Ruby Version Manager) if necessary.
- Ensures the required OpenSSL version (1.1) is installed.
- Installs or updates the specified version of OpenNebula CLI (default: 6.10.2).
- Configures the CLI with user-provided credentials and environment variables.
- Provides instructions to persist environment variables for convenience.

### Steps Performed by the Script

1. Checks for the required Ruby version (3.0.0 or higher).
2. Installs RVM if it is not already installed.
3. Installs the required version of Ruby using RVM.
4. Installs or updates the specified version of OpenNebula CLI.
5. Prompts the user for the OpenNebula frontend hostname, username, and password.
6. Configures the OpenNebula CLI with the provided credentials.
7. Sets environment variables for the CLI:
   - `ONE_XMLRPC`: URL of the OpenNebula frontend XML-RPC endpoint.
   - `ONE_AUTH`: Path to the CLI authentication file.
   - `ONEFLOW_URL`: URL of the OpenNebula Flow endpoint.
8. Provides instructions to persist the environment variables in `.bashrc` or `.zshrc`.

## Example Usage

After running the script, you can use the OpenNebula CLI commands. For example:

```bash
onevm list  # Lists all virtual machines
onehost list  # Lists all hosts
```

## Troubleshooting

If you encounter issues:

- Ensure that your system has an active internet connection.
- Verify that `curl` is installed and accessible from the command line.
- Check the contents of your `~/.bashrc` or `~/.zshrc` file to ensure the environment variables are set correctly.
- For more information, refer to the [OpenNebula CLI documentation](https://docs.opennebula.io/6.10/management_and_operations/references/cli.html).



---

Happy cloud management with OpenNebula CLI!

