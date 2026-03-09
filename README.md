# 📦 Sandboxie Custom Build & Certificate Handling

This repository contains a modified build of the open-source [Sandboxie](https://github.com/sandboxie/sandboxie) project. It introduces custom certificate handling and specialized driver loading for `SbieDrv.sys` on Windows 10/11.

---

## 📑 Table of Contents
1. [Prerequisites & Environment](#-prerequisites--environment)
2. [Setup Preparation Scripts](#️-1-setup-preparation-scripts)
3. [Visual Studio Configuration](#-2-visual-studio-project-configuration)
4. [Compilation Workflow (Build Order)](#-3-compilation-workflow)
5. [Custom Certificate Handling](#-4-custom-certificate-handling)
6. [Driver Loading (SbieDrv.sys)](#-5-driver-loading-sbiedrvsys)
7. [Credits & Links](#-credits--links)

---

## 🛠 Prerequisites & Environment

To successfully reproduce this build, you must have the following specific versions installed via the **Visual Studio Installer**:

* **Visual Studio 2022** (with *Desktop development with C++* workload)
* **Windows 10 SDK (10.0.19041.0)** — *Crucial for compatibility.*
* **MSVC v142 Build Tools** — (Required for specific core components).
* **MFC for v142 Build Tools** — (Select this from the *Individual Components* tab).
* **Windows Driver Kit (WDK) 10.0.19041** — [Download Link](https://go.microsoft.com/fwlink/?linkid=2128854).

> [!IMPORTANT]
> If the WDK Extension doesn't install automatically in VS 2022, manually run the VSIX installer found in your WDK installation path (usually `...\10\Vsix\VS2022`).

---

## ⚙️ 1. Setup Preparation Scripts

The helper scripts in the `Installer/` folder contain **absolute paths** hardcoded from the original development environment. You must update these to match your local folders.

1.  Open the `Installer/` directory.
2.  Edit the following files in a text editor:
    * `get_7zip.bat`
    * `get_openssl.bat`
    * `copy_build.bat`
3.  **Action:** Search for any hardcoded paths (e.g., `C:\Test\Sandboxie\...`) and update them to your actual local paths.
4.  **Run:** Execute all three scripts to fetch dependencies and prepare the `Installer\SbiePlus_x64` folder.

---

## 🧰 2. Visual Studio Project Configuration

You must manually point the project to your specific SDK and MSVC toolset. Right-click the projects in **Solution Explorer** and go to **Properties**.

### **Sandman Project**
* **Additional Include Directories:**
    ```text
    C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.44.35207\atlmfc\include
    ```
* **Additional Library Directories:**
    ```text
    C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.44.35207\atlmfc\lib\x64
    ```

### **SbieShell Project**
Ensure paths point to the **10.0.19041.0** SDK folder.
* **Additional Include Directories:**
    ```text
    C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\winrt;
    C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\shared;
    C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\um;
    C:\Program Files (x86)\Windows Kits\10\Include\10.0.19041.0\ucrt;
    ```

---

## 🚀 3. Compilation Workflow

> [!IMPORTANT]
> To compile for **x64**, you must first compile the **LowLevel** components for **Win32 (x86)**.

1.  Open [`Sandbox.sln`](./Sandboxie/Sandbox.sln) in **Visual Studio 2022**.
2.  Set Configuration to **Release** | **Win32**.
3.  Right-click `Solution/core/LowLevel` and select **Build**.
4.  Switch Configuration to **Release** | **x64**.
5.  Select **Build -> Build Solution**.
6.  **Output:** Use the [`copy_build.bat`](./Installer/copy_build.bat) script to move compiled files into [`Installer\SbiePlus_x64`](./Installer/).

---

## 🔑 4. Custom Certificate Handling

The software requires a `Certificate.dat` file in the application directory to unlock features. This file is parsed to determine your access level within the custom build.

**Create a file named `Certificate.dat` with this structure:**
```ini
NAME=DevUser // Required
TYPE=DEVELOPER // Required
SOFTWARE=Sandboxie // Required
DATE=2099-12-31 // Optional
SIGNATURE=0000 // Can be anything
UPDATEKEY=0000 // Optional
```

> [!TIP]
> **Supported TYPE values (Case-Insensitive):**
> * `DEVELOPER` / `CONTRIBUTOR` / `ETERNAL` (Full access) - *Personally, I'd go with one of these*.
> * `PATREON` (Variants like `ENTRY_PATREON` include a 3-month expiry check)
> * `BUSINESS` / `PERSONAL` / `SUPPORTER`

---

## 🚙 5. Driver Loading (SbieDrv.sys)

The kernel driver must be loaded before the Sandboxie service can function. Because this is a custom build, the driver is not signed by Microsoft.

### **Method A: GDRVLoader (Secure Boot ON)**
This is the recommended method for systems with Secure Boot enabled. It uses a signed exploit/helper to load the unsigned driver.
1. Place `GDRVLoader.exe` next to your compiled `SbieDrv.sys`.
2. Open an **Elevated Command Prompt** (Administrator).
3. Execute: `GDRVLoader.exe SbieDrv.sys`
4. When the loader prompt appears, type `load`.

### **Method B: Test-Signing (Secure Boot OFF)**
> [!TIP]
> This is most likely the easiest, but sometimes you need Secure Boot on for some games.

If Secure Boot is disabled in your BIOS, you can use Windows Test Mode.
1. Open an **Elevated Command Prompt**.
2. Run: `bcdedit.exe -set TESTSIGNING ON`
3. **Reboot your system.** (A "Test Mode" watermark will appear on your desktop).
4. Start the Sandboxie service.

---

## 📜 Credits & Links
* **Official Sandboxie:** [Sandboxie-Plus](https://github.com/sandboxie/sandboxie)
* **Inspiration:** [lyc8503/Sandboxie-crack](https://github.com/lyc8503/Sandboxie-crack)
* **Driver Loader:** [GDRVLoader by zer0condition](https://github.com/zer0condition/GDRVLoader)
