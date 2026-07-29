// ============================================================
//  SONIQ — lib/classifier/title_language_detector.dart
//
//  Production-Grade Romanized Indian Language Classifier.
//  Optimized for VidMate, YouTube, and Web MP3 downloads.
// ============================================================

class TitleDetectionResult {
  final String language;
  final double confidence;
  final String matchedSignal; // 'script', 'suffix', 'keyword'
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
  static final RegExp _downloadNoiseRegex = RegExp(
    r'(\[.*?\]|\(.*?\)|8k|4k|hd|320kbps|128kbps|mp3|official|video|lyrical|song|full|status|whatsapp|pagalworld|masstamilan|naasongs|sensongs|isaimini|vidmate|download|audio|remix|mix|cover)',
    caseSensitive: false,
  );

  static String cleanTitle(String rawTitle) {
    return rawTitle
        .replaceAll(_downloadNoiseRegex, ' ')
        .replaceAll(RegExp(r'[-_.]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // ── 2. Native Script Recognition (Confidence: 0.97) ────────────────────────
  static const Map<String, List<List<int>>> _scriptRanges = {
    'Kannada':   [[0x0C80, 0x0CFF]],
    'Tamil':     [[0x0B80, 0x0BFF]],
    'Telugu':    [[0x0C00, 0x0C7F]],
    'Malayalam': [[0x0D00, 0x0D7F]],
    'Hindi':     [[0x0900, 0x097F]],
    'Punjabi':   [[0x0A00, 0x0A7F]],
    'Bengali':   [[0x0980, 0x09FF]],
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

  // ── 3. High-Speed Phonetic Suffix Engine (Confidence: 0.85) ───────────────
  static final Map<String, RegExp> _groupedSuffixPatterns = {
    // 🎯 FIXED: Added denu and adenu to perfectly catch Thanmayaladenu and Paravashanadenu
    'Kannada': RegExp(
      r'\b[a-z]*(nalli|alli|inda|agide|bekilla|odeya|appa|anthe|odhu|idhe|idhu|aagide|thaane|aagi|illa|allave|helu|nodu|baro|hange|hinge|yaake|aase|jothe|yalli|denu|adenu)\b',
      caseSensitive: false,
    ),
    'Tamil': RegExp(
      r'\b[a-z]*(kaadhal|ngale|kudhu|vaazh|enidhu|thaan|aala|laam|iyya|aachu|irukku|poren|varen|vaanga|machan|chellam|azhagu|vizhi|uyir|kaatru|mazhai|poove|pookkal|illai|endru|aanal|aagum)\b',
      caseSensitive: false,
    ),
    'Telugu': RegExp(
      r'\b[a-z]*(ante|okka|undi|leru|thundhi|nundi|andi|aaru|indi|inchi|istam|ledu|ledha|thoti|kante|gurinchi|kosam|varaku|daka|aite|aina|cheppu|leni|unnadi)\b',
      caseSensitive: false,
    ),
    'Malayalam': RegExp(
      r'\b[a-z]*(njaan|kkund|undo|enne|ille|aane|aanu|ulla|thil|ente|ninte|avante|avalude|koode|oppam|mazha|unni|kutty|chechi|chettan|aayi|ittu|kond|aanenkil|enkil)\b',
      caseSensitive: false,
    ),
    'Hindi': RegExp(
      r'\b[a-z]*(wala|wali|wale|zindagi|humara|tumhara|deewana|deewani|sajna|sajni|saajan|dilwale|yaara|pyaar|mohabbat|ishq|aankhen|baatein|yaadein|raatein|bahara|khwabon|armaan|sapnon|nasha|deewangi|awaara|dilbar|dilruba|sanam)\b',
      caseSensitive: false,
    ),
    'Punjabi': RegExp(
      r'\b[a-z]*(jatt|gabru|mutiyar|viah|pind|dhol|dholna|soniye|heeriye|mahiya|sajjna|raanjha|heer|mirza|sohni|channa|taare|akhan|naina|nachdi|gidha|bhangra|boliyan|putt|kudi|munda|jawani|rangla)\b',
      caseSensitive: false,
    ),
  };

  static TitleDetectionResult? _detectSuffix(String title) {
    for (final entry in _groupedSuffixPatterns.entries) {
      final match = entry.value.firstMatch(title);
      if (match != null) {
        return TitleDetectionResult(
          language:       entry.key,
          confidence:     0.85,
          matchedSignal:  'suffix_pattern',
          matchedPattern: match.group(0) ?? '',
        );
      }
    }
    return null;
  }

  // ── 4. Comprehensive Keyword & Movie Title Sets (Confidence: 0.78) ────────
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
      'thanmay', 'eradu', 'ondee', 'dreamu', 'nara', 
      // 🎯 FIXED: Added the raw keywords just to be completely safe
      'thanmayaladenu', 'paravashanadenu', 'tabbahi', 'tabaahi'
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
      'pattadhari', 'vanakkam', 'ethir', 'neechal', 'kappal', 'namma', 'veettu'
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
      'ringa'
    },
    'Malayalam': {
      'penne', 'ormmayil', 'melle', 'sneham', 'kanne', 'manasse', 'ninte', 'ente', 'avante', 
      'premam', 'pranayam', 'moham', 'snehithan', 'koottukari', 'hridayam', 'hridayame', 
      'kannil', 'kannukal', 'sundari', 'sundariye', 'ninakkai', 'enikkum', 'enikku', 'ninakku', 
      'athu', 'ithu', 'evide', 'njaan', 'nee', 'avan', 'aval', 'nammal', 'ningal', 'ariyaathe', 
      'ariyaam', 'varika', 'varoo', 'vannu', 'ennum', 'ini', 'innu', 'naale', 'innale', 'neram', 
      'ratri', 'pakal', 'raavile', 'veyil', 'mazha', 'mazhakal', 'kaattu', 'kaatil', 'puzha', 
      'puzhayil', 'aaru', 'kadal', 'kadalil', 'thirathakal', 'akale', 'arike', 'aduthu', 'doorathe', 
      'ullil', 'purathu', 'mele', 'thazhe', 'munnil', 'pinnil', 'ishtam', 'ishtamaanu', 'snehithi', 
      'penkutty', 'aankutty', 'chettan', 'chechi', 'aniyan', 'aniyathi', 'amma', 'achan', 'makal', 
      'makan', 'koottukaaran', 'veedu', 'veettil', 'paattu', 'paadi', 'nritham', 'thaalam', 'raagam', 
      'sangeetham', 'kanneer', 'punchiri', 'chiri', 'chiriye', 'chundil', 'manassil', 'manassin', 
      'ullinte', 'bhavam', 'bhavame', 'swantham', 'janmam', 'janmamayi', 'ormmakal', 'ormmakale', 
      'vartha', 'varthamanam', 'enikkayi', 'ninakkayi', 'varum', 'varumo', 'povum', 'nilkku', 'nil', 
      'nadakkum', 'parayum', 'kelkku', 'kel', 'kaanan', 'kaanunna', 'kaanathe', 'marannu', 
      'marakkilla', 'marakkam', 'premikkunnu', 'premichu', 'snehikkunnu', 'snehichu', 'orthu', 
      'orkkunnu', 'nedi', 'nedum', 'tharaan', 'tharum', 'vaangi', 'kodukkum', 'paadum', 'paadunna', 
      'kaanam', 'kaathu', 'nokki', 'nokkunnu', 'nokku', 'kandu', 'kandathu', 'pinne', 'pinneedu', 
      'ennittum', 'ithuvare', 'athukond', 'drishyam', 'lucifer', 'minnal', 'jallikattu', 'kumbalangi', 
      'maniyarayile', 'trance', 'ayyappanum', 'moothon', 'sufiyum', 'illuminati', 'aavesham', 'premalu', 
      'bramayugam', 'goatlife', 'manichitrathazhu', 'kilukkam', 'chithram', 'thenmavin', 'kombath', 
      'yodha', 'nirnayam', 'sadayam', 'devasuram', 'raavanaprabhu', 'narasimham', 'prajapathi', 
      'balram', 'tharadas', 'kuttavum', 'shikshayum', 'thallumaala', 'rdx', 'manjummel', 'kishkindha', 
      'kaandam', 'angamaly', 'ustad', 'thattathin', 'marayath', 'ohm', 'shanthi', 'oshaana', 'maheshinte', 
      'prathikaram', 'biju', 'empuraan', 'koode', 'mayaanadhi', 'njan', 'prakashan', 'kunjappan', 
      'vellaripravinte', 'changathi', 'superum', 'pournamiyum', 'orungil', 'jomonte', 'suviseshangal', 
      'pulimurugan', 'ezra', 'godha', 'thondimuthalum', 'driksakshiyum', 'sudani', 'naayattu', 'malik', 
      'joji', 'varathan', 'thira', 'lukka', 'chuppi', 'vazhthuvangal', 'nerariyan', 'cbi', 'vellimoonga', 
      'oppam', 'mamangam', 'marakkar', 'kurup', 'bheeshma', 'parvam', 'anjaam', 'pathira', 'kappela', 
      'kanakam', 'kamini', 'kalaham', 'puzhu', 'pathonpatham', 'noottandu', 'jana', 'gana', 'mana', 
      'varane', 'avashyamund', 'ariyippu', 'thuramukham', 'churuli', 'thaan', 'kodu', 'romaancham',
      'manimba', 'thani', 'shoka'
    },
    'Hindi': {
      'pyaar', 'tujhe', 'tumhari', 'zindagi', 'ishq', 'mohabbat', 'deewani', 'dilbar', 'humsafar', 
      'dil', 'dhadkan', 'sanam', 'saajan', 'sajna', 'sajni', 'yaara', 'yaari', 'dosti', 'pyaara', 
      'pyaari', 'haseen', 'haseena', 'ada', 'adaayein', 'bahaar', 'bahaaron', 'mausam', 'sawan', 
      'barsaat', 'baarish', 'pani', 'nadiya', 'sahil', 'kinara', 'lehrein', 'hawa', 'hawayein', 
      'pawan', 'mehfil', 'shaam', 'subah', 'raat', 'raaton', 'din', 'duniya', 'jahaan', 'aasmaan', 
      'zameen', 'chand', 'taare', 'taaron', 'suraj', 'kirne', 'roshni', 'andhera', 'khwab', 'khwabon', 
      'sapna', 'sapnon', 'naina', 'naino', 'aankhein', 'aankhon', 'baatein', 'baaton', 'yaadein', 
      'yaadon', 'khushi', 'gham', 'dard', 'aah', 'aansoo', 'hasi', 'hasrat', 'tamanna', 'armaan', 
      'armaanon', 'chaahat', 'wafa', 'bewafa', 'bewafai', 'inteha', 'zindagani', 'jeena', 'jeene', 
      'marna', 'jaan', 'jaaneman', 'jaanleva', 'soniye', 'mahiya', 'dholna', 'heeriye', 'raanjha', 
      'heer', 'mirza', 'channa', 'ang', 'angdaai', 'bahon', 'bahaaren', 'khushboo', 'mehak', 'rang', 
      'rangila', 'rangrej', 'geet', 'geeton', 'sangeet', 'sargam', 'taan', 'taal', 'dhun', 'sur', 
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
      'arjan', 'bhagwan', 'nanga', 'pehle', 'chikni',
      // 🎯 FIXED: Added the exact Dreamum words to catch the Aiyyaa movie song perfectly
      'dreamum', 'dremum', 'wakeupum'
    },
    'Punjabi': {
      'jatt', 'gabru', 'mutiyar', 'viah', 'pind', 'dhol', 'chakk',
      'kudi', 'sohneya', 'sidhu', 'moosewala', 'diljit', 'dosanjh',
      'karan', 'aujla', 'shubh', 'punjabi', 'munde',
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
            confidence:     0.78,
            matchedSignal:  'keyword',
            matchedPattern: keyword,
          );
        }
      }
    }
    return null;
  }

  // ── 5. Main Entry Point ────────────────────────────────────────────────────
  static TitleDetectionResult? classify(String? title) {
    if (title == null || title.trim().isEmpty) return null;

    final cleaned = cleanTitle(title);
    if (cleaned.isEmpty) return null;

    // Check 1: Script (Kannada/Tamil/etc. native letters)
    final scriptResult = _detectScript(cleaned);
    if (scriptResult != null) return scriptResult;

    // Check 2: Phonetic Suffixes (e.g. -nalli, -ante, -kaadhal)
    final suffixResult = _detectSuffix(cleaned);
    if (suffixResult != null) return suffixResult;

    // Check 3: Keywords & Film Names
    final keywordResult = _detectKeyword(cleaned);
    if (keywordResult != null) return keywordResult;

    return null; // Not found -> let ML Kit or other fallbacks handle it
  }
}