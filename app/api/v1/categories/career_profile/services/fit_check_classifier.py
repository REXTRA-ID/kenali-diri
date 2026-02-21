RIASEC_DISTANCE = {
    ("R","R"):0, ("R","I"):1, ("R","A"):2, ("R","S"):3, ("R","E"):2, ("R","C"):1,
    ("I","R"):1, ("I","I"):0, ("I","A"):1, ("I","S"):2, ("I","E"):3, ("I","C"):2,
    ("A","R"):2, ("A","I"):1, ("A","A"):0, ("A","S"):1, ("A","E"):2, ("A","C"):3,
    ("S","R"):3, ("S","I"):2, ("S","A"):1, ("S","S"):0, ("S","E"):1, ("S","C"):2,
    ("E","R"):2, ("E","I"):3, ("E","A"):2, ("E","S"):1, ("E","E"):0, ("E","C"):1,
    ("C","R"):1, ("C","I"):2, ("C","A"):3, ("C","S"):2, ("C","E"):1, ("C","C"):0,
}

def calculate_match_score(user_code: str, profession_code: str) -> float:
    """
    Skor 0.0-1.0 berdasarkan rata-rata kedekatan huruf.
    1.0 = identik, 0.0 = semua berlawanan.
    Hanya untuk transparansi - tidak digunakan untuk klasifikasi utama.
    """
    max_distance = 3  # jarak maksimum di heksagon
    total_distance = 0
    comparisons = 0

    # Pastikan membandingkan sampai panjang minimum dari kedua kode
    for i in range(min(len(user_code), len(profession_code))):
        dist = RIASEC_DISTANCE.get((user_code[i], profession_code[i]), max_distance)
        total_distance += dist
        comparisons += 1

    if comparisons == 0:
        return 0.5
    avg_distance = total_distance / comparisons
    return round(1.0 - (avg_distance / max_distance), 2)


def classify_fit_check(
    user_riasec_code: str,
    profession_riasec_code: str
) -> dict:
    """
    Rule-based classification untuk FIT_CHECK.
    Return dict yang siap di-INSERT ke fit_check_results.

    Hierarki klasifikasi:
    HIGH   = dominant_same AND composition_same (semua huruf sama, urutan boleh beda)
    MEDIUM = dominant_same tapi composition berbeda  (rule: dominant_same)
             ATAU dominant adjacent (jarak 1 di heksagon)    (rule: adjacent_dominant)
    LOW    = fallback - semua kondisi di atas tidak terpenuhi (rule: mismatch)
    """
    if not user_riasec_code or not profession_riasec_code:
        return {
            "match_category": "LOW",
            "rule_type": "mismatch",
            "dominant_letter_same": False,
            "is_adjacent_hexagon": False,
            "match_score": 0.0
        }

    user_dominant = user_riasec_code[0]
    prof_dominant = profession_riasec_code[0]

    dominant_same = (user_dominant == prof_dominant)
    composition_same = sorted(user_riasec_code) == sorted(profession_riasec_code)

    dominant_distance = RIASEC_DISTANCE.get((user_dominant, prof_dominant), 3)
    is_adjacent = dominant_distance <= 1

    match_score = calculate_match_score(user_riasec_code, profession_riasec_code)

    # === CEK HIGH: dominant_same AND composition_same ===
    if dominant_same and composition_same:
        rule_type = "exact_match" if user_riasec_code == profession_riasec_code else "permutation_match"
        return {
            "match_category": "HIGH",
            "rule_type": rule_type,
            "dominant_letter_same": True,
            "is_adjacent_hexagon": is_adjacent,
            "match_score": match_score
        }

    # === CEK MEDIUM: Kondisi A - dominant_same tapi composition berbeda ===
    if dominant_same:
        return {
            "match_category": "MEDIUM",
            "rule_type": "dominant_same",
            "dominant_letter_same": True,
            "is_adjacent_hexagon": is_adjacent,
            "match_score": match_score
        }

    # === CEK MEDIUM: Kondisi B - dominant adjacent (jarak 1 di heksagon) ===
    if dominant_distance == 1:
        return {
            "match_category": "MEDIUM",
            "rule_type": "adjacent_dominant",
            "dominant_letter_same": False,
            "is_adjacent_hexagon": True,
            "match_score": match_score
        }

    # === FALLBACK: LOW ===
    return {
        "match_category": "LOW",
        "rule_type": "mismatch",
        "dominant_letter_same": dominant_same,
        "is_adjacent_hexagon": is_adjacent,
        "match_score": match_score
    }


def build_fit_check_explanation(match_category: str, rule_type: str) -> str:
    """
    Mengembalikan penjelasan singkat mengenai tingkat kecocokan profil dengan profesi.
    """
    if match_category == "HIGH":
        if rule_type == "exact_match":
            return "Profil kepribadian Anda sangat selaras dengan lingkungan dan tuntutan profesi ini. Anda memiliki potensi besar untuk menikmati, berprestasi, dan bertahan lama di bidang ini."
        else:
            return "Karakter dominan Anda sangat cocok dengan profesi ini, dan elemen pendukungnya saling melengkapi. Ini adalah pilihan arah karier yang sangat direkomendasikan untuk Anda."
    
    elif match_category == "MEDIUM":
        if rule_type == "dominant_same":
            return "Ketertarikan utama Anda sejalan dengan fokus utama profesi ini, namun ada beberapa aktivitas pendukung di pekerjaan ini yang mungkin kurang mencerminkan gaya alami Anda. Penyesuaian di beberapa kondisi akan diperlukan."
        elif rule_type == "adjacent_dominant":
            return "Terdapat relevansi yang cukup kuat antara kepribadian Anda dan tuntutan kerja profesi ini. Meskipun bukan kombinasi paling ideal, Anda tetap dapat menemukan kepuasan melalui adaptasi fokus kerja."
        else:
            return "Meskipun ada titik temu, profil Anda mungkin membutuhkan proses belajar dan pembiasaan ekstra di lingkungan kerja ini."
            
    else:  # LOW
        return "Karakter alami dan minat Anda memiliki banyak perbedaan fundamental dengan rutinitas profesi ini. Lingkungan kerjanya mungkin cepat membuat Anda bosan atau merasa kehabisan energi. Apabila Anda memilih untuk berkarier di sini, bersiaplah untuk beradaptasi terhadap tugas yang bisa jadi tidak selaras dengan zona nyaman Anda."
