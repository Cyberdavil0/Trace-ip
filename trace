#!/bin/bash   

show_help() {
  echo -e "\e[1;31m
┌──────────────────────────────────────────────────┐
│░█▀▀░█░█░█▀▀▄░█▀▀░█▀▄░ :: █▀▄░█░█░█▀▀▄░█▀▄░█▀▀█░   │
│░█░░░░█░░█▀▀▄░█▀▀░█▀▄░ :: █▀▄░█░█░█  █░█▀▄░█▀▀█░   │
│░▀▀▀░░▀░░▀▀▀░░▀▀▀░▀░▀░ :: ▀░▀░▀▀▀░▀▀▀ ░▀░▀░▀░░▀░   │
└──────────────────────────────────────────────────┘\e[0m\n"
  echo -e "\033[1;32mHello everyone\033[0m"
  echo -e "\033[1;34mWelcome to the world of hacking 🌎\033[0m\033[1;31m!\033[0m"
  echo ""
  echo "Usage:"
  echo "  trace -me             → Trace your own IP and device info"
  echo "  trace -t <target>     → Trace target IP or hostname"
  echo "  trace -net            → Scan nearby network devices"
  echo "  trace -w <domain>     → Resolve domain to IP"
  echo "  trace -help           → Show this help message"
}

case "$1" in
  -me) bash core/trace_me.sh ;;
  -t) bash core/trace_target.sh "$2" ;;
  -net) bash core/trace_network.sh ;;
  -w) bash core/trace_web.sh "$2" ;;
  -help|"") show_help ;;
  *) echo -e "\e[31m[ERROR]\e[0m Invalid option. Use -help to see available commands." ;;
esac