/// Ngoài trình duyệt không có chỗ để "tải xuống": ném để chỗ gọi báo lỗi rõ
/// ràng thay vì im lặng làm như đã lưu.
void downloadTextFile(String name, String text) =>
    throw UnsupportedError('Chỉ tải file xuống được trên trình duyệt');
