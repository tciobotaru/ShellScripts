#!/bin/bash
#Exercise 6

output_file="system_report.txt"
external_ip()
{
    ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)|| \
    ip="Unable to determine"
    echo "$ip"
}
is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

get_memory_info() {
    if is_macos; then
        echo "   $(top -l 1 | grep -E "^PhysMem" | sed 's/PhysMem://')"
    else
     
        echo "   Total RAM: $(free -h | awk '/Mem:/ {print $2}')"
        echo "   Used RAM: $(free -h | awk '/Mem:/ {print $3}')"
        echo "   Free RAM: $(free -h | awk '/Mem:/ {print $4}')"
        echo "   Available: $(free -h | awk '/Mem:/ {print $7}')"
    fi
}



{

  echo "------------------------------"
  echo "          SYSTEM REPORT"
  echo "------------------------------" 
  echo "1.DATE AND TIME:$(date)"\
  echo ""
  echo "2.USER INFO"
  echo "Username: $(whoami)"
  echo "USER ID: $(id -u)"
  echo "GROUPS: $(groups $(whoami))"
  echo""
  echo "3.NETWORK INFORMATION"
  echo "Hosname: $(hostname)"
  if is_macos; then
  echo "Internal IP: $(ipconfig getifaddr en0)"
  else
  echo "Internal IP: $(ip addr show | grep 'inet '|grep -v '127.0.0.1'|awk '{print $2}'|head -n1) "
  fi
  external_ip
  echo ""
  echo "4. OPERATING SYSTEM"
  echo "$(sw_vers)"
  echo "5. SYSTEMUPTIME:"
  echo "$(uptime)"
  echo ""
  echo "6.DISK USAGE:"
  echo "$(df -h)"
  echo ""
  echo "7.MEMORY INFORMATION:"
  get_memory_info
  echo ""
  echo "8. PROCESSOR INFORMATION:"
  echo "$(sysctl -n machdep.cpu.brand_string)"
  echo "Number of cores: $(sysctl -n hw.ncpu)"
  echo ""
  echo "9.ADDITIONAL INFORMATION:"
  echo "Kernet Version: $(uname -r)"
  echo "Arhitecture $(uname -m)"  


} | tee $output_file

echo "Raport generated in $output_file"
