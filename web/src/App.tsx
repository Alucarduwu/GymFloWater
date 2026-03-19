import { useState, useEffect, useMemo, memo } from 'react';
import { 
  LayoutDashboard, 
  Dumbbell, 
  BookOpen, 
  User as UserIcon,
  Calendar as CalendarIcon,
  Plus,
  Play,
  TrendingUp,
  Flame,
  ChevronRight,
  Sparkles,
  Waves,
  Search,
  Filter
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import WorkoutLogger from './components/WorkoutLogger';
import ProgressChart from './components/ProgressChart';
import RoutineManager from './components/RoutineManager';
import ExerciseLibrary from './components/ExerciseLibrary';
import { Workout, Routine, MUSCLE_CATEGORIES } from './types';

type Tab = 'dashboard' | 'workout' | 'routines' | 'library' | 'profile';

export default function App() {
  const [activeTab, setActiveTab] = useState<Tab>('dashboard');
  const [workouts, setWorkouts] = useState<Workout[]>([]);
  const [routines, setRoutines] = useState<Routine[]>([]);
  const [selectedRoutine, setSelectedRoutine] = useState<Routine | null>(null);
  const [userName, setUserName] = useState("Usuario");
  const [userGender, setUserGender] = useState<"hombre" | "mujer">("hombre");

  useEffect(() => {
    const savedWorkouts = localStorage.getItem('gym_workouts');
    const savedRoutines = localStorage.getItem('gym_routines');
    const savedProfile = localStorage.getItem('gym_profile');
    
    if (savedWorkouts) setWorkouts(JSON.parse(savedWorkouts));
    if (savedRoutines) setRoutines(JSON.parse(savedRoutines));
    if (savedProfile) {
      const p = JSON.parse(savedProfile);
      setUserName(p.name || "Usuario");
      setUserGender(p.gender || "hombre");
    }
  }, []);

  const handleSaveWorkout = (workout: Workout) => {
    const newWorkouts = [workout, ...workouts];
    setWorkouts(newWorkouts);
    localStorage.setItem('gym_workouts', JSON.stringify(newWorkouts));
    setActiveTab('dashboard');
    setSelectedRoutine(null);
  };

  const streak = useMemo(() => {
    if (workouts.length === 0) return 0;
    // Simple mock streak for now
    return 12; 
  }, [workouts]);

  const totalVolume = useMemo(() => {
    return workouts.reduce((acc, w) => acc + (w.totalVolume || 0), 0);
  }, [workouts]);

  const thisWeekVolume = useMemo(() => {
    const now = new Date();
    const startOfWeek = new Date(now.setDate(now.getDate() - now.getDay()));
    startOfWeek.setHours(0,0,0,0);
    return workouts
      .filter(w => new Date(w.date) >= startOfWeek)
      .reduce((acc, w) => acc + (w.totalVolume || 0), 0);
  }, [workouts]);

  const startWorkout = (routine?: Routine) => {
    setSelectedRoutine(routine || null);
    setActiveTab('workout');
  };

  const updateProfile = (name: string, gender: "hombre" | "mujer") => {
    setUserName(name);
    setUserGender(gender);
    localStorage.setItem('gym_profile', JSON.stringify({ name, gender }));
  };

  return (
    <div className="min-h-screen text-white font-sans selection:bg-accent/30 selection:text-white relative pb-24 sm:pb-32">
      <div className="deep-sea-bg" />
      
      {/* Dynamic Bubbles */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden z-0">
        {[...Array(8)].map((_, i) => (
          <div key={i} className="bubble" style={{ 
            left: `${Math.random() * 100}%`, 
            width: `${Math.random() * 40 + 10}px`, 
            height: `${Math.random() * 40 + 10}px`,
            animationDelay: `${Math.random() * 10}s`,
            animationDuration: `${Math.random() * 15 + 10}s`
          }} />
        ))}
      </div>

      {/* Main Content Area */}
      <main className="w-full max-w-2xl mx-auto px-4 sm:px-6 pt-6 relative z-10">
        <AnimatePresence mode="wait">
          {activeTab === 'dashboard' && (
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -20 }} className="space-y-8">
              {/* Header */}
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-accent text-[10px] font-black uppercase tracking-[0.3em] mb-1">Bienvenido de vuelta</p>
                  <h1 className="text-3xl font-black heading-gradient">{userName}</h1>
                </div>
                <div className="w-12 h-12 rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center text-2xl shadow-xl">
                  {userGender === 'mujer' ? '👩' : '👨'}
                </div>
              </div>

              {/* Bento Stats */}
              <div className="grid grid-cols-2 gap-4">
                <div className="glass-card p-6 rounded-[2.5rem] relative overflow-hidden group">
                  <div className="absolute -right-4 -top-4 text-accent/10 rotate-12 group-hover:rotate-45 transition-transform duration-700">
                    <Flame size={80} />
                  </div>
                  <div className="relative">
                    <div className="flex items-center gap-2 mb-2 text-accent">
                      <Flame size={14} fill="currentColor" />
                      <span className="text-[10px] font-black uppercase tracking-widest">Racha</span>
                    </div>
                    <div className="flex items-baseline gap-1">
                      <span className="text-4xl font-black">{streak}</span>
                      <span className="text-[10px] font-bold text-slate-500 uppercase">Días</span>
                    </div>
                  </div>
                </div>
                <div className="glass-card p-6 rounded-[2.5rem] relative overflow-hidden group">
                  <div className="absolute -right-4 -top-4 text-accent/10 rotate-12 group-hover:rotate-45 transition-transform duration-700">
                    <TrendingUp size={80} />
                  </div>
                  <div className="relative">
                    <div className="flex items-center gap-2 mb-2 text-accent">
                      <TrendingUp size={14} />
                      <span className="text-[10px] font-black uppercase tracking-widest">Volumen</span>
                    </div>
                    <div className="flex items-baseline gap-1">
                      <span className="text-4xl font-black">{Math.floor(thisWeekVolume / 1000)}k</span>
                      <span className="text-[10px] font-bold text-slate-500 uppercase">Kg/Sem</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Training Zone - Main Entry */}
              <section className="space-y-4">
                <div className="flex items-center justify-between">
                  <h2 className="text-xs font-black text-slate-500 uppercase tracking-widest px-2">Entrenar Hoy</h2>
                  <button onClick={() => setActiveTab('routines')} className="text-[10px] font-black text-accent uppercase tracking-widest hover:underline">Ver todas</button>
                </div>

                <div className="grid gap-3">
                  {routines.length > 0 ? routines.slice(0, 3).map(r => (
                    <button key={r.id} onClick={() => startWorkout(r)} className="glass-card w-full p-6 py-8 rounded-[2rem] text-left flex items-center justify-between group">
                      <div className="flex items-center gap-5">
                        <div className="w-14 h-14 rounded-2xl bg-accent/10 border border-accent/20 flex items-center justify-center text-accent group-hover:scale-110 transition-transform">
                          <Dumbbell size={24} />
                        </div>
                        <div>
                          <h3 className="text-xl font-black text-white mb-1 group-hover:text-accent transition-colors">{r.name}</h3>
                          <p className="text-[10px] font-bold text-slate-500 uppercase tracking-widest">{r.exercises.length} Ejercicios • Sugerido</p>
                        </div>
                      </div>
                      <div className="w-10 h-10 rounded-full border border-white/5 flex items-center justify-center text-slate-500 group-hover:bg-accent group-hover:text-white transition-all">
                        <Play size={16} fill="currentColor" className="ml-0.5" />
                      </div>
                    </button>
                  )) : (
                    <button onClick={() => setActiveTab('routines')} className="glass-card w-full p-8 rounded-[2rem] border-2 border-dashed border-white/5 flex flex-col items-center justify-center gap-3 text-slate-500">
                      <Plus size={24} />
                      <span className="text-[10px] font-black uppercase tracking-widest">Crea tu primera rutina</span>
                    </button>
                  )}
                  
                  <button onClick={() => startWorkout()} className="w-full py-5 bg-white/5 border border-white/10 rounded-3xl text-[10px] font-black uppercase tracking-widest hover:bg-white/10 transition-all flex items-center justify-center gap-2">
                    <Plus size={16} /> Rutina Vacía (Entreno libre)
                  </button>
                </div>
              </section>

              {/* Progress Chart */}
              <section className="space-y-4">
                <h2 className="text-xs font-black text-slate-500 uppercase tracking-widest px-2">Análisis de Progreso</h2>
                <ProgressChart workouts={workouts} />
              </section>
            </motion.div>
          )}

          {activeTab === 'library' && <ExerciseLibrary onQuickStart={(name) => startWorkout()} />}
          {activeTab === 'routines' && <RoutineManager routines={routines} onSave={(r) => {
            const newR = [...routines, r];
            setRoutines(newR);
            localStorage.setItem('gym_routines', JSON.stringify(newR));
          }} />}
          {activeTab === 'workout' && <WorkoutLogger routine={selectedRoutine} onSave={handleSaveWorkout} onCancel={() => setActiveTab('dashboard')} />}
          {activeTab === 'profile' && <ProfileView name={userName} gender={userGender} updateProfile={updateProfile} />}
        </AnimatePresence>
      </main>

      {/* Modern Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 z-[100] safe-pb px-4 pointer-events-none">
        <div className="max-w-md mx-auto pointer-events-auto">
          <div className="nav-glass mb-4 p-3 rounded-[2.5rem] flex items-center justify-between">
            <NavIcon active={activeTab === 'dashboard'} onClick={() => setActiveTab('dashboard')} icon={<LayoutDashboard size={22} />} label="Inicio" />
            <NavIcon active={activeTab === 'library'} onClick={() => setActiveTab('library')} icon={<BookOpen size={22} />} label="Biblioteca" />
            
            <button 
              onClick={() => startWorkout()}
              className="w-16 h-16 btn-primary rounded-3xl flex items-center justify-center -translate-y-6 border-[6px] border-[#010409]"
            >
              <Plus size={32} />
            </button>

            <NavIcon active={activeTab === 'routines'} onClick={() => setActiveTab('routines')} icon={<CalendarIcon size={22} />} label="Rutinas" />
            <NavIcon active={activeTab === 'profile'} onClick={() => setActiveTab('profile')} icon={<UserIcon size={22} />} label="Perfil" />
          </div>
        </div>
      </nav>
    </div>
  );
}

function NavIcon({ active, onClick, icon, label }: any) {
  return (
    <button onClick={onClick} className={`flex flex-col items-center gap-1 transition-all ${active ? 'text-accent scale-110' : 'text-slate-500'}`}>
      <div className={`p-2 rounded-2xl ${active ? 'bg-accent/10' : ''}`}>{icon}</div>
      <span className="text-[8px] font-black uppercase tracking-widest">{label}</span>
    </button>
  );
}

function ProfileView({ name, gender, updateProfile }: any) {
  const [editing, setEditing] = useState(false);
  const [tempName, setTempName] = useState(name);
  const [tempGender, setTempGender] = useState(gender);

  return (
    <motion.div initial={{ opacity: 0, scale: 0.95 }} animate={{ opacity: 1, scale: 1 }} className="space-y-8 pb-32">
      <div className="glass-card p-10 rounded-[3rem] text-center">
        <div className="w-24 h-24 mx-auto bg-gradient-to-br from-accent to-blue-900 rounded-[2rem] flex items-center justify-center text-4xl mb-6 shadow-2xl border-2 border-white/10">
          {gender === 'mujer' ? '👩' : '👨'}
        </div>
        {!editing ? (
          <>
            <h2 className="text-3xl font-black mb-1">{name}</h2>
            <p className="text-accent text-[10px] font-black uppercase tracking-widest mb-6">Nivel: Marine Elite</p>
            <button onClick={() => setEditing(true)} className="px-6 py-2 bg-white/5 rounded-xl text-[10px] font-black uppercase tracking-widest border border-white/5">Editar Perfil</button>
          </>
        ) : (
          <div className="space-y-4">
            <input value={tempName} onChange={e => setTempName(e.target.value)} className="w-full bg-white/5 border border-white/10 p-3 rounded-xl text-center font-bold" placeholder="Tu Nombre" />
            <div className="flex gap-2">
              <button onClick={() => setTempGender('hombre')} className={`flex-1 p-3 rounded-xl text-[10px] font-black uppercase border transition-all ${tempGender === 'hombre' ? 'bg-accent border-accent' : 'border-white/10'}`}>Hombre</button>
              <button onClick={() => setTempGender('mujer')} className={`flex-1 p-3 rounded-xl text-[10px] font-black uppercase border transition-all ${tempGender === 'mujer' ? 'bg-accent border-accent' : 'border-white/10'}`}>Mujer</button>
            </div>
            <button onClick={() => { updateProfile(tempName, tempGender); setEditing(false); }} className="w-full btn-primary py-3 rounded-xl text-[10px] font-black uppercase">Guardar</button>
          </div>
        )}
      </div>

      <div className="grid grid-cols-3 gap-4">
        {[
          { label: 'Entrenos', val: '24' },
          { label: 'Logros', val: '8' },
          { label: 'Rango', val: 'Pez Espada' }
        ].map(s => (
          <div key={s.label} className="glass-card p-4 rounded-3xl text-center">
            <p className="text-[8px] font-black text-slate-500 uppercase tracking-widest mb-1">{s.label}</p>
            <p className="text-sm font-black text-white">{s.val}</p>
          </div>
        ))}
      </div>
    </motion.div>
  );
}
