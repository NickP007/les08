#!/bin/sh
#
# An example hook script to verify what is about to be committed.
# Called by "git commit" with no arguments.  The hook should
# exit with non-zero status after issuing an appropriate message if
# it wants to stop the commit.
#

gitleaksEnabled() {
#    """Determine if the pre-commit hook for gitleaks is enabled."""
  gl_config=$(git config hooks.gitleaks)
  if [ "$gl_config" = "enable" ]; then
    return 1
  fi
  return 0
}

gitleaksCheck() {
  gl_res=0
  cur_ext="tar.gz"
  gl_url="https://github.com/gitleaks/gitleaks"
  targ_os=$(uname -s | tr '[:upper:]' '[:lower:]')
  targ_arch=$(uname -m | tr '[:upper:]' '[:lower:]')
  len_targ_os=${#targ_os}
  if [ $len_targ_os -gt 7 ]; then 
    if [ "$targ_os#mingw64" != "$targ_os" ]; then
      targ_os="mingw64"
    elif [ "$targ_os#darwin" != "$targ_os" ]; then
      targ_os="darwin"
    elif [ "$targ_os#linux" != "$targ_os" ]; then
      targ_os="linux"
    fi
  fi
  echo "os=$targ_os, arch=$targ_arch"
  case "$targ_os" in
    "linux" )                       cur_os="linux";;
    "darwin" )                      cur_os="darwin";;
    "mingw64" | "win" | "windows" ) cur_os="windows"; cur_ext="zip";;
    * )                             cur_os="unknown";;
  esac
  case "$targ_arch" in
    "i386" | "i686" | "x32" | "x86" ) cur_arch="x32";;
    "amd64" | "x86_64" )              cur_arch="x64";;
    "arm64" | "aarch64" )             cur_arch="arm64";;
    * )                               cur_arch="unknown";;
  esac
  if [ "$cur_os" = "unknown" -o "$cur_arch" = "unknown" ]; then
    echo "Unable to determined system OS or Arch. Commit command will be stopped."
    exit 1
  fi
  tmp_dir=$(mktemp -d)
  if [ "$(git remote -v | grep $gl_url | wc -l)" = "0" ]; then
    git remote add gitleaks $gl_url
  fi
  gl_tag=$(git fetch gitleaks --tags && git tag | sort -V | tail -1)
  gl_file_name="gitleaks_${gl_tag#v}_${cur_os}_${cur_arch}.${cur_ext}"
  gl_file_url="${gl_url}/releases/download/${gl_tag}/${gl_file_name}"
  if [ $cur_os = "windows" ]; then
    curl -k -o "${tmp_dir}/${gl_file_name}" -L $gl_file_url
    unzip "${tmp_dir}/${gl_file_name}" -d "${tmp_dir}"
    "${tmp_dir}/gitleaks.exe" protect -v --staged --redact
  else
    curl -k -L $gl_file_url | tar -C $tmp_dir -xz
    "${tmp_dir}/gitleaks" protect -v --staged --redact
  fi
  if [ "$?" != "0" ]; then
    echo "
Warning: gitleaks has detected sensitive information in your changes.
To disable the gitleaks precommit hook run the following command:

    git config hooks.gitleaks disable"
    gl_res=1
  fi
  rm -rf $tmp_dir
  return $gl_res
}

echo "-= start pre-commit hook =-"
gitleaksEnabled
if [ $? -eq 1 ]; then
  gitleaksCheck
  if [ $? -eq 1 ]; then exit 1; fi
else
  echo "gitleaks precommit disabled
(enable with 'git config hooks.gitleaks enable')"
fi
echo "-= end pre-commit hook =-"
