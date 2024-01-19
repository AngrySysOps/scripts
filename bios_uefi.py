# The script will perform the following actions:

# Connect to the iDRAC.
# Change the specified BIOS settings.
# Create a job to apply these settings on the next reboot.
# author: Piotr Tarnawski.
# angrysysops.com | X: @AngrySysOps | YT: https://www.youtube.com/@AngryAdmin


import requests
import json
from requests.auth import HTTPBasicAuth

# Reading iDRAC credentials from the secret file
secret_file = 'D:\\scripts\\secret.json'
with open(secret_file, 'r') as file:
    secrets = json.load(file)

idrac_ip = '10.5.12.40' # Assuming the secret file has a list of IPs
idrac_user = secrets['idrac_user']
idrac_password = secrets['idrac_password']
bios_url = f'https://{idrac_ip}/redfish/v1/Systems/System.Embedded.1/Bios/Settings'
job_url = f'https://{idrac_ip}/redfish/v1/Managers/iDRAC.Embedded.1/Jobs'
headers = {'Content-Type': 'application/json'}

# Suppress only the single InsecureRequestWarning from urllib3 needed
requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

def change_boot_mode_and_enable_tpm(idrac_ip, idrac_user, idrac_password):
    """
    Changes the boot mode to UEFI and enables TPM Security on a server using iDRAC and Redfish API.
    Then creates a job to apply these settings at the next reboot.
    """
   

    # Payload to change Boot Mode to UEFI and enable TPM Security
    bios_payload = {
        "Attributes": {
            "BootMode": "Uefi",
            "TPMSecurity": "On",
            "IntelTXT": "On",
            "SecureBoot": "Enabled"
        }
    }

    # Update BIOS settings
    bios_response = requests.patch(bios_url, auth=HTTPBasicAuth(idrac_user, idrac_password),
                                    headers=headers, data=json.dumps(bios_payload), verify=False)

    if bios_response.status_code == 200:
        print(f"BIOS settings updated successfully for {idrac_ip}.")
    else:
        print(f"Failed to update BIOS settings for {idrac_ip}.")
        print("HTTP Error: ", bios_response.status_code)
        print("Response: ", bios_response.json())

def schedule_boot(idrac_ip, idrac_user, idrac_password):

    # Create a job for applying these settings at the next reboot
    
    # Modify the job_payload as per your iDRAC version's requirement
    job_payload = {
    "TargetSettingsURI": "/redfish/v1/Systems/System.Embedded.1/Bios/Settings",
    #"RebootJobType": "PowerCycle"
    }

    job_response = requests.post(job_url, auth=HTTPBasicAuth(idrac_user, idrac_password),
                                  headers=headers, data=json.dumps(job_payload), verify=False)

    if job_response.status_code == 200:
           print(f"Job created successfully for {idrac_ip} to apply settings at the next reboot.")
    else:
           print(f"Failed to create job for BIOS update for {idrac_ip}.")
           print("HTTP Error: ", job_response.status_code)
           print("Response: ", job_response.json())

    
# Iterate over each iDRAC IP address
#for ip in idrac_ip:
change_boot_mode_and_enable_tpm(idrac_ip, idrac_user, idrac_password)
schedule_boot(idrac_ip, idrac_user, idrac_password)


