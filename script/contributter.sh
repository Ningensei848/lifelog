#!/bin/bash
#
# Original: from https://github.com/eggplants/contributter.sh
# ===============================================================
# The MIT License
#
# See also:
#   - [Contributter](https://contributter.potato4d.me)
#   - [potato4d/contributter: Evergreen for you.](https://github.com/potato4d/contributter)


usage(){
cat<<'A'
contributter - Contributter(https://contributter.potato4d.me) on Tarminal
Usage: contributter <GH-USERNAME> <DAY-BEFORE>
Args:
- GH-USERNAME GitHub's Username
- DAY-BEFORE  n days ago (default: 1)
A
}

contributter(){
  { (($#<1)) || (($#>2));} && usage && return 1

  local user="$1" day_before="${2-1}"
  echo "${user} さんの $(
    date +%Y/%m/%d -d "${day_before} day ago"
  ) の contribution 数: $(
    curl -s https://github.com/${user} \
      | tac \
      | grep ContributionCalendar-day \
      | sed -nr "$[6+day_before]s/.*data-count=\"([0-9]+)\".*/\\1/p"
  ) #contributter_report"
}

contributter $@
exit $?