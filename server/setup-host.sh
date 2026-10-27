#!/bin/sh
# Turn a fresh Ubuntu 24.04 x86_64 VM into the SSH playground server.
#
# Usage (as root, from a checkout of this repo on the VM):
#   sudo sh server/setup-host.sh <password-for-play-account>
#
# Attendees then run `ssh play@<vm-address>` with that password.
# Make sure your own SSH key works first: password logins are turned off
# for every account except play.

set -eu

die() { printf 'error: %s\n' "$1" >&2; exit 1; }

[ "$(id -u)" = 0 ] || die "run as root"
[ $# = 1 ] || die "usage: $0 <password-for-play-account>"
PASSWORD="$1"
REPO="$(cd "$(dirname "$0")/.." && pwd)"

apt-get update
# The Dockerfile needs BuildKit (ADD --chmod, ADD of a git URL), which comes
# from the buildx plugin; BuildKit shells out to git for the git ADD.
apt-get install -y docker.io docker-buildx git
systemctl enable --now docker

# The image is built from container/ alone: Dockerfile plus the home/ files
docker build -t playground "$REPO/container"

id play >/dev/null 2>&1 || useradd -m -s /bin/sh play
printf 'play:%s\n' "$PASSWORD" | chpasswd

install -m 755 "$REPO/server/playground-shell" /usr/local/bin/playground-shell
printf 'play ALL=(root) NOPASSWD: /usr/local/bin/playground-shell\n' > /etc/sudoers.d/playground
chmod 440 /etc/sudoers.d/playground
visudo -cf /etc/sudoers.d/playground

# PerSourcePenalties only exists in OpenSSH 9.8+ (Ubuntu 24.04 ships 9.6);
# drop it if this sshd doesn't know the option, or sshd -t would fail.
SSHD_CONF=/etc/ssh/sshd_config.d/10-playground.conf
# sshd -t needs this, and with socket activation it may not exist yet
mkdir -p /run/sshd
if sshd -t -o PerSourcePenalties=no 2>/dev/null; then
  install -m 644 "$REPO/server/sshd-playground.conf" "$SSHD_CONF"
else
  grep -v '^PerSourcePenalties' "$REPO/server/sshd-playground.conf" > "$SSHD_CONF"
  chmod 644 "$SSHD_CONF"
fi
sshd -t
systemctl restart ssh

printf 'Playground ready: ssh play@<this-host>\n'
