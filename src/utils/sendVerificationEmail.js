import nodemailer from 'nodemailer';

export const sendVerificationEmail = async (email, token) => {
  const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;

  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  await transporter.sendMail({
    from: `"Finance Department" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Verify your email',
    html: `
      <div style="font-family: Arial, sans-serif; line-height:1.6">
        <h2>Verify your email</h2>
        <p>Thank you for registering.</p>
        <p>Please click the button below to verify your email:</p>
        <a href="${verificationUrl}"
           style="
             display:inline-block;
             padding:10px 20px;
             background:#4f46e5;
             color:#fff;
             text-decoration:none;
             border-radius:6px;
             margin-top:10px
           ">
           Verify Email
        </a>
        <p style="margin-top:20px; font-size:12px; color:#666">
          This link will expire in 10 minutes.
        </p>
      </div>
    `,
  });
};