# git-identity

A shell script to quickly switch your Git author identity between two accounts — useful when working across personal and work/university repos on the same machine.

---

## Problem

Git uses a single global identity (`~/.gitconfig`) for all repos by default. If you have two accounts — personal and work/university — every commit you make will be authored under the same name and email, regardless of which project you're in.

This causes:
- Work/university commits showing your personal email (or vice versa)
- GitHub contribution graphs attributed to the wrong account
- No easy way to switch without manually running `git config` every time

## Solution

`git-identity` wraps Git's local config scope into two simple commands. Instead of remembering the `git config --local user.email` syntax, you run one command per repo once — and Git handles the rest automatically for every commit in that repo.

---

## Installation (run globally from anywhere)

Copy the script to a directory on your `$PATH`:

```bash
cp git-identity.sh ~/.local/bin/git-identity
chmod +x ~/.local/bin/git-identity
```

Make sure `~/.local/bin` is in your `PATH`. Add this to your `~/.bashrc` or `~/.zshrc` if it isn't:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then reload your shell:

```bash
source ~/.bashrc   # or source ~/.zshrc
```

Now you can run `git-identity` from any directory.

---

## Configuration

Before using, open the script and set your two identities at the top:

```bash
# Global / personal identity (default)
U1_NAME="Your Name"
U1_EMAIL="you@personal.com"

# Local / alternate identity (e.g. work or university)
U2_NAME="Your Name"
U2_EMAIL="you@work.com"
```

> Do not commit the script with real emails. Add it to `.gitignore` or use placeholder values in a shared version.

---

## Usage

```
git-identity [local|global|status]
```

| Command | What it does |
|---|---|
| `git-identity local` | Sets this repo's identity to the **alternate** account (U2) |
| `git-identity global` | Clears the local override — falls back to **global** account (U1) |
| `git-identity status` | Shows the effective, local, and global identity for the current repo |
| `git-identity` | Shows this help |

---

## How it works

Git resolves identity in this order — the most specific scope wins:

```
system  (~lowest priority)
  └── global  (~/.gitconfig)
        └── local  (.git/config)  ← wins
```

- `git-identity local` writes `user.name` and `user.email` into `.git/config` of the current repo only. No other repo is affected.
- `git-identity global` removes those local entries, so Git falls back to `~/.gitconfig`.

---

## Examples

```bash
# Inside a university project repo
cd ~/projects/uni-assignment
git-identity local    # switch to university email for this repo only

# Check what identity will be used
git-identity status

# Done with the project, reset to personal
git-identity global
```

---

## Notes

- Requires `bash` and `git` to be installed.
- Must be run from inside a Git repository for `local`, `global`, and `status` commands.
- In detached HEAD state, `status` will show the short commit SHA as the branch.
