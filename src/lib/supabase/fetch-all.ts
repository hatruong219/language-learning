/**
 * Đọc HẾT các dòng khớp điều kiện, tự phân trang.
 *
 * VÌ SAO CẦN
 *     PostgREST cắt ở 1000 dòng và KHÔNG báo lỗi — nó trả về 1000 dòng như thể
 *     đó là toàn bộ. `mnn_vocabulary` có 2201 dòng, nên gọi thẳng `.select()`
 *     mất 1201 từ một cách im lặng, và không ai phát hiện cho tới khi người học
 *     thấy thiếu từ.
 *
 *     Đây là bẫy đã cắn hai lần trong cùng một ngày: một lần ở API
 *     `web-mgmt-platform`, một lần ở trang kiểm tra từ bên này. Bảng nào có thể
 *     vượt 1000 dòng thì BẮT BUỘC đi qua hàm này.
 *
 * CÁCH DÙNG
 *     `build` nhận (from, to) và trả về truy vấn đã gắn `.range()`. Truyền hàm
 *     chứ không truyền query dựng sẵn, vì query của Supabase chỉ thi hành được
 *     một lần.
 */

const PAGE_SIZE = 1000

export async function fetchAllRows<T>(
  build: (
    from: number,
    to: number,
  ) => PromiseLike<{ data: unknown; error: { message: string } | null }>,
): Promise<{ rows: T[]; error: string | null }> {
  const rows: T[] = []
  for (let from = 0; ; from += PAGE_SIZE) {
    const { data, error } = await build(from, from + PAGE_SIZE - 1)
    if (error) return { rows, error: error.message }
    const page = (data ?? []) as T[]
    rows.push(...page)
    // Trang non hơn kích thước tối đa nghĩa là đã hết dữ liệu. Trang đầy đúng
    // bằng PAGE_SIZE thì phải hỏi tiếp — có thể còn, có thể vừa hết chẵn.
    if (page.length < PAGE_SIZE) return { rows, error: null }
  }
}
