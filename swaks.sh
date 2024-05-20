#!/bin/bash

# Define variables
subject=$(python get.py | grep -oP 'CurrentReading\s*=\s*\K\d+')
recipient="ess@hypermediasystems.com"
sender="noreply@officeServerRoom.ess"
smtp_server="outbound003.inf"
port="25" # Or the appropriate SMTP port

# Create a temporary file for the email content
temp_email=$(mktemp)
echo "From: $sender" >> $temp_email
echo "To: $recipient" >> $temp_email
echo "Subject: $subject" >> $temp_email
echo "" >> $temp_email
echo "The current temperature in Celcius of server room is: $subject" >> $temp_email

# Use Swaks to send the email
swaks --to "$recipient" \
      --from "$sender" \
      --server "$smtp_server" \
      --port "$port" \
      --data $temp_email

# Remove the temporary file
rm $temp_email
