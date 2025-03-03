#!/usr/bin/env nu
# ~/.config/yazelix/nushell/open_file.nu

# Open a file in Helix, integrating with Yazi and Zellij
source ~/.config/yazelix/nushell/utils.nu  # Import utility functions
source ~/.config/yazelix/nushell/zellij_utils.nu  # Import Zellij helpers

def main [file_path: path] {
    print $"DEBUG: file_path received: ($file_path), type: ($file_path | path type)"
    if not ($file_path | path exists) {
        print $"Error: File path ($file_path) does not exist"
        return
    }

    # Capture YAZI_ID from Yazi’s pane
    let yazi_id = $env.YAZI_ID
    if ($yazi_id | is-empty) {
        print "Warning: YAZI_ID not set in this environment. Yazi navigation may fail."
    }

    # Emit toggle-pane commands to the current Yazi instance
    ya emit-to $yazi_id "plugin" "toggle-pane" "reset"
    ya emit-to $yazi_id "plugin" "toggle-pane" "max-current"

    # Move focus and check Helix status
    focus_next_pane
    let running_command = (get_running_command)

    # Open file based on whether Helix is already running
    if (is_hx_running $running_command) {
        open_in_existing_helix $file_path
    } else {
        open_new_helix_pane $file_path $yazi_id
    }
}
