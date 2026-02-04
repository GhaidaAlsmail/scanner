import * as authService from './auth.service.js';

export const register = async (req, res) => {
  const { password, ...userData } = req.body;
  const user = await authService.register(userData, password);
  res.json(user);
};


export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await authService.login(email, password);
    res.json(result);
  } catch (e) {
    res.status(401).json({
      message: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    });
  }
};

export const forgotPassword = async (req, res) => {
  const { email } = req.body;

  // لاحقًا: توليد Token + Email
  res.json({
    message: 'إذا كان البريد موجود سيتم إرسال رسالة',
  });
};

