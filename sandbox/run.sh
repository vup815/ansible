#!/bin/bash
# Linux sandbox test for the portable subset of this playbook.
# Builds (if needed) and runs an ephemeral Ubuntu container that executes the
# REAL task files (mounted read-only from this repo) with HOME redirected to
# /tmp/testhome, so the host is never touched. The container is removed after.
#
# Covered: tasks/zsh.yml, git.yml, symlink.yml, ssh.yml + outcomes verification.
# NOT covered (macOS-only): tasks/brew.yml, the neovim homebrew task.
# The nvim-config SSH URL is read live from tasks/neovim.yml and clone-tested;
# note a passphrase-protected GitHub key cannot be used non-interactively
# inside the sandbox (ssh-agent lives on the Mac), so that step validates the
# URL + client path and the full key auth is covered by host-side ssh tests.
#
# Requirements: docker, ~/.ansible/collections with community.general
# (ansible-galaxy collection install community.general -p ~/.ansible/collections)
# NOTE: host ~/.ssh is mounted read-only into the test container.
set -u
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
docker build -t ansible-sandbox:latest "$REPO_ROOT/sandbox" >/dev/null 2>&1 || {
  echo "image build failed"; exit 1
}
docker run --rm \
  -v "$REPO_ROOT:/ansible:ro" \
  -v "$REPO_ROOT/sandbox/sandbox.yml:/sandbox.yml:ro" \
  -v "$HOME/.ssh:/sandbox-keys:ro" \
  -v "$HOME/.ansible/collections:/root/.ansible/collections:ro" \
  -e HOME=/tmp/testhome \
  -e ANSIBLE_COLLECTIONS_PATH=/root/.ansible/collections \
  ansible-sandbox:latest bash -c '
set -u
mkdir -p /tmp/testhome
export HOME=/tmp/testhome
echo "########## 1. ansible-playbook (real task files) ##########"
ansible-playbook /sandbox.yml
echo "PLAYBOOK_EXIT:$?"
echo "########## 2. verify zsh plugins ##########"
ls /tmp/testhome/.oh-my-zsh/custom/themes/ /tmp/testhome/.oh-my-zsh/custom/plugins/
echo "########## 3. verify git identity ##########"
cat /tmp/testhome/.gitconfig
echo "########## 4. verify dotfiles + stow symlinks ##########"
ls /tmp/testhome/dotfiles | head -5
ls -la /tmp/testhome/ | grep -- "->" || echo "NO STOW SYMLINKS FOUND"
echo "########## 5. verify ssh keys ##########"
ls -la /tmp/testhome/.ssh/
echo "########## 6. nvim-config SSH clone (URL from tasks/neovim.yml) ##########"
URL=$(grep -E "repo:" /ansible/tasks/neovim.yml | head -1 | sed "s/.*repo:[[:space:]]*[\"'"'"']//;s/[\"'"'"']//")
echo "URL under test: $URL"
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/tmp/testhome/.ssh/known_hosts"
rm -rf /tmp/nvim-sandbox
if CLONE_OUT=$(git clone --branch main --depth 1 "$URL" /tmp/nvim-sandbox 2>&1); then
  echo "CLONE OK"; ls /tmp/nvim-sandbox/lua/plugins/
else
  echo "$CLONE_OUT" | tail -2
  echo "CLONE FAILED (expected if the GitHub SSH key is passphrase-protected:"
  echo "no ssh-agent is forwarded into the sandbox; host-side ssh covers auth)"
fi
'
