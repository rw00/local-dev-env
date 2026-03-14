# Learn More About Ansible

This document serves as a one-stop-shop for understanding what Ansible is,
how it works under the hood,
why the project is structured the way it is,
and the key terminology and concepts.

---

## 1. What is Ansible?

Ansible is an open-source declarative **configuration management** and **automation tool**.
It allows the definition of the desired state of a system
(e.g., "Docker should be installed", "The `~/.zshrc` file must contain these exact lines"),
and Ansible will figure out the necessary steps to achieve that state.

**Why use it for a local dev env?**
*   **Idempotency**: This is a core feature of Ansible.
It means the same script can be run 10 times, and it will only apply changes when necessary.
If an app is already installed, Ansible simply skips it.
It won't install it twice, and it won't break anything.
*   **Agentless**: A background service or "agent" running constantly on the machine is not needed.
It simply runs over standard connections (like SSH for remote servers, or a local process for a laptop).
*   **Declarative vs. Imperative**: Instead of writing a fragile bash script that says "run `$ apt-get install docker`" (imperative),
the state is defined as `state: present` for the `docker` package (declarative).
Ansible abstracts the how.

---

## 2. How Does Ansible Work?

Ansible operates by pushing small programs, called **modules**, to the target machines.
These modules run on the target system to configure the requested state, and then they are removed.

In this local setup:
1.  Run `ansible-playbook main.yml`.
2.  Ansible reads the `inventory` to see which machines to connect to (in this case, just `localhost`).
3.  Ansible looks at the **playbook** (`main.yml`) and processes the instructions sequentially.
4.  Ansible invokes the correct modules (like `homebrew` for macOS packages, `apt` for Linux packages, or `git` to clone repos) and runs them directly on the machine.
5.  If a task requires supervisor permissions, the `become: yes` (or `become: true`) flag tells Ansible to escalate privileges using `sudo`.

---

## 3. Important Ansible Concepts

### Playbooks (`.yml` / `.yaml` files)
Playbooks are the instruction manuals.
They are composed of one or more "plays," mapping a group of hosts to well-defined **roles** or **tasks**.
A playbook serves as the entry point of the automation.

### Tasks
A task is a single unit of action.
For example, "Install `curl`" or "Copy a config file".
Tasks use **modules** to perform the action.

### Modules
Modules are the actual tools Ansible uses to execute tasks.
Ansible has thousands of built-in modules.
*   *Examples*: `file` (creates files/directories), `copy` (copies files), `command` / `shell` (executes raw terminal commands), `homebrew` (manages Mac packages).

### Inventories
An inventory is a list of servers/machines that Ansible manages.
It can be a simple text file (`inventory` in the project) or generated dynamically.
The provided inventory just contains `localhost` and explicitly tells Ansible to use a `local` connection avoiding SSH.

### Variables & Facts
*   **Variables**: Variables can be defined to make playbooks reusable (e.g., `ZSH_THEME="robbyrussell"`).
*   **Facts**: When Ansible connects to a machine, it automatically gathers information about it (OS version, IP addresses, CPU architecture).
These are called facts. The `ansible_os_family` fact is used to determine if the target platform is Mac (`Darwin`) or Linux (`Debian`).

### Handlers
Handlers are special tasks that only run when triggered (or "notified") by another task.
For example, if a configuration file changes, a handler might be notified to "restart the web server".

### `become` (Privilege Escalation)
Whenever Ansible needs `sudo` access, the `become` keyword is used.
*   `become: true` means execute as `root`.
*   Use `--ask-become-pass` when running the playbook so Ansible can prompt securely for the computer password.

---

## 4. The `roles/` Folder Structure

Instead of packing a thousand tasks into one massive playbook, Ansible uses **Roles** to organize automation content into standard, reusable structures.

A typical role looks like this:

```
roles/
└── {role_name}/
    ├── tasks/         # The main list of tasks that the role executes.
    │   └── main.yml   # The entry point for tasks.
    ├── handlers/      # Handlers triggered by tasks.
    ├── templates/     # Jinja2 templates (.j2) to generate dynamic config files.
    ├── files/         # Static files to be copied to the target machine.
    ├── vars/          # Variables that are not meant to be overridden.
    ├── defaults/      # Default variables for the role (can be easily overridden).
    └── meta/          # Metadata about the role (dependencies, author, etc).
```

### Purpose of This Structure
In this local dev env repository:
*   **`roles/system`**: Manages OS-level installations. It cleanly splits into `macos.yml` and `linux.yml`.
*   **`roles/terminal`**: Dedicated entirely to the shell experience (Oh My Zsh, plugins, `.zshrc`).
*   **`roles/languages`**: Handles all programming languages and version managers (like `mise`, Java, Maven).

This modular approach makes the codebase highly readable.
To add Node.js, simply add tasks to `roles/languages`.
To change the OS font, modify `roles/system`.
