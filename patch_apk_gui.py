import os
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox


class PatchGUI(tk.Tk):
    """Simple GUI wrapper for patch-apk.sh."""

    def __init__(self):
        super().__init__()
        self.title("APK SDK Patcher")
        self.resizable(False, False)

        self.apk_var = tk.StringVar()
        self.target_var = tk.StringVar(value="34")
        self.min_var = tk.StringVar()

        row = 0
        tk.Label(self, text="APK file:").grid(row=row, column=0, sticky="e", padx=5, pady=5)
        tk.Entry(self, textvariable=self.apk_var, width=40).grid(row=row, column=1, padx=5)
        tk.Button(self, text="Browse", command=self.browse_apk).grid(row=row, column=2, padx=5)

        row += 1
        tk.Label(self, text="targetSdk:").grid(row=row, column=0, sticky="e", padx=5, pady=5)
        tk.Entry(self, textvariable=self.target_var, width=10).grid(row=row, column=1, sticky="w", padx=5)

        row += 1
        tk.Label(self, text="minSdk (optional):").grid(row=row, column=0, sticky="e", padx=5, pady=5)
        tk.Entry(self, textvariable=self.min_var, width=10).grid(row=row, column=1, sticky="w", padx=5)

        row += 1
        tk.Button(self, text="Patch APK", command=self.patch_apk).grid(row=row, column=0, columnspan=3, pady=10)

    def browse_apk(self):
        path = filedialog.askopenfilename(filetypes=[("APK files", "*.apk")])
        if path:
            self.apk_var.set(path)

    def patch_apk(self):
        apk = self.apk_var.get()
        if not apk:
            messagebox.showerror("Error", "Please select an APK file")
            return

        cmd = [os.path.join(os.path.dirname(__file__), "patch-apk.sh"), apk]
        target = self.target_var.get().strip()
        if target:
            cmd.append(target)
        min_sdk = self.min_var.get().strip()
        if min_sdk:
            cmd.append(min_sdk)

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            messagebox.showinfo("Success", result.stdout)
        except subprocess.CalledProcessError as exc:
            messagebox.showerror("Error", exc.stderr or str(exc))


def main():
    gui = PatchGUI()
    gui.mainloop()


if __name__ == "__main__":
    main()
