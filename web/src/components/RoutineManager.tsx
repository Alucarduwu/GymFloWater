import { useState } from 'react';
import { Plus, Trash2, Dumbbell, X, Calendar, ChevronRight, Check } from 'lucide-react';
import { Routine, Exercise, Set, MUSCLE_GROUPS, MuscleGroup } from '../types';
import { motion, AnimatePresence } from 'motion/react';

export default function RoutineManager({ routines, onSave, onDelete }: { routines: Routine[], onSave: (r: Routine) => void, onDelete: (id: string) => void }) {
  const [isCreating, setIsCreating] = useState(false);
  const [name, setName] = useState("");
  const [selectedExs, setSelectedExs] = useState<Exercise[]>([]);
  const [days, setDays] = useState<number[]>([]);

  const DAYS = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

  const addExercise = () => {
    const newEx: Exercise = {
      id: Math.random().toString(36).substr(2, 9),
      name: "Nuevo Ejercicio",
      muscleGroup: "Pecho",
      sets: [{ id: Math.random().toString(36).substr(2, 9), weight: 0, reps: 0, completed: false }]
    };
    setSelectedExs([...selectedExs, newEx]);
  };

  const save = () => {
    if (!name || selectedExs.length === 0) return;
    onSave({
      id: Math.random().toString(36).substr(2, 9),
      name,
      exercises: selectedExs,
      daysOfWeek: days
    });
    setIsCreating(false);
    setName("");
    setSelectedExs([]);
    setDays([]);
  };

  return (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="space-y-8 pb-32">
      <div className="flex items-center justify-between">
        <h2 className="text-3xl font-black heading-gradient">Mis Rutinas</h2>
        {!isCreating && (
          <button onClick={() => setIsCreating(true)} className="w-12 h-12 btn-primary rounded-2xl flex items-center justify-center">
            <Plus size={24} />
          </button>
        )}
      </div>

      <AnimatePresence mode="wait">
        {isCreating ? (
          <motion.div key="create" initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} exit={{ opacity: 0, scale: 0.9 }} className="space-y-6">
            <div className="glass-card p-6 rounded-[2.5rem] space-y-6">
              <div className="flex items-center justify-between">
                <input 
                  value={name} 
                  onChange={e => setName(e.target.value)}
                  placeholder="Nombre de la rutina..." 
                  className="bg-transparent border-none outline-none text-2xl font-black text-white w-full"
                />
                <button onClick={() => setIsCreating(false)} className="text-slate-600 hover:text-white transition-colors">
                  <X size={20} />
                </button>
              </div>

              <div className="space-y-3">
                <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Días Programados</p>
                <div className="flex justify-between gap-1">
                  {DAYS.map((d, i) => (
                    <button 
                      key={i} 
                      onClick={() => setDays(days.includes(i) ? days.filter(x => x !== i) : [...days, i])}
                      className={`flex-1 aspect-square rounded-xl text-[10px] font-black transition-all border ${
                        days.includes(i) ? 'bg-accent border-accent text-white shadow-lg shadow-accent/20' : 'bg-white/5 border-white/5 text-slate-600'
                      }`}
                    >
                      {d}
                    </button>
                  ))}
                </div>
              </div>

              <div className="space-y-4">
                <p className="text-[10px] font-black text-slate-500 uppercase tracking-widest px-1">Ejercicios</p>
                {selectedExs.map((ex, idx) => (
                  <div key={ex.id} className="p-4 bg-white/5 rounded-2xl border border-white/5 flex items-center justify-between group">
                    <div className="flex flex-col gap-1">
                      <input 
                        value={ex.name} 
                        onChange={e => {
                          const newExs = [...selectedExs];
                          newExs[idx].name = e.target.value;
                          setSelectedExs(newExs);
                        }}
                        className="bg-transparent border-none outline-none font-bold text-sm text-white"
                      />
                      <select 
                        value={ex.muscleGroup}
                        onChange={e => {
                          const newExs = [...selectedExs];
                          newExs[idx].muscleGroup = e.target.value as MuscleGroup;
                          setSelectedExs(newExs);
                        }}
                        className="bg-transparent border-none outline-none text-[8px] font-black text-accent uppercase tracking-widest p-0"
                      >
                        {MUSCLE_GROUPS.map(m => <option key={m} value={m} className="bg-surface">{m}</option>)}
                      </select>
                    </div>
                    <button onClick={() => setSelectedExs(selectedExs.filter(e => e.id !== ex.id))} className="text-slate-800 hover:text-red-500 transition-colors">
                      <Trash2 size={14} />
                    </button>
                  </div>
                ))}
                
                <button onClick={addExercise} className="w-full py-4 border-2 border-dashed border-white/10 rounded-2xl text-[9px] font-black uppercase tracking-widest text-slate-600 hover:bg-white/5 transition-all flex items-center justify-center gap-2">
                  <Plus size={14} /> Añadir Ejercicio
                </button>
              </div>

              <button onClick={save} className="w-full py-4 btn-primary rounded-2xl text-[10px] font-black uppercase tracking-widest">
                Guardar Rutina
              </button>
            </div>
          </motion.div>
        ) : (
          <div className="grid gap-4">
            {routines.map(r => (
              <div key={r.id} className="glass-card p-6 rounded-[2.5rem] flex items-center justify-between group border-accent/0 hover:border-accent/30">
                <div className="flex items-center gap-5">
                  <div className="w-14 h-14 rounded-2xl bg-accent/10 flex items-center justify-center text-accent group-hover:scale-110 transition-transform">
                    <Dumbbell size={24} />
                  </div>
                  <div>
                    <h3 className="text-xl font-black text-white group-hover:text-accent transition-colors">{r.name}</h3>
                    <div className="flex gap-1 mt-2">
                      {DAYS.map((d, i) => (
                        <div key={i} className={`w-4 h-4 rounded-md flex items-center justify-center text-[7px] font-black transition-all ${r.daysOfWeek?.includes(i) ? 'bg-accent text-white' : 'bg-white/5 text-slate-800'}`}>
                          {d}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
                <button onClick={() => onDelete(r.id)} className="p-3 text-slate-800 hover:text-red-500 transition-colors">
                  <Trash2 size={18} />
                </button>
              </div>
            ))}
            {routines.length === 0 && (
              <div className="py-20 text-center space-y-4">
                <div className="w-20 h-20 bg-white/5 rounded-3xl flex items-center justify-center text-slate-800 mx-auto border-2 border-dashed border-white/5">
                  <Dumbbell size={32} />
                </div>
                <p className="text-slate-600 text-xs font-bold uppercase tracking-widest">No hay rutinas guardadas</p>
              </div>
            )}
          </div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}
