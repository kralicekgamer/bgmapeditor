import os
import requests
import tkinter as tk
from tkinter import messagebox, simpledialog, scrolledtext

valid_languages = ["cs", "de", "en", "fr", "pt", "ru"]
file_urls = {
    1: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/D1_West_Undead_Or_Alive.zip',
    2: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/D2_West_Gears_And_Guns.zip',
    3: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/G-Zombicide-A5-2E.zip',
    4: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/G-Zombicide-A6-ZC.zip',
    5: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/G-Zombicide-A7-FH.zip',
    6: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/B1_Fant_BP.zip',
    7: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/B2_Fant_GH.zip',
    8: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/B3_Fant_WB.zip',
    9: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/B4_Fant_FF.zip',
    10: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/B5_Fant_NRFTW.zip',
    11: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/C1_Sci_Invader.zip',
    12: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/C2_Sci_Dark_Side.zip',
    13: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/C3_Sci_Black_Ops.zip',
    14: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/C4_Sci_Operation_Persephone.zip',
    15: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/E1_Mov_Night_Of_The_Living_Dead.zip',
    16: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/A1_Mod-Zombicide.zip',
    17: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/A2_Mod_PO.zip',
    18: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/A3_Mod_RM.zip',
    19: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/A4_Mod_TCM.zip',
    20: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/A5_Mod_AN.zip',
    21: 'https://github.com/kralicekgamer/filehost/raw/main/zombicide/Z1_Characters.zip',
}

def set_language():
    language = simpledialog.askstring("Language", "Choose language (cs, de, en, fr, pt, ru):")
    if language is None:
        return  
    if language in valid_languages:
        config_path = './trunk/bgmapeditor.cfg'
        try:
            with open(config_path, 'r') as file:
                content = file.read()
            content = content.replace("en", language)
            with open(config_path, 'w') as file:
                file.write(content)
            messagebox.showinfo("Success", "Language set to " + language)
        except FileNotFoundError:
            messagebox.showerror("Error", "Configuration file not found.")
    else:
        messagebox.showinfo("Invalid Input", "Invalid input. Please choose from the available languages.")

def download_file(pack_number):
    url = file_urls.get(pack_number)
    if not url:
        messagebox.showinfo("Invalid Pack Number", "Invalid pack number.")
        return

    download_dir = './trunk/packs'
    os.makedirs(download_dir, exist_ok=True)
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        file_path = os.path.join(download_dir, f"pack_{pack_number}.zip")
        with open(file_path, 'wb') as f:
            f.write(response.content)
        messagebox.showinfo("Success", "Pack successfully downloaded")
    except requests.HTTPError as e:
        messagebox.showerror("HTTP Error", f"HTTP Error: {e}")
    except requests.RequestException as e:
        messagebox.showerror("Download Error", f"Failed to download pack {pack_number}. Error: {e}")

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
    All packs are hosted on https://github.com/kralicekgamer/filehost/tree/main/zombicide
    """
    def on_download():
        try:
            pack_number = int(pack_number_entry.get())
            if pack_number == 22:
                messagebox.showinfo("Info", "All packs download feature is not implemented.")
            elif pack_number == 23:
                messagebox.showinfo("Info", "Exit selected. Exiting the function.")
            elif 1 <= pack_number <= 21:
                download_file(pack_number)
            else:
                messagebox.showinfo("Invalid Number", "Invalid number. Please choose a number between 1 and 23.")
        except ValueError:
            messagebox.showinfo("Invalid Input", "Invalid input. Please enter a valid number.")
    
    packs_window = tk.Toplevel(root)
    packs_window.title("Download Packs")
    packs_window.geometry("600x450")
    packs_window.configure(bg="#f0f0f0")

    tk.Label(packs_window, text="Available Packs", font=("Helvetica", 14), bg="#f0f0f0").pack(pady=10)
    scrolled_text = scrolledtext.ScrolledText(packs_window, wrap=tk.WORD, width=60, height=15, font=("Helvetica", 10))
    scrolled_text.insert(tk.END, packs_info)
    scrolled_text.config(state=tk.DISABLED)
    scrolled_text.pack(pady=10)
    tk.Label(packs_window, text="Choose pack number:", font=("Helvetica", 12), bg="#f0f0f0").pack(pady=5)
    
    pack_number_entry = tk.Entry(packs_window, font=("Helvetica", 12))
    pack_number_entry.pack(pady=5)
    
    tk.Button(packs_window, text="Download", command=on_download, font=("Helvetica", 12), bg="#4CAF50", fg="white").pack(pady=5)

def install_perl(): 
    messagebox.showinfo("Install Perl", "To run bgmapeditor you need Strawberry Perl.\nDownload the latest release from https://strawberryperl.com/ and install it.")

def exit_program():
    messagebox.showinfo("Ready", "Application is ready.\nIf you downloaded packs, import them in the app.\nRun bgmapeditor.exe in the ./trunk folder.")
    root.destroy()

root = tk.Tk()
root.title("Bgmapeditor Installation Wizard")
root.geometry("600x450")
root.configure(bg="#f0f0f0")

tk.Label(root, text="Welcome to the bgmapeditor installation wizard", font=("Helvetica", 16), bg="#f0f0f0").pack(pady=10)
tk.Label(root, text="(C) 2024 by KralicekGamer", font=("Helvetica", 12), bg="#f0f0f0").pack(pady=5)

tk.Button(root, text="Set Language", command=set_language, font=("Helvetica", 12), bg="#4CAF50", fg="white").pack(pady=5)
tk.Button(root, text="Download Packs", command=download_packs, font=("Helvetica", 12), bg="#2196F3", fg="white").pack(pady=5)
tk.Button(root, text="Install Strawberry Perl", command=install_perl, font=("Helvetica", 12), bg="#FFC107", fg="white").pack(pady=5)
tk.Button(root, text="Exit", command=exit_program, font=("Helvetica", 12), bg="#F44336", fg="white").pack(pady=5)

root.mainloop()
