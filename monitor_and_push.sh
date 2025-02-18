#!/bin/bash

# Load configuration from config.cfg
source config.cfg

# Function to calculate the checksum of the monitored file/directory
get_checksum() {
    if [ -d "$MONITOR_PATH" ]; then
        find "$MONITOR_PATH" -type f -exec sha256sum {} \; | sha256sum
    else
        sha256sum "$MONITOR_PATH"
    fi
}

# Function to send an email notification using SendGrid API
send_email_notification() {
    curl --request POST \
        --url https://api.sendgrid.com/v3/mail/send \
        --header "Authorization: Bearer $SENDGRID_API_KEY" \
        --header "Content-Type: application/json" \
        --data '{
          "personalizations": [{
            "to": [
              '"$(printf '{"email": "%s"},' "${COLLAB_EMAILS[@]}" | sed 's/,$//')"'
            ],
            "subject": "Repository Update Notification"
          }],
          "from": {"email": "'$SENDGRID_SENDER_EMAIL'"},
          "content": [{
            "type": "text/plain",
            "value": "Changes have been detected and pushed to the repository."
          }]
        }'
}

# Monitor the file or directory
echo "Monitoring $MONITOR_PATH for changes..."
INITIAL_CHECKSUM=$(get_checksum)

while true; do
    CURRENT_CHECKSUM=$(get_checksum)

    # Check if a change is detected
    if [ "$INITIAL_CHECKSUM" != "$CURRENT_CHECKSUM" ]; then
        echo "Change detected in $MONITOR_PATH"
        
        # Stage, commit, and push changes
        git -C "$REPO_PATH" add "$MONITOR_PATH"
        git -C "$REPO_PATH" commit -m "Auto-commit: Changes detected in $MONITOR_PATH"
        if git -C "$REPO_PATH" push origin "$GIT_BRANCH"; then
            echo "Changes pushed successfully."

            # Send email notification
            send_email_notification
        else
            echo "Git push failed. Please check your connection or credentials."
        fi
        
        # Update the initial checksum
        INITIAL_CHECKSUM="$CURRENT_CHECKSUM"
    fi

    # Sleep for 10 seconds before checking again
    sleep 10
done

