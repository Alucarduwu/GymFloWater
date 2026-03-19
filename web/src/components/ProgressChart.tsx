import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Area, AreaChart } from 'recharts';
import { Workout } from '../types';
import { useMemo } from 'react';

export default function ProgressChart({ workouts }: { workouts: Workout[] }) {
  const chartData = useMemo(() => {
    return [...workouts]
      .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
      .slice(-7)
      .map(w => ({
        date: new Date(w.date).toLocaleDateString('es-ES', { day: 'numeric', month: 'short' }),
        volume: w.totalVolume || 0
      }));
  }, [workouts]);

  return (
    <div className="glass-card p-8 rounded-[3rem] h-80 relative overflow-hidden group">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h3 className="text-[10px] font-black text-accent uppercase tracking-widest px-1">Volumen Cargado</h3>
          <p className="text-[8px] font-bold text-slate-600 uppercase tracking-widest px-1 mt-0.5">Últimas 7 sesiones</p>
        </div>
      </div>
      
      <div className="w-full h-[70%]">
        <ResponsiveContainer width="100%" height="100%">
          <AreaChart data={chartData}>
            <defs>
              <linearGradient id="colorVol" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="rgba(255,255,255,0.03)" />
            <XAxis 
              dataKey="date" 
              axisLine={false} 
              tickLine={false} 
              tick={{ fontSize: 9, fill: 'rgba(255,255,255,0.2)', fontWeight: 'bold' }}
            />
            <YAxis hide />
            <Tooltip 
              contentStyle={{ 
                backgroundColor: 'rgba(0, 0, 0, 0.8)', 
                borderRadius: '16px', 
                border: '1px solid rgba(255,255,255,0.1)',
                backdropFilter: 'blur(20px)',
                padding: '12px'
              }}
              itemStyle={{ color: '#3b82f6', fontWeight: 'bold', fontSize: '10px' }}
              labelStyle={{ color: 'white', fontSize: '9px', fontWeight: 'black', marginBottom: '4px' }}
            />
            <Area 
              type="monotone" 
              dataKey="volume" 
              stroke="#3b82f6" 
              strokeWidth={4} 
              fillOpacity={1} 
              fill="url(#colorVol)" 
              animationDuration={2000}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
