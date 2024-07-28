import os
import requests

reset = "\033[0m"
red = "\033[31m"
green = "\033[32m"
yellow = "\033[93m"

success = f"[{green}*{reset}] "
info = f"[{yellow}I{reset}] "
failed = f"[{red}!{reset}] "

def set_language():
    valid_languages = ["cs", "de", "en", "fr", "pt"]
    language = input("Choose language (cs, de, en, fr, pt): ")

    if language in valid_languages:
        config_path = './trunk/bgmapeditor.cfg'
        try:
            with open(config_path, 'r') as file:
                content = file.read()

            content = content.replace("en", language)
            with open(config_path, 'w') as file:
                file.write(content)

            print(success + "Language set to " + language)
        except FileNotFoundError:
            print(failed + "Configuration file not found.")
    else:
        print(info + "Invalid input. Please choose from the available languages.")
        set_language()

def download_file(pack_number):
    file_urls = {
        1: 'https://www.zombicide.com/dl/mapeditor/D1_West_Undead_Or_Alive.zip',
        2: 'https://www.zombicide.com/dl/mapeditor/D2_West_Gears_And_Guns.zip',
        3: 'https://www.zombicide.com/dl/mapeditor/G-Zombicide-A5-2E.zip',
        4: 'https://www.zombicide.com/dl/mapeditor/G-Zombicide-A6-ZC.zip',
        5: 'https://www.zombicide.com/dl/mapeditor/G-Zombicide-A7-FH.zip',
        6: 'https://www.zombicide.com/dl/mapeditor/B1_Fant_BP.zip',
        7: 'https://www.zombicide.com/dl/mapeditor/B2_Fant_GH.zip',
        8: 'https://www.zombicide.com/dl/mapeditor/B3_Fant_WB.zip',
        9: 'https://www.zombicide.com/dl/mapeditor/B4_Fant_FF.zip',
        10: 'https://www.zombicide.com/dl/mapeditor/B5_Fant_NRFTW.zip',
        11: 'https://www.zombicide.com/dl/mapeditor/C1_Sci_Invader.zip',
        12: 'https://www.zombicide.com/dl/mapeditor/C2_Sci_Dark_Side.zip',
        13: 'https://www.zombicide.com/dl/mapeditor/C3_Sci_Black_Ops.zip',
        14: 'https://www.zombicide.com/dl/mapeditor/C4_Sci_Operation_Persephone.zip',
        15: 'https://www.zombicide.com/dl/mapeditor/E1_Mov_Night_Of_The_Living_Dead.zip',
        16: 'https://www.zombicide.com/dl/mapeditor/A1_Mod-Zombicide.zip',
        17: 'https://www.zombicide.com/dl/mapeditor/A2_Mod_PO.zip',
        18: 'https://www.zombicide.com/dl/mapeditor/A3_Mod_RM.zip',
        19: 'https://www.zombicide.com/dl/mapeditor/A4_Mod_TCM.zip',
        20: 'https://www.zombicide.com/dl/mapeditor/A5_Mod_AN.zip',
        21: 'https://www.zombicide.com/dl/mapeditor/Z1_Characters.zip',
    }

    url = file_urls.get(pack_number)
    if not url:
        print(info + "Invalid pack number.")
        return

    download_dir = './trunk/packs'
    os.makedirs(download_dir, exist_ok=True)
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        file_path = os.path.join(download_dir, f"pack_{pack_number}.zip")
        with open(file_path, 'wb') as f:
            f.write(response.content)
        print(success + "Pack successfully downloaded")
    except requests.HTTPError as e:
        print(failed + f"HTTP Error: {e}")
    except requests.RequestException as e:
        print(failed + f"Failed to download pack {pack_number}. Error: {e}")

def download_packs():
    packs_info = """
    Western Zombicide:
    1 - Zombicide: Undead or Alive
    2 - Zombicide: Gears and Guns

    Modern Zombicide
    3 - Zombicide: 2nd Edition Core box
    4 - Expansion Washington, Z.C.
    5 - Expansion: Fort Hendrix

    Fantasy Zombicide 
    6 - Zombicide: Black Plague
    7 - Zombicide: Green Horde
    8 - Expansion: Wulfsburg
    9 - Expansion: Friends And Foes
    10 - Expansion: No Rest For The Wicked

    Sci-Fi Zombicide
    11 - Zombicide: Invader
    12 - Zombicide: Dark Side
    13 - Expansion: Black Ops
    14 - Kickstarter Campaign: Operation Persephone

    Night Of The Living Dead
    15 - Zombicide: Night Of The Living Dead

    Classic Zombicide
    16 - Zombicide Season 1: (the original box)
    17 - Zombicide Season 2: Prison Outbreak
    18 - Zombicide Season 3: Rue Morgue
    19 - Expansion: Toxic City Mall
    20 - Expansion: Angry Neighbors
    21 - Zombie silhouette pack   

    22 - All
    23 - Exit
    All original packs are available on https://www.zombicide.com/zombicide-mapeditor/
    """
    print(packs_info)

    try:
        pack_number = int(input("Choose pack number: "))
        if pack_number == 22:
            print(info + "All packs download feature is not implemented.")
        elif pack_number == 23:
            print(info + "Exit selected. Exiting the function.")
        elif 1 <= pack_number <= 21:
            download_file(pack_number)
        else:
            print(info + "Invalid number. Please choose a number between 1 and 23.")
            download_packs()
    except ValueError:
        print(info + "Invalid input. Please enter a valid number.")
        download_packs()

def install_perl():
    print("To run bgmapeditor you need Strawberry Perl.")
    print("Download the latest release from https://strawberryperl.com/ and install it.")

def exit_program():
    print("Application is ready.")
    print("If you downloaded packs, import them in the app.")
    print("Run bgmapeditor.exe in the ./trunk folder.")
    input("Press any key to exit...")
    exit()


while True:
    print("""
    Welcome to the bgmapeditor installation wizard.
    (C) 2024 by KralicekGamer
              
    1 - Set language
    2 - Download packs
    3 - Install Strawberry Perl
    4 - Exit
    """)
    action = input("What action do you want to take: ")
    if action == "1":
        set_language()
    elif action == "2":
        download_packs()
    elif action == "3":
        install_perl()
    elif action == "4":
        exit_program()
    else:
        print(info + "Invalid input.")
