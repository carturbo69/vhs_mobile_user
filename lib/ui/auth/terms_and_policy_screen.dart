import 'package:flutter/material.dart';

class TermsAndPolicyScreen extends StatefulWidget {
  final int initialTab;
  
  const TermsAndPolicyScreen({super.key, this.initialTab = 0});

  @override
  State<TermsAndPolicyScreen> createState() => _TermsAndPolicyScreenState();
}

class _TermsAndPolicyScreenState extends State<TermsAndPolicyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Màu xanh theo web
  static const Color primaryBlue = Color(0xFF0284C7);
  static const Color darkBlue = Color(0xFF0369A1);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Điều khoản & Chính sách",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryBlue,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: "Điều khoản"),
            Tab(text: "Bảo hiểm"),
            Tab(text: "Bảo mật"),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Điều khoản
            _buildTermsTab(),
            // Tab 2: Bảo hiểm
            _buildInsuranceTab(),
            // Tab 3: Bảo mật
            _buildPrivacyTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.description,
            title: "Chính sách và Điều khoản chung",
            subtitle: "Quy định về quyền và nghĩa vụ khi cung cấp dịch vụ",
          ),
          const SizedBox(height: 24),
          _buildSubsection(
            "1. Giới thiệu",
            "Chào mừng bạn đến với VHS Platform - nền tảng kết nối dịch vụ tại nhà hàng đầu. Khi đăng ký trở thành nhà cung cấp dịch vụ (Provider), bạn đồng ý tuân thủ các điều khoản và điều kiện được quy định trong tài liệu này. Việc đăng ký và sử dụng dịch vụ của chúng tôi đồng nghĩa với việc bạn đã đọc, hiểu và chấp nhận toàn bộ nội dung.",
          ),
          _buildSubsection(
            "2. Quyền và Nghĩa vụ của Provider",
            null,
            items: [
              "Cung cấp dịch vụ chất lượng: Provider cam kết cung cấp dịch vụ đúng với mô tả, đảm bảo chất lượng và hoàn thành đúng thời gian đã cam kết với khách hàng.",
              "Trách nhiệm về thiết bị và nhân viên: Provider chịu trách nhiệm hoàn toàn về chất lượng dịch vụ, thiết bị, dụng cụ và nhân viên thực hiện dịch vụ. Đảm bảo tất cả đều đạt tiêu chuẩn an toàn và chất lượng.",
              "Giấy phép và chứng chỉ: Provider phải có đầy đủ giấy phép kinh doanh hợp lệ, chứng chỉ hành nghề và các giấy tờ pháp lý cần thiết theo quy định của pháp luật.",
              "Bảo mật thông tin: Provider cam kết bảo mật tuyệt đối thông tin khách hàng, không tiết lộ, chia sẻ hoặc sử dụng thông tin cho bất kỳ mục đích nào khác ngoài việc cung cấp dịch vụ.",
              "Giao tiếp chuyên nghiệp: Provider phải giao tiếp với khách hàng một cách lịch sự, chuyên nghiệp và tôn trọng. Không được có hành vi phân biệt đối xử hoặc từ chối dịch vụ một cách vô lý.",
            ],
          ),
          _buildSubsection(
            "3. Chính sách Hủy và Hoàn tiền",
            "Quy định hủy dịch vụ:",
            items: [
              "Sau 30 phút, hệ thống sẽ tự động hủy nếu nhà cung cấp chưa xác nhận và khách hàng chưa thanh toán",
              "Nếu khách hàng không thanh toán, đơn hàng sẽ tự động bị hủy",
              "Khách hàng được hoàn tiền 100% nếu báo cáo được xác nhận là đúng",
            ],
          ),
          _buildSubsection(
            "4. Phí dịch vụ và Thanh toán",
            "Cơ chế hoa hồng:",
            items: [
              "Thanh toán được xử lý hàng tuần vào mỗi thứ 6 cho tất cả các đơn hàng đã hoàn thành trong tuần trước đó.",
              "Provider cần cung cấp thông tin tài khoản ngân hàng chính xác để nhận thanh toán. Mọi thay đổi thông tin tài khoản cần được thông báo trước ít nhất 3 ngày làm việc.",
              "Phí giao dịch ngân hàng (nếu có) sẽ được trừ vào số tiền thanh toán.",
            ],
          ),
          _buildSubsection(
            "5. Chấm dứt Hợp tác",
            "VHS Platform có quyền tạm ngưng hoặc chấm dứt tài khoản Provider trong các trường hợp sau:",
            items: [
              "Vi phạm nghiêm trọng các điều khoản và quy định của platform.",
              "Nhận nhiều đánh giá xấu (dưới 3 sao) hoặc khiếu nại từ khách hàng trong thời gian ngắn.",
              "Có hành vi gian lận, lừa đảo hoặc cung cấp thông tin sai lệch.",
              "Không duy trì giấy phép kinh doanh hoặc bảo hiểm hợp lệ.",
              "Không phản hồi hoặc giải quyết khiếu nại của khách hàng một cách tích cực.",
            ],
          ),
          _buildSubsection(
            "6. Thay đổi Điều khoản",
            "VHS Platform có quyền cập nhật, sửa đổi hoặc bổ sung các điều khoản này khi cần thiết. Tất cả các thay đổi sẽ được thông báo trước ít nhất 7 ngày thông qua email, thông báo trên platform hoặc các kênh liên lạc chính thức. Việc tiếp tục sử dụng dịch vụ sau khi thay đổi có hiệu lực được xem như bạn đã đồng ý với các điều khoản mới.",
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInsuranceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.shield,
            title: "Chính sách Bảo hiểm và Đảm bảo Chất lượng",
            subtitle: "Quy định về bảo hiểm trách nhiệm và cam kết chất lượng dịch vụ",
          ),
          const SizedBox(height: 24),
          _buildSubsection(
            "1. Bảo hiểm Trách nhiệm Dân sự",
            "Tại sao cần bảo hiểm:\nProvider bắt buộc phải có bảo hiểm trách nhiệm dân sự hợp lệ để bảo vệ quyền lợi của khách hàng và chính Provider trong trường hợp xảy ra sự cố không mong muốn. Bảo hiểm này giúp:",
            items: [
              "Bảo vệ khách hàng khỏi thiệt hại về tài sản trong quá trình thực hiện dịch vụ (ví dụ: làm hỏng đồ đạc, thiết bị của khách hàng).",
              "Bảo vệ khách hàng khỏi thương tích hoặc tai nạn xảy ra do lỗi của Provider hoặc nhân viên trong quá trình cung cấp dịch vụ.",
              "Chi trả chi phí pháp lý và các khoản bồi thường liên quan đến các khiếu nại từ khách hàng.",
              "Tăng độ tin cậy và uy tín của Provider trong mắt khách hàng.",
            ],
          ),
          _buildSubsection(
            "2. Mức Bảo hiểm Tối thiểu Bắt buộc",
            "Để đảm bảo quyền lợi tối đa cho khách hàng, Provider cần duy trì bảo hiểm trách nhiệm với các mức tối thiểu sau:",
            items: [
              "Thiệt hại tài sản: Tối thiểu 50.000.000 VNĐ cho mỗi sự cố.",
              "Thương tích cá nhân: Tối thiểu 100.000.000 VNĐ cho mỗi sự cố.",
              "Chi phí pháp lý: Tối thiểu 20.000.000 VNĐ cho mỗi vụ việc.",
              "Tổng mức bảo hiểm: Khuyến nghị tối thiểu 200.000.000 VNĐ cho mỗi năm.",
            ],
          ),
          _buildSubsection(
            "3. Quy trình Xử lý Khiếu nại và Bồi thường",
            "Khi có sự cố xảy ra:",
            items: [
              "Báo cáo ngay: Provider và khách hàng phải báo cáo sự cố cho VHS Platform và công ty bảo hiểm trong vòng 24 giờ kể từ khi xảy ra sự cố.",
              "Cung cấp bằng chứng: Khách hàng cần gửi yêu cầu bồi thường kèm đầy đủ bằng chứng (ảnh chụp, video, biên bản, giấy tờ liên quan) trong vòng 7 ngày kể từ khi xảy ra sự cố.",
              "Điều tra và xác minh: VHS Platform sẽ phối hợp với công ty bảo hiểm để điều tra, xác minh và đánh giá mức độ thiệt hại.",
              "Phối hợp giải quyết: Provider phải phối hợp tích cực, cung cấp đầy đủ thông tin và tham gia giải quyết một cách minh bạch.",
              "Quyết định bồi thường: Quyết định bồi thường sẽ được đưa ra trong vòng 14 ngày làm việc kể từ khi nhận đủ hồ sơ và bằng chứng.",
              "Chi trả: Công ty bảo hiểm sẽ chi trả bồi thường theo quy định của hợp đồng bảo hiểm.",
            ],
          ),
          _buildSubsection(
            "4. Đảm bảo Chất lượng và An toàn Dịch vụ",
            "Để giảm thiểu rủi ro và đảm bảo chất lượng dịch vụ, Provider cam kết:",
            items: [
              "Thiết bị và vật tư: Sử dụng thiết bị, dụng cụ và vật tư đạt tiêu chuẩn chất lượng, an toàn và có nguồn gốc rõ ràng.",
              "Nhân viên chuyên nghiệp: Nhân viên thực hiện dịch vụ phải được đào tạo bài bản, có kỹ năng chuyên môn và chứng chỉ cần thiết (nếu có).",
              "An toàn lao động: Tuân thủ nghiêm ngặt các quy trình an toàn lao động, sử dụng thiết bị bảo hộ đầy đủ và đúng cách.",
              "Phòng ngừa rủi ro: Có kế hoạch và biện pháp phòng ngừa rủi ro cụ thể trong quá trình cung cấp dịch vụ, đặc biệt là các dịch vụ có tính chất nguy hiểm.",
              "Bảo trì và kiểm tra: Thường xuyên bảo trì, kiểm tra và thay thế thiết bị, dụng cụ để đảm bảo an toàn và hiệu quả.",
            ],
          ),
          _buildSubsection(
            "5. Miễn trừ Trách nhiệm",
            "VHS Platform không chịu trách nhiệm về các thiệt hại trong các trường hợp sau:",
            items: [
              "Lỗi từ phía khách hàng: Thiệt hại do khách hàng cung cấp thông tin sai lệch, không tuân thủ hướng dẫn an toàn, hoặc can thiệp vào quá trình thực hiện dịch vụ.",
              "Bất khả kháng: Sự cố do thiên tai (lũ lụt, bão, động đất), hỏa hoạn, dịch bệnh, chiến tranh hoặc các sự kiện bất khả kháng khác ngoài tầm kiểm soát.",
              "Tranh chấp ngoài platform: Các tranh chấp phát sinh từ giao dịch trực tiếp giữa Provider và khách hàng ngoài nền tảng VHS.",
              "Thiệt hại gián tiếp: Các khoản lợi nhuận bị mất, thiệt hại về danh tiếng hoặc các thiệt hại gián tiếp khác không liên quan trực tiếp đến dịch vụ được cung cấp.",
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Trong mọi trường hợp, VHS Platform sẽ cố gắng hỗ trợ tối đa để giải quyết tranh chấp một cách công bằng và minh bạch.",
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.lock,
            title: "Chính sách Bảo mật",
            subtitle: "Cam kết bảo vệ thông tin cá nhân của bạn",
          ),
          const SizedBox(height: 24),
          _buildSubsection(
            "1. Thu thập Thông tin",
            "VHS Platform thu thập các thông tin sau để cung cấp dịch vụ tốt nhất:",
            items: [
              "Thông tin cá nhân: Tên, email, số điện thoại, địa chỉ",
              "Thông tin tài khoản: Username, mật khẩu (được mã hóa)",
              "Thông tin giao dịch: Lịch sử đặt dịch vụ, thanh toán",
              "Thông tin thiết bị: Địa chỉ IP, loại thiết bị, trình duyệt",
            ],
          ),
          _buildSubsection(
            "2. Sử dụng Thông tin",
            "Thông tin của bạn được sử dụng để:",
            items: [
              "Cung cấp và cải thiện dịch vụ",
              "Xử lý đơn hàng và thanh toán",
              "Gửi thông báo quan trọng về dịch vụ",
              "Hỗ trợ khách hàng và giải quyết khiếu nại",
              "Phân tích và cải thiện trải nghiệm người dùng",
            ],
          ),
          _buildSubsection(
            "3. Bảo vệ Thông tin",
            "Chúng tôi cam kết bảo vệ thông tin của bạn bằng các biện pháp:",
            items: [
              "Mã hóa dữ liệu nhạy cảm (SSL/TLS)",
              "Kiểm soát truy cập nghiêm ngặt",
              "Bảo mật cơ sở dữ liệu",
              "Đào tạo nhân viên về bảo mật",
              "Cập nhật và vá lỗ hổng bảo mật thường xuyên",
            ],
          ),
          _buildSubsection(
            "4. Chia sẻ Thông tin",
            "Chúng tôi không bán hoặc cho thuê thông tin cá nhân của bạn. Thông tin chỉ được chia sẻ trong các trường hợp:",
            items: [
              "Với nhà cung cấp dịch vụ (Provider) để thực hiện đơn hàng",
              "Với đối tác thanh toán để xử lý giao dịch",
              "Khi có yêu cầu từ cơ quan pháp luật",
              "Để bảo vệ quyền lợi và an toàn của người dùng",
            ],
          ),
          _buildSubsection(
            "5. Quyền của Người dùng",
            "Bạn có quyền:",
            items: [
              "Truy cập và xem thông tin cá nhân",
              "Yêu cầu chỉnh sửa thông tin không chính xác",
              "Yêu cầu xóa tài khoản và dữ liệu",
              "Từ chối nhận email marketing",
              "Khiếu nại về việc xử lý dữ liệu",
            ],
          ),
          _buildSubsection(
            "6. Cookie và Công nghệ Theo dõi",
            "Chúng tôi sử dụng cookie và công nghệ tương tự để:",
            items: [
              "Ghi nhớ tùy chọn của bạn",
              "Cải thiện hiệu suất website/app",
              "Phân tích hành vi người dùng (ẩn danh)",
              "Cung cấp nội dung phù hợp",
            ],
          ),
          _buildSubsection(
            "7. Liên hệ",
            "Nếu bạn có câu hỏi về chính sách bảo mật, vui lòng liên hệ:\nEmail: support@vhs.com\nHotline: 0337 868 575",
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubsection(
    String title,
    String? description, {
    List<String>? items,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryBlue, darkBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ),
          ],
          if (items != null && items.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
