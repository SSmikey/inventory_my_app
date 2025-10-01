# 📦 Inventory My App

ระบบจัดการสต็อกสินค้า (Inventory Management) พัฒนาโดยใช้ Flutter รองรับทั้ง Android, iOS และ Web

---



## 🗂️ โครงสร้างโปรเจกต์


<div align="center">

<span style="color:#FF9800"><b>🏗️ โครงสร้างโปรเจกต์ (Project Structure)</b></span>

</div>

```plaintext
inventory_my_app/
│
├── android/                  # โปรเจกต์ Android (Gradle, build, src)
│   ├── app/
│   │   ├── build.gradle.kts
│   │   └── src/
│   │       ├── main/         # ไฟล์ Android หลัก (AndroidManifest, java, res)
│   │       ├── debug/
│   │       └── profile/
│   ├── build.gradle.kts
│   ├── gradle/
│   ├── gradle.properties
│   ├── gradlew, gradlew.bat
│   └── settings.gradle.kts
│
├── ios/                      # โปรเจกต์ iOS (Xcode, Swift, Assets)
│   ├── Flutter/
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Info.plist
│   │   ├── Assets.xcassets/
│   │   └── ...อื่นๆ
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
│
├── web/                      # ไฟล์สำหรับ Web (index.html, manifest, icons)
│   ├── favicon.png
│   ├── icons/
│   ├── index.html
│   └── manifest.json
│
├── lib/                      # <span style="color:#FF9800">โค้ดหลักของแอป (Flutter/Dart)</span>
│   ├── main.dart             # จุดเริ่มต้นแอป
│   ├── api/                  # จัดการเรียก API
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── dashboard_service.dart
│   │   ├── product_service.dart
│   │   └── stock_service.dart
│   ├── models/               # โมเดลข้อมูล
│   │   ├── dashboard.dart
│   │   ├── product.dart
│   │   ├── stock_transaction.dart
│   │   └── user.dart
│   ├── providers/            # State Management (Provider)
│   │   └── auth_provider.dart
│   ├── screens/              # หน้าจอ UI หลัก
│   │   ├── dashboard_screen.dart
│   │   ├── login_screen.dart
│   │   ├── product_screen.dart
│   │   ├── register_screen.dart
│   │   ├── stock_list_screen.dart
│   │   └── transaction_history_screen.dart
│   ├── utils/                # ฟังก์ชันช่วยเหลือ
│   │   └── helpers.dart
│   └── widgets/              # วิดเจ็ต UI ที่ใช้ซ้ำ
│       ├── chart_widget.dart
│       ├── product_item.dart
│       └── stock_item.dart
│
├── pubspec.yaml              # รายการ dependencies และ asset ต่างๆ
├── analysis_options.yaml     # กำหนดมาตรฐานโค้ด
└── README.md                 # ไฟล์แนะนำโปรเจกต์นี้
```

### คำอธิบายโฟลเดอร์/ไฟล์สำคัญ

- <span style="color:#FF9800">**android/**, **ios/**, **web/**</span>: ไฟล์สำหรับแต่ละแพลตฟอร์ม (Android, iOS, Web)
- <span style="color:#FF9800">**lib/**</span>: โค้ด Dart ทั้งหมดของแอป
	- <span style="color:#FF9800">**main.dart**</span>: Entry point ของแอป
	- <span style="color:#FF9800">**api/**</span>: ฟังก์ชันติดต่อ API (เช่น login, product, stock)
	- <span style="color:#FF9800">**models/**</span>: โครงสร้างข้อมูล (Data Models)
	- <span style="color:#FF9800">**providers/**</span>: ตัวจัดการ state (Provider)
	- <span style="color:#FF9800">**screens/**</span>: หน้าจอแต่ละส่วนของแอป (UI)
	- <span style="color:#FF9800">**utils/**</span>: ฟังก์ชันช่วยเหลือทั่วไป
	- <span style="color:#FF9800">**widgets/**</span>: วิดเจ็ต UI ที่นำกลับมาใช้ซ้ำ
- <span style="color:#FF9800">**pubspec.yaml**</span>: กำหนด dependencies และ assets
- <span style="color:#FF9800">**analysis_options.yaml**</span>: กำหนดมาตรฐานโค้ด
- <span style="color:#FF9800">**README.md**</span>: คู่มือโปรเจกต์

---

## 🚀 ฟีเจอร์หลัก

- ระบบล็อกอิน/สมัครสมาชิก
- แดชบอร์ดแสดงข้อมูลภาพรวม
- จัดการสินค้าและสต็อก
- ประวัติการทำรายการ
- รองรับ Responsive UI
- ใช้ Provider ในการจัดการสถานะ
- ใช้ Google Fonts เพื่อความสวยงาม

---

## 👨‍💻 ทีมผู้พัฒนา

- 👨‍💻 นายสิทธิชัย แสงนนท์ 6612732134
- 👨‍💻 นายพีรพัฒน์ สุทธปัญญา 6612732121
- 👩‍💻 นางสาววาสินี มาฤทธิ์ 6712732126
- 👩‍💻 นางสาววรัญญา ฉิมงาม 6712732125

🏛️ สาขาวิทยาการคอมพิวเตอร์  
🎓 มหาวิทยาลัยราชภัฏศรีสะเกษ

---

## 🛠️ วิธีเริ่มต้นใช้งาน

1. ติดตั้ง Flutter SDK
2. รันคำสั่ง `flutter pub get`
3. เลือกอุปกรณ์หรือ emulator ที่ต้องการ
4. รันแอปด้วย `flutter run`

---


---
## ⭐ ตัวอย่างหน้าจอในการใช้งาน

![หน้าจอแอป](./assets/imges/Inventory.png)

> 📦 **Inventory My App** — แอปจัดการสต็อกสินค้า ใช้งานง่าย ครบทุกฟีเจอร์สำหรับธุรกิจยุคใหม่
---
