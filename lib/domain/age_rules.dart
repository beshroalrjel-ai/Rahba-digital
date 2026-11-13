int ageInMonths(DateTime birthDate, DateTime today) {
  var months = (today.year - birthDate.year) * 12 +
      today.month -
      birthDate.month;

  if (today.day < birthDate.day) {
    months--;
  }

  return months;
}

bool canBeBreedingAdult(DateTime? birthDate, DateTime today) {
  if (birthDate == null || birthDate.isAfter(today)) {
    return false;
  }

  return ageInMonths(birthDate, today) >= 13;
}
