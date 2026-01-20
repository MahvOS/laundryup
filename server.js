const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const cors = require('cors');

const app = express();
app.use(cors());

dotenv.config();



app.use(express.json());

const db = mysql.createPool({
  host: process.env.DB_HOST || '45.130.231.127',
  user: process.env.DB_USER || 'dadang_laundryz',
  password: process.env.DB_PASSWORD || "laundrymodern@",
  database: process.env.DB_NAME || 'dadang_laundry',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
// -------------------
// OWNER AUTHENTICATION
// -------------------
app.post('/owner/login', (req, res) => {
    const { email_or_phone, password } = req.body;

    if (!email_or_phone || !password) {
        return res.status(400).json({ message: 'Email/No HP dan password diperlukan' });
    }

    const query = 'SELECT * FROM users WHERE email_or_phone = ?';
    db.query(query, [email_or_phone], async (err, results) => {
        if (err) return res.status(500).json({ message: 'Error saat login' });
        if (results.length === 0) return res.status(401).json({ message: 'Kredensial salah' });

        const user = results[0];

        // STRICT VALIDATION FOR OWNER
        if (user.role !== 'owner' && user.role !== 'admin') {
            return res.status(403).json({ message: 'Akses Ditolak. Area khusus Owner.' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) return res.status(401).json({ message: 'Kredensial salah' });

        res.json({
            message: 'Login Owner berhasil',
            user: {
                id: user.id,
                name: user.name,
                email_or_phone: user.email_or_phone,
                role: user.role
            },
        });
    });
});

// Serve login page for convenience
app.get('/login', (req, res) => {
    res.sendFile(__dirname + '/public/login.html');
});
app.get('/owner', (req, res) => {
    res.sendFile(__dirname + '/public/index.html');
});

// -------------------
// OWNER DASHBOARD APIS
// -------------------

// 1. Dashboard Stats
app.get('/owner/stats', (req, res) => {
    const queries = {
        totalIncome: 'SELECT SUM(estimated_total) as total FROM bookings WHERE current_status = "Selesai" OR current_status = "Siap Diambil"',
        activeOrders: 'SELECT COUNT(*) as total FROM bookings WHERE current_status NOT IN ("Selesai", "Dibatalkan", "Siap Diambil")',
        totalCustomers: 'SELECT COUNT(*) as total FROM users WHERE role = "customer"',
        completedOrders: 'SELECT COUNT(*) as total FROM bookings WHERE current_status IN ("Selesai", "Siap Diambil")'
    };

    const stats = {};
    let completed = 0;
    const keys = Object.keys(queries);

    keys.forEach(key => {
        db.query(queries[key], (err, result) => {
            if (err) {
                console.error(err);
                stats[key] = 0; // Fallback
            } else {
                stats[key] = result[0].total || 0;
            }
            completed++;
            if (completed === keys.length) {
                res.json(stats);
            }
        });
    });
});

// 2. Laporan (Reports) - List of completed transactions
app.get('/owner/reports', (req, res) => {
    const query = `
        SELECT b.id, u.name as customer_name, s.name as service_name, b.estimated_total, b.current_status, DATE_FORMAT(b.created_at, "%Y-%m-%d %H:%i") as date
        FROM bookings b
        LEFT JOIN users u ON b.user_id = u.id
        LEFT JOIN services s ON b.service_id = s.id
        ORDER BY b.created_at DESC
        LIMIT 100
    `;
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ message: 'Error fetching reports' });
        res.json(results);
    });
});

// 3. Pegawai (Employees) - CRUD
app.get('/owner/employees', (req, res) => {
    const query = 'SELECT id, name, email_or_phone as phone, role FROM users WHERE role = "staff" ORDER BY created_at DESC';
    db.query(query, (err, results) => {
        if (err) return res.status(500).json({ message: 'Error fetching employees' });
        res.json(results);
    });
});

app.post('/owner/employees', async (req, res) => {
    const { name, phone, password } = req.body;
    try {
        const hashedPassword = await bcrypt.hash(password || '123456', 10);
        const query = 'INSERT INTO users (name, email_or_phone, password, role) VALUES (?, ?, ?, "staff")';
        db.query(query, [name, phone, hashedPassword], (err, result) => {
            if (err) return res.status(500).json({ message: 'Error adding employee' });
            res.status(201).json({ message: 'Employee added' });
        });
    } catch (e) {
        res.status(500).json({ message: 'Server error' });
    }
});

app.delete('/owner/employees/:id', (req, res) => {
    const query = 'DELETE FROM users WHERE id = ?';
    db.query(query, [req.params.id], (err) => {
        if (err) return res.status(500).json({ message: 'Error deleting employee' });
        res.json({ message: 'Employee deleted' });
    });
});

// 4. Layanan (Services) - CRUD
app.post('/owner/services', (req, res) => {
    const { name, description, unit, price, category } = req.body;
    const desc = description || '';
    const query = 'INSERT INTO services (name, description, base_price) VALUES (?, ?, ?)';
    db.query(query, [name, desc, price], (err) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ message: 'Error adding service' });
        }
        res.status(201).json({ message: 'Service added' });
    });
});

app.put('/owner/services/:id', (req, res) => {
    const { name, description, price } = req.body;
    const query = 'UPDATE services SET name = ?, description = ?, base_price = ? WHERE id = ?';
    db.query(query, [name, description, price, req.params.id], (err) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ message: 'Error updating service' });
        }
        res.json({ message: 'Service updated' });
    });
});

app.delete('/owner/services/:id', (req, res) => {
    const query = 'DELETE FROM services WHERE id = ?';
    db.query(query, [req.params.id], (err) => {
        if (err) return res.status(500).json({ message: 'Error deleting service' });
        res.json({ message: 'Service deleted' });
    });
});

// -------------------
// END OWNER ROUTES
// -------------------

// -------------------
// ROUTE REGISTER (POST /register)
app.post('/register', async (req, res) => {
    const { name, email_or_phone, password } = req.body;

    if (!name || !email_or_phone || !password) {
        return res.status(400).json({ message: 'Nama, email/No HP dan password diperlukan' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const query = 'INSERT INTO users (name, email_or_phone, password) VALUES (?, ?, ?)';
        db.query(query, [name, email_or_phone, hashedPassword], (err, result) => {
            if (err) {
                if (err.code === 'ER_DUP_ENTRY') {
                    return res.status(409).json({ message: 'Email/No HP sudah terdaftar' });
                }
                return res.status(500).json({ message: 'Error saat registrasi' });
            }
            res.status(201).json({ message: 'Registrasi berhasil', userId: result.insertId });
        });
    } catch (error) {
        res.status(500).json({ message: 'Error server' });
    }
});

// -------------------
// ROUTE LOGIN (POST /login)
app.post('/login', (req, res) => {
  const { email_or_phone, password } = req.body;

  console.log('Login attempt:', { email_or_phone, password });  // Add this

  if (!email_or_phone || !password) {
    return res.status(400).json({ message: 'Email/No HP dan password diperlukan' });
  }

  const query = 'SELECT * FROM users WHERE email_or_phone = ?';
  db.query(query, [email_or_phone], async (err, results) => {
    if (err) {
      console.error('Database error in login:', err);
      return res.status(500).json({ message: 'Error saat login' });
    }
    console.log('Query results length:', results.length);  // Add this
    if (results.length === 0) {
      console.log('No user found for:', email_or_phone);  // Add this
      return res.status(401).json({ message: 'Kredensial salah' });
    }

    const user = results[0];
    console.log('User found:', user.id, user.email_or_phone);  // Add this
    console.log('Stored hash:', user.password);  // Add this
    const isMatch = await bcrypt.compare(password, user.password);
    console.log('Password match:', isMatch);  // Add this
    if (!isMatch) {
      console.log('Password does not match for user:', user.id);  // Add this
      return res.status(401).json({ message: 'Kredensial salah' });
    }

    res.json({
      message: 'Login berhasil',
      user: {
        id: user.id,
        name: user.name,
        email_or_phone: user.email_or_phone,
        role: user.role || 'customer',
      },
    });
  });
});


app.get('/services', (req, res) => {
  const query = 'SELECT * FROM services';
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ message: 'Error saat mengambil layanan' });
    const formatted = results.map(row => ({
      ...row,
      created_at: row.created_at
        ? row.created_at.toISOString().replace('T', ' ').replace(/\.\d{3}Z$/, '')
        : null
    }));
    res.json(formatted);
  });

});

// -------------------
// ROUTE BUAT BOOKING (POST /bookings)
app.post('/bookings', (req, res) => {
  const { user_id, service_id, booking_date, time_slot, delivery_type, estimated_total, notes, customer_name, customer_phone } = req.body;

  // If staff creating for customer, check/create user
  let finalUserId = user_id;
  if (!user_id && customer_phone) {
    // Check if user exists
    db.query('SELECT id FROM users WHERE email_or_phone = ?', [customer_phone], (userErr, userResults) => {
      if (userErr) return res.status(500).json({ message: 'Error checking user' });

      if (userResults.length > 0) {
        finalUserId = userResults[0].id;
        createBooking();
      } else {
        // Create new customer user
        const insertUserQuery = 'INSERT INTO users (email_or_phone, password, role) VALUES (?, ?, ?)';
        const tempPassword = 'temp123'; // Staff should set proper password later
        bcrypt.hash(tempPassword, 10, (hashErr, hash) => {
          if (hashErr) return res.status(500).json({ message: 'Error hashing password' });

          db.query(insertUserQuery, [customer_phone, hash, 'customer'], (insertErr, insertResult) => {
            if (insertErr) return res.status(500).json({ message: 'Error creating user' });
            finalUserId = insertResult.insertId;
            createBooking();
          });
        });
      }
    });
  } else {
    createBooking();
  }

  function createBooking() {
    if (!finalUserId || !service_id || !booking_date || !time_slot || !delivery_type || !estimated_total) {
      return res.status(400).json({ message: 'Data booking tidak lengkap' });
    }

    const query = 'INSERT INTO bookings (user_id, service_id, booking_date, time_slot, delivery_type, estimated_total, notes, current_status) VALUES (?, ?, ?, ?, ?, ?, ?, "Diterima")';
    db.query(query, [finalUserId, service_id, booking_date, time_slot, delivery_type, estimated_total, notes], (err, result) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ message: 'Error saat membuat booking' });
      }

      // Insert initial status history
      const historyQuery = 'INSERT INTO status_history (booking_id, status, updated_by) VALUES (?, "Diterima", "System")';
      db.query(historyQuery, [result.insertId], (histErr) => {
        if (histErr) console.error('Error inserting initial status history:', histErr);
      });

      res.status(201).json({ message: 'Booking berhasil dibuat', bookingId: result.insertId });
    });
  }
});

// -------------------
// ROUTE DAFTAR BOOKING USER (GET /bookings)
app.get('/bookings', (req, res) => {
  const { user_id } = req.query; // kirim user_id sebagai query param

  if (!user_id) {
    return res.status(400).json({ message: 'user_id diperlukan sebagai query parameter' });
  }

  const query = 'SELECT b.id, b.service_id, b.booking_date, b.time_slot, b.delivery_type, b.estimated_total, b.current_status, b.notes, DATE_FORMAT(b.created_at, "%Y-%m-%d %H:%i:%s") as created_at, s.name AS service_name FROM bookings b JOIN services s ON b.service_id = s.id WHERE b.user_id = ? ORDER BY b.created_at DESC';

  db.query(query, [user_id], (err, results) => {
    if (err) return res.status(500).json({ message: 'Error saat mengambil booking' });
    res.json(results);
  });
});

// -------------------
// ROUTE DETAIL STATUS BOOKING (GET /bookings/:id/status)
app.get('/bookings/:id/status', (req, res) => {
  const { id } = req.params;
  const { user_id } = req.query;

  console.log('Status request:', { id, user_id });  // Add this

  if (!user_id) {
    return res.status(400).json({ message: 'user_id diperlukan' });
  }

  const idInt = parseInt(id);
  const userIdInt = parseInt(user_id);

  if (isNaN(idInt) || isNaN(userIdInt)) {
    return res.status(400).json({ message: 'Invalid id or user_id' });
  }

  const query = 'SELECT current_status FROM bookings WHERE id = ? AND user_id = ?';
  db.query(query, [idInt, userIdInt], (err, bookingResults) => {
    if (err) {
      console.error('Error in status query:', err);  // Add this
      return res.status(500).json({ message: 'Error saat mengambil status' });
    }
    console.log('Booking results length:', bookingResults.length);  // Add this
    if (bookingResults.length === 0) {
      console.log('No booking found for id:', idInt, 'user_id:', userIdInt);  // Add this
      return res.status(404).json({ message: 'Booking tidak ditemukan atau bukan milik Anda' });
    }

    const historyQuery = 'SELECT id, booking_id, status, updated_by, notes, DATE_FORMAT(updated_at, "%Y-%m-%d %H:%i:%s") as updated_at FROM status_history WHERE booking_id = ? ORDER BY updated_at ASC';
    db.query(historyQuery, [idInt], (histErr, historyResults) => {
      if (histErr) {
        console.error('Error in history query:', histErr);  // Add this
        return res.status(500).json({ message: 'Error saat mengambil riwayat status' });
      }
      res.json({
        current_status: bookingResults[0].current_status,
        history: historyResults,
      });
    });
  });
});


app.delete('/bookings/:id', (req, res) => {
  const { id } = req.params;
  const { user_id } = req.query;

  if (!user_id) {
    return res.status(400).json({ message: 'user_id diperlukan' });
  }

  const idInt = parseInt(id);
  const userIdInt = parseInt(user_id);

  if (isNaN(idInt) || isNaN(userIdInt)) {
    return res.status(400).json({ message: 'Invalid id or user_id' });
  }

  // First, delete status history
  db.query('DELETE FROM status_history WHERE booking_id = ?', [idInt], (histErr) => {
    if (histErr) {
      console.error('Error deleting status history:', histErr);
    }
    // Then delete booking
    db.query('DELETE FROM bookings WHERE id = ? AND user_id = ?', [idInt, userIdInt], (err, result) => {
      if (err) {
        console.error('Error deleting booking:', err);
        return res.status(500).json({ message: 'Error saat menghapus booking' });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Booking tidak ditemukan atau bukan milik Anda' });
      }
      res.json({ message: 'Booking berhasil dihapus' });
    });
  });
});


// -------------------
// ROUTE UPDATE STATUS (POST /bookings/:id/update-status)
app.post('/bookings/:id/update-status', (req, res) => {
  const { id } = req.params;
  const { new_status, updated_by } = req.body;

  if (!new_status || !updated_by) {
    return res.status(400).json({ message: 'Status baru dan updated_by diperlukan' });
  }

  const idInt = parseInt(id);
  if (isNaN(idInt)) {
    return res.status(400).json({ message: 'Invalid id' });
  }

  const updateQuery = 'UPDATE bookings SET current_status = ? WHERE id = ?';
  db.query(updateQuery, [new_status, idInt], (err) => {
    if (err) return res.status(500).json({ message: 'Error saat update status' });

    const historyQuery = 'INSERT INTO status_history (booking_id, status, updated_by) VALUES (?, ?, ?)';
    db.query(historyQuery, [idInt, new_status, updated_by], (histErr) => {
      if (histErr) return res.status(500).json({ message: 'Error saat insert riwayat' });
      res.json({ message: 'Status berhasil diupdate' });
    });
  });
});

// pegawai routes
// GET all bookings for staff
app.get('/staff/bookings', (req, res) => {
  const query = 'SELECT b.id, b.user_id, b.service_id, b.booking_date, b.time_slot, b.delivery_type, b.estimated_total, b.current_status, b.notes, DATE_FORMAT(b.created_at, "%Y-%m-%d %H:%i:%s") as created_at, s.name AS service_name, u.email_or_phone AS customer_email FROM bookings b JOIN services s ON b.service_id = s.id JOIN users u ON b.user_id = u.id ORDER BY b.created_at DESC';
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ message: 'Error mengambil booking' });
    res.json(results);
  });
});

app.get('/staff/order-counts', (req, res) => {
  const queries = {
    orderBaru: 'SELECT COUNT(*) as count FROM bookings WHERE current_status = "Diterima"',
    dalamProses: 'SELECT COUNT(*) as count FROM bookings WHERE current_status IN ("Ditimbang", "Dicuci", "Dikeringkan", "Disetrika")',
    siapDiambil: 'SELECT COUNT(*) as count FROM bookings WHERE current_status = "Siap Diambil"',
  };

  const results = {};
  let completed = 0;

  Object.keys(queries).forEach(key => {
    db.query(queries[key], (err, result) => {
      if (err) return res.status(500).json({ message: 'Error getting counts' });
      results[key] = result[0].count;
      completed++;
      if (completed === Object.keys(queries).length) {
        res.json(results);
      }
    });
  });
});


// POST update status for staff (no user check)
app.post('/staff/bookings/:id/update-status', (req, res) => {
  const { id } = req.params;
  const { new_status, updated_by, notes } = req.body;

  if (!new_status || !updated_by) {
    return res.status(400).json({ message: 'Status baru dan updated_by diperlukan' });
  }

  const idInt = parseInt(id);
  if (isNaN(idInt)) {
    return res.status(400).json({ message: 'Invalid id' });
  }

  const updateQuery = 'UPDATE bookings SET current_status = ? WHERE id = ?';
  db.query(updateQuery, [new_status, idInt], (err) => {
    if (err) return res.status(500).json({ message: 'Error update status' });

    const historyQuery = 'INSERT INTO status_history (booking_id, status, updated_by, notes) VALUES (?, ?, ?, ?)';
    db.query(historyQuery, [idInt, new_status, updated_by, notes || null], (histErr) => {
      if (histErr) return res.status(500).json({ message: 'Error insert riwayat' });
      res.json({ message: 'Status berhasil diupdate' });
    });
  });
});

app.post('/bookings', (req, res) => {
  const { user_id, service_id, booking_date, time_slot, delivery_type, estimated_total, notes, customer_name, customer_phone } = req.body;

  // If staff creating for customer, check/create user
  let finalUserId = user_id;
  if (!user_id && customer_phone) {
    // Check if user exists
    db.query('SELECT id FROM users WHERE email_or_phone = ?', [customer_phone], (userErr, userResults) => {
      if (userErr) return res.status(500).json({ message: 'Error checking user' });

      if (userResults.length > 0) {
        finalUserId = userResults[0].id;
        createBooking();
      } else {
        // Create new customer user
        const insertUserQuery = 'INSERT INTO users (email_or_phone, password, role) VALUES (?, ?, ?)';
        const tempPassword = 'temp123'; // Staff should set proper password later
        bcrypt.hash(tempPassword, 10, (hashErr, hash) => {
          if (hashErr) return res.status(500).json({ message: 'Error hashing password' });

          db.query(insertUserQuery, [customer_phone, hash, 'customer'], (insertErr, insertResult) => {
            if (insertErr) return res.status(500).json({ message: 'Error creating user' });
            finalUserId = insertResult.insertId;
            createBooking();
          });
        });
      }
    });
  } else {
    createBooking();
  }

  function createBooking() {
    if (!finalUserId || !service_id || !booking_date || !time_slot || !delivery_type || !estimated_total) {
      return res.status(400).json({ message: 'Data booking tidak lengkap' });
    }

    const query = 'INSERT INTO bookings (user_id, service_id, booking_date, time_slot, delivery_type, estimated_total, notes, current_status) VALUES (?, ?, ?, ?, ?, ?, ?, "Diterima")';
    db.query(query, [finalUserId, service_id, booking_date, time_slot, delivery_type, estimated_total, notes], (err, result) => {
      if (err) {
        console.error(err);
        return res.status(500).json({ message: 'Error saat membuat booking' });
      }

      // Insert initial status history
      const historyQuery = 'INSERT INTO status_history (booking_id, status, updated_by) VALUES (?, "Diterima", "System")';
      db.query(historyQuery, [result.insertId], (histErr) => {
        if (histErr) console.error('Error inserting initial status history:', histErr);
      });

      res.status(201).json({ message: 'Booking berhasil dibuat', bookingId: result.insertId });
    });
  }
});



const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server berjalan di port ${PORT}`);
  console.log(`\n=== KREDENSIAL OWNER ===`);
  console.log(`Email: owner@laundry.com`);
  console.log(`Pass : admin`);
  console.log(`========================\n`);
});