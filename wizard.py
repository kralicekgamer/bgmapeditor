import os
import requests

reset = "\033[0m"
red = "\033[31m"
green = "\033[32m"
yellow = "\033[93m"

succes = "[" + green + "*" + reset + "] "
info = "[" + yellow + "I" + reset + "] "
failed = "[" + red + "!" + reset + "] "


def set_language():
    language = input("Choose language (cs, de, en, fr, pt): ")

    valid_languages = ["cs", "de", "en", "fr", "pt"]
    
    if language in valid_languages:
        with open('./trunk/bgmapeditor.cfg', 'r') as file:
            content = file.read()
        
        content = content.replace("en", language)
        
        with open('./trunk/bgmapeditor.cfg', 'w') as file:
            file.write(content)
        
        print(succes + "Language set to " + language)
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
        12: 'https://www.zombicide.com/dl/mapeditor/C2_Sci_Dark%20Side.zip',
        13: 'https://www.zombicide.com/dl/mapeditor/C3_Sci_Black%20Ops.zip',
        14: 'https://www.zombicide.com/dl/mapeditor/C4_Sci_Operation%20Persephone.zip',
        15: 'https://www.zombicide.com/dl/mapeditor/E1_Mov_Night_Of_The_Living_Dead.zip',
        16: 'https://www.zombicide.com/dl/mapeditor/A1_Mod-Zombicide.zip',
        17: 'https://www.zombicide.com/dl/mapeditor/A2_Mod_PO.zip',
        18: 'https://www.zombicide.com/dl/mapeditor/A3_Mod_RM.zip',
        19: 'https://www.zombicide.com/dl/mapeditor/A4_Mod_TCM.zip',
        20: 'https://www.zombicide.com/dl/mapeditor/A5_Mod_AN.zip',
        21: 'https://www.zombicide.com/dl/mapeditor/Z1_Characters.zip',
    }

    download_dir = './trunk/packs'
    os.makedirs(download_dir, exist_ok=True)

    url = file_urls.get(pack_number)
    if url:
        response = requests.get(url)
        if response.status_code == 200:
            file_path = os.path.join(download_dir, f"pack_{pack_number}.zip")
            with open(file_path, 'wb') as f:
                f.write(response.content)
                print(succes + "Pack succesly downloaded")
        else:
            print(failed + "Failed to download pack " + pack_number + " Status code: " + response.status_code)
    else:
        print(info + "Invalid pack number.")


def download_packs():
    print("""
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
    19 - Expanstion: Toxic City Mall
    20 - Expanstion: Angry Neigbors
    21 - Zombie silhouette pack   

    22 - All
    23 - Exit
    All original pack are available on https://www.zombicide.com/zombicide-mapeditor/
""")
    
    try:
        pack_number = int(input("Choose pack number: "))
        if 1 <= pack_number <= 23:
            if pack_number == 22:
                print(info + "All packs download feature is not implemented.")
            elif pack_number == 23:
                print(info + "Exit selected. Exiting the function.")
            else:
                download_file(pack_number)
        else:
            print(info +  "Invalid number. Please choose a number between 1 and 23.")
            download_packs() 
    except ValueError:
        print(info + "Invalid input. Please enter a valid number.")
        download_packs() 

def exit_program():
    print("Application is ready. ")
    print("If you downloading packs, import it in app.")
    print("Run bgmapeditor.exe in ./trunk folder.")
    input("Press any key to exit...")
    exit()


while True:
    print("""
    Welcome to the bgmapeditor installation wizard.
    (C) 2024 by KralicekGamer
          
    1 - Set language
    2 - Download packs
    3 - Exit
    """)
    action = input("What action do you want: ")
    if action == "1":
        set_language()
    elif action == "2":
        download_packs()
    elif action == "3":
        exit_program()
    else:
        print(info + "Invalid input.")



