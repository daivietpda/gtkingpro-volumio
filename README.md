# Volumio 4.0 for Beelink GT-King Pro (Amlogic S922X-H)

Bản port hoàn chỉnh hệ điều hành âm thanh cao cấp **Volumio 4.0** (Debian 12 Bookworm, Linux Kernel 6.12.108 LTS) dành riêng cho **Beelink GT-King Pro** (hỗ trợ cả phiên bản Wi-Fi 6 Ampak AP6275S và Wi-Fi 5 AP6356S).

---

## 🌟 Tính năng nổi bật

- **Âm thanh Hi-Fi DAC kép ESS SABRE ES9018 + RT6862 OpAmps:**
  - Hỗ trợ giải mã phần cứng qua cổng tai nghe 3.5mm Analog Audio Jack.
  - Tích hợp điều khiển mạch Mute Transistor (`GPIOAO_2`) và Power Amp (`GPIOA_6`) tự động, loại bỏ hoàn toàn tiếng nổ bụp (pop/click) khi khởi động hoặc chuyển bài.
  - TDM-B Clock Pad định tuyến chuẩn xác (`AUD_CLKID_TDM_MCLK_PAD0`, `AUD_CLKID_TDM_SCLK_PAD1`, `AUD_CLKID_TDM_LRCLK_PAD1`).
  - Hỗ trợ đa thiết bị ra âm thanh: HDMI Audio (Card 0, Device 0) và 3.5mm DAC Hi-Fi (Card 0, Device 1).
- **Điều khiển âm lượng phần cứng (Hardware Volume Control):**
  - Tích hợp điều khiển âm lượng phần cứng Native ALSA (`TDMOUT_B Lane 0`) độc quyền cho chip DAC ESS ES9018.
  - Tự động nhận diện Mixer Phần cứng trong Volumio Settings, điều khiển mượt mà từ thanh trượt giao diện, App Volumio hoặc núm xoay/remote mà không làm giảm bit-depth / chất lượng âm thanh bit-perfect.
- **Xuất hình ảnh HDMI & Đồng hồ VU Meter (Glass Engine):**
  - Tích hợp sẵn engine đồ họa siêu nhẹ **Glass Engine** (SDL2 + Panfrost GPU / DRM/KMS `/dev/dri/card0`).
  - Xuất trực tiếp giao diện phát nhạc kèm đồng hồ VU đung đưa theo nhịp điệu bài hát (Full HD 1080p @ 60 FPS) lên TV / Màn hình qua cổng HDMI mà không cần chạy Xorg hay Desktop cồng kềnh.
  - Thu âm thanh song song bằng ALSA tap ring buffer (`glasstap`), hoàn toàn không làm gián đoạn hay ảnh hưởng luồng phát I2S Hi-Res.
  - Tích hợp giao diện quản trị Web riêng biệt tại cổng `http://<ip-thiết-bị>:5582`.
- **Wi-Fi 6 Tốc độ cao (Ampak AP6275S / Broadcom BCM43752):**
  - Giao tiếp SDIO SDR104 tốc độ cao, băng thông rộng.
  - Hỗ trợ đầy đủ các mạng Wi-Fi 2.4GHz và 5GHz (Wi-Fi 6 802.11ax).
  - Power Sequencing với độ trễ mở nguồn và internal pull-up chuẩn xác.
- **Tiện ích (Plugins Store) & Đăng nhập (MyVolumio):**
  - Mở khóa kho tiện ích công cộng (Public Catalog) không yêu cầu ràng buộc tài khoản hoặc phần hardware độc quyền.
  - Tích hợp cầu nối token `my_volumio` tương thích với giao diện Volumio 4 Bookworm UI.
- **Hỗ trợ Ổ đĩa mạng CIFS/SMB (NAS Network Storage):**
  - Tự động nạp module nhân `cifs` (`cifs.ko`, `cifs_arc4.ko`, `cifs_md4.ko`, `nls_ucs2_utils.ko`) ngay khi khởi động.
  - Hỗ trợ kết nối và duyệt kho nhạc chia sẻ từ Windows Share, Samba Linux, NAS gia đình.
- **An toàn tuyệt đối cho thiết bị:**
  - Khởi động độc lập 100% từ thẻ MicroSD / USB.
  - Không ghi đè bootloader eMMC, không làm mất Android gốc của Box.

---

## 📺 Hướng dẫn sử dụng Glass Engine Web Manager (HDMI VU Meter)

Sau khi khởi động Volumio và cắm cáp HDMI từ Beelink GT-King Pro vào TV hoặc màn hình máy tính:

### 1. Truy cập Web Manager
Mở trình duyệt (trên điện thoại, máy tính bảng hoặc PC) và truy cập:
```
http://<địa-chỉ-IP-GT-King-Pro>:5582
```
*(Ví dụ: `http://192.168.10.35:5582`)*

Giao diện Web Manager cung cấp:
- **Live Preview:** Xem trực tiếp hình ảnh đang hiển thị trên màn hình HDMI theo thời gian thực (60fps).
- **Theme & Skin Manager:** Chọn hàng chục mẫu mặt đồng hồ VU huyền thoại (McIntosh xanh dương, Accuphase vàng champange, Marantz, Technics, Luxman, Pioneer, Studer Revox...).
- **Display Settings:** Cấu hình độ phân giải (1920x1080, 1280x720, 4K), tỷ lệ hiển thị, xoay màn hình (Landscape/Portrait cho màn hình kéo dài).
- **Audio Tap Sensitivity:** Tùy chỉnh độ nhạy của kim VU (Gain, Decay speed, Peak hold) để kim dao động sống động nhất theo từng thể loại nhạc.
- **Artist Fanart & Lyrics:** Bật/tắt chế độ tự tải hình ảnh ca sĩ chất lượng cao làm nền và hiển thị lời bài hát chạy chữ (karaoke mode).

### 2. Tải thêm Theme Packs (Bộ sưu tập giao diện)
Trong Web Manager, vào tab **Themes / Download**:
- Bạn có thể tải các gói theme độ phân giải cao `1920x1080` miễn phí chỉ bằng 1 cú click.
- Hệ thống tự động bung nén và áp dụng ngay lập tức mà không cần khởi động lại Box.

---

## 🛠 Cấu trúc thư mục

- `board/gtkingpro/`:
  - `boot/`: Chứa `aml_autoscript`, `gtkingpro_autoscript`, `boot.ini`, `config.ini`, DTB (`meson-g12b-gtking-pro.dtb`, `dtb.img`).
  - `boot-scripts/`: Mã nguồn U-Boot script template (`aml_autoscript.cmd`, `gtkingpro_autoscript.cmd`).
  - `dts/`: Mã nguồn Device Tree `meson-g12b-gtking-pro.dts` đã tối ưu hóa.
  - `firmware/brcm/`: Firmware Broadcom Wi-Fi 6 (`brcmfmac43752-sdio.*`), Wi-Fi 5 (`brcmfmac4356-sdio.*`), Bluetooth (`BCM4362A2.hcd`, `BCM4356A2.hcd`).
  - `packages/`: Gói cài đặt Glass Engine v0.10.38 tích hợp sẵn.
- `overlays/gtkingpro/`:
  - `rootfs/volumio/`: Mã nguồn Volumio đã patch (Plugin Manager, MyVolumio backend, WebSocket handler, Audio Cards config hỗ trợ Hardware Volume, Glass Engine pre-enabled).
  - `rootfs/etc/systemd/system/`: Các dịch vụ khởi tạo âm thanh và HTTP proxy.
  - `rootfs/usr/local/sbin/`: Script điều khiển phần cứng âm thanh (`gtkingpro-audio-init`).
- `recipes/devices/gtkingpro.sh`: Recipe đóng gói bản dựng cho `volumio-os`.
- `scripts/apply-gtkingpro-overlay.sh`: Script áp dụng overlay nhanh vào Rootfs.

---

## 🚀 Hướng dẫn cài đặt

1. Tải bản dựng image mới nhất từ mục **Releases** (`Volumio-4.0-gtkingpro-v1.2.zip`).
2. Giải nén file `.zip` để lấy file `.img`.
3. Ghi file image vào thẻ nhớ MicroSD (tối thiểu 8GB) bằng phần mềm **Rufus** hoặc **BalenaEtcher**.
4. Cắm thẻ MicroSD vào Beelink GT-King Pro:
   - Nếu box đang ở Android: Cài ứng dụng **Reboot to LibreELEC** hoặc gõ `adb reboot update` để box kích hoạt boot từ thẻ nhớ.
   - Hoặc dùng tăm chọc giữ nút Reset dưới đáy máy, cắm nguồn và giữ 5 giây rồi nhả ra.
5. Thiết bị sẽ khởi động vào Volumio. Truy cập qua trình duyệt: `http://volumio.local` hoặc địa chỉ IP của thiết bị.

---

## 👤 Tác giả & Đóng góp
- Port & Tối ưu hóa bởi **daivietpda**.

