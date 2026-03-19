export type SetType = "Normal" | "Descarga" | "Drop Set" | "Myo-rep";

export interface Set {
  id: string;
  weight: number; // Kilos for this specific set
  reps: number;
  completed: boolean;
  type?: SetType;
}

export interface Exercise {
  id: string;
  name: string;
  muscleGroup: MuscleGroup;
  sets: Set[];
}

export interface LibraryExercise {
  id: string;
  name: string;
  muscleGroup: MuscleGroup;
  category: "Superior" | "Inferior" | "Core";
}

export interface Routine {
  id: string;
  name: string;
  exercises: Exercise[];
  daysOfWeek?: number[];
}

export interface Workout {
  id: string;
  date: string;
  name: string;
  exercises: Exercise[];
  duration?: number;
  routineId?: string;
  totalVolume: number; // Sum of all weight * reps across all sets
}

export interface ProgressData {
  date: string;
  volume: number;
}

export type MuscleGroup = 
  | "Pecho" | "Espalda" | "Hombro" | "Bicep" | "Tricep" | "Trapecio" | "Antebrazo"
  | "Pierna Completa" | "Glúteo" | "Cuádriceps" | "Femoral" | "Pantorrilla"
  | "Abdomen";

export const MUSCLE_CATEGORIES: Record<MuscleGroup, "Superior" | "Inferior" | "Core"> = {
  "Pecho": "Superior",
  "Espalda": "Superior",
  "Hombro": "Superior",
  "Bicep": "Superior",
  "Tricep": "Superior",
  "Trapecio": "Superior",
  "Antebrazo": "Superior",
  "Pierna Completa": "Inferior",
  "Glúteo": "Inferior",
  "Cuádriceps": "Inferior",
  "Femoral": "Inferior",
  "Pantorrilla": "Inferior",
  "Abdomen": "Core"
};

export const MUSCLE_GROUPS = Object.keys(MUSCLE_CATEGORIES) as MuscleGroup[];

export const SET_TYPES: SetType[] = ["Normal", "Descarga", "Drop Set", "Myo-rep"];
