import { useState, useEffect } from 'react';
import { Play, Pause, RotateCcw, Timer as TimerIcon } from 'lucide-react';

interface TimerProps {
  onComplete?: () => void;
}

export default function Timer({ onComplete }: TimerProps) {
  const [seconds, setSeconds] = useState(60);
  const [isActive, setIsActive] = useState(false);

  useEffect(() => {
    let interval: any = null;
    if (isActive && seconds > 0) {
      interval = setInterval(() => {
        setSeconds((seconds) => seconds - 1);
      }, 1000);
    } else if (seconds === 0) {
      setIsActive(false);
      onComplete?.();
    }
    return () => clearInterval(interval);
  }, [isActive, seconds, onComplete]);

  const toggle = () => setIsActive(!isActive);
  const reset = () => {
    setSeconds(60);
    setIsActive(false);
  };

  const formatTime = (s: number) => {
    const mins = Math.floor(s / 60);
    const secs = s % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="bg-blue-900 text-white p-4 rounded-2xl shadow-xl flex items-center justify-between gap-4">
      <div className="flex items-center gap-3">
        <div className="bg-blue-500/20 p-2 rounded-lg">
          <TimerIcon size={20} className="text-blue-400" />
        </div>
        <div>
          <p className="text-[10px] font-bold text-blue-400 uppercase tracking-widest leading-none mb-1">Descanso</p>
          <p className="text-2xl font-mono font-black leading-none">{formatTime(seconds)}</p>
        </div>
      </div>
      
      <div className="flex items-center gap-2">
        <button 
          onClick={reset}
          className="p-2 hover:bg-blue-800 rounded-xl transition-colors text-blue-400"
        >
          <RotateCcw size={20} />
        </button>
        <button 
          onClick={toggle}
          className={`p-3 rounded-xl transition-all shadow-lg ${
            isActive ? 'bg-blue-600 text-white' : 'bg-blue-500 text-white'
          }`}
        >
          {isActive ? <Pause size={20} /> : <Play size={20} />}
        </button>
      </div>
    </div>
  );
}
