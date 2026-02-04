import User from './user.model.js';

export const createUser = (data) => User.create(data);

export const findByEmail = (email) =>
  User.findOne({ email }).lean();

export const findById = (id) =>
  User.findById(id).lean();

export const updateUser = (id, data) =>
  User.findByIdAndUpdate(id, data, { new: true });

export const getAllUsers = () =>
  User.find().lean();

export const deleteUser = (id) =>
  User.findByIdAndDelete(id);