#!/bin/bash

############################################################
# Check out whether Sun Grid Engine is installed or not.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   check_flag
############################################################
  function check_sungridengine() {
  check_flag=`which qstat >& /dev/null; echo $?` # is installed if output is 0
  echo ${check_flag}
}

############################################################
# Determine the risk by counting how many slots are used
# and assign the bar color:
# (low risk) green - blue - cyan - yellow - red (high risk)
# Globals:
#   None
# Arguments:
#   risk_ratio
# Outputs:
#   bg_fg_color
############################################################
  function risk_measure() {
  use_ratio=$1
  if [[ ${use_ratio} -gt 80 ]]; then
    bg_fg_color=31,41 # red (high risk)
    echo ${bg_fg_color}
  elif [[ ${use_ratio} -gt 60 ]]; then
    bg_fg_color=33,43 # yellow
    echo ${bg_fg_color}
  elif [[ ${use_ratio} -gt 40 ]]; then
    bg_fg_color=36,46 # cyan
    echo ${bg_fg_color}
  elif [[ ${use_ratio} -gt 20 ]]; then
    bg_fg_color=34,44 # blue
    echo ${bg_fg_color}
  else
    bg_fg_color=32,42 # green
    echo ${bg_fg_color}
  fi 
}

##############################################
# Check all queue (and node) status
# and make it easy to figure out at a glance.
# Globals:
#   node_number
# Arguments:
#   None
# Outputs:
#   print out queue status in 'queue_status'
##############################################
  function analysis_queue() {
  node_number=`qstat -f | sed '/-\+-/d' | sed '/BIP\|queuename/!d' | wc -l`
  node_count=0
  qstat -f | sed '/-\+-/d' | sed 's/ \+ /\t/g' | sed '/BIP\|queuename/!d' |
  while IFS= read -r line
  do
    if [[ $line == *"queuename"* ]]; then
      queue_status=''
      node_count=`expr $node_count + 1`
      queue_status=`printf '\n%-16s | %-16s | %-50s | %-16s | %-5s |\n' \
	      'Queue Name' 'Node' 'Slot Use Ratio' 'Use/Total(pct)' 'Load Ave.'`
      continue
    else
      name=`echo  ${line} | cut -d' ' -f1`
      slot=`echo  ${line} | cut -d' ' -f3`
      load=`echo  ${line} | cut -d' ' -f4`

      if [[ $line == *"@"* ]]; then # when a queue is consist of nodes
        queue_name=`echo ${name} | cut -d'@' -f1`
        node_name=`echo ${name} | cut -d'@' -f2`
      else # when only queue exists
        queue_name=${name}
	node_name=${name}
      fi

      used_slot=`echo ${slot} | cut -d'/' -f2`
      total_slot=`echo ${slot} | cut -d'/' -f3`
      slot_usage_ratio=`echo "scale=3;$used_slot / $total_slot" \* 100 | bc`
      print_slot_usage_ratio=`printf %.1f ${slot_usage_ratio}`
      risk_ratio=`printf %.0f ${slot_usage_ratio}`
      tr_slot_usage_ratio=`echo "$slot_usage_ratio" / 2 | bc`\
      # ratio reduction from 100 to 50 for space

      rist_fg_color=`echo $(risk_measure ${risk_ratio}) | cut -d',' -f1`     
      risk_bg_color=`echo $(risk_measure ${risk_ratio}) | cut -d',' -f2`
      bar_slot_usage_ratio=`echo $(for i in $(seq 1 ${tr_slot_usage_ratio}); \
      do printf "\033[${rist_fg_color};${risk_bg_color}m■\033[0m"; done)`
      remain_slot_usage_ratio=`echo "50 - ${tr_slot_usage_ratio}" | bc`
      bar_remain_slot_usage_ratio=`echo $(for i in $(seq 1 ${remain_slot_usage_ratio}); \
      do printf "□"; done)`
      ratio=$bar_slot_usage_ratio$bar_remain_slot_usage_ratio

      slot_num=${used_slot}/${total_slot}"("$print_slot_usage_ratio"%%)"
      queue_status=${queue_status}'\n'`printf '%-16s | %-16s | %-120s | %-17s | %-9s |\n' \
	      ${queue_name} ${node_name} ${ratio} ${slot_num} ${load}`
      node_count=`expr $node_count + 1`
    fi
    if [[ ${node_number} -eq ${node_count} ]]; then
      printf "${queue_status}"
    fi
  done
}

main() {
  clear
  check_flag=$(check_sungridengine)
  if [[ ${check_flag} -eq 0 ]]; then
    :
  else
    printf '\nSun Grid Engine is not installed.\n'
    exit
  fi
  while true;
  do
    analysis_queue
    sleep 0.01 # refresh interval
    printf "\033[${node_number}A"
  done
}
main "$0"
