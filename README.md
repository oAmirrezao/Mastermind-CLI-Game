Amirreza Inanloo 401105667

# 🎮 Mastermind CLI Game (Swift, Windows-Compatible)

A colorful command‑line implementation of the classic **Mastermind** game written in **Swift**.  
You’ll compete against a secret 4‑digit code, making guesses until you crack it —  
with real‑time feedback and color‑coded pegs for clues.

---

## 📦 Features

- **Windows, macOS, and Linux compatibility**  
  Works cross‑platform thanks to conditional imports.
- **ANSI color output** for clear and fun gameplay visuals:
  - Digits 1–6 have unique colors.
  - Black (`●`) = correct digit in correct position.
  - White (`○`) = correct digit in wrong position.
- **Interactive CLI menu**
  - Start new game
  - Make guesses
  - Exit anytime
- **Input validation**
  - Detects wrong length, non‑digit, or out‑of‑range guesses instantly.
- **Clean API integration**
  - Connects to the [mastermind.darkube.app](https://mastermind.darkube.app) service.
- **Graceful error handling**
  - Friendly messages for invalid guesses, network issues, and server errors.

---

## 🚀 Getting Started

### **1. Install Swift**
If you haven’t already, install Swift for Windows from:  
👉 [https://www.swift.org/download/](https://www.swift.org/download/)  
Ensure `swiftc` is available in your PATH:
```powershell
swiftc --version
```

---

### **2. Clone or Download**
Save the `main.swift` file from this repository into a folder, for example:
```
C:\Users\YourName\Mastermind\
```

---

### **3. Compile**
From CMD or PowerShell:
```powershell
swiftc main.swift -o mastermind.exe
```

---

### **4. Run**
```powershell
.\mastermind.exe
```

---

## 📸 First Launch
When you start the game, you should see the title banner, instructions, and menu options.

<img width="622" height="347" alt="image" src="https://github.com/user-attachments/assets/f19be780-f310-46c4-8b56-d2509062cd0d" />


---

## 🕹️ How to Play

1. Choose **Start a new game** from the menu.
2. Enter a 4‑digit guess (digits between 1 and 6).
3. After each guess:
   - You’ll see your guess in **color**.
   - You’ll see black and white pegs as clues.
4. Keep guessing until:
   - **4 black pegs** → you win 🎉
   - Or you choose to exit.

Type `exit` at any time during a game to quit and delete your current game session.

---

## 🧪 Test Scenario



### **Test 1: Invalid Menu Choices**
- At the menu, enter:
```
9
start
```
**Expected:** Red error message: `Invalid choice. Please try again.`

<img width="380" height="245" alt="image" src="https://github.com/user-attachments/assets/d76760fd-108a-4e3e-a73b-a392706a3815" />


---

### **Test 2: Start New Game**
- Choose `1` from menu.
- You should see a **New game started** message and `Game ID`.

<img width="391" height="177" alt="image" src="https://github.com/user-attachments/assets/34c31f86-ceae-4afd-922a-31595690362d" />


---

### **Test 3: Invalid Guess Handling**
- Enter:
```
abc
123
12345
1789
1122
```
**Expected:** Red error: `Invalid guess. Please enter exactly 4 digits between 1 and 6.`

<img width="602" height="286" alt="image" src="https://github.com/user-attachments/assets/03cead7f-a2f3-4fb1-8692-728703c0c60a" />


---

### **Test 4: Valid Guess Feedback**
- Enter:
```
1234
```
**Expected:** Colored digits, peg results.

<img width="605" height="157" alt="image" src="https://github.com/user-attachments/assets/3985b3c7-97ea-4eb5-b2bc-3aede884aafc" />


---

### **Test 5: Winning the Game**
- Keep guessing until you get **4 black pegs**.

**Expected:** Green congratulatory message and game deletion notice.

<img width="577" height="427" alt="image" src="https://github.com/user-attachments/assets/3805f91d-cf76-4a00-b9c5-051cc220c6c1" />


---

### **Test 6: Exit During Game**
- Start game → type `exit`.

**Expected:** Yellow game deletion success message and menu return.

<img width="580" height="352" alt="image" src="https://github.com/user-attachments/assets/bdf6a399-d863-44ee-a367-3ec16b4d4e17" />


---

### **Test 7: Exiting Program**
- At menu, enter `2`.

**Expected:** Yellow `Thank you for playing! Goodbye!`

<img width="545" height="137" alt="image" src="https://github.com/user-attachments/assets/e2844af0-6d16-48d9-b81b-84ceaef91bce" />


---

## ⚠ Troubleshooting

- **No colors in output:**  
  Windows CMD might need ANSI enabled. Use Windows Terminal or PowerShell for best results.
- **Network errors:**  
  Make sure you have an active internet connection — the game contacts an online API.
- **Compilation errors:**  
  Ensure you have the fixed Windows‑friendly `main.swift` with `FoundationNetworking` import.

---

## 📄 License
This project is provided for educational purposes — feel free to extend or adapt it.


