# 🚕 Taxi Job (ESX)

This job allows players to work as a taxi driver. Players start the job at an NPC, automatically receive a taxi, pick up an NPC passenger, and drive them to a random destination. Each successful ride earns a variable reward – driving well and on time pays off!

---

## ⚠️ Important Notice

- **❌ DO NOT RESELL**  
  This script is provided **for free** to support the FiveM community. **Reselling, reuploading, or using this script commercially without the developer's permission is strictly prohibited.**

## ⚠️ Key Features

- **Easy configuration via `config.lua`**
  - Payment settings per ride  
  - NPC and vehicle spawn settings  
  - Pickup & drop-off locations  
  - Fully compatible with **ESX Legacy**

- 🚖 Auto-spawn taxi vehicle on job start  
- 🧍‍♂️ NPC pickup and drop-off with map blips  
- ⏱️ Timed rides with crash penalties  
- 💸 Random payout per completed job  
- 🔗 Full ESX compatibility  
- 🧩 Uses `ox_lib` for clean UI/notifications

---

## 🔧 Installation

1. Download and place the folder in your `resources` directory.  
2. Make sure `ox_lib` and `es_extended` are installed and working.
3. Add the following lines to your `server.cfg`:
   ```cfg
   ensure taxi-job
