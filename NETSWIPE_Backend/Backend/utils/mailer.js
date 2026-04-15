const nodemailer = require('nodemailer');

const smtpHost = process.env.SMTP_HOST;
const smtpPort = Number(process.env.SMTP_PORT || 587);
const smtpSecure = String(process.env.SMTP_SECURE || 'false').toLowerCase() === 'true';
const emailUser = process.env.EMAIL_USER;
const emailPass = process.env.EMAIL_PASS;
const emailFrom = process.env.EMAIL_FROM || emailUser;

const isEmailConfigured = Boolean(smtpHost && smtpPort && emailUser && emailPass && emailFrom);

let transporter = null;

const getTransporter = () => {
  if (!isEmailConfigured) {
    return null;
  }

  if (!transporter) {
    transporter = nodemailer.createTransport({
      host: smtpHost,
      port: smtpPort,
      secure: smtpSecure,
      auth: {
        user: emailUser,
        pass: emailPass,
      },
    });
  }

  return transporter;
};

const sendOtpEmail = async ({ to, username, otp }) => {
  const mailer = getTransporter();

  if (!mailer) {
    return {
      sent: false,
      reason: 'Email transport is not configured',
    };
  }

  await mailer.sendMail({
    from: emailFrom,
    to,
    subject: 'NetSwipe OTP Verification Code',
    text: `Hello ${username || 'there'}, your NetSwipe OTP is ${otp}. It expires in 10 minutes.`,
    html: `
      <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #222;">
        <h2 style="margin-bottom: 8px;">NetSwipe Verification</h2>
        <p>Hello ${username || 'there'},</p>
        <p>Your OTP code is:</p>
        <div style="font-size: 28px; font-weight: bold; letter-spacing: 4px; margin: 16px 0;">
          ${otp}
        </div>
        <p>This code expires in 10 minutes.</p>
      </div>
    `,
  });

  return { sent: true };
};

module.exports = {
  isEmailConfigured,
  sendOtpEmail,
};
