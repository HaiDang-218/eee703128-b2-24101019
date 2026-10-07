# D04 — Bộ đếm vòng và bộ đếm Johnson 8-bit

## Thông tin

- Mã sinh viên: 24101019
- Đề tài: D04
- Ngôn ngữ: Verilog
- Top module: `tt_um_eee703128_24101019`

## Chức năng

Thiết kế gồm hai chế độ:

- Ring counter 8 trạng thái.
- Johnson counter 16 trạng thái.
- Chọn chế độ bằng `uio_in[0]`.
- Enable bằng `uio_in[1]`.
- Reset đồng bộ active-low bằng `rst_n`.
- Tự phục hồi khi xuất hiện trạng thái không hợp lệ.

## Kiểm thử

Testbench kiểm tra toàn bộ chuỗi trạng thái của Ring và Johnson counter, chức năng enable/hold, chuyển chế độ và tự phục hồi.

Kết quả:

- 28 ca kiểm thử.
- 0 ca lỗi.

## Tổng hợp

Thiết kế đã được tổng hợp bằng Yosys.

- Tổng số cell: 167.

Chi tiết được lưu trong `yosys.log`.

## Tài liệu

Mô tả thiết kế và kết quả được trình bày trong:

`docs/info.md`
