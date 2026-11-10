Excel Add-On & Registry Exporter (PC-to-PC Migration Guide)

⚠️ Beta Notice (v0.1.0-beta): This project is currently in Beta. Some features or scripts may encounter edge cases or unexpected behavior depending on your Windows version and Office build. Please review registry files carefully before importing them on a new machine.

A utility guide and script repository for backing up, exporting, and migrating Excel add-ons and their associated Windows Registry settings between PCs.

📌 Features

Registry Backup Scripts: Quickly export relevant Office and add-on registry keys.

PC-to-PC Migration Guide: Step-by-step instructions to move add-ons without breaking file paths.

Troubleshooting Tips: How to handle username changes and path discrepancies between different machines.

🚀 Getting Started

Clone the repository:

git clone https://github.com/MedoSamer2022/Excel-Add-On-Reg-File-Exporter-PC-To-PC.git


Export Your Registry Keys:

Press Win + R, type regedit, and navigate to your add-on or Office registry hive (e.g., HKEY_CURRENT_USER\Software\Microsoft\Office\Excel\Addins).

Right-click the key and select Export to save it as a .reg file.

Prepare for Migration:

Open the .reg file in Notepad.

Check for hard-coded user paths (e.g., C:\Users\OldName\...) and update them to match your new PC's username/path structure.

Import: Double-click the edited .reg file on the destination PC to apply the settings.

🛠️ Contributing

Contributions, bug reports, and feature requests are welcome! Since this tool is in Beta, feel free to open an issue if you run into any compatibility snags.

📄 License

This project is licensed under the GNU General Public License v3.0. See the LICENSE file for details.
