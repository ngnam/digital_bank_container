-- =========================
-- Module 1: AUTH
-- =========================

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number    VARCHAR(20) UNIQUE NOT NULL,
    display_name    VARCHAR(100),
    password_hash   TEXT NOT NULL,
    email           VARCHAR(100),
    is_biometric_enabled BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT now(),
    updated_at      TIMESTAMP DEFAULT now()
);

COMMENT ON COLUMN users.id IS 'ID duy nhất của người dùng (UUID)';
COMMENT ON COLUMN users.phone_number IS 'Số điện thoại đăng ký, duy nhất';
COMMENT ON COLUMN users.display_name IS 'Tên hiển thị của người dùng';
COMMENT ON COLUMN users.password_hash IS 'Mật khẩu đã được băm (hash)';
COMMENT ON COLUMN users.email IS 'Địa chỉ email của người dùng';
COMMENT ON COLUMN users.is_biometric_enabled IS 'Cờ cho biết người dùng đã bật xác thực sinh trắc học';
COMMENT ON COLUMN users.created_at IS 'Thời điểm tạo bản ghi';
COMMENT ON COLUMN users.updated_at IS 'Thời điểm cập nhật bản ghi gần nhất';

CREATE TABLE trusted_devices (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id       VARCHAR(255) NOT NULL,
    device_name     VARCHAR(100),
    registered_at   TIMESTAMP DEFAULT now(),
    last_used_at    TIMESTAMP
);

COMMENT ON COLUMN trusted_devices.id IS 'ID duy nhất của thiết bị tin cậy';
COMMENT ON COLUMN trusted_devices.user_id IS 'Tham chiếu tới người dùng sở hữu thiết bị';
COMMENT ON COLUMN trusted_devices.device_id IS 'Mã định danh thiết bị (device fingerprint)';
COMMENT ON COLUMN trusted_devices.device_name IS 'Tên thiết bị do người dùng đặt hoặc hệ thống nhận diện';
COMMENT ON COLUMN trusted_devices.registered_at IS 'Thời điểm thiết bị được đăng ký';
COMMENT ON COLUMN trusted_devices.last_used_at IS 'Thời điểm thiết bị được sử dụng gần nhất';

CREATE TABLE sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token           TEXT NOT NULL,
    created_at      TIMESTAMP DEFAULT now(),
    expires_at      TIMESTAMP NOT NULL,
    is_locked       BOOLEAN DEFAULT FALSE
);

COMMENT ON COLUMN sessions.id IS 'ID duy nhất của phiên đăng nhập';
COMMENT ON COLUMN sessions.user_id IS 'Tham chiếu tới người dùng';
COMMENT ON COLUMN sessions.token IS 'Token phiên (JWT hoặc session token)';
COMMENT ON COLUMN sessions.created_at IS 'Thời điểm tạo phiên';
COMMENT ON COLUMN sessions.expires_at IS 'Thời điểm hết hạn phiên';
COMMENT ON COLUMN sessions.is_locked IS 'Cờ cho biết phiên đã bị khóa hay chưa';

-- =========================
-- Module 3: ACCOUNTS
-- =========================

CREATE TABLE accounts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_number  VARCHAR(30) UNIQUE NOT NULL,
    currency        VARCHAR(10) NOT NULL,
    balance         NUMERIC(18,2) DEFAULT 0,
    created_at      TIMESTAMP DEFAULT now(),
    updated_at      TIMESTAMP DEFAULT now()
);

COMMENT ON COLUMN accounts.id IS 'ID duy nhất của tài khoản';
COMMENT ON COLUMN accounts.user_id IS 'Tham chiếu tới chủ sở hữu tài khoản';
COMMENT ON COLUMN accounts.account_number IS 'Số tài khoản ngân hàng, duy nhất';
COMMENT ON COLUMN accounts.currency IS 'Loại tiền tệ (VND, USD,...)';
COMMENT ON COLUMN accounts.balance IS 'Số dư hiện tại của tài khoản';
COMMENT ON COLUMN accounts.created_at IS 'Thời điểm tạo tài khoản';
COMMENT ON COLUMN accounts.updated_at IS 'Thời điểm cập nhật tài khoản gần nhất';

CREATE TABLE transactions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id      UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    type            VARCHAR(10) NOT NULL CHECK (type IN ('DEBIT','CREDIT')),
    amount          NUMERIC(18,2) NOT NULL,
    description     TEXT,
    created_at      TIMESTAMP DEFAULT now()
);

COMMENT ON COLUMN transactions.id IS 'ID duy nhất của giao dịch';
COMMENT ON COLUMN transactions.account_id IS 'Tham chiếu tới tài khoản liên quan';
COMMENT ON COLUMN transactions.type IS 'Loại giao dịch: DEBIT (ghi nợ) hoặc CREDIT (ghi có)';
COMMENT ON COLUMN transactions.amount IS 'Số tiền giao dịch';
COMMENT ON COLUMN transactions.description IS 'Mô tả chi tiết giao dịch';
COMMENT ON COLUMN transactions.created_at IS 'Thời điểm thực hiện giao dịch';

CREATE INDEX idx_transactions_account_id_created_at
    ON transactions(account_id, created_at DESC);

-- =========================
-- Module 4: PAYMENTS
-- =========================

CREATE TABLE payments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_account_id UUID NOT NULL REFERENCES accounts(id),
    to_account_id   UUID REFERENCES accounts(id), -- null nếu external
    to_bank_code    VARCHAR(20),
    to_account_number VARCHAR(30),
    to_name         VARCHAR(100),
    amount          NUMERIC(18,2) NOT NULL,
    description     TEXT,
    status          VARCHAR(20) NOT NULL CHECK (status IN ('PENDING_2FA','SUCCESS','FAILED')),
    created_at      TIMESTAMP DEFAULT now(),
    confirmed_at    TIMESTAMP
);

COMMENT ON COLUMN payments.id IS 'ID duy nhất của giao dịch thanh toán';
COMMENT ON COLUMN payments.from_account_id IS 'Tài khoản nguồn thực hiện thanh toán';
COMMENT ON COLUMN payments.to_account_id IS 'Tài khoản đích (nếu nội bộ), null nếu liên ngân hàng';
COMMENT ON COLUMN payments.to_bank_code IS 'Mã ngân hàng đích (nếu liên ngân hàng)';
COMMENT ON COLUMN payments.to_account_number IS 'Số tài khoản đích';
COMMENT ON COLUMN payments.to_name IS 'Tên người nhận';
COMMENT ON COLUMN payments.amount IS 'Số tiền thanh toán';
COMMENT ON COLUMN payments.description IS 'Nội dung/mô tả giao dịch';
COMMENT ON COLUMN payments.status IS 'Trạng thái giao dịch: PENDING_2FA, SUCCESS, FAILED';
COMMENT ON COLUMN payments.created_at IS 'Thời điểm tạo giao dịch';
COMMENT ON COLUMN payments.confirmed_at IS 'Thời điểm xác nhận thành công';

CREATE TABLE payment_templates (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    alias           VARCHAR(100) NOT NULL,
    bank_code       VARCHAR(20),
    account_number  VARCHAR(30) NOT NULL,
    account_name    VARCHAR(100),
    created_at      TIMESTAMP DEFAULT now()
);

COMMENT ON COLUMN payment_templates.id IS 'ID duy nhất của mẫu thanh toán';
COMMENT ON COLUMN payment_templates.user_id IS 'Người dùng sở hữu mẫu';
COMMENT ON COLUMN payment_templates.alias IS 'Tên gợi nhớ cho mẫu (ví dụ: Tiền nhà)';
COMMENT ON COLUMN payment_templates.bank_code IS 'Mã ngân hàng của người nhận';
COMMENT ON COLUMN payment_templates.account_number IS 'Số tài khoản người nhận';
COMMENT ON COLUMN payment_templates.account_name IS 'Tên người nhận';
COMMENT ON COLUMN payment_templates.created_at IS 'Thời điểm tạo mẫu';

CREATE TABLE payment_schedules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    template_id     UUID REFERENCES payment_templates(id) ON DELETE CASCADE,
    amount          NUMERIC(18,2) NOT NULL,
    frequency       VARCHAR(20) NOT NULL CHECK (frequency IN ('DAILY','WEEKLY','MONTHLY')),
    next_run_at     TIMESTAMP NOT NULL,
    created_at      TIMESTAMP DEFAULT now(),
    active          BOOLEAN DEFAULT TRUE
);

COMMENT ON COLUMN payment_schedules.id IS 'ID duy nhất của lịch thanh toán';
COMMENT ON COLUMN payment_schedules.user_id IS 'Người dùng tạo lịch thanh toán';
COMMENT ON COLUMN payment_schedules.template_id IS 'Tham chiếu tới mẫu thanh toán';
COMMENT ON COLUMN payment_schedules.amount IS 'Số tiền cần thanh toán theo lịch';
COMMENT ON COLUMN payment_schedules.frequency IS 'Tần suất: DAILY, WEEKLY, MONTHLY';
COMMENT ON COLUMN payment_schedules.next_run_at IS 'Thời điểm chạy tiếp theo';
COMMENT ON COLUMN payment_schedules.created_at IS 'Thời điểm tạo lịch';
COMMENT ON COLUMN payment_schedules.active IS 'Cờ cho biết lịch còn hiệu lực hay không';

-- =========================
-- Audit Logs (chung cho security)
-- =========================

CREATE TABLE audit_logs (
    id              BIGSERIAL PRIMARY KEY,
    user_id         UUID REFERENCES users(id),
    event           VARCHAR(50) NOT NULL,
    detail          JSONB,
    ip_address      INET,
    device_id       VARCHAR(255),
    created_at      TIMESTAMP DEFAULT now()
);

COMMENT ON COLUMN audit_logs.id IS 'ID duy nhất của log';
COMMENT ON COLUMN audit_logs.user_id IS 'Người dùng liên quan đến sự kiện';
COMMENT ON COLUMN audit_logs.event IS 'Tên sự kiện (LOGIN, PAYMENT_CREATED,...)';
COMMENT ON COLUMN audit_logs.detail IS 'Chi tiết sự kiện dạng JSON';
COMMENT ON COLUMN audit_logs.ip_address IS 'Địa chỉ IP của client';
COMMENT ON COLUMN audit_logs.device_id IS 'Mã định danh thiết bị';
COMMENT ON COLUMN audit_logs.created_at IS 'Thời điểm ghi log';
