import paramiko
import time

# Define the server and credentials
hostname = "192.168.103.225"
username = "root"
password = "calvin"  # Replace with your actual password

# Define the commands to be executed
commands = [
    "smclp",
    "show /system1/temperatures1/tempsensor1"
]

# Function to execute the commands and retrieve the output
def get_temperature_reading():
    # Create an SSH client
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        # Connect to the server
        client.connect(hostname, username=username, password=password, timeout=10)

        # Start an interactive shell session
        shell = client.invoke_shell()
        time.sleep(1)  # Allow some time for the shell to be ready

        # Send the commands to the shell
        output = ""
        for command in commands:
            shell.send(command + "\n")
            time.sleep(2)  # Adjust this sleep time as necessary for your environment
            
            while shell.recv_ready():
                output += shell.recv(1024).decode('utf-8')

        # Debugging: print the entire output to see what is returned
        #print("Full output from commands:")
        #print(output)

        # Find and print the current temperature reading
        for line in output.splitlines():
            if "CurrentReading" in line:
                print(line.strip())
                break
        else:
            print("Current temperature reading not found.")

    except paramiko.SSHException as e:
        print(f"SSH error: {e}")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Close the connection
        client.close()

# Retry logic
max_retries = 3
for attempt in range(max_retries):
    try:
        get_temperature_reading()
        break  # Exit the loop if successful
    except Exception as e:
        print(f"Attempt {attempt + 1} failed: {e}")
        if attempt < max_retries - 1:
            time.sleep(5)  # Wait before retrying
        else:
            print("Max retries reached. Exiting.")
