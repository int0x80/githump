# githump

Simple bash script that loots email addresses from commit entries.  Email addresses are set via user config when pushing changes up to github.  Running `git log` against a repository shows a list of commits, from which email addresses can be parsed.  The `githump` script enumerates all repositories for a target organization or user and then extracts email addresses from the commit logs of each repository.  Finally, all unique emails are extracted from the intermediary results and saved off in the `results` directory.

# Usage

Usage is easy:  `./githump.sh <target>` where `<target>` is the github account username.  For example, `./githump.sh SalesforceEng` to target everything at https://github.com/SalesforceEng.

# TODO

Future improvements to be enumerated here.

## Historical Aggregation

This is more of a documentation and calling issue.  Write up instructions for running as a repeated task and collecting email addresses historically.  This could be done by pushing result commits up to bitbucket or another version control repository.

## New Results Only

The JSON results from the github API include an `updated_at` key-value pair.  If running `githump` daily and aggregating results, a check should be added to only clone and search repositories that have been updated since the previous run.

