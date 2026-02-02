import db from '../../config/database';

export async function create(user) {
  await db('users').insert(user);
  return user;
}

export async function findByEmail(email) {
  return db('users').where({ email }).first();
}

export async function findById(id) {
  return db('users').where({ id }).first();
}

export async function update(id, data) {
  return db('users').where({ id }).update(data);
}
