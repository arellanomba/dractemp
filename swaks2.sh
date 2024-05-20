#!/bin/bash

# Define variables
recipient="ess@hypermediasystems.com"
sender="noreply@officeServer.ess"
smtp_server="outbound003.inf"
port="25" # Or the appropriate SMTP port

# Initialize attempt counter
attempt=0
max_attempts=5
subject=""

# Retry loop to get the subject
while [ $attempt -lt $max_attempts ]; do
    subject=$(python /home/warellano/code/dractemp/get.py | grep -oP 'CurrentReading\s*=\s*\K\d+')
    
    if [ -n "$subject" ]; then
        break
    fi
    
    attempt=$((attempt + 1))
    
    if [ $attempt -lt $max_attempts ]; then
        echo "Temp not found, retrying in 3 minutes... (Attempt $attempt of $max_attempts)"
        sleep 180
    fi
done

# Check if the subject is still empty after max attempts
if [ -z "$subject" ]; then
    echo "Error: Temp not found after $max_attempts attempts."
    exit 1
fi

# Create a temporary file for the email content
temp_email=$(mktemp)
echo "From: $sender" >> $temp_email
echo "To: $recipient" >> $temp_email
echo "Subject: $subject" >> $temp_email
echo "" >> $temp_email
echo "This is for El Segundo Office Server room." >> $temp_email
echo "" >> $temp_email
echo "Temperature in Celcius in Office Server Room: $subject" >> $temp_email

# Use Swaks to send the email
swaks --to "$recipient" \
      --from "$sender" \
      --server "$smtp_server" \
      --port "$port" \
      --data $temp_email

# Remove the temporary file
rm $temp_email
