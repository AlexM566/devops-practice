# Linux User and Group Management

**Difficulty:** Beginner
**Estimated Time:** 30 minutes
**Prerequisites:** Basic command line familiarity, understanding of file permissions

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to create and manage users and groups in Linux, understand user information storage, and work with sudo privileges. By the end of this exercise, you'll be able to manage user accounts and control access to system resources.

## Instructions

### Part 1: Understanding Current User

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-ubuntu bash
```

2. Check your current username:
```bash
whoami
```

3. View detailed information about your user:
```bash
id
```

4. View all groups you belong to:
```bash
groups
```

5. View information about a specific user:
```bash
id root
finger root  # If available
```

### Part 2: Creating Users

6. Create a new user called `testuser`:
```bash
useradd -m -s /bin/bash testuser
```

7. Set a password for the new user:
```bash
passwd testuser
# Enter password: test123
# Confirm password: test123
```

8. View the user's entry in /etc/passwd:
```bash
grep testuser /etc/passwd
```

9. View the user's home directory:
```bash
ls -la /home/testuser
```

10. Create another user with more options:
```bash
useradd -m -s /bin/bash -c "Developer Account" devuser
passwd devuser
# Enter password: dev123
```

### Part 3: Managing Groups

11. View all groups on the system:
```bash
cat /etc/group | tail -20
```

12. Create a new group called `developers`:
```bash
groupadd developers
```

13. Add testuser to the developers group:
```bash
usermod -aG developers testuser
```

14. Verify the user was added to the group:
```bash
groups testuser
id testuser
```

15. Add devuser to the developers group as well:
```bash
usermod -aG developers devuser
groups devuser
```

16. Create a shared directory for the developers group:
```bash
mkdir /home/shared
chgrp developers /home/shared
chmod 770 /home/shared
ls -ld /home/shared
```

### Part 4: Switching Users

17. Switch to the testuser account:
```bash
su - testuser
```

18. Verify you're now testuser:
```bash
whoami
pwd
```

19. Try to access root-only files (this should fail):
```bash
cat /etc/shadow
```

20. Exit back to root:
```bash
exit
```

### Part 5: Sudo Access

21. Try running a command as testuser with sudo (this should fail):
```bash
su - testuser
sudo ls /root
exit
```

22. Add testuser to the sudo group:
```bash
usermod -aG sudo testuser
```

23. Verify sudo access (you may need to log out and back in):
```bash
su - testuser
sudo ls /root
# Enter password when prompted
exit
```

24. View the sudoers configuration:
```bash
cat /etc/sudoers | grep -v "^#" | grep -v "^$"
```

### Part 6: Modifying and Deleting Users

25. Change testuser's shell:
```bash
usermod -s /bin/sh testuser
grep testuser /etc/passwd
```

26. Lock a user account:
```bash
passwd -l devuser
```

27. Unlock the user account:
```bash
passwd -u devuser
```

28. Delete a user (keeping home directory):
```bash
userdel testuser
ls /home/
```

29. Delete a user and their home directory:
```bash
userdel -r devuser
ls /home/
```

30. Remove the developers group:
```bash
groupdel developers
```

## Expected Output

**After checking current user (step 2-4):**
```
root
uid=0(root) gid=0(root) groups=0(root)
root
```

**After creating user (step 8):**
```
testuser:x:1001:1001::/home/testuser:/bin/bash
```

**After adding user to group (step 14):**
```
testuser : testuser developers
uid=1001(testuser) gid=1001(testuser) groups=1001(testuser),1002(developers)
```

**After switching users (step 18):**
```
testuser
/home/testuser
```

## Verification Steps

Verify your work by checking:
- Users were created: `cat /etc/passwd | grep testuser`
- Groups were created: `cat /etc/group | grep developers`
- User belongs to correct groups: `groups testuser`
- Shared directory has correct permissions: `ls -ld /home/shared`
- Users were deleted: `ls /home/` should not show deleted users

## Hints

<details>
<summary>Hint 1: Understanding /etc/passwd</summary>

The /etc/passwd file format:
```
username:x:UID:GID:comment:home_directory:shell
```

- username: login name
- x: password placeholder (actual password in /etc/shadow)
- UID: user ID number
- GID: primary group ID number
- comment: user description
- home_directory: path to home directory
- shell: default shell
</details>

<details>
<summary>Hint 2: useradd vs adduser</summary>

- `useradd`: low-level utility, requires manual setup
- `adduser`: high-level script, interactive and user-friendly
- `useradd -m`: creates home directory
- `useradd -s /bin/bash`: sets default shell
- `useradd -c "comment"`: adds user description
</details>

<details>
<summary>Hint 3: usermod Options</summary>

Common usermod options:
- `-aG group`: add user to supplementary group (append)
- `-G group`: set user's supplementary groups (replace)
- `-s shell`: change user's shell
- `-d directory`: change home directory
- `-l newname`: change username
- `-L`: lock account
- `-U`: unlock account
</details>

<details>
<summary>Hint 4: Sudo Configuration</summary>

Sudo access can be granted by:
1. Adding user to sudo group: `usermod -aG sudo username`
2. Editing /etc/sudoers with visudo command
3. Creating file in /etc/sudoers.d/ directory

Always use `visudo` to edit sudoers file to prevent syntax errors.
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Complete solution with all commands:

```bash
# Access container
docker exec -it devops-ubuntu bash

# Part 1: Understanding Current User
whoami
id
groups
id root

# Part 2: Creating Users
useradd -m -s /bin/bash testuser
passwd testuser
# Enter: test123
grep testuser /etc/passwd
ls -la /home/testuser
useradd -m -s /bin/bash -c "Developer Account" devuser
passwd devuser
# Enter: dev123

# Part 3: Managing Groups
cat /etc/group | tail -20
groupadd developers
usermod -aG developers testuser
groups testuser
id testuser
usermod -aG developers devuser
groups devuser
mkdir /home/shared
chgrp developers /home/shared
chmod 770 /home/shared
ls -ld /home/shared

# Part 4: Switching Users
su - testuser
whoami
pwd
cat /etc/shadow  # Should fail
exit

# Part 5: Sudo Access
su - testuser
sudo ls /root  # Should fail
exit
usermod -aG sudo testuser
su - testuser
sudo ls /root  # Should work after entering password
exit
cat /etc/sudoers | grep -v "^#" | grep -v "^$"

# Part 6: Modifying and Deleting Users
usermod -s /bin/sh testuser
grep testuser /etc/passwd
passwd -l devuser
passwd -u devuser
userdel testuser
ls /home/
userdel -r devuser
ls /home/
groupdel developers
```

**Explanation:**

- `whoami`: displays current username
- `id`: shows user ID, group ID, and all groups
- `useradd`: creates new user account
- `-m`: creates home directory
- `-s`: specifies default shell
- `-c`: adds comment/description
- `passwd`: sets or changes user password
- `groupadd`: creates new group
- `usermod -aG`: adds user to group (append)
- `su - username`: switch to user with their environment
- `sudo`: execute command as another user (usually root)
- `userdel`: deletes user account
- `-r`: removes home directory and mail spool
- `groupdel`: deletes group
- `/etc/passwd`: user account information
- `/etc/shadow`: encrypted passwords
- `/etc/group`: group information
</details>

## Additional Resources

- [Linux User Management Guide](https://www.digitalocean.com/community/tutorials/how-to-add-and-delete-users-on-ubuntu-20-04)
- [Understanding /etc/passwd](https://www.cyberciti.biz/faq/understanding-etcpasswd-file-format/)
- [Sudo Configuration Guide](https://www.sudo.ws/docs/man/sudoers.man/)
- [Linux Groups Explained](https://www.redhat.com/sysadmin/linux-groups)
