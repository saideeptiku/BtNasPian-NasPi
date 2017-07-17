#!/usr/bin/python3
#
#


def readfile(filename):
    """
    read a file
    add each line to a list
    :param filename: name of file to be read
    :return: list of each line in file
    """

    lines = []
    try:
        with open(filename) as file:
            for line in file:
                lines.append(line.rstrip())
        return lines
    except FileNotFoundError:
        print("failed to open file: " + filename)
        return []


def writefile(filename, text_list, mode="w+"):
    """
    write a file line by line
    :param filename: name of file to be read
    :param text_list: list of text
    :param mode of file write
    :return: list of each line in file
    """

    file = open(filename, mode)
    for item in text_list:
        file.write(str(item) + "\n")
    file.close()


def write_config_var(config_var, var_val, file_name="nas_setup.sh"):
    lines = readfile(file_name)

    config_var_str = config_var + "="

    for i in range(len(lines)):
        if config_var_str in lines[i]:
            lines[i] = config_var_str + "\"" + var_val + "\""

    writefile(file_name, lines, mode="w")


def make_bkp(file_name="nas_setup.sh"):
    if readfile(file_name):
        writefile(file_name + ".bkp", readfile(file_name), mode="w")


uuid_info = """**********************************************************
INFO: Instruction to get the UUID of your hard drive:
1. Connect your USB hard drive to this raspberry pi.
2. Run the following command in a new terminal:
    sudo ls -l /dev/disk/by-uuid
3. copy UUID of your USB hard drive.
4. paste it in this terminal when prompted for.
**********************************************************
"""

user_info = """**********************************************************
INFO: A user will be created for raspberry pi.
Please enter the new username and password when prompted for.
Do not forget what you enter here.
**********************************************************
"""

print("\n")
print("NAS CONFIG REQUIRED!")
make_bkp()

print(uuid_info)
hdd_uuid = input("UUID: ")
write_config_var("HDD_UUID", hdd_uuid)

nas_name = input("\nName of folder as it will appear on network: ")
write_config_var("NAS_NAME", nas_name)

print(user_info)
nas_user = input("NAS Username: ")
write_config_var("NAS_USER", nas_user)

nas_pass = input("NAS Password: ")
write_config_var("NAS_USER_PASS", nas_pass)
