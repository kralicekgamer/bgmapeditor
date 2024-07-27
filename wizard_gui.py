import os
import requests
import tkinter as tk
from tkinter import messagebox, simpledialog

def set_language():
    language = simpledialog.askstring("Set Language", "Choose language (cs, de, en, fr, pt):")
    valid_languages = ["cs", "de", "en", "fr", "pt"]
    if language in valid_languages:
        with open('./trunk/bgmapeditor.cfg', 'r') as file:
            content = file.read()
        
        content = content.replace("en", language)
        
        with open('./trunk/bgmapeditor.cfg', 'w') as file:
            file.write(content)
        
        messagebox.showinfo("Success", f"Language set to {language}")
    else:
        messagebox.showwarning("Warning", "Invalid input. Please choose from the available languages.")

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
                messagebox.showinfo("Success", "Pack successfully downloaded")
        else:
            messagebox.showerror("Error", f"Failed to download pack {pack_number}. Status code: {response.status_code}")
    else:
        messagebox.showwarning("Warning", "Invalid pack number.")

def download_packs():
    packs = """
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
    """
    pack_number = simpledialog.askinteger("Download Packs", f"Choose pack number:\n{packs}")
    if pack_number == 22:
        messagebox.showinfo("Info", "All packs download feature is not implemented.")
    elif pack_number == 23:
        messagebox.showinfo("Info", "Exit selected. Exiting the function.")
    elif 1 <= pack_number <= 21:
        download_file(pack_number)
    else:
        messagebox.showwarning("Warning", "Invalid number. Please choose a number between 1 and 23.")

def install_perl():
    messagebox.showinfo("Install Strawberry Perl", "For running bgmapeditor you need Strawberry Perl.\nDownload the latest release on https://strawberryperl.com/ and install it.")

def exit_program():
    messagebox.showinfo("Exit", "Application is ready.\nIf you downloaded packs, import them in the app.\nRun bgmapeditor.exe in ./trunk folder.")
    root.destroy()

root = tk.Tk()
root.title("BGMapEditor Wizard")
root.geometry("500x400")

frame = tk.Frame(root, padx=20, pady=20)
frame.pack(expand=True, fill=tk.BOTH)

tk.Label(frame, text="BGMapEditor Wizard", font=("Helvetica", 16)).pack(pady=10)

tk.Button(frame, text="Set Language", command=set_language, width=25, height=2).pack(pady=5)
tk.Button(frame, text="Download Packs", command=download_packs, width=25, height=2).pack(pady=5)
tk.Button(frame, text="Install Strawberry Perl", command=install_perl, width=25, height=2).pack(pady=5)
tk.Button(frame, text="Exit", command=exit_program, width=25, height=2).pack(pady=5)

root.mainloop()
