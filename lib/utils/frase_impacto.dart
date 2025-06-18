String generarFraseImpacto(double horas) {
  if (horas >= 160) return "¿Vale un mes de tu vida?";
  if (horas >= 80) return "¿Trabajarías dos semanas por esto?";
  if (horas >= 40) return "¿Vale una semana completa?";
  if (horas >= 8) return "Un día entero de trabajo por esto.";
  return "Parece pequeño... ¿pero lo necesitas?";
}
