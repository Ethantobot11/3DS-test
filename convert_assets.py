import os
import subprocess

def main():
    os.makedirs("assets/romfs/haxe3ds", exist_ok=True)
    with open("assets/romfs/haxe3ds/version", "w") as f:
        f.write("")

    if not os.path.exists("assets"):
        print("No 'assets' directory found. Skipping conversion.")
        return

    for root, dirs, files in os.walk("assets"):
        for file in files:
            file_path = os.path.join(root, file)
            name, ext = os.path.splitext(file)
            ext = ext.lower()

            if ext == ".mp3":
                out_path = os.path.join(root, name + ".ogg")
                print(f"Converting {file_path} to OGG...")
                try:
                    subprocess.run(["ffmpeg", "-y", "-i", file_path, "-q:a", "4", out_path], check=True)
                    if os.path.exists(file_path):
                        os.remove(file_path)
                except subprocess.CalledProcessError as e:
                    print(f"Error: ffmpeg failed to convert {file_path} (Exit code {e.returncode}). Skipping...")
                except Exception as e:
                    print(f"Unexpected error during MP3 conversion for {file_path}: {e}")

            elif ext == ".ogg":
                out_path = os.path.join(root, name + ".cwav")
                print(f"Converting {file_path} to CWAV...")
                try:
                    subprocess.run(["cwavtool", "-i", file_path, "-o", out_path], check=True)
                except subprocess.CalledProcessError as e:
                    print(f"Error: cwavtool failed on {file_path} (Exit code {e.returncode}). Skipping...")
                except Exception as e:
                    print(f"Unexpected error during CWAV conversion for {file_path}: {e}")

if __name__ == "__main__":
    main()