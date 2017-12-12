# https://raw.githubusercontent.com/Konstruktionist/fish/master/conf.d/git_helpers.fish
# Building Gary Bernhardt's githelpers bash script in fish
# ========================================================
#
# Log output:
#
# * 51c333e    (12 days)    <Gary Bernhardt>   add vim-eunuch
#
# Branch output:
#
# * release/v1.1    (13 days)    <Leyan Lo>   add pretty_git_branch
#
# The time massaging regexes start with ^[^<]* because that ensures that they
# only operate before the first "<". That "<" will be the beginning of the
# author name, ensuring that we don't destroy anything in the commit message
# that looks like time.
#
# The log format uses ∬ characters between each field, and `column` is later
# used to split on them. A ∬ in the commit subject or any other field will
# break this. (GB used originally the } character, I think that may
# occasionally show up in a commit message)
# -----------------------------------------

set -l ycolor (set_color bryellow)
set -l ncolor (set_color normal)
set -l gcolor (set_color brgreen)
set -l bcolor (set_color blue)
set -l rcolor (set_color brred)

set -l log_hash "$ycolor%h"
set -l log_relative_time "$gcolor(%ar)"
set -l log_author "$bcolor<%an>"
set -l log_refs "$rcolor%d$ncolor"
set -l log_subject "%s"

# Use a special character to separate our fields so strings with spaces in
# them (like names & subjects) will not split on them.
# Character used is ∬ = U+222C (DOUBLE INTEGRAL). I'm fairly sure nobody uses
# that in commit messages.
# DO NOT use it between log_refs and log_subject to prevent hideous whitespace
# problems.

set log_format "$log_hash∬$log_relative_time∬$log_author∬$log_refs $log_subject"

set -l branch_prefix "%(HEAD)"
set -l branch_ref "$rcolor%(refname:short)"
set -l branch_hash "$ycolor%(objectname:short)"
set -l branch_date "$gcolor(%(committerdate:relative))"
set -l branch_author "$bcolor<%(authorname)>$ncolor"
set -l branch_contents "%(contents:subject)"

set branch_format "$branch_prefix∬$branch_ref∬$branch_hash∬$branch_date∬$branch_author∬$branch_contents"

# Logs
function gitl -d 'l = all commits, only current branch'
  # 1st string replace: remove all ' ago' only in date column
  # 2nd string replace: replace (2 years, 5 months) with (2 years)
  # 3rd - 5th string replace: print Merge commit messages in cyan
  # NOTE: to get the merge commit messages printed cyan we can not use the above
  # declared variables rcolor & ncolor. If we do we get an error stating:
  # 'Variables may not be used as commands' or 'string replace: Expected
  # argument"
  git log --graph --pretty="tformat:$log_format" $argv |\
    string replace -r '(^[^<]*)\sago\)' '$1)' |\
    string replace -r ',\s\d+?\s\w+\s?' '' |\
    string replace -r 'Merge branch\s.*' (set_color cyan)'$0'(set_color normal) |\
    string replace -r 'Merge pull request\s.*' (set_color cyan)'$0'(set_color normal) |\
    string replace -r 'Merge remote-tracking branch\s.*' (set_color cyan)'$0'(set_color normal) |\
    # TODO: Ideally these last 3 would be replaced by
    #
    #   string replace -r ([\s]{3}Merge.*) (set_color cyan)'$1'(set_color normal)
    #
    # but somehow fish doesn't understand this and ignores it. There are no
    # error messages, it just ignores the set_color commands & prints the
    # commit message in normal color. It works in RegExR & online regex
    # testers.
    # Needs further investigation.
    column -t -s '∬' |\
    less -FXRS
end

function gitla -d 'la = all commits, all reachable refs'
  gitl --all
end

function gitr -d 'r = recent commits, only current branch'
  gitl -30
end

function gitra -d 'ra = recent commits, all reachable refs'
  gitr --all
end

function gith -d 'h = head'
  gitl -1
end

function githp -d 'hp = head with patch'
  gitl -1
  git show -p --pretty="tformat:"
end

# Branches
#   This follows the same logic as in the Logs section
function gitb -d 'b = all branches'
  git branch -v --format=$branch_format $argv |\
    string replace -r '(^[^<]*)\sago\)' '$1)' |\
    string replace -r ',\s\d+?\s\w+\s?' '' |\
    string replace -r 'Merge branch\s.*' (set_color cyan)'$0'(set_color normal) |\
    string replace -r 'Merge pull request\s.*' (set_color cyan)'$0'(set_color normal) |\
    string replace -r 'Merge remote-tracking branch\s.*' (set_color cyan)'$0'(set_color normal) |\
    column -t -s '∬' | less -FXRS
end

function gitbs -d 'bs = all branches, sorted by last commit date'
  git branch -v --format=$branch_format --sort=-committerdate $argv |\
    string replace -r '(^[^<]*)\sago\)' '$1)' |\
    string replace -r ',\s\d+?\s\w+\s?' '' |\
    string replace -r 'Merge branch\s.*' (set_color cyan)'$0'(set_color normal) |\
    string replace -r 'Merge pull request\s.*' (set_color cyan)'$0'(set_color normal) |\
    string replace -r 'Merge remote-tracking branch\s.*' (set_color cyan)'$0'(set_color normal) |\
    column -t -s '∬' | less -FXRS
end
