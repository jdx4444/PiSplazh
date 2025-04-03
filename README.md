# PiSplazh

![Robo Pony Animation](assets/RoboPony.GIF)

PiSplazh is a bash script that automates the creation and installation of a custom animated Plymouth boot splash for Raspberry Pi OS (Bookworm 64-bit). The script takes a series of PNG images (labeled `frame1.png`, `frame2.png`, etc.), rotates and optionally scales them, and then creates the necessary Plymouth theme files so your Raspberry Pi displays a cool animated splash during boot. 

NOTE: I wasn't able to figure out how to delay the plymouth splash, so the length of your animation is dependent on the time it takes for your system to boot; i.e. if your sytem is running fast, your animation might only be a second or so. 

## Requirements

- Raspberry Pi running Raspberry Pi OS (Bookworm 64-bit)
- PNG frames named `frame1.png`, `frame2.png`, … (up to `frame99.png`)
- **Optional:** [ImageMagick](https://imagemagick.org) (for rotating and scaling images; the script will prompt you to install it if not already available)
- Root privileges (use `sudo`) to install the Plymouth theme

## Installation

Follow these steps:

1. **Download or Clone the Repository**

   Open a terminal and run:
    ```bash
    git clone https://github.com/jdx4444/PiSplazh.git
    cd PiSplazh
    ```

2. **Review the Repository Structure**

   Your repository should look like this(I've included png frames if you want to use them for testing, or indefinitely, idk):
    ```
    .
    ├── LICENSE
    ├── README.md
    ├── assets
    │   ├── RoboPony.GIF
    │   ├── frame1.png
    │   ├── frame2.png
    │   ├── frame3.png
    │   ├── frame4.png
    │   └── frame5.png
    └── install_plymouth.sh
    ```

3. **Make the Script Executable**

   Run:
    ```bash
    chmod +x install_plymouth.sh
    ```

4. **Run the Install Script**

   For example, if your PNG images are in the `assets` folder and you have 5 frames, to rotate them 90° clockwise and scale them to 150%, run:
    ```bash
    sudo ./install_plymouth.sh -p assets -c 5 -r 90 -s 150
    ```
   
   **Options Explained:**
   - `-p`  Path to the directory containing your PNG images.
   - `-c`  (Optional) Number of image frames (if omitted, the script counts matching files).
   - `-r`  (Optional) Rotation angle in degrees (e.g. `-r 90` rotates the images 90° clockwise).
   - `-s`  (Optional) Scaling percentage (e.g. `150` for 150% scaling; if omitted, no scaling is done).
   
   If ImageMagick is not installed, the script will prompt you to install it before processing the images.

5. **Reboot Your System**

   After the script completes, reboot your Raspberry Pi to see your new animated boot splash:
    ```bash
    sudo reboot
    ```

## Usage

Once installed, each boot will display your custom animated Plymouth splash screen made from your PNG frames. If you need to update the animation, adjust the images or options, then re-run the install script.

## Troubleshooting

- **Image Naming:** Ensure your PNG files are correctly named (`frame1.png`, `frame2.png`, etc.).
- **Dependencies:** If prompted, allow the installation of ImageMagick for image processing.
- **Script Options:** Adjust rotation (`-r`) and scaling (`-s`) options as needed, and re-run the script to update the splash screen.

## License

This project is licensed under the GNU General Public License.
