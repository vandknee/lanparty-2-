#!/usr/bin/env bash
# LAN Party control panel for Linux.
# This script only runs the existing C++ programs; it does not change them.

set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/.." && pwd)"
build_dir="$project_dir/build"
server_bin="$build_dir/server"
client_bin="$build_dir/client"
discovery_bin="$build_dir/discovery_client"
pid_file="$build_dir/lanparty-server.pid"
log_file="$build_dir/lanparty-server.log"

show_help() {
    cat <<'HELP'
LAN Party - Bash Control Panel

Usage: ./scripts/lanparty.sh [command] [optional server IP]

Commands:
  menu           Open the interactive menu
  build          Build existing C++ programs using CMake
  start          Start the server in the background
  stop           Stop the server started by this script
  status         Show whether that server is running
  join [IP]      Open the chat client (auto-discover if no IP)
  discover       Search for LAN Party servers using UDP
  logs           Show the last 40 lines of the server log
  help           Show this help

Examples:
  ./scripts/lanparty.sh build
  ./scripts/lanparty.sh start
  ./scripts/lanparty.sh join
  ./scripts/lanparty.sh join 127.0.0.1
  ./scripts/lanparty.sh discover
  ./scripts/lanparty.sh stop
HELP
}

need_program() {
    if [[ ! -x "$1" ]]; then
        echo "Missing program: $1"
        echo "Run: ./scripts/lanparty.sh build"
        return 1
    fi
}

# Verify both the recorded PID and its executable, so a stale PID file
# cannot accidentally make us stop an unrelated process.
server_is_running() {
    [[ -f "$pid_file" ]] || return 1

    local saved_pid running_exe
    IFS= read -r saved_pid < "$pid_file" || return 1
    [[ "$saved_pid" =~ ^[0-9]+$ ]] || return 1
    kill -0 "$saved_pid" 2>/dev/null || return 1
    running_exe="$(readlink -f "/proc/$saved_pid/exe" 2>/dev/null)" || return 1
    [[ "$running_exe" == "$server_bin" ]]
}

build_project() {
    if ! command -v cmake >/dev/null 2>&1; then
        echo "CMake is not installed. Install CMake and the project dependencies first."
        return 1
    fi

    cmake -S "$project_dir" -B "$build_dir" && cmake --build "$build_dir"
}

start_server() {
    need_program "$server_bin" || return 1

    if server_is_running; then
        echo "LAN Party server is already running (PID: $(cat "$pid_file"))."
        return 0
    fi

    mkdir -p "$build_dir" || return 1
    # Line-buffered output makes server events visible in the log promptly.
    if command -v stdbuf >/dev/null 2>&1; then
        nohup stdbuf -oL -eL "$server_bin" > "$log_file" 2>&1 < /dev/null &
    else
        nohup "$server_bin" > "$log_file" 2>&1 < /dev/null &
    fi
    local new_pid=$!
    printf '%s\n' "$new_pid" > "$pid_file"

    sleep 1
    if server_is_running; then
        echo "LAN Party server started (PID: $new_pid)."
        echo "Log: $log_file"
    else
        echo "Server did not stay running. Check the output below:"
        tail -n 20 "$log_file" 2>/dev/null || true
        rm -f "$pid_file"
        return 1
    fi
}

stop_server() {
    if ! server_is_running; then
        echo "No LAN Party server managed by this script is running."
        return 0
    fi

    local saved_pid
    saved_pid="$(cat "$pid_file")"
    if ! kill -TERM "$saved_pid" 2>/dev/null; then
        echo "Could not stop server PID $saved_pid."
        return 1
    fi

    local attempt
    for attempt in 1 2 3 4 5 6 7 8 9 10; do
        if ! server_is_running; then
            rm -f "$pid_file"
            echo "LAN Party server stopped."
            return 0
        fi
        sleep 0.2
    done

    echo "Server is still running; check its status before trying again."
    return 1
}

server_status() {
    if server_is_running; then
        echo "LAN Party server is RUNNING (PID: $(cat "$pid_file"))."
        echo "Log: $log_file"
    else
        echo "LAN Party server is STOPPED (or was not started by this script)."
    fi
}

join_chat() {
    need_program "$client_bin" || return 1
    if [[ $# -gt 1 ]]; then
        echo "Usage: ./scripts/lanparty.sh join [SERVER_IP]"
        return 1
    fi

    if [[ $# -eq 1 ]]; then
        "$client_bin" "$1"
    else
        "$client_bin"
    fi
}

discover_servers() {
    need_program "$discovery_bin" || return 1
    "$discovery_bin"
}

show_logs() {
    if [[ -f "$log_file" ]]; then
        tail -n 40 "$log_file"
    else
        echo "No server log yet. Start the server first."
    fi
}

show_menu() {
    local choice address
    while true; do
        echo
        echo "========== LAN PARTY =========="
        echo "1. Build project"
        echo "2. Start server"
        echo "3. Join chat"
        echo "4. Discover servers"
        echo "5. Server status"
        echo "6. View server logs"
        echo "7. Stop server"
        echo "0. Exit"
        echo "==============================="
        if ! read -r -p "Choose an option: " choice; then
            echo
            return 0
        fi

        case "$choice" in
            1) build_project ;;
            2) start_server ;;
            3)
                read -r -p "Server IP (leave blank to auto-discover): " address || return 0
                if [[ -n "$address" ]]; then
                    join_chat "$address"
                else
                    join_chat
                fi
                ;;
            4) discover_servers ;;
            5) server_status ;;
            6) show_logs ;;
            7) stop_server ;;
            0) echo "Goodbye!"; return 0 ;;
            *) echo "Invalid choice. Try again." ;;
        esac
    done
}

command="${1:-menu}"
if [[ $# -gt 0 ]]; then
    shift
fi

case "$command" in
    menu) show_menu ;;
    build) build_project ;;
    start) start_server ;;
    stop) stop_server ;;
    status) server_status ;;
    join|client) join_chat "$@" ;;
    discover) discover_servers ;;
    logs) show_logs ;;
    help|-h|--help) show_help ;;
    *) echo "Unknown command: $command"; show_help; exit 1 ;;
esac
