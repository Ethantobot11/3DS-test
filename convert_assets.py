import os
import subprocess
import shutil
import xml.etree.ElementTree as ET
import re

try:
    from PIL import Image
    HAS_PILLOW = True
except ImportError:
    HAS_PILLOW = False
    print("WARNING: Pillow not installed. Auto-resize disabled. Run: pip install Pillow")

def get_tool_path(tool_name: str) -> str:
    tool_path = shutil.which(tool_name)
    if tool_path: return tool_path
    linux_path = f"/opt/devkitpro/tools/bin/{tool_name}"
    if os.path.exists(linux_path): return linux_path
    win_path = f"C:\\devkitPro\\tools\\bin\\{tool_name}.exe"
    if os.path.exists(win_path): return win_path
    return tool_name

def main():
    os.makedirs("assets/romfs/haxe3ds", exist_ok=True)
    with open("assets/romfs/haxe3ds/version", "w") as f: 
        f.write("")

    if not os.path.exists("assets"):
        print("No 'assets' directory found. Skipping conversion.")
        return

    excluded_files = {
        os.path.normpath("assets/resources/audio.wav"),
        os.path.normpath("assets/romfs/resources/audio.wav"),
        os.path.normpath("resources/audio.wav"),
        os.path.normpath("audio.wav")
    }
    looped_files = { os.path.normpath("assets/sounds/home.ogg") }

    tex3ds_path = get_tool_path("tex3ds")
    cwavtool_path = get_tool_path("cwavtool")
    
    print(f"Using tex3ds at: {tex3ds_path}")
    print(f"Using cwavtool at: {cwavtool_path}")

    sprite_sheets = []
    other_files = []

    for root, dirs, files in os.walk("assets"):
        for file in files:
            file_path = os.path.join(root, file)
            name, ext = os.path.splitext(file)
            ext = ext.lower()
            
            if ext == ".xml":
                png_path = os.path.join(root, name + ".png")
                if os.path.exists(png_path):
                    sprite_sheets.append((root, name, file_path, png_path))
                else:
                    print(f"Warning: Found {file_path} but no corresponding {name}.png")
            else:
                other_files.append((root, name, ext, file_path))

    for root, name, xml_path, png_path in sprite_sheets:
        t3x_name = name + ".t3x"
        t3x_path = os.path.join(root, t3x_name)
        cea_path = os.path.join(root, name + ".cea")
        
        print(f"\nProcessing sprite sheet: {name}")
        
        scale_x, scale_y = 1.0, 1.0
        MAX_TEX_SIZE = 2048
        
        if HAS_PILLOW and os.path.exists(png_path):
            try:
                img = Image.open(png_path)
                orig_w, orig_h = img.size
                if orig_w > MAX_TEX_SIZE or orig_h > MAX_TEX_SIZE:
                    scale = min(MAX_TEX_SIZE / orig_w, MAX_TEX_SIZE / orig_h)
                    new_w = int(orig_w * scale)
                    new_h = int(orig_h * scale)
                    print(f"  [RESIZE] {orig_w}x{orig_h} exceeds {MAX_TEX_SIZE}px. Resizing to {new_w}x{new_h}")
                    img = img.resize((new_w, new_h), Image.LANCZOS)
                    img.save(png_path)
                    scale_x = new_w / orig_w
                    scale_y = new_h / orig_h
            except Exception as e:
                print(f"  WARNING: Could not resize {png_path}: {e}")

        print(f"  [1/3] Converting {png_path} to {t3x_path} using tex3ds...")
        tex3ds_success = False
        try:
            subprocess.run([tex3ds_path, png_path, "-o", t3x_path, "-f", "rgba8"], check=True, env=os.environ)
            tex3ds_success = True
        except Exception as e:
            print(f"  ERROR: tex3ds failed on {png_path}. ({e})")

        print(f"  [2/3] Generating 10-column {cea_path} from {xml_path}...")
        try:
            tree = ET.parse(xml_path)
            root_elem = tree.getroot()
            cea_lines = []
            anim_counters = {}
            
            for subtex in root_elem.findall(".//SubTexture"):
                x = float(subtex.get("x", "0"))
                y = float(subtex.get("y", "0"))
                width = float(subtex.get("width", "0"))
                height = float(subtex.get("height", "0"))
                
                frameX = float(subtex.get("frameX", "0"))
                frameY = float(subtex.get("frameY", "0"))
                frameWidth = float(subtex.get("frameWidth", str(width)))
                frameHeight = float(subtex.get("frameHeight", str(height)))

                if scale_x != 1.0 or scale_y != 1.0:
                    x = round(x * scale_x)
                    y = round(y * scale_y)
                    width = round(width * scale_x)
                    height = round(height * scale_y)
                    frameX = round(frameX * scale_x)
                    frameY = round(frameY * scale_y)
                    frameWidth = round(frameWidth * scale_x)
                    frameHeight = round(frameHeight * scale_y)

                frame_name = subtex.get("name")
                
                match = re.search(r'^(.*?)(\d+)$', frame_name)
                if match:
                    anim_name = match.group(1)
                    if anim_name.endswith('_'):
                        anim_name = anim_name[:-1]
                        
                    if anim_name not in anim_counters:
                        anim_counters[anim_name] = 0
                        
                    frame_idx = anim_counters[anim_name]
                    anim_counters[anim_name] += 1
                        
                    cea_line = f"{t3x_name}?{int(x)}?{int(y)}?{int(width)}?{int(height)}?{int(frameX)}?{int(frameY)}?{int(frameWidth)}?{int(frameHeight)}?{anim_name}-{frame_idx}"
                else:
                    cea_line = f"{t3x_name}?{int(x)}?{int(y)}?{int(width)}?{int(height)}?{int(frameX)}?{int(frameY)}?{int(frameWidth)}?{int(frameHeight)}?{frame_name}-0"
                    
                cea_lines.append(cea_line)
            
            with open(cea_path, "w", encoding="utf-8") as f:
                f.write("\n".join(cea_lines) + "\n")
                
        except Exception as e:
            print(f"  ERROR: Failed to parse XML {xml_path}: {e}")

        print(f"  [3/3] Cleaning up...")
        if tex3ds_success:
            try:
                if os.path.exists(png_path): os.remove(png_path)
                if os.path.exists(xml_path): os.remove(xml_path)
                print(f"  SUCCESS: {name} fully converted and cleaned up.")
            except Exception as e:
                print(f"  WARNING: Could not delete original files: {e}")
        else:
            print(f"  WARNING: Kept PNG/XML for debugging since tex3ds failed.")

    for root, name, ext, file_path in other_files:
        if not os.path.exists(file_path): continue
        if ext == ".mp3" and os.path.normpath(file_path) not in excluded_files:
            out_path = os.path.join(root, name + ".ogg")
            try:
                subprocess.run(["ffmpeg", "-y", "-i", file_path, "-q:a", "4", out_path], check=True)
                os.remove(file_path)
            except Exception as e: print(f"Error converting {file_path} to OGG: {e}")
        elif ext in [".wav", ".ogg"] and os.path.normpath(file_path) not in excluded_files:
            out_path = os.path.join(root, name + ".cwav")
            try:
                cmd = [cwavtool_path, "-i", file_path, "-o", out_path]
                if os.path.normpath(file_path) in looped_files: cmd.extend(["-ls", "0", "-le", "end"])
                subprocess.run(cmd, check=True, env=os.environ)
                if ext == ".wav": os.remove(file_path)
            except Exception as e: print(f"Error converting {file_path} to CWAV: {e}")

if __name__ == "__main__":
    main()
