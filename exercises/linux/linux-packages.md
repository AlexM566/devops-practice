# Linux Package Management and Services

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** Basic Linux commands, understanding of processes, sudo access

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to manage software packages using apt (Debian/Ubuntu), update the system, and manage system services with systemd. By the end of this exercise, you'll be able to install, update, and remove software, as well as control system services.

## Instructions

### Part 1: Understanding Package Management

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-ubuntu bash
```

2. Update the package list:
```bash
apt update
```

3. View available updates:
```bash
apt list --upgradable
```

4. Search for a package:
```bash
apt search htop
apt search nginx
```

5. View detailed information about a package:
```bash
apt show curl
```

6. Check if a package is installed:
```bash
dpkg -l | grep curl
apt list --installed | grep curl
```

### Part 2: Installing Packages

7. Install a simple utility (tree):
```bash
apt install -y tree
```

8. Verify the installation:
```bash
which tree
tree --version
```

9. Use the newly installed tool:
```bash
cd /etc
tree -L 2
```

10. Install multiple packages at once:
```bash
apt install -y htop net-tools dnsutils
```

11. Verify the installations:
```bash
which htop
which netstat
which dig
```

### Part 3: Managing Packages

12. List all installed packages:
```bash
apt list --installed | head -20
```

13. View package dependencies:
```bash
apt depends curl
```

14. View reverse dependencies (what depends on this package):
```bash
apt rdepends curl
```

15. Download a package without installing:
```bash
cd /tmp
apt download wget
ls -lh wget*.deb
```

16. View contents of a .deb package:
```bash
dpkg -c wget*.deb | head -20
```

### Part 4: Updating and Upgrading

17. Update package lists again:
```bash
apt update
```

18. Upgrade all packages (simulation):
```bash
apt upgrade --dry-run
```

19. Perform the actual upgrade:
```bash
apt upgrade -y
```

20. Check for distribution upgrades:
```bash
apt dist-upgrade --dry-run
```

21. Clean up package cache:
```bash
apt clean
apt autoclean
```

22. Remove unnecessary packages:
```bash
apt autoremove -y
```

### Part 5: Removing Packages

23. Remove a package (keeping configuration):
```bash
apt remove -y tree
which tree  # Should return nothing
```

24. Reinstall the package:
```bash
apt install -y tree
which tree
```

25. Completely remove a package (including configuration):
```bash
apt purge -y tree
```

26. Verify removal:
```bash
dpkg -l | grep tree
```

### Part 6: Working with Services

27. Check if systemd is available:
```bash
which systemctl
ps -p 1
```

Note: In Docker containers, systemd may not be running. The following commands demonstrate the syntax, but may not work in all container environments.

28. List all services:
```bash
systemctl list-units --type=service --all 2>/dev/null || echo "systemd not available in this container"
```

29. Check status of a service (if available):
```bash
systemctl status cron 2>/dev/null || service cron status 2>/dev/null || echo "Service management limited in container"
```

30. For demonstration, let's work with a simple process:
```bash
# Start a background process
nohup sleep 1000 > /dev/null 2>&1 &
SLEEP_PID=$!
echo "Started process with PID: $SLEEP_PID"

# Check if it's running
ps -p $SLEEP_PID

# Stop the process
kill $SLEEP_PID

# Verify it's stopped
ps -p $SLEEP_PID || echo "Process stopped"
```

### Part 7: Package Information and History

31. View package installation history:
```bash
grep " install " /var/log/dpkg.log | tail -10
```

32. View package removal history:
```bash
grep " remove " /var/log/dpkg.log | tail -10
```

33. Check disk space used by packages:
```bash
du -sh /var/cache/apt/archives/
```

34. List files installed by a package:
```bash
dpkg -L curl | head -20
```

35. Find which package owns a file:
```bash
dpkg -S /usr/bin/curl
```

### Part 8: Advanced Package Operations

36. Hold a package at current version (prevent upgrades):
```bash
apt-mark hold curl
apt-mark showhold
```

37. Unhold the package:
```bash
apt-mark unhold curl
apt-mark showhold
```

38. Simulate package installation:
```bash
apt install --simulate nginx
```

39. View package changelog:
```bash
apt changelog curl 2>/dev/null | head -30 || echo "Changelog not available"
```

40. Check for broken dependencies:
```bash
apt check
```

## Expected Output

**After updating package list (step 2):**
```
Hit:1 http://archive.ubuntu.com/ubuntu jammy InRelease
Get:2 http://archive.ubuntu.com/ubuntu jammy-updates InRelease [119 kB]
Reading package lists... Done
Building dependency tree... Done
```

**After installing tree (step 7):**
```
Reading package lists... Done
Building dependency tree... Done
The following NEW packages will be installed:
  tree
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
```

**After using tree (step 9):**
```
/etc
├── alternatives
│   ├── README
│   ├── awk -> /usr/bin/mawk
│   └── ...
├── apt
│   ├── apt.conf.d
│   └── sources.list.d
...
```

**After checking package ownership (step 35):**
```
curl: /usr/bin/curl
```

## Verification Steps

Verify your work by checking:
- Package list is updated: `apt update` runs without errors
- Packages are installed: `which htop net-tools` returns paths
- Package was removed: `which tree` returns nothing after removal
- Package cache is clean: `du -sh /var/cache/apt/archives/`
- No broken dependencies: `apt check` reports no issues

## Hints

<details>
<summary>Hint 1: APT vs APT-GET</summary>

- `apt`: Modern, user-friendly interface (recommended for interactive use)
- `apt-get`: Traditional interface (better for scripts)
- `apt-cache`: Search and query package information

Both work, but `apt` provides better output formatting and progress bars.
</details>

<details>
<summary>Hint 2: Common APT Commands</summary>

Essential apt commands:
- `apt update`: Update package lists
- `apt upgrade`: Upgrade installed packages
- `apt install <package>`: Install package
- `apt remove <package>`: Remove package
- `apt purge <package>`: Remove package and config
- `apt search <term>`: Search for packages
- `apt show <package>`: Show package details
- `apt autoremove`: Remove unnecessary packages
- `apt clean`: Clean package cache
</details>

<details>
<summary>Hint 3: Package States</summary>

Package states in dpkg:
- `ii`: Installed and configured
- `rc`: Removed but config files remain
- `un`: Unknown/not installed
- `iU`: Installed but not configured

View with: `dpkg -l | grep <package>`
</details>

<details>
<summary>Hint 4: Service Management</summary>

Systemd service commands (when available):
- `systemctl start <service>`: Start service
- `systemctl stop <service>`: Stop service
- `systemctl restart <service>`: Restart service
- `systemctl status <service>`: Check status
- `systemctl enable <service>`: Enable at boot
- `systemctl disable <service>`: Disable at boot

In containers without systemd, use `service` command or manage processes directly.
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Complete solution with all commands:

```bash
# Access container
docker exec -it devops-ubuntu bash

# Part 1: Understanding Package Management
apt update
apt list --upgradable
apt search htop
apt show curl
dpkg -l | grep curl

# Part 2: Installing Packages
apt install -y tree
which tree
tree --version
cd /etc
tree -L 2
apt install -y htop net-tools dnsutils
which htop netstat dig

# Part 3: Managing Packages
apt list --installed | head -20
apt depends curl
apt rdepends curl
cd /tmp
apt download wget
ls -lh wget*.deb
dpkg -c wget*.deb | head -20

# Part 4: Updating and Upgrading
apt update
apt upgrade --dry-run
apt upgrade -y
apt dist-upgrade --dry-run
apt clean
apt autoclean
apt autoremove -y

# Part 5: Removing Packages
apt remove -y tree
which tree
apt install -y tree
apt purge -y tree
dpkg -l | grep tree

# Part 6: Working with Services
which systemctl
ps -p 1
systemctl list-units --type=service --all 2>/dev/null || echo "systemd not available"
nohup sleep 1000 > /dev/null 2>&1 &
SLEEP_PID=$!
echo "Started process with PID: $SLEEP_PID"
ps -p $SLEEP_PID
kill $SLEEP_PID
ps -p $SLEEP_PID || echo "Process stopped"

# Part 7: Package Information
grep " install " /var/log/dpkg.log | tail -10
grep " remove " /var/log/dpkg.log | tail -10
du -sh /var/cache/apt/archives/
dpkg -L curl | head -20
dpkg -S /usr/bin/curl

# Part 8: Advanced Operations
apt-mark hold curl
apt-mark showhold
apt-mark unhold curl
apt install --simulate nginx
apt check
```

**Explanation:**

- `apt update`: Downloads package lists from repositories
- `apt upgrade`: Installs newer versions of installed packages
- `apt install`: Installs new packages
- `apt remove`: Removes packages but keeps configuration
- `apt purge`: Removes packages and configuration files
- `apt autoremove`: Removes packages that were installed as dependencies but are no longer needed
- `apt clean`: Removes downloaded package files from cache
- `dpkg`: Low-level package manager
- `dpkg -l`: Lists installed packages
- `dpkg -L`: Lists files installed by package
- `dpkg -S`: Finds package that owns a file
- `apt-mark hold`: Prevents package from being upgraded
- `systemctl`: Controls systemd services (when available)
- `/var/log/dpkg.log`: Package management history
</details>

## Additional Resources

- [APT User Guide](https://www.debian.org/doc/manuals/apt-guide/)
- [Ubuntu Package Management](https://ubuntu.com/server/docs/package-management)
- [Systemd Service Management](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
- [DPKG Documentation](https://www.dpkg.org/doc/)
