import { useState, useEffect, useRef, memo, useCallback } from 'react';
import { Plus, Trash2, CheckCircle2, Dumbbell, Clock, ChevronRight, X, Sparkles } from 'lucide-react';
import { Workout, Exercise, Set, Routine, SetType, SET_TYPES } from '../types';
import { motion, AnimatePresence } from 'motion/react';

export default function WorkoutLogger({ routine, onSave, onCancel }: { routine: Routine | null, onSave: (w: Workout) => void, onCancel: () => void }) {
  const [name, setName] = useState(routine?.name || "Nuevo Entrenamiento");
  const [exercises, setExercises] = useState<Exercise[]>(routine?.exercises.map(ex => ({
    ...ex,
    sets: ex.sets.map(s => ({ ...s, completed: false }))
  })) || []);
  const [startTime] = useState(Date.now());
  const [elapsed, setElapsed] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => setElapsed(Math.floor((Date.now() - startTime) / 1000)), 1000);
    return () => clearInterval(timer);
  }, [startTime]);

  const addExercise = () => {
    const newEx: Exercise = {
      id: Math.random().toString(36).substr(2, 9),
      name: "Nuevo Ejercicio",
      muscleGroup: "Pecho",
      sets: [{ id: Math.random().toString(36).substr(2, 9), weight: 0, reps: 0, completed: false }]
    };
    setExercises([...exercises, newEx]);
  };

  const addSet = (exId: string) => {
    setExercises(exercises.map(ex => {
      if (ex.id === exId) {
        const last = ex.sets[ex.sets.length - 1];
        return { ...ex, sets: [...ex.sets, { id: Math.random().toString(36).substr(2, 9), weight: last?.weight || 0, reps: last?.reps || 0, completed: false }] };
      }
      return ex;
    }));
  };

  const updateSet = (exId: string, setId: string, updates: Partial<Set>) => {
    setExercises(exercises.map(ex => {
      if (ex.id === exId) {
        return { ...ex, sets: ex.sets.map(s => s.id === setId ? { ...s, ...updates } : s) };
      }
      return ex;
    }));
  };

  const totalVolume = exercises.reduce((acc, ex) => 
    acc + ex.sets.reduce((sAcc, s) => sAcc + (s.weight * s.reps), 0), 0
  );

  const handleFinish = () => {
    if (exercises.length === 0) return;
    onSave({
      id: Math.random().toString(36).substr(2, 9),
      date: new Date().toISOString(),
      name,
      exercises,
      duration: elapsed,
      totalVolume
    });
  };

  return (
    <motion.div initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} className="space-y-8 pb-40">
      {/* Header Info */}
      <div className="flex items-center justify-between sticky top-0 bg-surface/80 backdrop-blur-xl py-4 z-50">
        <div>
          <h2 className="text-xl font-black heading-gradient">{name}</h2>
          <div className="flex items-center gap-3 mt-1">
            <span className="text-[10px] font-black text-accent uppercase tracking-widest flex items-center gap-1">
              <Clock size={10} /> {Math.floor(elapsed / 60)}:{(elapsed % 60).toString().padStart(2, '0')}
            </span>
            <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest">{totalVolume.toLocaleString()} KG TOTAL</span>
          </div>
        </div>
        <button onClick={onCancel} className="p-2 text-slate-500 hover:text-white transition-colors">
          <X size={20} />
        </button>
      </div>

      <div className="space-y-6">
        {exercises.map((ex, exIdx) => (
          <div key={ex.id} className="glass-card rounded-[2rem] overflow-hidden">
            <div className="p-6 border-b border-white/5 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-xl bg-accent/10 flex items-center justify-center text-accent">
                  <Dumbbell size={18} />
                </div>
                <input 
                  value={ex.name} 
                  onChange={e => {
                    const newExs = [...exercises];
                    newExs[exIdx].name = e.target.value;
                    setExercises(newExs);
                  }}
                  className="bg-transparent border-none outline-none font-black text-white text-lg w-full"
                />
              </div>
              <button onClick={() => setExercises(exercises.filter(e => e.id !== ex.id))} className="text-slate-700 hover:text-red-500 transition-colors">
                <Trash2 size={16} />
              </button>
            </div>

            <div className="p-6 space-y-4">
              <div className="grid grid-cols-12 gap-2 text-[8px] font-bold text-slate-600 uppercase tracking-widest px-2">
                <div className="col-span-2">Serie</div>
                <div className="col-span-4">Kilos</div>
                <div className="col-span-4">Reps</div>
                <div className="col-span-2">Ok</div>
              </div>

              {ex.sets.map((s, sIdx) => (
                <div key={s.id} className="grid grid-cols-12 gap-2 items-center">
                  <div className="col-span-2 text-xs font-black text-slate-700">{sIdx + 1}</div>
                  <input 
                    type="number" 
                    value={s.weight || ''} 
                    onChange={e => updateSet(ex.id, s.id, { weight: parseFloat(e.target.value) || 0 })}
                    className="col-span-4 bg-white/5 border border-white/5 p-3 rounded-xl text-center text-xs font-black focus:border-accent/40 focus:ring-0"
                    placeholder="0"
                  />
                  <input 
                    type="number" 
                    value={s.reps || ''} 
                    onChange={e => updateSet(ex.id, s.id, { reps: parseInt(e.target.value) || 0 })}
                    className="col-span-4 bg-white/5 border border-white/5 p-3 rounded-xl text-center text-xs font-black focus:border-accent/40 focus:ring-0"
                    placeholder="0"
                  />
                  <button 
                    onClick={() => updateSet(ex.id, s.id, { completed: !s.completed })}
                    className={`col-span-2 aspect-square rounded-xl flex items-center justify-center border transition-all ${
                      s.completed ? 'bg-accent/20 border-accent text-accent' : 'bg-white/5 border-white/5 text-slate-800'
                    }`}
                  >
                    <CheckCircle2 size={16} />
                  </button>
                </div>
              ))}

              <button 
                onClick={() => addSet(ex.id)}
                className="w-full py-4 border-2 border-dashed border-white/5 rounded-2xl text-[9px] font-black uppercase tracking-widest text-slate-600 hover:bg-white/5 transition-all flex items-center justify-center gap-2"
              >
                <Plus size={14} /> Añadir Serie
              </button>
            </div>
          </div>
        ))}

        <button 
          onClick={addExercise}
          className="w-full py-6 bg-accent/5 border border-accent/20 rounded-[2rem] text-accent text-xs font-black uppercase tracking-widest flex items-center justify-center gap-3 active:scale-95 transition-all"
        >
          <Plus size={20} /> Añadir Ejercicio
        </button>
      </div>

      <div className="fixed bottom-10 left-0 right-0 px-6 z-50">
        <button 
          onClick={handleFinish}
          className="w-full py-5 btn-primary rounded-2xl text-[10px] font-black uppercase tracking-[0.2em] flex items-center justify-center gap-3"
        >
          Finalizar Entrenamiento
        </button>
      </div>
    </motion.div>
  );
}
