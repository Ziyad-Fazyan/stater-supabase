-- Admin Table (untuk login admin saja, tidak ada register)
DROP TABLE IF EXISTS admins CASCADE;
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Parents/Wali Table (berdasarkan siswa)
DROP TABLE IF EXISTS parents CASCADE;
CREATE TABLE IF NOT EXISTS parents (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT,
  address TEXT NOT NULL,
  relationship TEXT, -- 'ayah', 'ibu', 'wali'
  created_by UUID REFERENCES admins(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Students Table (Wisudawan)
DROP TABLE IF EXISTS students CASCADE;
CREATE TABLE IF NOT EXISTS students (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  parent_id UUID REFERENCES parents(id) ON DELETE SET NULL,
  student_number TEXT UNIQUE,
  graduation_status TEXT DEFAULT 'registered', -- 'registered', 'confirmed', 'graduated'
  created_by UUID REFERENCES admins(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Graduation Events Table (Event Wisuda)
DROP TABLE IF EXISTS graduation_events CASCADE;
CREATE TABLE IF NOT EXISTS graduation_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_name TEXT NOT NULL,
  event_description TEXT,
  graduation_date DATE NOT NULL,
  graduation_time TIME NOT NULL,
  venue TEXT NOT NULL,
  venue_address TEXT NOT NULL,
  total_capacity INTEGER DEFAULT 0,
  current_registrations INTEGER DEFAULT 0,
  registration_deadline DATE,
  event_status TEXT DEFAULT 'planning', -- 'planning', 'open', 'closed', 'completed'
  created_by UUID REFERENCES admins(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Student Graduation Registration (Pendaftaran Wisuda Siswa)
DROP TABLE IF EXISTS student_graduations CASCADE;
CREATE TABLE IF NOT EXISTS student_graduations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  graduation_event_id UUID REFERENCES graduation_events(id) ON DELETE CASCADE,
  registration_status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  seat_number TEXT,
  notes TEXT,
  registered_by UUID REFERENCES admins(id) ON DELETE SET NULL,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(student_id, graduation_event_id)
);

-- Graduation Invitations (Undangan Wisuda - bisa berdasarkan student atau tidak)
DROP TABLE IF EXISTS graduation_invitations CASCADE;
CREATE TABLE IF NOT EXISTS graduation_invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  email TEXT,
  student_id UUID REFERENCES students(id) ON DELETE SET NULL, -- opsional, bisa null jika bukan berdasarkan student
  graduation_event_id UUID REFERENCES graduation_events(id) ON DELETE CASCADE,
  relationship_to_student TEXT, -- jika berdasarkan student: 'orangtua', 'keluarga', 'saudara', 'teman', dll
  invitation_type TEXT NOT NULL, -- 'family', 'vip', 'staff', 'external'
  invitation_code TEXT UNIQUE, -- kode unik undangan
  invitation_status TEXT DEFAULT 'sent', -- 'sent', 'confirmed', 'declined', 'attended'
  seat_category TEXT, -- 'family', 'vip', 'general'
  seat_number TEXT,
  qr_code TEXT, -- untuk scanning masuk
  response_note TEXT,
  notes TEXT, -- catatan admin
  created_by UUID REFERENCES admins(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);