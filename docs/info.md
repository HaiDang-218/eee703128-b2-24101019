# D04 — Bộ đếm vòng và bộ đếm Johnson 8-bit

## 1. Mô tả thiết kế

Thiết kế gồm hai chế độ đếm trên cùng một bộ đếm 8-bit:

- Ring counter: 8 trạng thái hợp lệ.
- Johnson counter: 16 trạng thái hợp lệ.
- Chế độ hoạt động được chọn bằng `uio_in[0]`.
- Cho phép đếm bằng `uio_in[1]`.
- Có tín hiệu reset đồng bộ mức thấp `rst_n`.
- Có cơ chế tự phục hồi khi bộ đếm rơi vào trạng thái không hợp lệ.

## 2. Nguyên lý hoạt động

### Ring counter

Khi `uio_in[0] = 0`, bộ đếm hoạt động ở chế độ Ring.

Chuỗi trạng thái hợp lệ:

`01 → 02 → 04 → 08 → 10 → 20 → 40 → 80 → 01`

Mỗi chu kỳ clock khi enable được bật, bit `1` được dịch vòng sang vị trí kế tiếp.

### Johnson counter

Khi `uio_in[0] = 1`, bộ đếm hoạt động ở chế độ Johnson.

Chuỗi 16 trạng thái:

`00 → 01 → 03 → 07 → 0F → 1F → 3F → 7F → FF → FE → FC → F8 → F0 → E0 → C0 → 80 → 00`

Mỗi chu kỳ clock khi enable được bật, bit đảo của bit cao nhất được đưa vào bit thấp nhất.

## 3. Tự phục hồi trạng thái

Thiết kế kiểm tra trạng thái hiện tại.

- Nếu ở chế độ Ring và trạng thái không thuộc 8 trạng thái hợp lệ, bộ đếm trở về `01`.
- Nếu ở chế độ Johnson và trạng thái không thuộc 16 trạng thái hợp lệ, bộ đếm trở về `00`.

Điều này giúp bộ đếm có khả năng tự phục hồi từ trạng thái không hợp lệ.

## 4. Chuyển chế độ

Khi chế độ thay đổi:

- Chuyển sang Ring: khởi tạo trạng thái `01`.
- Chuyển sang Johnson: khởi tạo trạng thái `00`.

Việc khởi tạo lại giúp chuỗi trạng thái bắt đầu từ trạng thái hợp lệ của chế độ mới.

## 5. Ánh xạ chân

| Tín hiệu | Chức năng |
|---|---|
| `clk` | Clock |
| `rst_n` | Reset đồng bộ, active-low |
| `ena` | Enable tổng của thiết kế |
| `uio_in[0]` | Chọn chế độ: `0` Ring, `1` Johnson |
| `uio_in[1]` | Enable bộ đếm |
| `uo_out[7:0]` | Trạng thái bộ đếm |
| `uio_out[7:0]` | Không sử dụng, giữ mức 0 |
| `uio_oe[7:0]` | Không sử dụng, giữ mức 0 |

## 6. Kiểm thử

Testbench kiểm tra:

- Trạng thái reset của Ring counter.
- Toàn bộ 8 trạng thái Ring.
- Quay vòng Ring.
- Chức năng hold khi disable.
- Chuyển sang Johnson counter.
- Toàn bộ 16 trạng thái Johnson.
- Quay vòng Johnson.
- Tự phục hồi từ trạng thái không hợp lệ.

Kết quả mô phỏng:

- Tổng số ca kiểm thử: **28**
- Số ca lỗi: **0**
- Kết luận: **Tất cả các ca kiểm thử đều đạt.**

## 7. Tổng hợp RTL

Thiết kế đã được tổng hợp thử bằng Yosys.

Kết quả tổng hợp trước đó:

- Tổng số cell: **167**
- Có các phần tử logic AND, MUX, NOT, OR, XOR và flip-flop.

Các kết quả này được dùng để kiểm tra sơ bộ cấu trúc RTL trước khi đưa thiết kế vào flow B2.

## 8. Giới hạn

Kết quả mô phỏng và tổng hợp ở trên chỉ xác nhận chức năng RTL và bước tổng hợp logic.

Chưa được xem là kết quả tape-out, sign-off vật lý hoặc chip sản xuất thực tế.

## 9. Sử dụng AI

Trong quá trình thực hiện bài, AI được sử dụng để hỗ trợ giải thích yêu cầu, kiểm tra lỗi cú pháp, hướng dẫn mô phỏng/tổng hợp và hỗ trợ tổ chức tài liệu. Thiết kế và các kết quả kiểm thử được kiểm tra lại bằng công cụ mô phỏng và tổng hợp.
