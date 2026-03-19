import { useState, useMemo } from 'react';
import { 
  Search, 
  Dumbbell, 
  Target, 
  Info,
  Layers,
  Sparkles,
  ChevronRight,
  Filter
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { MuscleGroup, MUSCLE_CATEGORIES, MUSCLE_GROUPS } from '../types';

interface LibraryExercise {
  name: string;
  muscle: MuscleGroup;
  category: "Superior" | "Inferior" | "Core";
}

const PRESET_EXERCISES: LibraryExercise[] = [
  { name: "Press de Banca", muscle: "Pecho", category: "Superior" },
  { name: "Press Inclinado", muscle: "Pecho", category: "Superior" },
  { name: "Aperturas con Polea", muscle: "Pecho", category: "Superior" },
  { name: "Dominadas", muscle: "Espalda", category: "Superior" },
  { name: "Remo con Barra", muscle: "Espalda", category: "Superior" },
  { name: "Jalón al Pecho", muscle: "Espalda", category: "Superior" },
  { name: "Press Militar", muscle: "Hombros", category: "Superior" },
  { name: "Elevaciones Laterales", muscle: "Hombros", category: "Superior" },
  { name: "Face Pulls", muscle: "Hombros", category: "Superior" },
  { name: "Curl con Barra", muscle: "Bicep", category: "Superior" },
  { name: "Curl Martillo", muscle: "Bicep", category: "Superior" },
  { name: "Press Francés", muscle: "Tricep", category: "Superior" },
  { name: "Extensión en Polea", muscle: "Tricep", category: "Superior" },
  { name: "Encogimientos", muscle: "Trapecio", category: "Superior" },
  { name: "Curl de Antebrazo", muscle: "Antebrazo", category: "Superior" },
  { name: "Sentadilla Libre", muscle: "Pierna Completa", category: "Inferior" },
  { name: "Prensa de Piernas", muscle: "Pierna Completa", category: "Inferior" },
  { name: "Hip Thrust", muscle: "Glúteo", category: "Inferior" },
  { name: "Extensión de Cuádriceps", muscle: "Cuádriceps", category: "Inferior" },
  { name: "Curl Femoral", muscle: "Femoral", category: "Inferior" },
  { name: "Peso Muerto Rumano", muscle: "Femoral", category: "Inferior" },
  { name: "Elevación de Talones", muscle: "Pantorrilla", category: "Inferior" },
  { name: "Crunch Abdominal", muscle: "Abdomen", category: "Core" },
  { name: "Elevación de Piernas", muscle: "Abdomen", category: "Core" },
  { name: "Plancha", muscle: "Abdomen", category: "Core" },
];

export default function ExerciseLibrary({ onQuickStart }: { onQuickStart: (name: string) => void }) {
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState<"Todos" | "Superior" | "Inferior" | "Core">("Todos");
  const [selectedMuscle, setSelectedMuscle] = useState<MuscleGroup | "Todos">("Todos");

  const filtered = useMemo(() => {
    return PRESET_EXERCISES.filter(ex => {
      const matchesSearch = ex.name.toLowerCase().includes(search.toLowerCase());
      const matchesCategory = filter === "Todos" || ex.category === filter;
      const matchesMuscle = selectedMuscle === "Todos" || ex.muscle === selectedMuscle;
      return matchesSearch && matchesCategory && matchesMuscle;
    });
  }, [search, filter, selectedMuscle]);

  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="space-y-8 pb-32">
      {/* Header & Search */}
      <div className="space-y-6">
        <div>
          <h2 className="text-3xl font-black heading-gradient">Biblioteca</h2>
          <p className="text-slate-500 text-[10px] font-black uppercase tracking-widest mt-1">Explora y selecciona tus ejercicios</p>
        </div>

        <div className="relative group">
          <div className="absolute inset-0 bg-accent/20 blur-2xl group-focus-within:bg-accent/40 transition-all opacity-0 group-focus-within:opacity-100" />
          <div className="relative glass-card flex items-center gap-4 px-6 py-4 rounded-3xl border-white/10 group-focus-within:border-accent/40 transition-all">
            <Search className="text-slate-500 group-focus-within:text-accent transition-colors" size={20} />
            <input 
              value={search} 
              onChange={e => setSearch(e.target.value)}
              placeholder="Buscar ejercicio..." 
              className="bg-transparent border-none outline-none w-full font-bold text-white placeholder:text-slate-600"
            />
          </div>
        </div>

        {/* Categories */}
        <div className="flex gap-2 overflow-x-auto no-scrollbar pb-2">
          {["Todos", "Superior", "Inferior", "Core"].map((cat: any) => (
            <button 
              key={cat} 
              onClick={() => { setFilter(cat); setSelectedMuscle("Todos"); }}
              className={`px-6 py-2.5 rounded-2xl text-[10px] font-black uppercase tracking-widest transition-all whitespace-nowrap border ${
                filter === cat ? 'bg-accent border-accent text-white shadow-lg shadow-accent/20' : 'bg-white/5 border-white/10 text-slate-500'
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Muscle Specific Sub-filters */}
        <div className="flex gap-2 overflow-x-auto no-scrollbar pb-2">
          {["Todos", ...MUSCLE_GROUPS.filter(m => filter === "Todos" || MUSCLE_CATEGORIES[m as MuscleGroup] === filter)].map((m: any) => (
            <button 
              key={m} 
              onClick={() => setSelectedMuscle(m)}
              className={`px-4 py-2 rounded-xl text-[9px] font-black uppercase tracking-widest transition-all whitespace-nowrap border ${
                selectedMuscle === m ? 'bg-white text-surface border-white scale-105 shadow-xl' : 'bg-white/5 border-white/5 text-slate-600'
              }`}
            >
              {m}
            </button>
          ))}
        </div>
      </div>

      {/* Grid List */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <AnimatePresence mode='popLayout'>
          {filtered.map((ex) => (
            <motion.div 
              layout 
              key={ex.name} 
              initial={{ opacity: 0, scale: 0.9 }} 
              animate={{ opacity: 1, scale: 1 }}
              className="glass-card p-6 rounded-3xl flex items-center justify-between group cursor-pointer"
              onClick={() => onQuickStart(ex.name)}
            >
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center text-slate-500 group-hover:bg-accent/10 group-hover:text-accent transition-all">
                  <Dumbbell size={20} />
                </div>
                <div>
                  <h4 className="font-black text-white group-hover:text-accent transition-colors">{ex.name}</h4>
                  <p className="text-[9px] font-black text-slate-600 uppercase tracking-widest mt-0.5">{ex.muscle}</p>
                </div>
              </div>
              <ChevronRight className="text-slate-700 group-hover:text-white group-hover:translate-x-1 transition-all" size={16} />
            </motion.div>
          ))}
        </AnimatePresence>
      </div>
    </motion.div>
  );
}
