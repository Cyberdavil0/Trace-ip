# 🕵️‍♂️ Trace-ip CLI

# Trace-ip
Trace-it is a cinematic, hacker-grade CLI for tracing IPs, domains, and networks with speed and precision. It reveals geolocation, ISP, and ASN data, scans nearby devices, and traces your own system — built for researchers, analysts, and enthusiasts who value clarity, performance, and real-world usability.


## 🚀 Features

- 🔍 Trace any IP or hostname with geolocation, ISP, and ASN info  
- 🌐 Resolve domains and trace all associated public hosts  
- 📡 Scan nearby devices with IP and MAC addresses  
- 🧠 Trace your own device: local IP, public IP, ISP, and location  
- ✅ Validates inputs and dependencies before execution  
- 🛠️ Works on rooted and non-rooted Linux, Termux, and Kali  

## 📦 Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/Cyberdavil0/Trace-it.git
cd Trace-it
bash setup.sh

The installer will:

* Install Trace-it globally (if root) or locally (if non-root)
* Add it to your `PATH` automatically
* Install required packages: `curl`, `jq`, `dig`, `arp`, `hostname`, `ip`

## 🧪 Usage

```bash
trace -me                 # Trace your own device
trace -t <target>         # Trace target IP or hostname
trace -w <domain>         # Trace all hosts for a domain
trace -net                # Scan nearby devices
trace -h                  # Show help screen

Example:

```bash
trace -t 8.8.8.8
```

## ✅ Requirements

* Bash shell
* Internet connection (for IP tracing)
* Packages: `curl`, `jq`, `dig`, `arp`, `hostname`, `ip`

## 🧠 Author

Built by [Rudra](https://github.com/cyberdavil0) — inventive, methodical, and future-oriented.
**Trace-it** is designed for clarity, reproducibility, and real-world usability.

## 🤝 Contributing

Pull requests are welcome!
For major changes, please open an issue first to discuss what you’d like to improve or extend.

## 📜 License

This project is licensed under the [MIT License](LICENSE).

## ⭐️ Show Your Support

If you find this tool useful:

* ⭐️ Give it a star on GitHub
* 🧑‍💻 Share it with fellow hackers and analysts

> 💀 *Trace-it — Built for clarity. Powered by curiosity. Built by Cyberdavil0 / Cyber_davil_Rudra*

