# คู่มือขั้นตอนการเริ่มต้นสร้างโปรเจกต์ Flutter ใหม่ (Flutter Project Setup Guide)

คู่มือนี้สรุปขั้นตอนตั้งแต่การเตรียมเครื่อง, การใช้คำสั่งสร้างโปรเจกต์, โครงสร้างไฟล์สำคัญ, การติดตั้งแพ็กเกจ ไปจนถึงการรันแอปพลิเคชันอย่างเป็นระบบ

---

## 1. การเตรียมความพร้อมและตรวจเช็คสภาพแวดล้อม (Prerequisites)

ก่อนเริ่มสร้างโปรเจกต์ ให้เปิด Terminal (PowerShell หรือ Command Prompt) แล้วพิมพ์คำสั่ง:

```bash
flutter doctor
```

### การตรวจสอบผลลัพธ์:
* **Flutter & Dart:** ต้องขึ้นเครื่องหมายถูก `[✓]` แสดงว่าติดตั้ง SDK เรียบร้อย
* **Android toolchain:** ต้องขึ้น `[✓]` (หากขึ้น `!` ให้อนุญาต License ด้วยคำสั่ง `flutter doctor --android-licenses`)
* **VS Code / Android Studio:** ต้องขึ้น `[✓]` และติดตั้งปลั๊กอิน **Flutter** และ **Dart** แล้ว
* **Connected device:** ต้องมีอย่างน้อย 1 อุปกรณ์ (เช่น Android Emulator, Chrome, หรือ Windows)

---

## 2. ขั้นตอนการสร้างโปรเจกต์ใหม่ (Project Creation)

### วิธีที่ 1: สร้างผ่าน Command Line (แนะนำ สะดวกและรวดเร็ว)

1. เปิด Terminal และนำทางไปยังโฟลเดอร์ที่ต้องการเก็บโปรเจกต์ เช่น:
   ```bash
   cd D:\MobileApp
   ```

2. รันคำสั่งสร้างโปรเจกต์:
   ```bash
   flutter create <ชื่อโปรเจกต์>
   ```

   **ตัวอย่าง:**
   ```bash
   flutter create mydiary
   ```

#### กฎเหล็กในการตั้งชื่อโปรเจกต์ Flutter:
* ใช้รูปแบบ **snake_case** เท่านั้น (ตัวพิมพ์เล็กคั่นด้วยเครื่องหมายขีดล่าง `_`)
* ห้ามใช้ตัวพิมพ์ใหญ่ (เช่น `MyDiary` ❌)
* ห้ามใช้เครื่องหมายขีดกลาง (เช่น `my-diary` ❌)
* ห้ามขึ้นต้นด้วยตัวเลข
* **ห้ามตั้งชื่อซ้ำกับชื่อแพ็กเกจยอดนิยม** เช่น `test`, `http`, `material` เพราะจะทำให้ Import โค้ดชนกัน

#### ออปชันเสริมที่เป็นประโยชน์:
* กำหนด Domain ของ Package Name (สำหรับนำขึ้นสโตร์):
  ```bash
  flutter create --org com.example mydiary
  ```
* ระบุเฉพาะแพลตฟอร์มที่ต้องการ:
  ```bash
  flutter create --platforms=android,ios,windows mydiary
  ```
* สร้างโปรเจกต์แบบคลีน (ไม่มีโค้ดตัวอย่างปุ่มนับเลข):
  ```bash
  flutter create --empty mydiary
  ```

---

### วิธีที่ 2: สร้างผ่าน VS Code (สำหรับสาย GUI)

1. เปิดโปรแกรม VS Code
2. กดคีย์ลัด `Ctrl + Shift + P` (Windows) หรือ `Cmd + Shift + P` (macOS) เพื่อเปิด **Command Palette**
3. พิมพ์ค้นหาคำว่า `Flutter: New Project` แล้วกด Enter
4. เลือกประเภทเป็น **Application**
5. เลือกโฟลเดอร์ปลายทางที่ต้องการบันทึกโปรเจกต์
6. พิมพ์ตั้งชื่อโปรเจกต์ (เช่น `mydiary`) แล้วกด Enter ระบบจะสร้างโปรเจกต์และเปิดโฟลเดอร์ให้อัตโนมัติ

---

## 3. โครงสร้างโฟลเดอร์และไฟล์สำคัญ (Project Structure)

เมื่อสร้างเสร็จ โฟลเดอร์จะมีโครงสร้างหลักดังนี้:

```text
mydiary/
├── android/            # โค้ด Native สำหรับระบบปฏิบัติการ Android
├── ios/                # โค้ด Native สำหรับระบบปฏิบัติการ iOS
├── web/                # ไฟล์สำหรับรันบนเว็บเบราว์เซอร์
├── windows/            # โค้ดสำหรับรันเป็นแอป Desktop บน Windows
├── lib/                # ⭐ พื้นที่เขียนโค้ดภาษา Dart ทั้งหมด (หัวใจหลักของแอป)
│   └── main.dart       # จุดสตาร์ตเริ่มต้นของแอปพลิเคชัน (ฟังก์ชัน main)
├── test/               # โฟลเดอร์สำหรับเขียน Unit Test และ Widget Test
├── pubspec.yaml        # ⭐ ไฟล์ตั้งค่าโปรเจกต์, จัดการ Dependencies, ฟอนต์ และรูปภาพ
└── pubspec.lock        # ไฟล์บันทึกเวอร์ชันจริงของแพ็กเกจ (ห้ามแก้ไขเอง)
```

---

## 4. การติดตั้งแพ็กเกจเสริม (Adding Dependencies)

เมื่อต้องการเพิ่มฟีเจอร์ เช่น การต่ออินเทอร์เน็ต หรือฐานข้อมูลในเครื่อง:

### ติดตั้งผ่านคำสั่ง Terminal:
```bash
# แพ็กเกจเชื่อมต่อ REST API
flutter pub add http

# แพ็กเกจฐานข้อมูล SQLite
flutter pub add sqflite path

# แพ็กเกจเก็บค่าตั้งค่าแบบ Key-Value
flutter pub add shared_preferences
```

คำสั่งนี้จะเพิ่มชื่อและเวอร์ชันลงในไฟล์ `pubspec.yaml` และดาวน์โหลดโค้ดมาให้อัตโนมัติ

---

## 5. การทดสอบรันแอปพลิเคชัน (Running the Application)

1. ตรวจสอบรายชื่ออุปกรณ์ที่สามารถรันได้:
   ```bash
   flutter devices
   ```

2. คำสั่งรันแอป:
   ```bash
   # รันบนอุปกรณ์เริ่มต้น (Default Device)
   flutter run

   # เลือกรันบน Google Chrome
   flutter run -d chrome

   # เลือกรันเป็น Windows Desktop
   flutter run -d windows
   ```

### คีย์ลัดขณะรันแอป (Terminal Shortcuts):
* `r` = **Hot Reload** (อัปเดตการเปลี่ยนแปลงของ UI ในเสี้ยววินาทีโดยไม่รีเซ็ต State)
* `R` = **Hot Restart** (เริ่มแอปใหม่ทั้งหมด รีเซ็ต State เริ่มต้นใหม่)
* `q` = ออกจากการรันโปรแกรม

---

## 6. เคล็ดลับและแนวทางปฏิบัติที่ดี (Best Practices & Troubleshooting)

1. **เปิด Workspace ให้ถูกระดับ:**
   * ใน VS Code ให้เปิดโฟลเดอร์ที่ระดับโปรเจกต์ที่มีไฟล์ `pubspec.yaml` อยู่โดยตรง ไม่ควรเปิดโฟลเดอร์แม่ที่คลุมหลายๆ โปรเจกต์ซ้อนกัน เพราะจะทำให้ Extension ของ Flutter หาเส้นทางไม่เจอ
2. **วิธีแก้ปัญหาเมื่อแอปเพี้ยนหรือคอมไพล์ไม่ผ่าน:**
   ```bash
   flutter clean      # ลบไฟล์ Build เก่าที่ค้างอยู่
   flutter pub get    # ดึง Library มาประกอบใหม่
   flutter run        # สั่งรันใหม่อีกครั้ง
   ```
3. **การจัดระเบียบโค้ดใน `lib/` สำหรับสเกลโปรเจกต์:**
   * แยกเป็นโมเดล เช่น `lib/models/`
   * แยกหน้าจอ เช่น `lib/screens/` หรือ `lib/views/`
   * แยกบริการเชื่อมต่อ เช่น `lib/services/`
