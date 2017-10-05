#!/bin/bash
# -----------------------------------------------------------
# githump clones all repositories for a specified user/org
# then extracts all unique authors from the commit history.
# -----------------------------------------------------------


# -----------------------------------------------------------
# color configuration
# -----------------------------------------------------------
blue=$(tput setaf 4)
green=$(tput setaf 2)
red=$(tput setaf 1)
rst=$(tput sgr0)

error="$red-$rst"
info="$blue*$rst"
success="$green+$rst"


# -----------------------------------------------------------
# runtime configuration
# -----------------------------------------------------------
count=0
temp_dir="/tmp/githump"


# -----------------------------------------------------------
# utility logging functions
# -----------------------------------------------------------
function log_error() {
  echo "[$error] ${1}"
}

function log_info() {
  echo "[$info] ${1}"
}

function log_success() {
  echo "[$success] ${1}"
}


# -----------------------------------------------------------
# welcome banner
# -----------------------------------------------------------
function welcome() {
  log_success "githump: Loaded at $(date)"
}


# -----------------------------------------------------------
# print usage and exit
# -----------------------------------------------------------
function usage() {
  log_error "Missing required target organization or user."
  log_error "Org or user is the account name from https://github.com/<user>"
  log_error "Example: $0 rapid7 (for https://github.com/rapid7)"
  log_error "Usage:   $0 <org|user>"
  exit 1
}


# -----------------------------------------------------------
# grab the list of repos via the /orgs api
# -----------------------------------------------------------
function get_org_emails() {
  curl -s "https://api.github.com/orgs/${1}/repos" | grep html_url | sort | uniq | awk -F \" '{print $4}' | tail -n +2 | while read repo; do
    # -----------------------------------------------------------
    # set up the results directory and file
    # -----------------------------------------------------------
    repo_dir=$(basename "${repo}")
    output_dir="${temp_dir}/${1}/${repo_dir}"
    output_file="${output_dir}/${repo_dir}.results"
    mkdir -p "${output_dir}"

    # -----------------------------------------------------------
    # clone the repo and extract email addresses
    # -----------------------------------------------------------
    git clone -n -q "${repo}"
    cd ${repo_dir}
    git log --all | grep "^Author:" | sort | uniq | egrep -o "\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\b" >> "${output_file}"

    # -----------------------------------------------------------
    # update user with status
    # -----------------------------------------------------------
    total=$(git log --all | grep "^Author:" | sort | uniq | egrep -o "\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\b" | wc -l)
    [ $total -gt 0 ] && log_success "Dumped ${total} email addresses to ${output_file}"

    # -----------------------------------------------------------
    # remove the repo
    # -----------------------------------------------------------
    cd ..
    rm -rf "${repo_dir}" 
  done
}


# -----------------------------------------------------------
# grab the list of repos via the /orgs api
# -----------------------------------------------------------
function get_user_emails() {
  curl -s "https://api.github.com/users/${1}/repos" | grep html_url | sort | uniq | awk -F \" '{print $4}' | tail -n +2 | while read repo; do
    # -----------------------------------------------------------
    # set up the results directory and file
    # -----------------------------------------------------------
    repo_dir=$(basename "${repo}")
    output_dir="${temp_dir}/${1}/${repo_dir}"
    output_file="${output_dir}/${repo_dir}.results"
    mkdir -p "${output_dir}"

    # -----------------------------------------------------------
    # clone the repo and extract email addresses
    # -----------------------------------------------------------
    git clone -n -q "${repo}"
    cd ${repo_dir}
    git log --all | grep "^Author:" | sort | uniq | egrep -o "\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\b" >> "${output_file}"

    # -----------------------------------------------------------
    # update user with status
    # -----------------------------------------------------------
    total=$(git log --all | grep "^Author:" | sort | uniq | egrep -o "\b[a-zA-Z0-9.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z0-9.-]+\b" | wc -l)
    [ $total -gt 0 ] && log_success "Dumped ${total} email addresses to ${output_file}"

    # -----------------------------------------------------------
    # remove the repo
    # -----------------------------------------------------------
    cd ..
    rm -rf "${repo_dir}" 
  done
}


# -----------------------------------------------------------
# display welcome message
# -----------------------------------------------------------
welcome

# -----------------------------------------------------------
# print usage and exit if no targets specified
# -----------------------------------------------------------
[ $# -eq 0 ] && usage


# -----------------------------------------------------------
# begin the acquisition
# -----------------------------------------------------------
mkdir -p results
for target in ${BASH_ARGV[*]}; do
  # -----------------------------------------------------------
  # collect the emails from the repositories
  # -----------------------------------------------------------
  log_info "Beginning collection for $target.  This may take a while."
  get_org_emails $target
  get_user_emails $target

  # -----------------------------------------------------------
  # accumulate all the unique emails
  # -----------------------------------------------------------
  address_count=$(find "${temp_dir}/${target}" -name "*.results" -type f -exec cat "{}" + | sort | uniq | wc -l)
  find "${temp_dir}/${target}" -name "*.results" -type f -exec cat "{}" + | sort | uniq >> "./results/${target}.txt"
  rm -rf "${temp_dir}/${target}"
  log_success "Collected ${address_count} emails for $target, stored in ./results/${target}.txt"

  # -----------------------------------------------------------
  # update user with number of targets remaining
  # -----------------------------------------------------------
  count=$(($count + 1))
  log_info "$(($# - ${count})) remaining."
done

# -----------------------------------------------------------
# clean up the working directory and exit
# -----------------------------------------------------------
rm -rf "${temp_dir}"
exit 0
