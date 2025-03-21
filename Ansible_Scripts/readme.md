# Ansible Scripts

This repository showcases a collection of Ansible roles designed to automate the setup of development environments for **Java**, **Node.js**, and **Python** applications on **Linux servers**.

## Project Structure

The repository is organized into the following directories:

- **Inventory**: Contains the `inventory` file where server details and their IP addresses are defined.
- **Playbooks**: Includes sample playbooks demonstrating how to write and use Ansible playbooks effectively.
- **Roles**: Houses individual roles for setting up specific environments or services. Each role adheres to the standard Ansible role structure:
  - `tasks/`: Main list of tasks to be executed.
  - `handlers/`: Handlers triggered by task notifications.
  - `templates/`: Jinja2 templates for configuration files.
  - `files/`: Static files to be used or deployed by tasks.
  - `vars/`: Variables for the role.

## Roles Overview

### Java Role

The **Java** role installs **Java** and **Tomcat** on the target server, configuring the environment to run Java applications on a Tomcat server. Key features include:

- **Optional Nginx Installation**: Controlled by the `install_nginx` variable. Set it to `true` to install Nginx or `false` to skip.
- **Let's Encrypt Integration**: Automatically installs Let's Encrypt and generates SSL certificates for specified domains. Nginx configurations will be updated based on the SSL certificate path and the specified domain.
- **Deployment Scripts**: Includes scripts to deploy new JAR files to the server.

### Node.js Role

The **Node.js** role sets up a Node.js environment. Features include:

- **Version Selection**: Specify the Node.js version to install using the `node_version` variable.

### Python Role

The **Python** role prepares a Python development environment with the following features:

- **Version Selection**: Specify the Python version to install using the `python_version` variable.

## Requirements

- **Ansible**: Ensure Ansible is installed on the control machine.
- **Supported Systems**: These roles are designed for **Linux servers**.

## Usage

1. **Clone the Repository**:
2. **Update Inventory**: Modify the `inventory` file in the `Inventory` directory with your server details.
3. **Customize Playbooks**: Adjust variables in each role as needed by editing or creating playbooks in the `playbooks` folder.
4. **Run Playbooks**: Execute the desired playbook:
   ```bash
   ansible-playbook -i inventory/inventory playbooks/your-playbook.yml
   ```

## Example Playbooks


[sample-playbook-1.yaml](playbooks/sample-playbook-1.yaml) demonstrates how to **attach an EFS (Elastic File System) block** to an **EC2 instance**.

- **Variables**: The playbook defines the **base path** where the **EFS file system** will be mounted, along with the **EFS system ID** as variables.
- **Installation Requirements**: To mount **EFS**, we install:
  - **Python Boto3** package
  - **EFS Utils** tool
- **Final Step**: The **EFS** will be automatically mounted to the **EC2 instance** by adding a record in the **fstab** file.

[sample-playbook-2.yaml](playbooks/sample-playbook-2.yaml) is an example of how to use the `python-installation` role with optional Nginx installation. It additionally installs **node-exporter** and **Promtail**. **Promtail** is used to ship logs to **Grafana Loki**, which is Grafana's purpose-built log aggregation system.
