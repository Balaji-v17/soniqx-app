// ============================================================
//  SONIQ — lib/classifier/title_language_detector.dart
//
//  Production-Grade Romanized Indian Language Classifier.
//  Optimized for VidMate, YouTube, and Web MP3 downloads.
// ============================================================

class TitleDetectionResult {
  final String language;
  final double confidence;
  final String matchedSignal; // 'script', 'phrase', 'keyword', 'hex'
  final String matchedPattern;

  const TitleDetectionResult({
    required this.language,
    required this.confidence,
    required this.matchedSignal,
    required this.matchedPattern,
  });

  @override
  String toString() =>
      'TitleDetectionResult($language, ${confidence.toStringAsFixed(2)}, '
      '$matchedSignal: "$matchedPattern")';
}

class TitleLanguageDetector {
  // ── 1. Download Junk Stripper ──────────────────────────────────────────────
  // 🎯 ADDED: reprise, version, unplugged, mashup, short, cover
  static final RegExp _downloadNoiseRegex = RegExp(
    r'(\[.*?\]|\(.*?\)|8k|4k|hd|320kbps|128kbps|mp3|official|video|lyrical|song|full|status|whatsapp|pagalworld|masstamilan|naasongs|sensongs|isaimini|vidmate|download|audio|remix|mix|cover|reprise|version|unplugged|mashup|short)',
    caseSensitive: false,
  );

  static String cleanTitle(String rawTitle) {
    String decodedTitle = rawTitle;
    
    try {
      decodedTitle = Uri.decodeFull(rawTitle);
    } catch (_) {
      // Fallback to original if decoding fails due to corruption
    }

    return decodedTitle
        .replaceAll(_downloadNoiseRegex, ' ')
        .replaceAll(RegExp(r'[-_.]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ── 2. Raw Hexadecimal Script Detector (For Corrupted VidMate URLs) ────────
  static TitleDetectionResult? _detectRawHex(String rawTitle) {
    final upper = rawTitle.toUpperCase();
    if (upper.contains('%E0%A4') || upper.contains('%E0%A5')) {
      return const TitleDetectionResult(language: 'Hindi', confidence: 0.99, matchedSignal: 'hex', matchedPattern: 'Devanagari');
    }
    if (upper.contains('%E0%AE') || upper.contains('%E0%AF')) {
      return const TitleDetectionResult(language: 'Tamil', confidence: 0.99, matchedSignal: 'hex', matchedPattern: 'Tamil');
    }
    if (upper.contains('%E0%B0') || upper.contains('%E0%B1')) {
      return const TitleDetectionResult(language: 'Telugu', confidence: 0.99, matchedSignal: 'hex', matchedPattern: 'Telugu');
    }
    if (upper.contains('%E0%B2') || upper.contains('%E0%B3')) {
      return const TitleDetectionResult(language: 'Kannada', confidence: 0.99, matchedSignal: 'hex', matchedPattern: 'Kannada');
    }
    if (upper.contains('%E0%B4') || upper.contains('%E0%B5')) {
      return const TitleDetectionResult(language: 'Malayalam', confidence: 0.99, matchedSignal: 'hex', matchedPattern: 'Malayalam');
    }
    return null;
  }

  // ── 3. Native Script Recognition (Confidence: 0.97) ────────────────────────
  static const Map<String, List<List<int>>> _scriptRanges = {
    'Kannada':   [[0x0C80, 0x0CFF]],
    'Tamil':     [[0x0B80, 0x0BFF]],
    'Telugu':    [[0x0C00, 0x0C7F]],
    'Malayalam': [[0x0D00, 0x0D7F]],
    'Hindi':     [[0x0900, 0x097F]],
    'Punjabi':   [[0x0A00, 0x0A7F]],
    'Bengali':   [[0x0980, 0x09FF]],
    // Explicitly removed Japanese and Russian ranges so they fall to 'Unclassified'
  };

  static TitleDetectionResult? _detectScript(String title) {
    for (final rune in title.runes) {
      for (final entry in _scriptRanges.entries) {
        for (final range in entry.value) {
          if (rune >= range[0] && rune <= range[1]) {
            final confidence = entry.key == 'Hindi' ? 0.88 : 0.97;
            return TitleDetectionResult(
              language:       entry.key,
              confidence:     confidence,
              matchedSignal:  'script',
              matchedPattern: String.fromCharCode(rune),
            );
          }
        }
      }
    }
    return null;
  }

  // ── 4. EXACT PHRASE MATCHER (Confidence: 0.95) ─────────────────────────────
  // 🎯 ADDED: This bypasses single-word collisions and locks specific songs instantly
  static final Map<String, String> _phraseMatches = {
    'suraj': 'Kannada', // Master override for all Suraj KM remixes
    'aaseya bhaava': 'Kannada',
    'aaseya bhhava': 'Kannada',
    'naliva gulabi': 'Kannada',
    'naliva gulaabi': 'Kannada',
    'naliva gulabbi': 'Kannada',
    'yaava mohana': 'Kannada',
    'ide naadu': 'Kannada',
    'telephone gelathi': 'Kannada',
    'usire usire': 'Kannada',
    'adey bhoomi': 'Kannada',
    'ninnindale': 'Kannada',
    'aakaasha deepavu': 'Kannada',
    'ninade nenapu': 'Kannada',
    'bhale bhale': 'Kannada',
    'enendu hesaridali': 'Kannada',
    'karavli': 'Kannada',
    'karavali': 'Kannada',
    'dadda': 'Kannada',
    'aitalakadi': 'Kannada',
    'bheema bad boys': 'Kannada',
    'jackie shiva antha': 'Kannada',
    'gaja movie': 'Kannada',
    'yaar yaar jeevana': 'Kannada',
    'kenchalo': 'Kannada',
    'manchalo': 'Kannada',
    'ninnanne': 'Kannada',
    'ninnane': 'Kannada',
    'drama chandutiya': 'Kannada',
    'chandutiya pakadalli': 'Kannada',
    'love aagoythe': 'Kannada',
    'nannavale': 'Kannada',
    'kolle nannanne': 'Kannada',
    'omme baro': 'Kannada',
    'o baby once again': 'Kannada',
    'nooraru bannagalu': 'Kannada',
    'dwapara': 'Kannada',
    'kaadadeye': 'Kannada',
    'chinnamma': 'Kannada',
    'onde samane': 'Kannada',
    'tara tara': 'Kannada',
    'jagave neenu': 'Kannada',
    'radhe radhe': 'Kannada',
    'jeeva jeeva': 'Kannada',
    'ulidavaru kandante': 'Kannada',
    'muusanje veleli': 'Kannada',
    'onde usiranthe': 'Kannada',
    'college kumara': 'Kannada',
    'kissige': 'Kannada',
    'mehabooba mehabooba': 'Kannada',
    'o gulabiye': 'Kannada',
    'helbide': 'Kannada',
    'yenammi': 'Kannada',
    'nooraaru hrudayagalu': 'Kannada',
    'yaarige yaru': 'Kannada',
    'preethisuve': 'Kannada',
    'bhajarangi': 'Kannada',
    'bajarangi': 'Kannada',
    'yaru yaru': 'Kannada',
    'marethuhoyithe': 'Kannada',
    'i am villain': 'Kannada',
    'neene modaalu': 'Kannada',
    'the villain': 'Kannada',
    'rana rana': 'Kannada',
    'lucky baskar': 'Telugu',
    'srimathi garu': 'Telugu',
    'joome jo pathaan': 'Hindi',
    'besharam rang': 'Hindi',
    'mast maga': 'Hindi',
    'mast magan': 'Hindi',
    'tose naina': 'Hindi',
    'jhumritalaiyya': 'Hindi'
  };

  static TitleDetectionResult? _detectPhrase(String cleanedTitle) {
    final lower = cleanedTitle.toLowerCase();
    for (final entry in _phraseMatches.entries) {
      if (lower.contains(entry.key)) {
        return TitleDetectionResult(
          language: entry.value,
          confidence: 0.95,
          matchedSignal: 'phrase',
          matchedPattern: entry.key,
        );
      }
    }
    return null;
  }

  // ── 5. Comprehensive Keyword Sets (Confidence: 0.85) ──────────────────────
  static final Map<String, Set<String>> _keywords = {
    'Kannada': {
      'mungaru', 'kirik', 'ulidavaru', 'vikrant', 'raajakumara', 'pogaru', 'yenagali', 
      'cheluve', 'bombe', 'hoovu', 'beladingala', 'krishnaveni', 'baare', 'hodre', 
      'irodu', 'barodu', 'nimage', 'naange', 'maduve', 'hrudaya', 'mallige', 'kaadu', 
      'sigadalli', 'ondagi', 'sambhrama', 'preethi', 'kanasu', 'chooru', 'ondhu', 
      'huduga', 'hudugi', 'sandalwood', 'nanna', 'ninna', 'yaaru', 'hege', 'nodappa', 
      'kannada', 'yemanasagide', 'helu', 'nodu', 'agala', 'preethse', 'naguva', 'kannu', 
      'manasu', 'kgf', 'kantara', 'tagaru', 'roberrt', 'martin', 'salaga', 'charlie', 
      'ui', 'max', 'kabzaa', 'phantom', 'bairagee', 'james', 'yuva', 'appu', 'jogi', 
      'duniya', 'gaalipata', 'googly', 'adhyaksha', 'ugramm', 'rangi', 'taranga', 
      'godhi', 'banna', 'sadharana', 'mykattu', 'yajamana', 'srimannarayana', 'kandante', 
      'lucia', 'thithi', 'garuda', 'gamana', 'vrishabha', 'vahana', 'kavaludaari', 
      'kurukshetra', 'pailwaan', 'kotigobba', 'madhagaja', 'vedha', 'toby', 'kaatera', 
      'sapta', 'saagaradaache', 'badava', 'rascal', 'petromax', 'thothapuri', 'gajarama', 
      'majestic', 'aaptamitra', 'rakshaka', 'paramathma', 'bacchan', 'shivajinagara', 
      'ramachari', 'rathavara', 'vamshi', 'dayavittu', 'gamanisi', 'snehitharu', 
      'abhinetri', 'milana', 'arasu', 'nanditha', 'manikya', 'airavata', 'chakravarthy', 
      'bharjari', 'nishabda', 'rathnan', 'prapancha', 'lanke', 'sinnga', 'padde', 'nildana', 'sangama',
      'thanmay', 'eradu', 'ondee', 'dreamu', 'nara', 'thanmayaladenu', 'paravashanadenu', 'tabbahi', 'tabaahi',
      'aakasha', 'neeli', 'aadi', 'magane', 'bheema', 'aata', 'hudugatavo', 'hatavadi', 
      'ambara', 'ambaradaache', 'ammava', 'raathibommava', 'anisuthide', 'araluthiru', 
      'avala', 'olava', 'nage', 'chandu', 'avalendare', 'manadalada', 'rhaatee', 'ayyo', 
      'sivane', 'banaras', 'belakina', 'kavithe', 'geleyanige', 'gudiya', 'kattu', 'baanali', 'badalago',
      'rajkumar', 'puneeth', 'darshan', 'hamsalekha', 'usire', 'rajesh', 'meghave', 'shetty', 
      'gurukiran', 'bhandari', 'dennana', 'rangitaranga', 'nirup', 'radhika', 'upendra', 
      'rishab', 'hariprriya', 'jayatheertha', 'ajaneesh', 'bhupathi', 'harikrishna', 'chithra', 
      'sanjith', 'hegde', 'ashoka', 'amrutha', 'chandan', 'navarasan', 'apurva', 'yethake', 
      'thangi', 'kulukabeda', 'sanje', 'amruthavarshini', 'madbeku', 'suthradaari', 'onthara', 'bindaas',
      'geleya', 'beku', 'hoovantha', 'ivanu', 'geleyanalla', 'gajakesari', 'karunada', 'veera', 
      'kannugale', 'lifu', 'ishtene', 'pancharangi', 'diganth', 'manomurthy', 'maatanaadi', 
      'maayavade', 'ninthu', 'maleyali', 'jotheyali', 'manase', 'neenu', 'mosagaatiye', 
      'arfaz', 'ullala', 'nithin', 'shankaraghatta', 'premave', 'bengaluru', 'bulls',
      'udugore', 'moda', 'modalu', 'bhoomigilida', 'yashwanth', 'murali', 'rakshitha', 
      'moggina', 'manasali', 'ninagende', 'visheshavaada', 'nadedaduva', 'kamanabillu', 
      'ninnidale', 'olavina', 'kodalenu', 'ambarish', 'samane', 'poojari', 'kannalle', 
      'lokesh', 'neethu', 'preethiya', 'hudugige', 'hogutidde', 'kanna', 'muche', 'kade', 'rambo',
      'nalli', 'alli', 'inda', 'agide', 'bekilla', 'odeya', 'appa', 'anthe', 'odhu', 'idhe', 'idhu', 
      'aagide', 'thaane', 'aagi', 'illa', 'allave', 'baro', 'hange', 'hinge', 'yaake', 'aase', 'jothe', 
      'yalli', 'denu', 'adenu'
    },
    'Tamil': {
      'rowdy', 'kannaney', 'veyyon', 'silli', 'mutta', 'kalakki', 'oththa', 'rekka', 
      'kanave', 'ponniyin', 'jailer', 'vikram', 'kaithi', 'varisu', 'thunivu', 'iraivan', 
      'theri', 'mersal', 'bigil', 'sarkar', 'petta', 'darbar', 'annaatthe', 'beast', 
      'kadhale', 'kannamma', 'neeye', 'yennai', 'unakkaga', 'vaadi', 'pulla', 'azhage', 
      'thalaiva', 'anbae', 'kadhal', 'paattu', 'tamil', 'kollywood', 'leo', 'goat', 
      'coolie', 'kanguva', 'viduthalai', 'votta', 'kannathil', 'muthamittal', 'alaipayuthey', 
      'minnale', 'vinnai', 'thandi', 'varuvaya', 'vaaranam', 'aayiram', 'aayirathil', 
      'oruvan', 'ratsasan', 'vada', 'chennai', 'asuran', 'karnan', 'soodhu', 'kavvum', 
      'pudhupettai', 'aaranya', 'kaandam', 'paruthiveeran', 'subramaniapuram', 'mankatha', 
      'visaranai', 'kaakka', 'muttai', 'jigarthanda', 'kolaigaran', 'maanagaram', 'irumbu', 
      'thirai', 'comali', 'thozhil', 'ayalaan', 'maamannan', 'gargi', 'natchathiram', 
      'nagargiradhu', 'chithha', 'mudhalvan', 'enthiran', 'sivaji', 'chandramukhi', 
      'annamalai', 'baasha', 'padaiyappa', 'nayakan', 'thuppakki', 'kaththi', 'nanban', 
      'aadukalam', 'vettaiyaadu', 'vilaiyaadu', 'pithamagan', 'nanum', 'remo', 'kaala', 
      'kabali', 'lingaa', 'mouna', 'raagam', 'nayagan', 'thalapathi', 'bairavi', 'moondram', 
      'pirai', 'salangai', 'arunachalam', 'kannukkul', 'nilavu', 'thanga', 'magan', 'velai', 
      'pattadhari', 'vanakkam', 'ethir', 'neechal', 'kappal', 'namma', 'veettu',
      'kolaveri', 'anirudh', 'dhanush', 'azhagiya', 'thimirudan',
      'madhavan', 'meera', 'jasmine', 'balasubrahmanyam', 'kathali', 'havoc',
      'ngale', 'kudhu', 'vaazh', 'enidhu', 'thaan', 'aala', 'laam', 'iyya', 'aachu', 'irukku', 
      'poren', 'varen', 'vaanga', 'machan', 'chellam', 'azhagu', 'vizhi', 'uyir', 'kaatru', 
      'mazhai', 'poove', 'pookkal', 'illai', 'endru', 'aanal', 'aagum'
    },
    'Telugu': {
      'butta', 'bomma', 'samajavaragamana', 'inkem', 'vachindamma', 'anaganaganaga', 
      'baahubali', 'pushpa', 'rrr', 'kalki', 'devara', 'dasara', 'geetha', 'govindam', 
      'arjun', 'reddy', 'srivalli', 'antava', 'naatu', 'pilla', 'prema', 'gunde', 'chupulu', 
      'nuvve', 'naathoni', 'cheliya', 'telugu', 'tollywood', 'gamechanger', 'salaar', 'og', 
      'hanuman', 'sankranthiki', 'familystar', 'vaikunthapurramuloo', 'sarileru', 'neekevvaru', 
      'janatha', 'temper', 'gurram', 'dookudu', 'gabbar', 'magadheera', 'eega', 'nannaku', 
      'prematho', 'satyamurthy', 'attarintiki', 'daredi', 'adurs', 'sye', 'simhadri', 'arya', 
      'bommarillu', 'kotha', 'bangaru', 'lokam', 'bhadra', 'murari', 'adavi', 'ramudu', 
      'yamadonga', 'chirutha', 'desamuduru', 'pokiri', 'ithi', 'cameraman', 'gangatho', 
      'rambabu', 'dammu', 'ramayya', 'vasthavayya', 'evadi', 'gola', 'vadidhi', 'jalsa', 
      'chello', 'thammudu', 'bangaram', 'akhil', 'kosame', 'ninnu', 'kori', 'majili', 
      'saradaa', 'jaan', 'palasa', 'guntur', 'kaaram', 'bheemla', 'nayak', 'radhe', 'shyam', 
      'acharya', 'mahanati', 'pelli', 'choopulu', 'falaknuma', 'mathu', 'vadalara', 'kota', 
      'bommali', 'virupaksha', 'nanna', 'mirchi', 'gaddalakonda', 'ganesh', 'uppena', 'gully', 
      'sammohanam', 'singha', 'ranga', 'vaibhavanga', 'athreya', 'goodachari', 'dhruva', 'goutham', 'nanda',
      'ringa', 'bava', 'uppenantha',
      'ante', 'okka', 'undi', 'leru', 'thundhi', 'nundi', 'andi', 'aaru', 'indi', 'inchi', 
      'istam', 'ledu', 'ledha', 'thoti', 'kante', 'gurinchi', 'kosam', 'varaku', 'daka', 
      'aite', 'aina', 'cheppu', 'leni', 'unnadi'
    },
    'Malayalam': {
      'maanimba', 'poomole', 'kannur', 'shabaz',
      'njaan', 'kkund', 'undo', 'enne', 'ille', 'aane', 'aanu', 'ulla', 'thil', 'ente', 'ninte', 
      'avante', 'avalude', 'koode', 'oppam', 'mazha', 'unni', 'kutty', 'chechi', 'chettan', 
      'aayi', 'ittu', 'kond', 'aanenkil', 'enkil'
    },
    'Hindi': {
      'pyaar', 'tujhe', 'tumhari', 'zindagi', 'ishq', 'mohabbat', 'deewani', 'dilbar', 'humsafar', 
      'dil', 'dhadkan', 'sanam', 'saajan', 'sajna', 'sajni', 'yaara', 'yaari', 'dosti', 'pyaara', 
      'pyaari', 'haseen', 'haseena', 'ada', 'adaayein', 'bahaar', 'bahaaron', 'mausam', 'sawan', 
      'barsaat', 'baarish', 'pani', 'nadiya', 'sahil', 'kinara', 'lehrein', 'hawa', 'hawayein', 
      'pawan', 'mehfil', 'shaam', 'subah', 'raat', 'raaton', 'din', 'duniya', 'jahaan', 'aasmaan', 
      'zameen', 'chand', 'taare', 'taaron', 'kirne', 'roshni', 'andhera', 'khwab', 'khwabon', 
      'sapna', 'sapnon', 'naina', 'naino', 'aankhein', 'aankhon', 'baatein', 'baaton', 'yaadein', 
      'yaadon', 'khushi', 'gham', 'dard', 'aah', 'aansoo', 'hasi', 'hasrat', 'tamanna', 'armaan', 
      'armaanon', 'chaahat', 'wafa', 'bewafa', 'bewafai', 'inteha', 'zindagani', 'jeena', 'jeene', 
      'marna', 'jaan', 'jaaneman', 'jaanleva', 'soniye', 'mahiya', 'dholna', 'heeriye', 'raanjha', 
      'heer', 'mirza', 'channa', 'ang', 'angdaai', 'bahon', 'bahaaren', 'khushboo', 'mehak', 'rang', 
      'rangila', 'rangrej', 'geet', 'geeton', 'sangeet', 'sargam', 'taan', 'taal', 'dhun', 
      'saaz', 'anjaam', 'anjaane', 'begana', 'ajnabi', 'paraya', 'apna', 'apni', 'apnon', 'ghulam', 
      'bandagi', 'ibadat', 'khuda', 'rab', 'maula', 'ilaahi', 'ali', 'maalik', 'jannat', 'jahannum', 
      'aashiq', 'mashooq', 'madhosh', 'behosh', 'mast', 'masti', 'deewangi', 'aashiqui', 'sukoon', 
      'chain', 'qaraar', 'karar', 'beqaraar', 'bechain', 'tadap', 'tadapna', 'tadapne', 'jalna', 
      'jalte', 'jalwa', 'jalwe', 'sitaara', 'sitaare', 'jhilmil', 'chamke', 'damke', 'jhalke', 
      'barsaatein', 'boondein', 'rimjhim', 'badra', 'badal', 'ghata', 'ghataayein', 'bijli', 
      'chamak', 'kadak', 'garaj', 'barse', 'megha', 'megh', 'puravaiyya', 'khairiyat', 'raataan', 
      'lambiyaan', 'animal', 'stree', 'pathaan', 'jawan', 'gadar', 'sholay', 'mughal', 'azam', 
      'pakeezah', 'umrao', 'abhimaan', 'amar', 'maine', 'aapke', 'hain', 'koun', 'dilwale', 
      'dulhania', 'jayenge', 'kuch', 'hota', 'khushi', 'kabhie', 'gham', 'veer', 'zaara', 'devdas', 
      'lagaan', 'basanti', 'zameen', 'bajrangi', 'bhaijaan', 'dangal', 'andhadhun', 'barfi', 
      'jawaani', 'mushkil', 'tamasha', 'raees', 'pagal', 'kaho', 'raaz', 'jannat', 'villain', 
      'malang', 'jodi', 'dhoom', 'zinda', 'housefull', 'golmaal', 'simmba', 'sooryavanshi', 
      'singham', 'rathore', 'dabangg', 'bharat', 'bajirao', 'mastani', 'padmaavat', 'leela', 
      'tanhaji', 'kesari', 'manikarnika', 'katha', 'chhichhore', 'sonu', 'titu', 'sweety', 'luka', 
      'badhaai', 'bhediya', 'munjya', 'brahmastra', 'bahadur', 'rocky', 'rani', 'kahani', 'satyaprem', 
      'hatke', 'bachke', 'kashmir', 'surgical', 'raazi', 'dhadak', 'gangubai', 'kathiawadi', 
      'befikre', 'sejal', 'chennai', 'dhadakne', 'dobara', 'sanju', 'roohi', 'bhool', 'bhulaiyaa',
      'arjan', 'bhagwan', 'nanga', 'pehle', 'chikni', 'dreamum', 'dremum', 'wakeupum',
      'arijit', 'pachtaoge', 'baaghi', 'sahii', 'alvida', 'aasan', 'nahin', 'yahan', 'abhi', 'desh',
      'teri', 'dishoom', 'gori', 'cham', 'chaand', 'baaliyan', 'aditya', 'hawaioen', 'palke',
      'liye', 'meherbaan', 'siddharth', 'musafir', 'jaana', 'soniya', 'phir', 'wahi', 
      'piya', 'aaye', 'premika', 'sajde', 'tera', 'tere', 'binaa', 'milaw', 'tujhi', 'mein', 
      'ullu', 'pattha', 'yaaron', 'tune', 'javed', 'bashir', 'raakh', 'huye', 'khwaab',
      'wala', 'wali', 'wale'
    },
    'Punjabi': {
      'jatt', 'gabru', 'mutiyar', 'viah', 'pind', 'dhol', 'dholna', 'soniye', 'heeriye', 'mahiya', 
      'sajjna', 'raanjha', 'heer', 'mirza', 'sohni', 'channa', 'taare', 'akhan', 'naina', 'nachdi', 
      'gidha', 'bhangra', 'boliyan', 'putt', 'kudi', 'munda', 'jawani', 'rangla'
    },
    'English': {
      'lana', 'feat', 'lyrics', 'music', 'travis', 'scott', 'ringtone', 'lyric', 'joker', 'badam', 
      'hits', 'trending', 'anne', 'paul', 'rockabye', 'sean', 'bandit', 'clean', 'marie', 
      'cradles', 'dharia', 'szhyr', 'brownies', 'girl', 'extended', 'cinnamon', 'casa', 'papel', 
      'artbat', 'atlxs', 'aurora', 'hazakura', 'alan', 'walker', 'eilish', 'billie', 'ckay', 'joeboy', 
      'enisa', 'emin', 'jony', 'flute', 'remix', 'netflix', 'audio', 'lover', 'dawn', 'daylight', 
      'sugar', 'soul', 'mockingbird', 'middle', 'night', 'calm', 'blur', 'better', 'concorde', 'bass', 
      'beat', 'slowed', 'reverb', 'tiktok', 'viral', 'instrumental', 'lose', 'control', 'fergie', 
      'nathan', 'visualiser', 'julia', 'michaels', 'cheri', 'stop', 'mashup', 'praniti', 'world', 
      'glow', 'golden', 'class', 'heroes', 'stereo', 'hearts', 'adam', 'levine', 'hippie', 'sabotage', 
      'devil', 'eyes', 'indila', 'tourner', 'dans', 'vide', 'indulgence', 'insomnia', 'jeanette', 
      'porque', 'joris', 'voorn', 'nicholson', 'july', 'jungle', 'karol', 'shakira', 'laura', 'argy', 
      'omnya', 'loreen', 'tattoo', 'lukas', 'graham', 'enemy', 'eternity', 'fall', 'again', 'further', 
      'away', 'aran', 'asking', 'miracle', 'mirador', 'album', 'miss', 'molfar', 'mwaki', 'wanna', 
      'slave', 'never', 'forget', 'nobody', 'nudge', 'vocal', 'other', 'side', 'pantheon', 'piggyback', 
      'react', 'rauf', 'faik', 'childhood', 'solar', 'safari', 'shrink', 'snappy', 'subliminal', 
      'sweet', 'jazz', 'sweater', 'weather', 'randall', 'wahran', 'sandra', 'lullaby', 'melodic', 
      'techno', 'tango', 'tennis', 'chant', 'neighbourhood', 'rapture', 'tokyo', 'drift', 'tones', 
      'treasure', 'tungevaag', 'raaban', 'welcome', 'whistle', 'gray', 'goes', 'nanana', 'arquitecto', 
      'sombras', 'without'
    },
  };

  static TitleDetectionResult? _detectKeyword(String cleanedTitle) {
    final tokens = cleanedTitle
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .map((t) => t.replaceAll(RegExp(r'[^a-z]'), ''))
        .where((t) => t.length >= 3) 
        .toSet();

    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (tokens.contains(keyword)) {
          return TitleDetectionResult(
            language:       entry.key,
            confidence:     0.85,
            matchedSignal:  'keyword',
            matchedPattern: keyword,
          );
        }
      }
    }
    return null;
  }

  // ── 6. Main Entry Point ────────────────────────────────────────────────────
  static TitleDetectionResult? classify(String? title) {
    if (title == null || title.trim().isEmpty) return null;

    final hexResult = _detectRawHex(title);
    if (hexResult != null) return hexResult;

    final cleaned = cleanTitle(title);
    if (cleaned.isEmpty) return null;

    final scriptResult = _detectScript(cleaned);
    if (scriptResult != null) return scriptResult;

    // 🎯 ADDED: Exact phrase matching is now checked BEFORE single keywords 
    // to prevent generic English/Hindi words from hijacking regional titles.
    final phraseResult = _detectPhrase(cleaned);
    if (phraseResult != null) return phraseResult;

    final keywordResult = _detectKeyword(cleaned);
    if (keywordResult != null) return keywordResult;

    return null; 
  }
}