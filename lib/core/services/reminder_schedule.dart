const dhikrIntervals = [0, 60, 120, 180, 240];

const dhikrMessages = [
  (
    ar: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    en: 'Verily, in the remembrance of Allah do hearts find rest',
  ),
  (
    ar: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
    en: 'Glory be to Allah and His is the praise, glory be to Allah the Magnificent',
  ),
  (
    ar: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ',
    en: 'There is no power nor strength except with Allah, the Most High, the Supreme',
  ),
  (
    ar: 'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
    en: 'I seek forgiveness from Allah the Almighty and repent unto Him',
  ),
  (
    ar: 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    en: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers',
  ),
  (
    ar: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    en: 'O Allah, send blessings and peace upon our Prophet Muhammad',
  ),
  (
    ar: 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ',
    en: 'Sufficient for me is Allah; there is no deity except Him. Upon Him I have relied',
  ),
  (
    ar: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ',
    en: 'O Ever-Living, O Sustainer, by Your mercy I seek assistance',
  ),
  (
    ar: 'سُبْحَانَ اللَّهِ ، وَالْحَمْدُ لِلَّهِ ، وَلَا إِلَهَ إِلَّا اللَّهُ ، وَاللَّهُ أَكْبَرُ',
    en: 'Glory be to Allah, all praise is due to Allah, there is no god but Allah, and Allah is the Greatest',
  ),
  (
    ar: 'رَضِيتُ بِاللَّهِ رَبّاً، وَبِالإِسْلاَمِ دِيناً، وَبِمُحَمَّدٍ رَسُولاً',
    en: 'I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad as my Messenger',
  ),
  (
    ar: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    en: 'O Allah, help me remember You, thank You, and worship You in the best manner',
  ),
  (
    ar: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلَا فِي السَّمَاءِ',
    en: 'In the name of Allah, with whose name nothing on earth or in heaven can cause harm',
  ),
  (
    ar: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ',
    en: 'O Allah, You are my Lord, there is no god but You. You created me and I am Your servant',
  ),
  (
    ar: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ ، وَالْحَمْدُ لِلَّهِ',
    en: 'We have reached the morning and the kingdom belongs to Allah, and all praise is to Allah',
  ),
  (
    ar: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ ، وَالْحَمْدُ لِلَّهِ',
    en: 'We have reached the evening and the kingdom belongs to Allah, and all praise is to Allah',
  ),
  (
    ar: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ كَرِيمٌ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
    en: 'O Allah, You are Pardoning and Generous, You love to pardon, so pardon me',
  ),
  (
    ar: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    en: 'Our Lord, give us in this world that which is good and in the Hereafter good, and save us from the torment of the Fire',
  ),
  (
    ar: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ',
    en: 'There is no god but Allah alone, having no partner. To Him belongs sovereignty and praise',
  ),
  (
    ar: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي',
    en: 'My Lord, expand for me my chest and ease for me my task',
  ),
  (
    ar: 'سُبْحَانَ اللَّهِ عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ',
    en: 'Glory be to Allah, as many times as the number of His creation, and according to His good pleasure',
  ),
];

bool isQuietHour(int hour, int? start, int? end) {
  if (start == null || end == null) return false;
  return start == end ||
      (start < end ? hour >= start && hour < end : hour >= start || hour < end);
}

List<int> dhikrReminderHours(int minutes, {int? quietStart, int? quietEnd}) {
  if (minutes <= 0 || !dhikrIntervals.contains(minutes)) return const [];
  return [
    for (var hour = 9; hour < 21; hour += minutes ~/ 60)
      if (!isQuietHour(hour, quietStart, quietEnd)) hour,
  ];
}
