INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    1,
    'R',
    'Realistic (R)',
    'Profil Realistic menunjukkan bahwa kamu adalah tipe yang lebih nyaman dengan pekerjaan praktis dan konkret dibandingkan hal yang abstrak. Berdasarkan pengalaman saya sebagai praktisi psikologi industri dan organisasi, individu dengan profil ini biasanya sangat baik dalam pelaksanaan teknis dan implementasi. Kamu cenderung lebih menyukai pendekatan "langsung mengerjakan" daripada menghabiskan waktu berjam-jam dalam rapat perencanaan. Di kampus, kamu mungkin lebih menikmati praktikum atau kerja laboratorium dibanding kuliah teori murni. Kekuatan khas dari tipe Realistic adalah kemampuanmu dalam memecahkan masalah teknis secara sistematis.',
    '["Pemecah masalah yang praktis: Kamu cenderung berpikir dalam pola \"apa yang bisa saya lakukan sekarang\" daripada hanya berteori tanpa tindakan. Kemampuan ini sangat berharga dalam dunia kerja yang dinamis dan menuntut hasil nyata", "Teliti dalam hal teknis: Ketika menangani peralatan, sistem, atau proses teknis, kamu secara natural memperhatikan detail penting. Kamu menyadari inkonsistensi kecil yang mungkin terlewat oleh orang lain", "Pembelajar mandiri: Kamu tidak membutuhkan pengawasan atau bimbingan terus-menerus. Berikan kamu alat yang tepat dan panduan dasar, kamu bisa mempelajari sisanya melalui praktik langsung", "Dapat diandalkan dalam eksekusi: Ketika kamu berkomitmen untuk menyelesaikan sesuatu, orang lain bisa mengandalkanmu. Kamu memahami pentingnya menuntaskan apa yang sudah dimulai"]'::jsonb,
    '["Kurang sabar dengan diskusi abstrak: Pembahasan yang terlalu konseptual tanpa rencana aksi yang jelas bisa membuatmu frustrasi. Kamu mungkin sering bertanya dalam hati, \"Jadi kita mau mengerjakan apa sebenarnya?\"", "Kesulitan menjelaskan kepada orang awam: Menjelaskan hal teknis kepada orang yang tidak memiliki latar belakang sama adalah tantangan tersendiri. Kamu memahami prosesnya dengan sangat baik, tetapi menerjemahkannya ke bahasa sederhana membutuhkan keterampilan khusus", "Tidak nyaman dengan perubahan mendadak: Kamu cenderung lebih menyukai metode yang sudah terbukti berhasil. Kalau tiba-tiba ada perubahan arah tanpa penjelasan yang masuk akal, kamu memerlukan waktu untuk menyesuaikan diri"]'::jsonb,
    '["Latih kemampuan menjelaskan: Berlatihlah menjelaskan hal teknis menggunakan analogi atau contoh sehari-hari. Coba rekam diri kamu menjelaskan sesuatu, lalu tinjau kembali apakah penjelasanmu bisa dipahami orang di luar bidangmu", "Bangun kebiasaan dokumentasi: Biasakan untuk mendokumentasikan proses kerjamu. Ini tidak hanya membantu orang lain memahami pekerjaanmu, tetapi juga menciptakan referensi berharga untuk dirimu sendiri di masa depan", "Cari kolaborasi lintas bidang: Bekerjalah secara aktif dengan orang dari fungsi atau latar belakang berbeda. Hal ini akan membuka perspektif baru dan meningkatkan kemampuan adaptasimu"]'::jsonb,
    '["Spesifikasi yang jelas: Kamu berkembang optimal ketika persyaratan kerja dan hasil yang diharapkan terdefinisi dengan baik", "Akses ke alat yang tepat: Baik peralatan fisik, perangkat lunak, atau mesin, memiliki alat yang tepat sangat penting untuk kualitas kerjamu", "Penilaian berbasis kinerja: Lingkungan kerja di mana penilaian didasarkan pada hasil kerja konkret, bukan politik kantor"]'::jsonb,
    '["Komunikasi langsung dan faktual: Dalam berkomunikasi, kamu cenderung langsung ke inti permasalahan tanpa bertele-tele", "Lebih suka mendemonstrasikan: Ketika menjelaskan sesuatu, kamu cenderung lebih suka menunjukkan atau mendemonstrasikan langsung", "Nyaman dengan keheningan: Berbeda dengan beberapa orang yang butuh interaksi terus-menerus, kamu merasa nyaman bekerja dalam suasana tenang"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    2,
    'I',
    'Investigative (I)',
    'Tipe Investigative pada dasarnya adalah individu yang selalu bertanya "mengapa". Kamu tidak bisa puas hanya dengan pemahaman di permukaan. Berdasarkan praktik saya di bidang psikologi industri dan organisasi, individu dengan profil ini sering kali unggul dalam bidang yang memerlukan analisis mendalam dan pemikiran sistematis. Kamu mungkin adalah tipe orang yang benar-benar membaca jurnal penelitian untuk kesenangan pribadi, atau yang selalu penasaran dengan cara kerja sesuatu. Dalam proyek kelompok, kamu biasanya menjadi orang yang mengajukan pertanyaan kritis yang belum terpikirkan oleh anggota lain. Yang khas dari tipe Investigative adalah rasa ingin tahu yang otentik, bukan sekadar ingin tahu tetapi benar-benar ingin memahami mekanisme dan logika di baliknya.',
    '["Kemampuan analitis yang tinggi: Kamu bisa memproses informasi kompleks dan mengidentifikasi pola yang tidak langsung terlihat oleh orang lain. Ini adalah aset besar dalam pemecahan masalah yang rumit", "Menguasai metodologi penelitian: Kamu nyaman dengan penyelidikan yang sistematis, tahu bagaimana merancang pertanyaan penelitian, mengumpulkan data, dan mengevaluasi temuan secara objektif", "Berpikir kritis: Kamu tidak begitu saja menerima informasi yang diberikan. Selalu mempertanyakan asumsi dan menguji validitas informasi, hal ini sangat penting untuk pengambilan keputusan yang berkualitas", "Mampu mengintegrasikan konsep: Kamu terampil dalam menghubungkan ide dari berbagai bidang atau teori yang berbeda. Kemampuan melihat gambaran teoretis yang lebih luas adalah kekuatanmu"]'::jsonb,
    '["Terlalu banyak menganalisis: Terkadang kamu menghabiskan terlalu banyak waktu untuk menganalisis hingga terlambat mengambil tindakan. Keinginan untuk mendapatkan informasi yang sempurna bisa menjadi penghambat", "Tidak sabar dengan pendekatan dangkal: Ketika orang lain mengambil jalan pintas atau tidak menyeluruh dalam analisis, hal ini mengganggu kamu. Namun perlu diingat bahwa tidak semua orang memerlukan tingkat kedalaman yang sama", "Kesenjangan dalam berkomunikasi: Kamu kadang menganggap orang lain memiliki tingkat pemahaman yang sama, sehingga penjelasanmu bisa menjadi terlalu teknis atau rinci", "Kurang mempertimbangkan kendala praktis: Logika murni tidak selalu memperhitungkan keterbatasan dunia nyata seperti batasan waktu, anggaran, atau pertimbangan politik organisasi"]'::jsonb,
    '["Tetapkan batas waktu untuk analisis: Berikan dirimu tenggat waktu yang jelas untuk fase penelitian. Misalnya, \"Saya punya tiga hari untuk mengeksplorasi topik ini, setelah itu saya harus mengambil keputusan\"", "Latih pengambilan keputusan yang cukup baik: Tidak setiap keputusan memerlukan analisis yang sangat mendalam. Kembangkan intuisi untuk mengetahui kapan informasi sebesar 70 hingga 80 persen sudah cukup", "Berkolaborasi dengan tipe pelaksana: Bermitra dengan orang yang cenderung langsung bertindak. Mereka bisa membantu kamu menerjemahkan analisis menjadi tindakan konkret", "Komunikasi berlapis: Mulailah dengan ringkasan singkat, kemudian tawarkan detail tambahan hanya saat diminta. Hormati bahwa orang lain mungkin memerlukan tingkat kedalaman berbeda"]'::jsonb,
    '["Otonomi intelektual: Kamu memerlukan kebebasan untuk mengejar penyelidikan dengan caramu sendiri. Manajemen yang terlalu mengatur detail akan membunuh produktivitasmu", "Akses ke sumber informasi: Baik perpustakaan, basis data, atau jaringan ahli, kamu memerlukan akses ke sumber daya untuk memenuhi kebutuhan risetmu", "Budaya yang menghargai kerja mendalam: Lingkungan yang memahami bahwa analisis berkualitas memerlukan waktu, bukan tempat yang mengharapkan jawaban instan", "Rekan kerja yang merangsang intelektual: Memiliki kolega yang bisa berdiskusi mendalam dan menantang pemikiranmu sangat penting untuk pertumbuhan dan motivasimu"]'::jsonb,
    '["Komunikasi berbasis pertanyaan: Cara alami kamu berkomunikasi adalah dengan mengajukan pertanyaan untuk memahami lebih dalam", "Diskusi berbasis bukti: Kamu selalu membawa data dan rujukan penelitian untuk mendukung argumenmu", "Menghargai nuansa: Kamu nyaman dengan ambiguitas dan kompleksitas. Pemikiran yang terlalu hitam putih cenderung membuatmu frustrasi", "Lebih suka komunikasi tertulis: Kamu sering merasa lebih nyaman dengan komunikasi tertulis karena bisa menjelaskan dengan struktur yang rapi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    3,
    'A',
    'Artistic (A)',
    'Profil Artistic menunjukkan bahwa kamu adalah seseorang yang melihat dunia melalui lensa kemungkinan dan orisinalitas. Dalam pengalaman saya bekerja dengan para profesional kreatif, yang konsisten adalah kebutuhan mereka untuk ekspresi diri yang otentik. Kamu mungkin merasa terkekang ketika diminta untuk "ikuti saja format yang sudah ada", karena mengapa harus mengikuti kalau kamu bisa menyempurnakan atau menciptakan sesuatu yang lebih baik? Di lingkungan akademik, kamu mungkin adalah mahasiswa yang menyerahkan tugas yang secara teknis memenuhi persyaratan tetapi dipresentasikan dengan cara yang tidak biasa atau mengejutkan. Penting untuk dipahami bahwa tipe Artistic ini bukan hanya tentang seni visual, ini tentang pendekatan kreatif dan inovatif terhadap masalah di bidang apa pun.',
    '["Pemikiran divergen: Ketika orang lain melihat satu solusi standar, kamu melihat berbagai kemungkinan alternatif. Pola pikir inovasi semacam ini semakin berharga dalam dunia yang terus berubah", "Kepekaan estetika: Kamu memiliki kepekaan terhadap desain, komposisi, dan presentasi. Bagimu, sesuatu tidak cukup hanya berfungsi dengan baik, seharusnya juga terlihat atau terasa tepat", "Nyaman dengan ketidakpastian: Tidak seperti tipe yang membutuhkan struktur yang sangat jelas, kamu justru nyaman dengan masalah yang terbuka. Ketidakpastian adalah ruang di mana kreativitas berkembang", "Motivasi dari dalam: Kamu didorong oleh kepuasan internal dari proses menciptakan sesuatu, bukan semata-mata oleh penghargaan atau pengakuan eksternal"]'::jsonb,
    '["Mudah bosan dengan rutinitas: Tugas yang repetitif dan monoton dengan cepat menguras energi mentalmu. Bekerja dengan cara yang sama setiap hari adalah skenario yang sangat tidak ideal bagimu", "Tekanan tenggat waktu: Ironisnya, meskipun tenggat waktu seharusnya membantu, proses kreatifmu mungkin tidak selalu sejalan dengan jadwal yang kaku. Terburu-buru menyelesaikan karya bisa terasa seperti mengorbankan kualitas", "Sensitif terhadap kritik: Karena karyamu adalah perpanjangan dari identitas dan ekspresi dirimu, umpan balik negatif bisa terasa sangat personal. Memisahkan ego dari hasil karya adalah pembelajaran yang terus-menerus", "Kesulitan dengan pembatasan: Batasan anggaran, keterbatasan teknis, atau proses persetujuan yang ketat bisa terasa menyesakkan"]'::jsonb,
    '["Ciptakan sistem untuk kreativitas: Strukturkan rutinitas kerjamu untuk melindungi waktu kreatif. Miliki ritual atau kebiasaan yang menandakan \"sekarang saatnya mode kreatif\", bisa berupa mendengarkan musik tertentu atau bekerja di tempat khusus", "Minta umpan balik di tahap awal: Jangan menunggu sampai karya sudah hampir selesai untuk mendapatkan masukan. Iterasi sejak dini membantu memisahkan ide yang benar-benar bagus dari sekadar keterikatan emosional", "Berkolaborasi dengan tipe yang terorganisir: Orang dengan tipe Conventional yang berorientasi detail dan sistematis bisa membantu kamu menerjemahkan visi kreatif menjadi rencana yang realistis", "Belajar menghargai batasan: Terkadang keterbatasan justru memaksa munculnya kreativitas yang lebih baik. Cobalah melihat batasan sebagai tantangan kreatif"]'::jsonb,
    '["Jadwal yang fleksibel: Rutinitas kerja yang kaku mungkin tidak cocok dengan ritme kreatifmu. Fleksibilitas untuk bekerja pada jam-jam puncak produktivitas kreatifmu sangat penting", "Ruang kerja yang menginspirasi: Lingkungan fisikmu sangat memengaruhi output. Pencahayaan yang baik, elemen visual yang menarik, atau atmosfer yang merangsang bisa meningkatkan kreativitasmu", "Budaya yang mendukung eksperimen: Lingkungan yang memberikan ruang untuk mencoba-coba tanpa takut gagal. Tidak setiap upaya kreatif akan berhasil, dan itu harus bisa diterima", "Kebebasan dalam pendekatan: Bukan hanya kebebasan menentukan apa yang akan dibuat, tetapi juga bagaimana cara membuatnya"]'::jsonb,
    '["Komunikasi yang ekspresif: Kamu menggunakan bahasa yang hidup, metafora, atau alat bantu visual ketika berkomunikasi", "Berpikir melalui cerita: Daripada poin-poin, kamu lebih suka menyampaikan ide melalui narasi atau cerita yang menggambarkan konsepmu", "Berpikir visual: Membuat sketsa atau menunjukkan contoh visual adalah cara alami kamu menjelaskan", "Menikmati sesi curah gagasan: Diskusi untuk menghasilkan ide secara kolaboratif memberimu energi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    4,
    'S',
    'Social (S)',
    'Profil Social menunjukkan bahwa kamu adalah seseorang yang mendapatkan makna dari dampak positif yang kamu berikan kepada orang lain. Sepanjang karier saya, saya mengamati bahwa tipe Social sering menjadi jangkar kecerdasan emosional dalam tim. Kamu mungkin adalah orang yang secara natural didatangi oleh orang lain ketika mereka butuh seseorang untuk diajak bicara atau meminta saran. Di lingkungan akademik, kamu mungkin lebih menyukai kerja kelompok bukan karena bebannya lebih ringan, tetapi karena kamu benar-benar menikmati proses kolaborasi. Tipe Social adalah tentang koneksi, memahami bahwa kesuksesan profesional sangat terkait erat dengan kualitas hubungan antarmanusia.',
    '["Empati yang tinggi: Kamu bisa membaca dinamika emosional yang mungkin terlewat oleh orang lain. Ini membantumu menavigasi situasi interpersonal yang kompleks dengan baik", "Jembatan komunikasi: Kamu terampil dalam memfasilitasi komunikasi antara orang atau kelompok yang memiliki perspektif atau gaya berbeda", "Meningkatkan kohesi tim: Kehadiranmu sering meningkatkan semangat dan kekompakan tim. Kamu menyadari ketika ada anggota tim yang sedang kesulitan dan secara natural menawarkan dukungan", "Sabar dalam pengembangan: Baik saat membimbing junior atau mendukung rekan kerja, kamu memiliki kesabaran untuk melihat orang berkembang"]'::jsonb,
    '["Kelelahan emosional: Terus-menerus mengelola emosi orang lain sambil juga mengelola emosimu sendiri bisa sangat menguras energi", "Kesulitan menghadapi konflik: Menghindari percakapan yang sulit demi menjaga harmoni bisa berdampak buruk. Masalah yang tidak dibahas akan berkembang menjadi lebih besar", "Sulit mengatakan tidak: Menolak permintaan orang lain terasa seperti mengecewakan mereka. Ini bisa membuat kamu terlalu banyak berkomitmen", "Jarak profesional: Terlalu terlibat secara emosional dalam masalah orang lain bisa memengaruhi objektivitas dan kesejahteraanmu sendiri"]'::jsonb,
    '["Tetapkan batasan yang jelas: Tidak apa-apa untuk memiliki batasan. Misalnya, \"Saya bisa membantu kamu selama 30 menit\" adalah respons yang valid dan sehat", "Kembangkan ketegasan: Berlatih menyatakan kebutuhanmu sendiri atau tidak setuju dengan cara yang diplomatis. Menjadi orang yang membantu bukan berarti harus selalu mengalah", "Cari supervisi atau dukungan rekan: Proses pengalaman-pengalamanmu dengan mentor atau kelompok sejawat. Jangan menanggung beban emosional sendirian", "Jadwalkan waktu untuk diri sendiri: Secara harfiah blokir waktu untuk mengisi ulang energi. Perlakukan ini sebagai janji yang tidak bisa dibatalkan dengan dirimu sendiri"]'::jsonb,
    '["Budaya kolaboratif: Lingkungan yang menghargai kerja tim dan kesuksesan bersama, bukan kompetisi individual yang brutal", "Misi yang bermakna: Organisasi yang tujuannya mencakup dampak positif kepada masyarakat", "Manajemen yang suportif: Pemimpin yang menghargai kecerdasan emosional dan memberikan pengecekan rutin untuk memastikan kesejahteraan tim", "Kesempatan berinteraksi: Hindari pekerjaan yang sepenuhnya terisolasi. Kamu membutuhkan kontak manusia secara regular"]'::jsonb,
    '["Pendengar aktif: Kamu memberikan perhatian penuh, menjaga kontak mata, dan menunjukkan ketertarikan yang tulus", "Pendekatan yang hangat: Gaya komunikasimu membuat orang merasa nyaman. Bahkan ketika harus menyampaikan umpan balik yang sulit, kamu melakukannya dengan perhatian", "Membaca bahasa non-verbal: Kamu menangkap bahasa tubuh, perubahan nada suara, atau ketidaknyamanan yang mungkin tidak disadari orang lain", "Membangun konsensus: Dalam diskusi kelompok, kamu sering bekerja untuk menemukan titik temu yang bisa diterima semua pihak"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    5,
    'E',
    'Enterprising (E)',
    'Tipe Enterprising adalah tentang dorongan untuk mencapai sesuatu dan memberikan pengaruh. Dalam pengalaman saya bekerja dengan para pengusaha dan pemimpin, individu dengan profil Enterprising memiliki energi yang tidak pernah berhenti untuk mewujudkan sesuatu. Kamu mungkin adalah orang yang dengan sukarela mengambil peran memimpin proyek atau mempresentasikan ide di depan kelompok. Di lingkungan kampus, kamu mungkin aktif di organisasi mahasiswa, kepanitiaan acara, atau inisiatif lainnya. Tipe Enterprising bukan otomatis berarti otoriter, ini tentang memiliki visi dan mengambil inisiatif untuk merealisasikannya. Yang membedakan tipe Enterprising adalah kesediaan untuk mengambil risiko yang terkalkulasi dan kemampuan untuk menggerakkan orang lain menuju tujuan bersama.',
    '["Inisiatif kepemimpinan: Kamu tidak menunggu izin atau kondisi sempurna untuk bertindak. Melihat peluang dan langsung mengambil tindakan adalah cara kerjamu", "Komunikasi yang persuasif: Kamu bisa mengartikulasikan visi dengan cara yang menarik dan membuat orang lain antusias serta berkomitmen", "Pemikiran strategis: Di luar tugas-tugas langsung, kamu berpikir tentang posisi, keunggulan kompetitif, dan tujuan jangka panjang", "Ketahanan mental: Kemunduran tidak menghentikanmu. Kamu melihatnya sebagai umpan balik untuk menyesuaikan strategi, bukan alasan untuk menyerah"]'::jsonb,
    '["Tidak sabar dengan proses yang lambat: Birokrasi atau proses pembangunan konsensus yang panjang membuatmu frustrasi. Instingmu adalah segera memutuskan dan melanjutkan", "Terlalu blak-blakan: Fokusmu pada hasil bisa terkesan tidak sensitif atau mengabaikan kekhawatiran orang lain", "Titik buta terhadap risiko: Kepercayaan diri pada keputusanmu bisa membuat kamu meremehkan risiko atau mengabaikan kekhawatiran yang valid", "Kesulitan mendelegasikan: Mentalitas \"kalau ingin cepat selesai, kerjakan sendiri\" sering muncul. Mempercayai orang lain dengan tugas penting memang tidak mudah"]'::jsonb,
    '["Kembangkan kesabaran: Kenali bahwa dukungan dari orang lain sering memerlukan proses. Terburu-buru bisa menciptakan resistensi yang kontraproduktif", "Praktikkan kepemimpinan yang empatik: Seimbangkan fokus pada tugas dengan perhatian terhadap kebutuhan dan pengembangan anggota tim", "Bangun kebiasaan penilaian risiko: Sebelum membuat keputusan besar, buat daftar sistematis tentang potensi dampak negatif. Libatkan perspektif dari orang yang lebih berhati-hati", "Belajar memberdayakan orang lain: Investasikan waktu dalam mengembangkan kemampuan orang lain. Pertumbuhan mereka akan melipatgandakan dampakmu"]'::jsonb,
    '["Dinamika yang cepat: Lingkungan yang bergerak cepat, membuat keputusan dengan gesit, dan melihat hasil secara konkret", "Budaya kewirausahaan: Organisasi yang menghargai inisiatif dan pengambilan risiko yang terkalkulasi", "Metrik kinerja yang jelas: Mengetahui seperti apa kesuksesan itu dan bagaimana diukur", "Kesempatan membangun jaringan: Akses ke koneksi, acara industri, atau platform untuk memperluas pengaruh"]'::jsonb,
    '["Kehadiran yang percaya diri: Kamu memancarkan keyakinan yang membuat orang percaya pada arah yang kamu tunjukkan", "Komunikasi langsung: Kamu menghargai efisiensi, tidak bertele-tele, sampaikan apa yang perlu disampaikan", "Energi yang memotivasi: Antusiasme kamu menular. Orang merasa berenergi setelah berinteraksi denganmu", "Investasi dalam hubungan: Kamu dengan sengaja membangun hubungan yang saling menguntungkan secara strategis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    6,
    'C',
    'Conventional (C)',
    'Profil Conventional menandakan bahwa kamu berkembang dengan struktur, keteraturan, dan praktik yang sudah mapan. Dari perspektif psikologi organisasi, tipe Conventional adalah tulang punggung yang memastikan operasional berjalan lancar. Kamu mungkin adalah orang yang membuat daftar tugas terorganisir, memberi kode warna pada catatan, atau memelihara sistem arsip yang benar-benar masuk akal. Di konteks akademik, kamu cenderung mengumpulkan tugas tepat waktu atau bahkan lebih awal, mengikuti panduan dengan teliti, dan menjaga jadwal belajar yang terorganisir. Tipe Conventional bukan tentang menjadi kaku atau tidak kreatif, ini tentang mengenali nilai dari sistem yang terbukti efektif dan efisiensi melalui organisasi yang baik.',
    '["Keunggulan organisasional: Kamu menciptakan dan memelihara sistem yang meningkatkan efisiensi. Proses yang berantakan menjadi lebih terstruktur di bawah pengaruhmu", "Perhatian pada detail: Kesalahan atau inkonsistensi yang terlewat oleh orang lain tertangkap olehmu. Kontrol kualitas adalah kekuatan alami", "Dapat diandalkan: Ketika kamu berkomitmen pada tenggat waktu atau hasil kerja, itu akan terjadi. Orang tahu mereka bisa bergantung padamu", "Dokumentasi proses: Kamu secara natural mendokumentasikan prosedur, membuat transfer pengetahuan menjadi mudah dan mengurangi ketergantungan pada individu tertentu"]'::jsonb,
    '["Resistensi terhadap perubahan: Sistem baru atau perubahan mendadak terasa tidak nyaman. Reaksi pertamamu adalah \"Kenapa harus mengubah yang sudah berfungsi baik?\"", "Perfeksionisme yang melumpuhkan: Terkadang mengejar kesempurnaan menunda kemajuan. Selesai itu lebih baik daripada sempurna, tetapi ini adalah prinsip yang sulit bagimu", "Improvisasi terbatas: Ketika situasi memerlukan adaptasi cepat di luar prosedur yang sudah ada, kamu mungkin merasa kehilangan arah", "Menghindari risiko: Preferensi pada metode yang terbukti bisa berarti melewatkan peluang inovatif yang memiliki ketidakpastian"]'::jsonb,
    '["Praktikkan perubahan bertahap: Daripada menolak perubahan, berlatihlah beradaptasi dengan perubahan kecil secara teratur. Bangun kemampuan fleksibilitas", "Tetapkan standar yang cukup baik: Tidak semuanya memerlukan presisi maksimal. Tentukan tingkat kualitas yang sesuai berdasarkan konteks tugas", "Kembangkan pola pikir rencana cadangan: Rencanakan untuk pengecualian. Memiliki rencana cadangan membuatmu lebih nyaman ketika prosedur standar tidak bisa diikuti", "Hargai pendekatan berbeda: Secara aktif cari perspektif dari tipe yang kurang terstruktur. Cara kerja mereka mungkin memiliki kebijaksanaan tersembunyi"]'::jsonb,
    '["Struktur organisasi yang jelas: Mengetahui garis pelaporan, tanggung jawab, dan prosedur memberikan kenyamanan", "Lingkungan yang stabil: Prediktabilitas dalam operasi, minim kejutan atau perubahan menit terakhir", "Standar yang terdefinisi: Organisasi dengan tolok ukur kualitas yang jelas dan kriteria evaluasi", "Sistem yang memadai: Akses ke alat, perangkat lunak, atau template yang mendukung pekerjaan sistematis"]'::jsonb,
    '["Formalitas profesional: Terutama dalam konteks kerja, kamu lebih suka tingkat formalitas yang sesuai", "Dokumentasi tertulis: Kamu lebih suka mengkomunikasikan hal penting secara tertulis untuk kejelasan dan referensi", "Rapat yang terstruktur: Diskusi yang dipandu agenda adalah preferensimu dibanding percakapan bebas", "Perencanaan di muka: Kamu menghargai pemberitahuan sebelumnya tentang perubahan atau informasi baru, bukan kejutan menit terakhir"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    10,
    'RI',
    'Realistic Investigative (RI)',
    'Kombinasi Realistic dan Investigative menciptakan tipe yang menggabungkan kemampuan praktis dengan pemikiran analitis. Ini adalah kombinasi langka yang sangat berharga di bidang teknis. Kamu bukan hanya bisa mengeksekusi, tetapi juga memahami teori di baliknya. Bayangkan seorang insinyur riset, ilmuwan data yang juga menulis kode, atau profesional medis yang juga melakukan penelitian. Dalam praktik, saya melihat individu dengan profil RI unggul dalam peran yang memerlukan keduanya: melakukan dan berpikir. Kamu tidak puas hanya mengikuti prosedur tanpa memahami alasannya, dan tidak puas dengan teori murni tanpa implementasi.',
    '["Sintesis teknis dan analitis: Kamu bisa merancang eksperimen atau sistem dan juga mengimplementasikannya sendiri. Ini mengurangi ketergantungan dan mempercepat iterasi", "Diagnosis masalah: Kamu mendekati pemecahan masalah secara sistematis dengan membentuk hipotesis, menguji, dan menyesuaikan. Bukan sekadar coba-coba", "Penerjemahan penelitian: Kamu bisa mengambil konsep teoretis dan benar-benar membangun prototipe atau aplikasi praktis", "Praktik berbasis bukti: Keputusanmu berdasarkan data dan pengujian, bukan asumsi atau perasaan semata"]'::jsonb,
    '["Tidak sabar dengan teori murni atau eksekusi murni: Kamu frustrasi kalau terjebak hanya melakukan salah satu. Kamu butuh stimulasi intelektual dan output praktis", "Komunikasi dengan orang non-teknis: Menjelaskan pekerjaanmu ke orang tanpa latar belakang teknis dan analitis adalah tantangan ganda", "Perfeksionisme dalam metodologi: Menginginkan teori sempurna dan implementasi sempurna bisa memperlambatmu"]'::jsonb,
    '["Cari peran yang hybrid: Cari posisi yang secara eksplisit menggabungkan riset dengan implementasi", "Dokumentasikan alasanmu: Ketika mengimplementasikan, jelaskan mengapa. Ini membantu orang lain belajar dan menghargai pendekatanmu", "Tetapkan tujuan iterasi: Rencanakan untuk beberapa versi. Pertama untuk pembelajaran, kemudian untuk penyempurnaan"]'::jsonb,
    '["Lingkungan riset dan pengembangan: Laboratorium, tim inovasi, atau perusahaan yang berinvestasi dalam jalur riset ke produk", "Otonomi teknis: Kebebasan untuk merancang pendekatan dan mengeksekusinya", "Sumber daya untuk eksperimen: Akses ke alat, data, dan anggaran untuk menguji ide"]'::jsonb,
    '["Tunjukkan dan jelaskan: Kamu lebih suka mendemonstrasikan sambil menjelaskan logikanya", "Menghargai dialog teknis: Menikmati diskusi yang menyeimbangkan teori dengan pertimbangan praktis", "Dokumentasi teknis tertulis: Preferensi kuat untuk dokumentasi yang detail dan terstruktur dengan baik"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    7,
    'RA',
    'Realistic Artistic (RA)',
    'Realistic dan Artistic adalah kombinasi menarik yang menggabungkan eksekusi praktis dengan visi kreatif. Kamu adalah tipe yang bisa membayangkan sesuatu yang original dan benar-benar membangunnya. Pikirkan desainer produk, arsitek, pengrajin, atau teknolog kreatif. Yang menarik dari RA adalah kamu memahami keterbatasan teknis namun tetap mendorong batas kreatif. Dalam pekerjaan proyek, kamu mungkin adalah orang yang berkontribusi baik dalam ide maupun eksekusi.',
    '["Pembuatan prototipe kreatif: Kamu bisa dengan cepat menerjemahkan konsep kreatif menjadi prototipe nyata", "Keseimbangan estetika dan fungsional: Karyamu tidak hanya berfungsi tetapi juga terlihat atau terasa tepat", "Kreativitas langsung: Berbeda dengan tipe Artistic murni yang terjebak di konsep, kamu benar-benar mewujudkan ide", "Pemecahan masalah dengan gaya: Solusi standar membosankanmu. Kamu menemukan cara kreatif untuk memecahkan masalah praktis"]'::jsonb,
    '["Frustrasi dengan murni estetis atau murni fungsional: Kamu menginginkan keduanya, yang tidak selalu mungkin dalam batasan yang ada", "Kesulitan estimasi waktu: Proses kreatif memakan waktu yang tidak terduga, bertentangan dengan tenggat waktu praktis", "Perfeksionisme dalam kerajinan: Baik Realistic maupun Artistic memiliki standar kualitas. Digabungkan, ini bisa melumpuhkan"]'::jsonb,
    '["Tetapkan batasan kreatif: Gunakan keterbatasan sebagai tantangan kreatif daripada hambatan", "Pisahkan ideasi dari eksekusi: Miliki fase terpisah untuk curah gagasan bebas, kemudian beralih ke mode implementasi", "Bangun portofolio: Dokumentasikan karyamu untuk menunjukkan kemampuan kreatif dan teknis"]'::jsonb,
    '["Ruang pembuat: Akses ke alat dan kebebasan kreatif", "Studio desain: Lingkungan yang menghargai bentuk dan fungsi", "Proses kreatif fleksibel: Ruang untuk eksperimen dalam batasan proyek"]'::jsonb,
    '["Komunikasi visual: Penggunaan berat sketsa, prototipe, atau referensi visual", "Demonstrasi kemampuan: Lebih suka tunjukkan portofolio daripada penjelasan verbal murni", "Apresiasi untuk kerajinan: Menghormati keterampilan teknis dan kepekaan estetika"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    11,
    'RS',
    'Realistic Social (RS)',
    'Kombinasi Realistic dan Social menciptakan individu yang praktis tetapi juga berorientasi pada orang. Kamu adalah penolong praktis yang lebih suka membantu orang lain melalui tindakan nyata daripada hanya dukungan emosional. Pikirkan terapis okupasi, pelatih, atau spesialis dukungan teknis. Yang khas dari RS adalah kamu menunjukkan kepedulian melalui melakukan sesuatu untuk atau dengan orang, bukan hanya berbicara. Layanan praktis adalah cara kamu menunjukkan perhatian.',
    '["Bantuan terapan: Kamu memecahkan masalah orang melalui solusi praktis, bukan hanya simpati", "Instruktur yang sabar: Bisa mengajarkan keterampilan teknis dengan cara yang mudah diakses dan mendukung", "Implementasi tim: Baik dalam memimpin eksekusi dan memastikan semua orang termasuk", "Kolaborasi langsung: Lebih suka bekerja bersama orang daripada koordinasi murni"]'::jsonb,
    '["Pekerjaan emosional kurang terlihat: Bantuan praktismu mungkin kurang terlihat dibanding dukungan emosional", "Menyeimbangkan tugas versus orang: Kadang terjebak antara menyelesaikan tugas dan mengurus kebutuhan tim", "Preferensi komunikasi: Lebih suka tunjukkan daripada berbicara, yang mungkin tidak selalu melayani kebutuhan interpersonal"]'::jsonb,
    '["Artikulasikan gaya dukunganmu: Bantu orang lain memahami bahwa caramu peduli adalah melalui tindakan", "Kembangkan pengecekan verbal: Latih bertanya \"bagaimana kabarmu\" di luar pertanyaan terkait tugas", "Cari peran layanan: Cari karier yang menggabungkan keterampilan teknis dengan dampak langsung pada orang"]'::jsonb,
    '["Berorientasi layanan: Organisasi fokus pada membantu melalui solusi praktis", "Proyek berbasis tim: Lingkungan kerja kolaboratif versus pekerjaan teknis terisolasi", "Budaya pelatihan langsung: Di mana pengembangan keterampilan terjadi melalui melakukan bersama"]'::jsonb,
    '["Dukungan berorientasi aksi: Respons alami kamu adalah \"Biar saya bantu kamu dengan itu\"", "Melakukan kolaboratif: Lebih suka bekerja bersama daripada diskusi murni", "Saran praktis: Ketika orang berbagi masalah, kamu menawarkan solusi konkret"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    9,
    'RE',
    'Realistic Enterprising (RE)',
    'Realistic dan Enterprising menggabungkan kemampuan teknis dengan dorongan untuk mencapai dan memimpin. Kamu bukan hanya ahli teknis, kamu ingin menerapkan keterampilan teknis untuk kesuksesan bisnis atau kepemimpinan. Pikirkan pendiri teknis, manajer operasi, atau pemimpin proyek di bidang teknis. Individu RE adalah pelaksana yang juga ingin mengarahkan ke mana tindakan itu menuju. Kamu nyaman dengan pekerjaan langsung dan keputusan strategis.',
    '["Kepemimpinan teknis: Bisa memimpin tim teknis dengan kredibel karena memahami pekerjaannya", "Eksekusi berbasis hasil: Fokus pada output praktis yang penting untuk tujuan bisnis", "Kepercayaan implementasi: Bersedia membuat keputusan dan mengeksekusi tanpa informasi sempurna", "Optimasi sumber daya: Kamu praktis tentang sumber daya yang dibutuhkan dan cara menggunakannya secara efisien"]'::jsonb,
    '["Tidak sabar dengan kepemimpinan non-teknis: Frustrasi ketika orang non-teknis membuat keputusan teknis", "Terlalu percaya diri dalam kelayakan: Kadang meremehkan kompleksitas karena merasa bisa melakukannya", "Kesulitan delegasi: Lebih suka melakukan sendiri karena tahu akan melakukannya dengan benar"]'::jsonb,
    '["Kembangkan kecerdasan bisnis: Pelajari aspek keuangan, pemasaran, atau strategis untuk melengkapi keterampilan teknis", "Praktikkan kepemimpinan inklusif: Kenali bahwa tidak semua orang perlu teknis untuk berkontribusi nilai", "Bangun tim teknis: Investasi dalam merekrut dan mengembangkan orang yang bisa menangani eksekusi sementara kamu fokus pada strategi"]'::jsonb,
    '["Perusahaan teknis: Organisasi di mana keahlian teknis dihargai dalam kepemimpinan", "Budaya berorientasi hasil: Fokus pada pengiriman dan hasil daripada proses murni", "Peluang kewirausahaan: Ruang untuk inisiatif dalam arah teknis dan bisnis"]'::jsonb,
    '["Kepemimpinan teknis langsung: Instruksi jelas berdasarkan pemahaman praktis", "Rapat berorientasi aksi: Lebih suka diskusi yang mengarah pada keputusan dan langkah selanjutnya", "Komunikasi hasil: Membingkai update dalam hal apa yang telah dicapai"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    8,
    'RC',
    'Realistic Conventional (RC)',
    'Realistic dan Conventional adalah kombinasi ideal untuk peran yang memerlukan presisi, keandalan, dan eksekusi sistematis. Kamu adalah spesialis teknis yang juga mencintai organisasi dan prosedur yang tepat. Pikirkan jaminan kualitas, spesialis dokumentasi teknis, atau administrator sistem. Individu RC memastikan bahwa pekerjaan teknis tidak hanya selesai, tetapi selesai dengan benar dan konsisten. Kamu adalah penjaga standar dalam domain teknis.',
    '["Pola pikir jaminan kualitas: Secara natural memeriksa dan memverifikasi pekerjaan teknis memenuhi standar", "Dokumentasi proses: Unggul dalam membuat prosedur operasi standar, manual, atau prosedur sistematis", "Eksekusi konsisten: Karyamu memiliki variasi minimal dengan output kualitas yang dapat diandalkan", "Organisasi teknis: Bisa mengorganisir sistem atau informasi teknis yang kompleks secara logis"]'::jsonb,
    '["Kekakuan dalam metode: Preferensi untuk prosedur yang teruji bisa menolak inovasi yang bermanfaat", "Perfeksionisme menunda: Baik Realistic maupun Conventional menginginkannya benar, yang bisa memperlambat pengiriman", "Resistensi perubahan: Preferensi ganda untuk stabilitas bisa membuat adaptasi sulit"]'::jsonb,
    '["Jadwalkan waktu inovasi: Sisihkan waktu khusus untuk menjelajahi metode baru di luar rutinitas harian", "Gunakan pola pikir kontrol versi: Perubahan oke sebagai peningkatan bertahap, bukan penggantian total", "Bermitra dengan tipe fleksibel: Berkolaborasi dengan orang yang bisa mendorongmu keluar dari zona nyaman secara konstruktif"]'::jsonb,
    '["Budaya fokus kualitas: Organisasi yang memprioritaskan melakukan hal dengan benar daripada cepat", "Prosedur mapan: Standar dan praktik terbaik yang jelas sudah ada", "Infrastruktur teknis: Alat, sistem, dan platform dokumentasi yang tepat"]'::jsonb,
    '["Komunikasi berbasis prosedur: Referensi standar, pedoman, atau preseden", "Spesifikasi tertulis: Lebih suka persyaratan tertulis detail versus instruksi verbal", "Diskusi sistematis: Penjelasan metodis, langkah demi langkah dari proses"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    12,
    'IA',
    'Investigative Artistic (IA)',
    'Investigative dan Artistic adalah kombinasi kuat untuk inovasi yang menggabungkan ketelitian analitis dengan imajinasi kreatif. Kamu adalah pencipta berbasis riset atau ilmuwan kreatif. Pikirkan peneliti pengalaman pengguna, peneliti desain, atau analis data kreatif. Yang menarik dari IA adalah kamu tidak menerima ide kreatif tanpa bukti, tetapi juga tidak puas dengan data yang tidak disajikan secara kreatif. Ketegangan ini mendorong inovasi.',
    '["Kreativitas berbasis riset: Ide kamu didasarkan pada wawasan dari penelitian atau analisis", "Formulasi masalah kreatif: Kamu membingkai ulang masalah dengan cara inovatif melalui lensa analitis", "Pola pikir eksperimental: Memperlakukan karya kreatif sebagai pengujian hipotesis dengan iterasi berdasarkan temuan", "Sintesis novel: Menggabungkan konsep berbeda dengan cara original yang didukung oleh koneksi logis"]'::jsonb,
    '["Kelumpuhan dari analisis: Terlalu memikirkan pilihan kreatif karena ingin bukti untuk setiap keputusan", "Ketegangan antara ketelitian dan aliran: Aliran kreatif membutuhkan spontanitas, riset membutuhkan sistematika", "Komunikasi kompleksitas: Ide kamu canggih dan menjelaskannya secara sederhana adalah tantangan"]'::jsonb,
    '["Pisahkan fase: Fase riset terfokus, fase kreatif eksploratif. Jangan campur mode secara bersamaan", "Rangkul intuisi dalam kreativitas: Tidak setiap pilihan kreatif memerlukan dukungan riset. Percaya pada naluri artistik", "Visualisasikan kompleksitas: Gunakan diagram, kerangka kerja, atau sistem visual untuk mengkomunikasikan ide kompleks"]'::jsonb,
    '["Laboratorium inovasi: Lingkungan riset dan pengembangan yang menghargai riset dan kreativitas", "Tim interdisipliner: Campuran peneliti, desainer, dan peran hybrid lainnya", "Budaya eksploratif: Ruang untuk bereksperimen tanpa tekanan komersial langsung"]'::jsonb,
    '["Diskusi berbasis konsep: Menikmati eksplorasi ide di tingkat abstrak dan kreatif", "Visual-analitis: Menggabungkan visualisasi data dengan presentasi kreatif", "Apresiasi kedalaman: Menghargai orang lain yang bisa mendiskusikan ide dengan nuansa dan kecanggihan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    15,
    'IR',
    'Investigative Realistic (IR)',
    'Investigative dan Realistic membalik RI, di mana kamu memimpin dengan analisis tetapi tetap terdasar dalam implementasi praktis. Ini menciptakan pemecah masalah sistematis yang berbasis bukti. Pikirkan peneliti klinis, analis forensik, atau analis kuantitatif. Individu IR memastikan keputusan keduanya dipikirkan dengan baik dan praktis dapat dieksekusi.',
    '["Implementasi berbasis bukti: Tidak akan mengeksekusi tanpa analisis yang tepat terlebih dahulu", "Pemecahan masalah sistematis: Mendekati masalah secara metodis dan mendokumentasikan temuan", "Eksekusi riset berkualitas: Studi yang kamu lakukan memiliki keduanya ketelitian dan metodologi tepat", "Penulisan teknis: Bisa mendokumentasikan proses atau temuan kompleks dengan jelas"]'::jsonb,
    '["Keseimbangan analisis dan eksekusi: Kadang terlalu banyak menganalisis sebelum terjun langsung", "Komunikasi dengan orang yang bias aksi: Mereka ingin kamu mulai, kamu ingin memahami dulu", "Perfeksionisme dalam proses: Ingin metode sempurna dan eksekusi sempurna"]'::jsonb,
    '["Tetapkan titik keputusan: Tentukan sebelumnya berapa banyak analisis yang cukup sebelum pindah ke tindakan", "Pendekatan percontohan: Lakukan implementasi skala kecil untuk menguji kesimpulan analisis", "Cari mitra komplementer: Bekerja dengan orang yang lebih kuat di satu dimensi"]'::jsonb,
    '["Institusi riset: Laboratorium, lembaga pemikir, atau departemen analitis", "Bidang berbasis bukti: Kedokteran, kebijakan, atau sains di mana ketelitian penting", "Sumber daya teknis: Akses ke alat analitis dan peralatan implementasi"]'::jsonb,
    '["Penjelasan metodis: Komunikasi langkah demi langkah yang logis", "Rekomendasi berbasis data: Selalu berikan alasan dengan bukti", "Mempertanyakan asumsi: Tantang premis sebelum menerima kesimpulan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    13,
    'IC',
    'Investigative Conventional (IC)',
    'Investigative dan Conventional menggabungkan pemikiran analitis dengan kecintaan pada organisasi dan sistem. Kamu adalah analis sistematis di mana semuanya terdokumentasi, terstruktur dengan baik, dan dievaluasi secara metodis. Pikirkan spesialis tata kelola data, administrator riset, atau konsultan analitis. Individu IC membawa keteraturan pada pekerjaan analitis yang kompleks.',
    '["Analisis terstruktur: Riset atau analisismu terorganisir dengan baik dan dapat direproduksi", "Fokus kualitas data: Memastikan informasi yang digunakan akurat, lengkap, dan divalidasi dengan benar", "Dokumentasi keunggulan: Membuat dokumentasi analitis yang komprehensif dan terawat dengan baik", "Peningkatan proses: Mengidentifikasi inefisiensi dalam alur kerja analitis secara sistematis"]'::jsonb,
    '["Terlalu struktur eksplorasi: Kadang analisis membutuhkan fase eksplorasi yang berantakan", "Resistensi terhadap metode baru: Lebih suka pendekatan analitis yang mapan", "Perfeksionisme dalam data: Bisa menunda wawasan menunggu kumpulan data sempurna"]'::jsonb,
    '["Izinkan fase eksploratif: Anggarkan waktu untuk eksplorasi data yang tidak terstruktur", "Tetap diperbarui: Secara teratur tinjau metode atau alat analitis baru", "Kemajuan atas kesempurnaan: Tetapkan tonggak untuk berbagi temuan sementara"]'::jsonb,
    '["Organisasi berbasis data: Perusahaan yang menghargai bukti dan manajemen data yang tepat", "Tim analitis terstruktur: Alur kerja yang jelas, kontrol versi, proses terdokumentasi", "Standar kualitas: Organisasi dengan standar analitis yang mapan"]'::jsonb,
    '["Pelaporan formal: Lebih suka laporan terstruktur dengan bagian metodologi yang jelas", "Diskusi proses: Fokus pada bagaimana analisis dilakukan, bukan hanya hasil", "Tanya jawab berorientasi detail: Ajukan pertanyaan klarifikasi tentang spesifikasi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    14,
    'IE',
    'Investigative Enterprising (IE)',
    'Investigative dan Enterprising menciptakan analis strategis dengan ambisi. Kamu tidak hanya memahami data, kamu ingin menggunakan wawasan untuk mendorong keputusan dan mencapai tujuan. Pikirkan konsultan strategi, analis bisnis, atau analis investasi. Individu IE mengubah analisis menjadi keunggulan kompetitif.',
    '["Generasi wawasan strategis: Mengekstrak wawasan yang dapat ditindaklanjuti dari data untuk keunggulan bisnis", "Komunikasi berpengaruh: Mempresentasikan temuan analitis dengan cara yang menarik dan persuasif", "Kepercayaan keputusan: Menggunakan analisis untuk membuat rekomendasi berani", "Pemahaman pasar: Menganalisis tidak hanya data tetapi juga lanskap kompetitif dan peluang"]'::jsonb,
    '["Tidak sabar dengan riset murni: Ingin analisis mendorong tindakan dengan cepat", "Risiko penyederhanaan berlebihan: Dorongan untuk wawasan yang dapat ditindaklanjuti mungkin mengorbankan nuansa penting", "Bias analisis kompetitif: Mungkin terlalu fokus pada keunggulan kompetitif versus pertimbangan lain"]'::jsonb,
    '["Seimbangkan kedalaman wawasan: Tahan dorongan untuk selalu mengurangi kompleksitas untuk pemangku kepentingan", "Libatkan ahli domain: Periksa kesimpulan analitis dengan orang yang memahami konteks secara mendalam", "Pemikiran jangka panjang: Pertimbangkan implikasi strategis di luar langkah kompetitif langsung"]'::jsonb,
    '["Firma konsultan: Strategi, manajemen, atau konsultan bisnis", "Tim strategi korporat: Departemen perencanaan strategis internal", "Lingkungan keputusan tinggi: Di mana wawasan analitis langsung memengaruhi keputusan besar"]'::jsonb,
    '["Komunikasi eksekutif: Terampil mempresentasikan ke kepemimpinan dengan rekomendasi jelas", "Analisis persuasif: Membingkai temuan untuk membangun kasus untuk tindakan", "Dialog strategis: Menikmati diskusi tentang posisi kompetitif dan peluang"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    16,
    'IS',
    'Investigative Social (IS)',
    'Investigative dan Social menggabungkan kemampuan analitis dengan fokus pada manusia. Kamu adalah peneliti atau analis yang benar-benar tertarik pada kesejahteraan manusia. Pikirkan peneliti kesehatan masyarakat, peneliti pendidikan, atau ilmuwan data sosial. Individu IS menggunakan metode yang ketat untuk memahami dan membantu orang.',
    '["Riset berpusat manusia: Mempelajari orang dengan keduanya ketelitian dan empati", "Riset kolaboratif: Bisa bekerja secara efektif dengan pemangku kepentingan yang beragam", "Fokus translasional: Ingin riset benar-benar membantu orang, bukan hanya memajukan pengetahuan", "Sensitivitas etis: Secara natural mempertimbangkan dampak manusia dalam desain riset"]'::jsonb,
    '["Keterlibatan emosional: Bisa menjadi terlalu terlibat dalam partisipan riset atau hasil", "Ketegangan objektivitas: Menyeimbangkan antara empati dan jarak analitis", "Frustrasi dengan dampak lambat: Riset membutuhkan waktu untuk diterjemahkan menjadi membantu orang"]'::jsonb,
    '["Tetapkan batasan: Pisahkan hubungan riset dari hubungan pribadi", "Libatkan dengan praktisi: Terhubung dengan orang yang mengimplementasikan intervensi", "Komunikasikan temuan secara publik: Bagikan riset dengan cara yang dapat diakses untuk dampak lebih luas"]'::jsonb,
    '["Institusi riset sosial: Kesehatan masyarakat, pendidikan, ilmu sosial", "Organisasi fokus dampak: Kelompok riset dengan misi jelas untuk kebaikan sosial", "Lingkungan kolaboratif: Bekerja dengan komunitas atau praktisi, bukan hanya akademisi"]'::jsonb,
    '["Wawancara empatik: Menciptakan ruang aman untuk partisipan dalam riset", "Komunikasi yang dapat diakses: Menerjemahkan temuan untuk audiens non-akademis", "Keterlibatan pemangku kepentingan: Secara aktif melibatkan komunitas dalam proses riset"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    20,
    'AR',
    'Artistic Realistic (AR)',
    'Artistic dan Realistic membalik RA, di mana kreativitas memimpin tetapi tetap terdasar dalam eksekusi praktis. Kamu adalah visioner yang juga tahu cara benar-benar membuat sesuatu. Pikirkan sutradara film, arsitek, atau pengembang permainan. Visi kreatif mendorongmu, tetapi kamu memahami kendala dan kemungkinan teknis.',
    '["Eksekusi visioner: Bisa membayangkan hasil inovatif dan mencari tahu cara membangunnya", "Kreativitas teknis: Menggunakan keterampilan teknis sebagai medium kreatif, bukan hanya alat eksekusi", "Pembuatan prototipe cepat: Menerjemahkan ide menjadi bentuk nyata dengan cepat untuk menguji konsep", "Pemecahan masalah kreatif: Menemukan solusi inovatif dalam kendala teknis"]'::jsonb,
    '["Ketegangan visi dan realitas: Kadang visi kreatif melebihi kelayakan teknis", "Bosan oleh eksekusi murni: Setelah masalah kreatif terpecahkan, implementasi mungkin terasa membosankan", "Frustrasi keterbatasan sumber daya: Alat atau material terbatas membatasi ekspresi kreatif"]'::jsonb,
    '["Rangkul penciptaan iteratif: Bangun beberapa versi, meningkatkan dengan setiap iterasi", "Pelajari keterampilan teknis terkait: Perluas perangkat teknis untuk memungkinkan kemungkinan kreatif yang lebih luas", "Berkolaborasi dalam implementasi: Bermitra dengan tipe Realistic untuk mengeksekusi sementara kamu fokus pada arah"]'::jsonb,
    '["Studio kreatif dengan sumber daya teknis: Akses ke keduanya kebebasan kreatif dan alat", "Pekerjaan berbasis proyek: Tantangan baru secara teratur versus produksi repetitif", "Peran teknis fleksibel: Di mana kamu bisa memengaruhi keduanya arah kreatif dan pendekatan teknis"]'::jsonb,
    '["Tunjukkan melalui pembangunan: Lebih suka mendemonstrasikan ide melalui prototipe atau model", "Diskusi kreatif teknis: Bicara tentang kemungkinan kreatif dalam realitas teknis", "Umpan balik iteratif: Ingin membangun, mendapatkan umpan balik, membangun kembali"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    19,
    'AI',
    'Artistic Investigative (AI)',
    'Artistic dan Investigative membalik IA, di mana eksplorasi kreatif mendorong penyelidikan. Kamu adalah pencipta penasaran yang meneliti untuk menemukan inspirasi. Pikirkan peneliti desain, penulis kreatif yang meneliti topik, atau seniman eksperimental. Kreativitasmu memicu apa yang ingin kamu pahami.',
    '["Kreativitas eksploratif: Riset membuka kemungkinan kreatif versus membatasinya", "Kedalaman konseptual: Karya kreatif memiliki substansi intelektual, bukan hanya estetika", "Kemampuan sintesis: Menggabungkan wawasan riset dalam ekspresi kreatif original", "Pendekatan eksperimental: Memperlakukan karya kreatif sebagai eksplorasi, menemukan melalui pembuatan"]'::jsonb,
    '["Lubang kelinci riset: Tersesat dalam riset yang menarik daripada menciptakan", "Terlalu intelektualisasi: Kadang analisis melumpuhkan aliran kreatif", "Aksesibilitas audiens: Karya mungkin terlalu kompleks konseptual untuk audiens luas"]'::jsonb,
    '["Tetapkan tenggat waktu penciptaan: Paksa dirimu untuk beralih dari mode riset ke mode penciptaan", "Ciptakan selama riset: Buat sketsa atau catatan kreatif saat kamu meneliti", "Tes dengan audiens: Dapatkan umpan balik apakah konsep sampai dengan dampak yang dimaksud"]'::jsonb,
    '["Institusi riset kreatif: Tempat di mana eksplorasi kreatif dihargai", "Ruang eksperimental: Studio, laboratorium, atau program yang mendukung riset artistik", "Lingkungan lintas disiplin: Di mana seni dan sains berpotongan"]'::jsonb,
    '["Diskusi fokus konsep: Ingin bicara tentang ide di balik karya kreatif", "Komunitas kreatif intelektual: Cari orang lain yang menciptakan dengan kedalaman konseptual", "Berbagi proses: Terbuka tentang riset dan pemikiran di balik keputusan kreatif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    21,
    'AS',
    'Artistic Social (AS)',
    'Artistic dan Social menggabungkan kreativitas dengan fokus pada orang. Kamu menciptakan untuk dan dengan orang. Senimu adalah tentang koneksi dan dampak. Pikirkan seniman komunitas, terapis seni, atau pengusaha sosial dengan pendekatan kreatif. Ekspresi kreatif melayani koneksi manusia.',
    '["Kreativitas kolaboratif: Bisa memfasilitasi proses kreatif dengan orang lain secara efektif", "Ekspresi empatik: Karya kreatif mencerminkan pemahaman mendalam tentang pengalaman manusia", "Keterlibatan komunitas: Menggunakan kreativitas untuk menyatukan orang", "Kreativitas yang dapat diakses: Membuat proses kreatif ramah versus intimidatif"]'::jsonb,
    '["Menyeimbangkan visi dan masukan: Kadang proses kolaboratif mengencerkan visi kreatif", "Paparan emosional: Berbagi karya kreatif terasa sangat rentan secara pribadi", "Pengukuran dampak: Sulit mengukur dampak sosial dari karya kreatif"]'::jsonb,
    '["Tetapkan batasan partisipasi: Putuskan aspek mana yang kolaboratif versus kepengarangan kamu", "Pisahkan tipe umpan balik: Bedakan reaksi pribadi dari masukan konstruktif", "Dokumentasikan cerita dampak: Kumpulkan testimoni kualitatif tentang bagaimana karya memengaruhi orang"]'::jsonb,
    '["Organisasi komunitas: Lembaga swadaya masyarakat, perusahaan sosial, pusat komunitas", "Studio kolaboratif: Ruang di mana penciptaan terjadi dengan daripada untuk orang lain", "Fokus dampak sosial: Organisasi yang menghargai keterlibatan komunitas melalui kreativitas"]'::jsonb,
    '["Proses kreatif inklusif: Membuat orang lain merasa bisa berpartisipasi secara kreatif", "Koneksi berbasis cerita: Berbagi narasi pribadi dalam karya kreatif", "Presentasi hangat: Mempresentasikan karya kreatif dengan cara yang mengundang"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    18,
    'AE',
    'Artistic Enterprising (AE)',
    'Artistic dan Enterprising menciptakan pencipta ambisius. Kamu ingin kesuksesan kreatif dan pengakuan. Kamu membangun bisnis kreatif, memimpin tim kreatif, atau mendorong batas kreatif secara komersial. Kewirausahaan kreatif adalah domainmu. Visi bertemu kecerdasan bisnis.',
    '["Kreativitas komersial: Bisa menciptakan karya inovatif yang juga berhasil di pasar", "Kepemimpinan kreatif: Memimpin tim kreatif dengan keduanya visi dan arah strategis", "Kenyamanan promosi diri: Mampu memasarkan diri atau karyamu secara efektif", "Kreativitas pengambilan risiko: Bersedia mengejar arah kreatif yang berani"]'::jsonb,
    '["Ketegangan integritas kreatif: Menyeimbangkan kesuksesan komersial dengan keaslian artistik", "Tidak sabar dengan proses kreatif: Ingin hasil cepat, tetapi kreativitas membutuhkan waktu", "Pola pikir kompetitif: Mungkin membandingkan diri dengan pencipta lain dengan cara yang tidak sehat"]'::jsonb,
    '["Definisikan kesuksesan secara pribadi: Kejelasan tentang apa arti kesuksesan kreatif di luar ukuran eksternal", "Bangun keterampilan bisnis kreatif: Pelajari pemasaran, keuangan, manajemen proyek untuk usaha kreatif", "Temukan ceruk kamu: Kembangkan gaya atau pendekatan tanda tangan yang membedakan kamu"]'::jsonb,
    '["Industri kreatif: Periklanan, hiburan, agensi desain", "Ruang kewirausahaan kreatif: Perusahaan rintisan, pekerja lepas, atau wirausaha", "Peluang visibilitas: Platform atau posisi di mana karya kreatif mendapat pengakuan"]'::jsonb,
    '["Presentasi percaya diri: Presentasikan karya kreatif dengan antusiasme dan keyakinan", "Membangun jaringan secara aktif: Bangun hubungan dalam industri kreatif", "Promosi kreativitas: Bingkai ide kreatif sebagai peluang atau solusi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    17,
    'AC',
    'Artistic Conventional (AC)',
    'Artistic dan Conventional mungkin terdengar kontradiktif, tapi sebenarnya ini menciptakan pencipta yang disiplin. Kamu punya visi kreatif tapi juga menghargai struktur dan keteraturan. Bayangkan desainer grafis yang sangat terorganisir, editor konten yang perfeksionis, atau direktur kreatif yang juga manajer proyek. Yang unik dari AC adalah kamu bisa berkreasi dalam kerangka kerja yang terstruktur. Kreativitasmu tidak kacau, justru kamu tahu kapan harus mengeksplorasi dan kapan harus mengeksekusi dengan presisi.',
    '["Kreativitas terorganisir: Kamu punya sistem untuk mengelola proses kreatifmu. Ada alur kerja yang jelas dari ideasi sampai finalisasi", "Perhatian detail dalam karya kreatif: Karya kamu tidak cuma kreatif tapi juga rapi dan bebas dari kesalahan kecil yang mengganggu", "Keandalan dalam tenggat waktu: Berbeda dari kebanyakan orang kreatif yang kesulitan dengan tenggat waktu, kamu justru bisa mengirimkan tepat waktu tanpa mengorbankan kualitas", "Pola pikir kontrol kualitas: Kamu secara natural meninjau dan menyempurnakan karya sampai memenuhi standar yang kamu tetapkan, tidak asal jadi"]'::jsonb,
    '["Perfeksionisme kreatif: Keinginan untuk sempurna bisa membuat kamu menghabiskan terlalu banyak waktu di detail yang sebenarnya sudah cukup baik", "Kesulitan dengan spontanitas: Ketika situasi butuh improvisasi atau perubahan cepat, struktur yang biasa kamu andalkan malah jadi hambatan", "Proses kreatif yang kaku: Kamu mungkin punya cara kerja yang tetap, dan kalau ada yang mengganggu proses itu, produktivitas kamu bisa menurun"]'::jsonb,
    '["Tetapkan tenggat waktu progresif: Buat tonggak untuk versi draft. Versi 1.0 untuk eksplorasi, versi 2.0 untuk penyempurnaan, versi 3.0 poles akhir. Ini mencegah perbaikan tanpa akhir", "Latih kreativitas berwaktu: Sesekali tantang diri kamu untuk menciptakan sesuatu dalam batas waktu yang ketat. Ini membantu mengembangkan fleksibilitas", "Berkolaborasi dengan tipe spontan: Bermitra dengan tipe Artistic yang lebih bebas bisa mendorong kamu keluar dari zona nyaman secara sehat"]'::jsonb,
    '["Agensi kreatif dengan struktur: Studio atau agensi yang punya proses jelas tapi juga menghargai kualitas kreatif", "Penerbitan atau media: Lingkungan yang menyeimbangkan konten kreatif dengan jadwal produksi yang ketat", "Peran sistem desain: Posisi yang melibatkan pembuatan dan pemeliharaan standar atau panduan kreatif"]'::jsonb,
    '["Curah gagasan terstruktur: Kamu lebih suka sesi ideasi yang ada fasilitasinya, bukan yang sepenuhnya bebas", "Presentasi portofolio: Kamu mempresentasikan karya dengan cara yang terorganisir, sering menyertakan dokumentasi proses", "Brief kreatif tertulis: Kamu menghargai brief yang jelas dan cenderung mendokumentasikan keputusan kreatifmu"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    26,
    'SR',
    'Social Realistic (SR)',
    'Social dan Realistic adalah kombinasi dari orientasi pada orang dengan keterampilan praktis. Ini adalah versi terbalik dari RS, di mana fokus pada orang lebih dominan tapi didukung dengan kemampuan teknis. Kamu peduli membantu orang lain dan lebih suka melakukannya melalui dukungan langsung. Pikirkan terapis fisik, pelatih vokasional, atau spesialis dukungan teknis yang benar-benar peduli. Yang khas dari SR adalah motivasi melayanimu diekspresikan melalui bantuan praktis.',
    '["Bantuan langsung yang terapan: Kamu tidak cuma simpatik, tapi secara aktif melakukan hal-hal untuk membantu orang lain memecahkan masalah praktis mereka", "Pengajar teknis yang sabar: Bisa mengajarkan keterampilan teknis dengan cara yang mudah didekati dan mendukung. Kamu tidak membuat orang merasa bodoh karena tidak mengerti", "Empati praktis: Kamu memahami kebutuhan orang dalam istilah praktis. Ketika seseorang kesulitan, kamu bisa mengidentifikasi apa yang secara konkret mereka butuhkan", "Pemecahan masalah kolaboratif: Kuat dalam bekerja dengan orang untuk mencari solusi, bukan hanya memberi tahu mereka apa yang harus dilakukan"]'::jsonb,
    '["Pekerjaan emosional kurang terlihat: Bantuan praktismu mungkin kurang terlihat dibanding dukungan emosional verbal", "Menyeimbangkan tugas versus orang: Kadang terjebak antara menyelesaikan tugas dan mengurus kebutuhan tim", "Preferensi komunikasi: Lebih suka menunjukkan daripada berbicara, yang mungkin tidak selalu melayani kebutuhan interpersonal"]'::jsonb,
    '["Artikulasikan gaya dukunganmu: Bantu orang lain memahami bahwa caramu peduli adalah melalui tindakan", "Kembangkan pengecekan verbal: Latih bertanya \"bagaimana kabarmu\" di luar pertanyaan terkait tugas", "Cari peran layanan: Cari karier yang menggabungkan keterampilan teknis dengan dampak langsung pada orang"]'::jsonb,
    '["Layanan kesehatan atau rehabilitasi: Lingkungan yang fokus pada perawatan pasien praktis dan pemulihan", "Pelatihan atau pendidikan: Peran yang melibatkan pengembangan keterampilan langsung dengan individu", "Organisasi layanan komunitas: Lembaga swadaya masyarakat atau perusahaan sosial yang memberikan bantuan praktis"]'::jsonb,
    '["Komunikasi teknis yang hangat: Kamu menjelaskan hal teknis dengan cara yang ramah dan sabar", "Dukungan berorientasi tindakan: Ketika orang datang dengan masalah, kamu langsung memikirkan apa yang bisa dilakukan", "Tindak lanjut secara natural: Kamu memeriksa kembali dengan orang untuk memastikan solusi berhasil"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    25,
    'SI',
    'Social Investigative (SI)',
    'Social dan Investigative menciptakan peneliti atau analis yang sangat peduli dengan kesejahteraan manusia. Ini adalah kebalikan dari IS, di mana motivasi sosialmu memimpin tapi didukung oleh kemampuan analitis. Kamu ingin memahami orang bukan hanya secara intuitif, tapi melalui studi sistematis. Pikirkan psikolog klinis, peneliti sosial, atau analis data di organisasi nirlaba. Yang unik dari SI adalah kamu menggunakan ketelitian untuk melayani orang dengan lebih baik.',
    '["Riset berpusat pada manusia: Kamu secara natural merancang riset yang etis dan menghormati partisipan, tidak memperlakukan mereka sebagai sekadar titik data", "Menerjemahkan temuan untuk dampak: Baik dalam mengomunikasikan riset dengan cara yang dapat ditindaklanjuti untuk membantu orang. Tidak puas hanya menerbitkan paper", "Wawancara empatik: Terampil dalam membangun hubungan dengan partisipan riset, membuat mereka nyaman berbagi secara jujur", "Kesadaran etis: Kepekaan kuat terhadap etika riset dan potensi bahaya. Selalu mempertimbangkan dampak manusia dari keputusan riset"]'::jsonb,
    '["Kedekatan emosional: Kadang terlalu dekat secara emosional dengan subjek atau topik riset, memengaruhi objektivitas", "Frustrasi dengan laju riset: Riset membutuhkan waktu untuk diterjemahkan menjadi bantuan nyata, yang bisa membuat frustrasi ketika melihat kebutuhan mendesak", "Menyeimbangkan ketelitian dengan relevansi: Ketegangan antara mempertahankan standar akademis versus membuat riset dapat diakses dan segera berguna"]'::jsonb,
    '["Libatkan praktisi: Secara aktif terhubung dengan orang yang mengimplementasikan intervensi berdasarkan riset. Ini membantumu melihat dampak lebih cepat", "Riset berbasis komunitas: Libatkan komunitas dalam proses riset. Pendekatan partisipatif memuaskan dorongan analitis dan sosial", "Kembangkan ringkasan awam: Untuk setiap output riset, buat versi yang dapat diakses untuk audiens lebih luas"]'::jsonb,
    '["Institusi riset terapan: Organisasi yang fokus pada riset untuk dampak sosial daripada akademis murni", "Riset kebijakan: Lembaga pemikir atau agensi pemerintah di mana riset menginformasikan kebijakan sosial", "Riset kesehatan: Uji klinis, studi kesehatan masyarakat, atau riset medis dengan fokus pasien"]'::jsonb,
    '["Profesionalisme hangat: Kamu mempertahankan batasan profesional tapi dengan kehangatan tulus", "Presentasi berbasis cerita: Ketika mempresentasikan data, kamu menyertakan cerita manusia untuk membuat temuan relatable", "Keterlibatan pemangku kepentingan: Kecenderungan natural untuk melibatkan komunitas yang terpengaruh dalam diseminasi riset"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    22,
    'SA',
    'Social Artistic (SA)',
    'Social dan Artistic membalik AS, menempatkan fokus orang terlebih dahulu yang didukung oleh kreativitas. Kamu secara fundamental didorong oleh koneksi manusia tapi mengekspresikannya secara kreatif. Pikirkan terapis drama, fasilitator seni komunitas, atau pembuat cerita dampak sosial. Kreativitasmu adalah kendaraan untuk terhubung dengan dan melayani orang lain. Yang khas dari SA adalah senimu bersifat relasional, bukan soliter.',
    '["Kreativitas fasilitatif: Sangat baik dalam menciptakan ruang di mana orang lain merasa aman untuk mengekspresikan diri secara kreatif", "Penggunaan terapeutik seni: Memahami bagaimana ekspresi kreatif bisa menyembuhkan dan mengembangkan orang", "Proses kreatif inklusif: Membuat kreativitas dapat diakses, menghilangkan mistik bagi orang yang berpikir \"Saya tidak kreatif\"", "Koneksi melalui bercerita: Terampil dalam menggunakan narasi untuk membangun empati dan pemahaman antar orang"]'::jsonb,
    '["Identitas artistik personal: Kesulitan dengan suara artistik sendiri karena sangat fokus pada memfasilitasi kreativitas orang lain", "Batasan dalam berbagi kreatif: Sulit menentukan berapa banyak karya kreatif personal untuk dibagikan versus disimpan pribadi", "Mengukur dampak: Sulit mengukur dampak sosial dari intervensi kreatif, yang bisa membuat frustrasi"]'::jsonb,
    '["Pertahankan praktik personal: Sisihkan waktu untuk karya kreatif sendiri yang bukan tentang orang lain. Ini mencegah kelelahan dan membuat kamu tetap terinspirasi", "Dokumentasikan proses dan hasil: Kumpulkan testimoni, foto, video dari program kreatif untuk menunjukkan dampak", "Jaringan dengan praktisi serupa: Terhubung dengan fasilitator seni atau terapis lain untuk dukungan rekan dan pengembangan profesional"]'::jsonb,
    '["Terapi atau pendidikan seni: Pengaturan klinis, sekolah, atau program komunitas menggunakan seni untuk pengembangan atau penyembuhan", "Perusahaan sosial: Organisasi menggunakan industri kreatif untuk misi sosial", "Pusat komunitas: Tempat di mana pemrograman seni melayani tujuan pengembangan komunitas"]'::jsonb,
    '["Menciptakan ruang aman: Kamu secara natural membangun lingkungan di mana orang merasa oke untuk rentan secara kreatif", "Mengafirmasi partisipasi: Penguatan positif konsisten untuk upaya kreatif orang, terlepas dari tingkat keterampilan", "Pengalaman kreatif bersama: Lebih suka menciptakan bersama versus mendemonstrasikan kepada orang lain"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    24,
    'SE',
    'Social Enterprising (SE)',
    'Social dan Enterprising menggabungkan keterampilan orang dengan dorongan untuk mencapai dampak sosial dalam skala besar. Ini membalik ES, menempatkan orang terlebih dahulu tapi dengan ambisi strategis. Pikirkan pengusaha sosial, pemimpin organisasi nirlaba, atau investor dampak. Kamu ingin membantu orang tapi juga ingin perubahan sistemik, bukan hanya bantuan individual. Yang kuat dari SE adalah kemampuan memobilisasi sumber daya untuk kebaikan sosial.',
    '["Kepemimpinan berbasis misi: Dapat menginspirasi dan memimpin tim di sekitar misi sosial bersama. Keterampilan orang membuatmu pemimpin efektif", "Mobilisasi sumber daya: Baik dalam penggalangan dana, membangun kemitraan, dan mengamankan sumber daya untuk inisiatif sosial", "Pemikiran strategis untuk dampak sosial: Kamu berpikir melampaui membantu langsung, mempertimbangkan sistem berkelanjutan dan skala", "Manajemen pemangku kepentingan: Unggul dalam menavigasi hubungan dengan pemangku kepentingan beragam dari penerima manfaat hingga donor hingga pemerintah"]'::jsonb,
    '["Menyeimbangkan misi dengan keberlanjutan: Ketegangan antara ingin membantu semua orang versus mempertahankan kelangsungan hidup finansial organisasi", "Beban emosional skala: Melihat masalah sistemik bisa sangat memberatkan. Dapat menyebabkan kelelahan mencoba melakukan terlalu banyak", "Keputusan sulit: Kadang harus membuat panggilan sulit yang tampak bertentangan dengan membantu individu demi misi lebih besar"]'::jsonb,
    '["Definisikan teori perubahan: Jelas tentang bagaimana kerjamu menciptakan dampak. Ini membantu ketika membuat keputusan prioritas yang sulit", "Bangun tim kuat: Kelilingi dirimu dengan orang yang berbagi misi tapi membawa keterampilan komplementer. Delegasikan secara efektif", "Perawatan diri dan batasan: Kenali kamu tidak bisa membantu semua orang. Tetapkan cakupan realistis untuk mempertahankan keberlanjutan jangka panjang"]'::jsonb,
    '["Perusahaan sosial: Bisnis dengan misi sosial jelas di samping tujuan finansial", "Kepemimpinan organisasi nirlaba: Peran eksekutif dalam organisasi nirlaba atau yayasan", "Investasi dampak: Peran keuangan fokus pada pengembalian sosial atau lingkungan di samping pengembalian finansial"]'::jsonb,
    '["Komunikasi inspirasional: Kamu mengartikulasikan visi dengan cara yang menggerakkan orang untuk bertindak", "Pembangunan hubungan autentik: Orang merasakan kepedulian tulus melampaui hubungan transaksional", "Pengambilan keputusan inklusif: Cenderung melibatkan komunitas yang terpengaruh dalam keputusan strategis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    23,
    'SC',
    'Social Conventional (SC)',
    'Social dan Conventional menggabungkan orientasi orang dengan kecintaan pada struktur dan sistem. Pikirkan konselor sekolah, spesialis sumber daya manusia, atau administrator layanan sosial. Kamu ingin membantu orang tapi dalam kerangka kerja yang terorganisir. Yang berharga dari SC adalah kemampuan untuk memberikan dukungan konsisten dan dapat diandalkan melalui sistem yang tepat.',
    '["Pengiriman dukungan sistematis: Menciptakan dan memelihara sistem yang memastikan orang mendapat bantuan yang mereka butuhkan secara konsisten, bukan acak", "Pencatatan untuk layanan: Memahami pentingnya dokumentasi untuk melacak kemajuan dan memastikan kontinuitas perawatan", "Kesadaran kebijakan dalam membantu: Mengetahui kebijakan, regulasi, dan sumber daya relevan. Dapat menavigasi sistem untuk mengadvokasi orang", "Tindak lanjut yang dapat diandalkan: Orang dapat bergantung padamu untuk menindaklanjuti dan menyelesaikan aspek administratif dari membantu"]'::jsonb,
    '["Frustrasi oleh birokrasi: Birokrasi bisa terasa seperti penghalang untuk membantu ketika melihat kebutuhan mendesak", "Menyeimbangkan empati dengan protokol: Kadang protokol tampak tidak manusiawi tapi kamu memahami kebutuhannya. Terkoyak antara hati dan aturan", "Keterbatasan sistem: Sadar akan kesenjangan atau kegagalan dalam sistem yang kamu kerjakan. Frustrasi ketika tidak bisa membantu karena kebijakan"]'::jsonb,
    '["Bekerja untuk perubahan sistem: Dari dalam, advokasi untuk perbaikan kebijakan yang membuat sistem lebih manusiawi", "Kembangkan solusi kreatif: Pelajari cara kreatif untuk menavigasi sistem demi keuntungan klien sambil tetap dalam aturan", "Supervisi profesional: Debriefing reguler dengan supervisor atau rekan untuk memproses kasus menantang di mana keterbatasan sistem menyebabkan kesulitan"]'::jsonb,
    '["Agensi layanan sosial: Pemerintah atau organisasi nirlaba yang menyediakan program dukungan terstruktur", "Administrasi kesehatan: Pekerjaan sosial rumah sakit, advokasi pasien, atau koordinasi perawatan", "Administrasi pendidikan: Konseling sekolah, layanan mahasiswa, atau penasihat akademik"]'::jsonb,
    '["Empati profesional: Menyeimbangkan kehangatan dengan batasan profesional yang sesuai", "Komunikasi proses yang jelas: Membantu orang memahami apa yang diharapkan dalam hal garis waktu dan prosedur", "Pola pikir dokumentasi: Kecenderungan natural untuk mendokumentasikan interaksi untuk kontinuitas dan akuntabilitas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    30,
    'ER',
    'Enterprising Realistic (ER)',
    'Enterprising dan Realistic membalik RE, menempatkan dorongan kepemimpinan terlebih dahulu yang didukung oleh kompetensi teknis. Kamu lebih tentang mengarahkan pekerjaan teknis daripada menjadi pelaksana teknis utama. Pikirkan direktur operasi, manajer produksi, atau manajer proyek konstruksi. Kamu memahami realitas teknis tapi kekuatanmu adalah mengorganisir dan mendorong eksekusi.',
    '["Manajemen fokus hasil: Mendorong untuk hasil nyata. Tidak tertarik pada aktivitas kecuali menghasilkan hasil", "Pengambilan keputusan praktis: Membuat keputusan berdasarkan apa yang benar-benar layak, bukan ideal teoretis. Pemikiran strategis yang membumi", "Optimasi sumber daya: Baik dalam mengidentifikasi dan menghilangkan inefisiensi. Memastikan sumber daya digunakan secara efektif", "Kepemimpinan teknis yang kredibel: Karena memahami pekerjaan teknis, dapat memimpin tim teknis dengan kredibilitas. Mereka menghormati kamu tahu apa yang kamu minta"]'::jsonb,
    '["Tidak sabar dengan kesempurnaan teknis: Lebih tertarik pada cukup baik dan maju versus eksekusi teknis sempurna", "Dapat mengabaikan kekhawatiran teknis: Percaya diri dalam keputusan mungkin menyebabkan mengabaikan keberatan teknis valid dari tim", "Frustrasi delegasi: Mendelegasikan perlu tapi kadang frustrasi melihat orang lain melakukan pekerjaan berbeda dari cara kamu"]'::jsonb,
    '["Investasi dalam tim teknis: Merekrut dan mengembangkan orang teknis kuat sehingga kamu bisa fokus pada strategi daripada eksekusi", "Dengarkan tanda bahaya teknis: Ciptakan budaya di mana tim nyaman mengemukakan kekhawatiran. Jangan abaikan peringatan", "Seimbangkan kecepatan dengan keberlanjutan: Kemenangan jangka pendek bagus tapi tidak dengan mengorbankan utang teknis jangka panjang"]'::jsonb,
    '["Manufaktur atau produksi: Manajemen operasi dalam fasilitas yang memproduksi barang fisik", "Perusahaan konstruksi atau teknik: Manajemen proyek mengawasi eksekusi teknis", "Logistik atau rantai pasokan: Mengelola sistem operasional kompleks"]'::jsonb,
    '["Langsung dan berorientasi tindakan: Rapat harus mengarah pada keputusan dan penugasan, bukan diskusi tanpa akhir", "Komunikasi fokus metrik: Bicara dalam hal angka, indikator kinerja, tanggal pengiriman", "Budaya akuntabilitas: Jelas tentang siapa yang bertanggung jawab untuk apa, harapkan tindak lanjut"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    29,
    'EI',
    'Enterprising Investigative (EI)',
    'Enterprising dan Investigative membalik IE, memimpin dengan dorongan strategis tapi didukung oleh pemikiran analitis. Pikirkan konsultan manajemen, direktur strategi, atau kapitalis ventura. Kamu ambisius dan berorientasi tujuan tapi membuat keputusan berdasarkan analisis. Yang kuat adalah menggabungkan visi strategis dengan pendekatan berbasis data.',
    '["Strategi berbasis bukti: Menggunakan data dan analisis untuk menginformasikan keputusan strategis, bukan hanya intuisi atau pengalaman", "Intelijen kompetitif: Terampil dalam menganalisis pasar, pesaing, tren untuk mengidentifikasi peluang atau ancaman", "Pola pikir pengembalian investasi: Berpikir dalam hal pengembalian investasi. Menganalisis apakah inisiatif layak sumber daya yang diperlukan", "Mengartikulasikan visi dengan data: Mempresentasikan arah strategis dengan cara menarik didukung oleh bukti. Persuasif karena kredibel"]'::jsonb,
    '["Analisis dapat memperlambat tindakan: Keinginan untuk data solid mungkin menunda keputusan ketika perlu bergerak cepat", "Terlalu percaya diri dari data: Data memberikan rasa kepastian palsu. Dunia nyata lebih kompleks dari model", "Mengabaikan intuisi: Kadang pengenalan pola atau perasaan intuitif valid bahkan tanpa data keras untuk mendukung"]'::jsonb,
    '["Perencanaan skenario: Persiapkan untuk beberapa masa depan daripada mencoba memprediksi hasil tunggal. Bangun fleksibilitas", "Iterasi cepat: Gunakan pendekatan ramping, uji dengan data minimal, pelajari, sesuaikan. Tidak semua keputusan perlu analisis penuh", "Masukan beragam: Cari perspektif dari orang dengan jenis keahlian berbeda melampaui hanya analis data"]'::jsonb,
    '["Firma konsultan: Konsultasi strategi, manajemen, atau bisnis di tingkat senior", "Strategi korporat: Tim strategi internal dalam organisasi besar", "Modal ventura atau ekuitas swasta: Peran investasi menganalisis peluang dan membimbing perusahaan portofolio"]'::jsonb,
    '["Percakapan strategis: Nikmati diskusi tentang posisi kompetitif, dinamika pasar, skenario jangka panjang", "Penceritaan data: Presentasikan analisis dalam bentuk narasi yang menarik untuk pembuat keputusan", "Tantang asumsi: Kecenderungan natural untuk menyelidiki asumsi mendasar dalam proposal orang lain"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    27,
    'EA',
    'Enterprising Artistic (EA)',
    'Enterprising dan Artistic membalik AE, di mana ambisi mendorong tapi diekspresikan secara kreatif. Pikirkan direktur kreatif dengan kecerdasan bisnis, produser hiburan, atau ahli strategi merek. Kamu ingin menang tapi melalui keunggulan kreatif. Dorongan kompetitif disalurkan ke industri kreatif.',
    '["Kreativitas komersial: Memahami cara menciptakan karya yang inovatif dan dapat dipasarkan. Menyeimbangkan integritas artistik dengan kelangsungan hidup bisnis", "Kepemimpinan tim kreatif: Memimpin tim kreatif dengan arahan jelas sambil menghormati proses kreatif", "Pembangunan merek: Terampil dalam menciptakan identitas atau gaya khas yang membedakan kamu atau organisasi", "Promosi kreativitas: Unggul dalam mempresentasikan konsep kreatif dengan cara persuasif dan percaya diri yang mendapat dukungan"]'::jsonb,
    '["Ketegangan kompromi kreatif: Bergulat antara mempertahankan visi kreatif versus beradaptasi untuk pasar atau permintaan klien", "Mendorong tim terlalu keras: Garis waktu ambisius dapat membakar tim kreatif. Pekerjaan kreatif perlu ruang", "Metrik kesuksesan: Bagaimana mendefinisikan kesuksesan? Pujian kritis versus kesuksesan komersial versus kepuasan pribadi?"]'::jsonb,
    '["Definisikan yang tidak dapat dinegosiasikan: Jelas tentang prinsip kreatif yang tidak akan kamu kompromi versus area terbuka untuk negosiasi", "Lindungi waktu kreatif: Sambil mendorong untuk hasil, pastikan tim punya waktu memadai untuk pekerjaan kreatif berkualitas", "Metrik kesuksesan ganda: Evaluasi karya pada dimensi ganda. Tidak semua harus blockbuster komersial"]'::jsonb,
    '["Agensi kreatif di kepemimpinan: Direktur kreatif atau peran pengelola dalam periklanan, desain, atau agensi media", "Industri hiburan: Produksi, manajemen bakat, atau penciptaan konten di tingkat eksekutif", "Konsultasi merek: Peran kreatif strategis membantu organisasi membangun kehadiran pasar"]'::jsonb,
    '["Presentasi kreatif percaya diri: Presentasikan karya dengan keyakinan. Kamu percaya pada ide dan membuat orang lain percaya juga", "Budaya kreatif kompetitif: Memupuk lingkungan di mana tim mendorong satu sama lain untuk keunggulan", "Jaringan dalam industri kreatif: Aktif dalam acara industri, mempertahankan hubungan dengan pemain kunci"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    31,
    'ES',
    'Enterprising Social (ES)',
    'Enterprising dan Social membalik SE, di mana dorongan pencapaian datang pertama tapi dengan fokus orang. Pikirkan pemimpin korporat yang benar-benar mengembangkan orang, pelatih eksekutif, atau direktur pengembangan bakat. Ambisius untuk kesuksesan sendiri dan mengembangkan orang lain.',
    '["Kepemimpinan pengembangan: Mendorong orang untuk mencapai potensi mereka. Menetapkan standar tinggi sambil mendukung pertumbuhan", "Pembangunan tim untuk kinerja: Terampil dalam merakit dan mengembangkan tim berkinerja tinggi. Memahami orang adalah kunci kesuksesan", "Mentorship berpengaruh: Dapat membimbing karier orang lain sambil memajukan sendiri. Melihat mentorship sebagai hubungan saling menguntungkan", "Kepemimpinan perubahan organisasi: Memimpin inisiatif perubahan dengan perhatian pada dampak orang. Mendapat dukungan melalui keterlibatan"]'::jsonb,
    '["Ekspektasi menuntut: Standar tinggi bisa terasa seperti tekanan. Beberapa orang menganggapmu intens atau mengintimidasi", "Tidak sabar dengan pengembang lambat: Frustrasi ketika orang tidak tumbuh secepat yang kamu pikir mereka bisa", "Kebutuhan pribadi sekunder: Sangat fokus pada pencapaian dan mengembangkan orang lain mungkin mengabaikan kesejahteraan atau hubungan sendiri"]'::jsonb,
    '["Sesuaikan gaya kepemimpinan: Kenali tidak semua orang merespons pendekatan yang sama. Beberapa perlu dorongan, yang lain perlu pemeliharaan", "Rayakan kemajuan bertahap: Akui kemenangan kecil, bukan hanya pencapaian akhir. Jaga orang tetap termotivasi", "Model keseimbangan kerja kehidupan: Jika kamu ingin tim berkelanjutan, kamu perlu memodelkannya sendiri. Ambil istirahat, punya batasan"]'::jsonb,
    '["Kepemimpinan korporat: Peran eksekutif dalam perusahaan yang berinvestasi dalam pengembangan orang", "Pelatihan atau konsultasi: Pelatihan eksekutif, konsultasi pengembangan kepemimpinan", "Pengembangan bakat: Direktur sumber daya manusia atau peran manajemen bakat fokus pada membangun kemampuan organisasi"]'::jsonb,
    '["Menantang dengan dukungan: Mendorong orang melampaui zona nyaman tapi memberikan sumber daya dan dorongan", "Umpan balik langsung: Berikan umpan balik jujur karena kamu percaya itu membantu orang tumbuh, disampaikan dengan perhatian", "Keterlibatan energi tinggi: Bawa antusiasme yang menular. Doronganmu memotivasi orang lain"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    28,
    'EC',
    'Enterprising Conventional (EC)',
    'Enterprising dan Conventional menggabungkan ambisi dengan kecintaan pada sistem dan ketertiban. Pikirkan direktur operasi, direktur kepatuhan, atau pemimpin keunggulan proses. Kamu ingin mencapai melalui sistem yang tepat. Efisiensi dan skala melalui organisasi.',
    '["Pemikiran sistem untuk skala: Memahami kamu tidak bisa berskala melalui upaya individual. Membangun sistem dan proses yang memungkinkan pertumbuhan", "Keunggulan operasional: Mendorong efisiensi dan kualitas melalui operasi yang dirancang dengan baik. Menghilangkan pemborosan, mengoptimalkan alur kerja", "Manajemen risiko: Menyeimbangkan ambisi dengan penilaian risiko yang bijaksana. Memastikan pertumbuhan berkelanjutan, bukan ceroboh", "Kepemimpinan kepatuhan: Menganggap serius regulasi tapi melihatnya sebagai kerangka untuk kesuksesan bukan hanya penghalang"]'::jsonb,
    '["Kecenderungan birokratis: Menciptakan terlalu banyak proses dapat memperlambat organisasi. Terlalu sistematis", "Resistensi terhadap gangguan: Berinvestasi dalam sistem saat ini mungkin menolak inovasi yang mengancam mereka", "Risiko mikromanajemen: Fokus detail dikombinasikan dengan dorongan pencapaian dapat menyebabkan kontrol berlebihan"]'::jsonb,
    '["Tinjauan proses reguler: Secara berkala audit sistem untuk menghilangkan proses usang atau terlalu kompleks", "Berdayakan pemilik proses: Delegasikan otoritas untuk meningkatkan domain mereka. Percayai orang lain untuk mengoptimalkan dalam cakupan mereka", "Seimbangkan struktur dengan kelincahan: Bangun sistem yang memberikan pagar tapi memungkinkan fleksibilitas untuk adaptasi"]'::jsonb,
    '["Kepemimpinan operasi: Direktur operasi atau wakil presiden operasi dalam perusahaan berkembang", "Konsultasi proses: Membantu organisasi meningkatkan efisiensi operasional", "Kualitas atau kepatuhan: Peran kepemimpinan memastikan standar organisasi dan kepatuhan regulasi"]'::jsonb,
    '["Rapat terstruktur: Didorong agenda, dibatasi waktu, item tindakan didokumentasikan. Penggunaan waktu rapat yang efisien", "Komunikasi metrik kinerja: Pelaporan reguler pada indikator kinerja, kemajuan menuju tujuan, kinerja sistem", "Ekspektasi standar: Jelas tentang standar kualitas dan kepatuhan proses. Penegakan konsisten"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    35,
    'CR',
    'Conventional Realistic (CR)',
    'Conventional dan Realistic membalik RC, di mana kecintaan pada ketertiban memimpin tapi didukung dalam pekerjaan teknis. Pikirkan insinyur kualitas, auditor teknis, atau administrator sistem. Kamu memastikan pekerjaan teknis memenuhi standar melalui pendekatan sistematis.',
    '["Ketelitian jaminan kualitas: Secara sistematis menguji dan memverifikasi pekerjaan teknis. Menangkap kesalahan sebelum menjadi masalah", "Keunggulan dokumentasi teknis: Membuat dokumentasi teknis yang komprehensif dan akurat. Membuat pengetahuan dapat diakses dan dapat dipelihara", "Konsistensi dalam eksekusi teknis: Memberikan hasil yang dapat diandalkan dan dapat diulang. Meminimalkan variasi dalam kualitas output", "Penegakan standar: Memperjuangkan praktik terbaik dan standar. Memastikan kepatuhan tim untuk pemeliharaan jangka panjang"]'::jsonb,
    '["Dianggap sebagai hambatan: Proses jaminan kualitas menyeluruh dapat memperlambat hal. Dilihat sebagai penghalang daripada nilai tambah", "Resistensi terhadap perbaikan cepat: Ketika tim ingin solusi cepat, kekerasan kamu pada pendekatan yang tepat menyebabkan gesekan", "Inovasi terbatas: Fokus pada metode terbukti mungkin melewatkan peluang dari teknologi atau pendekatan baru"]'::jsonb,
    '["Otomatisasi pemeriksaan kualitas: Gunakan alat untuk menangkap masalah rutin. Cadangkan waktu kamu untuk kekhawatiran kualitas kompleks", "Pendekatan berbasis risiko: Tidak semua perlu tingkat pengawasan yang sama. Prioritaskan upaya jaminan kualitas berdasarkan kritikalitas", "Pembelajaran berkelanjutan: Tetap diperbarui pada praktik teknis baru. Pastikan standar berkembang dengan teknologi"]'::jsonb,
    '["Tim jaminan kualitas: Pengujian, verifikasi, dan validasi dalam organisasi teknis", "Dokumentasi teknis: Peran fokus pada memelihara basis pengetahuan teknis dan dokumentasi", "Kepatuhan atau audit: Memastikan pekerjaan teknis memenuhi standar regulasi atau organisasi"]'::jsonb,
    '["Tinjauan teknis detail: Umpan balik menyeluruh dan sistematis pada pekerjaan teknis", "Referensi dokumentasi: Arahkan ke standar, spesifikasi, praktik terbaik dalam diskusi", "Preferensi komunikasi tertulis: Untuk hal teknis, lebih suka instruksi tertulis dan dokumentasi jelas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    34,
    'CI',
    'Conventional Investigative (CI)',
    'Conventional dan Investigative membalik IC, memimpin dengan organisasi tapi diterapkan pada pekerjaan analitis. Pikirkan koordinator riset, spesialis tata kelola data, atau manajer program ilmiah. Kamu memastikan riset sistematis dan terkelola dengan baik.',
    '["Keunggulan administrasi riset: Mengelola proyek riset secara efisien. Melacak garis waktu, anggaran, kepatuhan", "Kualitas dan tata kelola data: Memastikan pengumpulan dan manajemen data mengikuti protokol yang tepat. Mempertahankan integritas data", "Riset yang dapat direproduksi: Mendokumentasikan metode secara menyeluruh sehingga studi dapat direplikasi. Sains memerlukan reproduksibilitas", "Manajemen hibah dan kepatuhan: Menavigasi persyaratan pendanaan dan kepatuhan regulasi untuk proyek riset"]'::jsonb,
    '["Ketegangan dengan riset eksploratif: Pekerjaan eksplorasi tahap awal berantakan. Keinginan kamu untuk struktur bisa terasa prematur", "Beban administratif: Begitu banyak waktu pada proses dan kepatuhan sehingga waktu terbatas untuk pemikiran riset aktual", "Dianggap sebagai birokratis: Peneliti mungkin melihat kamu menambahkan birokrasi daripada memungkinkan riset"]'::jsonb,
    '["Proses berjenjang: Sentuhan ringan untuk fase eksplorasi, lebih banyak struktur saat bergerak menuju studi formal", "Keterlibatan peneliti: Libatkan peneliti dalam merancang proses. Buat mereka dikembangkan secara kolaboratif, bukan dipaksakan", "Demonstrasi nilai: Secara teratur bagikan contoh bagaimana sistem kamu mencegah kesalahan atau memungkinkan kesuksesan"]'::jsonb,
    '["Institusi riset: Peran administratif dalam universitas, laboratorium riset, lembaga pemikir", "Tata kelola data: Organisasi mengelola basis data riset besar atau repositori", "Manajemen uji klinis: Koordinasi studi riset medis dengan protokol ketat"]'::jsonb,
    '["Komunikasi berorientasi proses: Jelaskan persyaratan, garis waktu, hasil kerja dengan jelas", "Rapat pos pemeriksaan: Update status reguler untuk memastikan proyek di jalur", "Permintaan dokumentasi: Minta dokumentasi metode, hasil, keputusan yang tepat"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    32,
    'CA',
    'Conventional Artistic (CA)',
    'Conventional dan Artistic membalik AC, di mana organisasi memimpin diterapkan pada pekerjaan kreatif. Pikirkan direktur seni yang sangat terorganisir, kurator museum, atau desainer produksi. Kamu membawa ketertiban pada kekacauan kreatif.',
    '["Manajemen proyek untuk pekerjaan kreatif: Menjaga proyek kreatif di jalur. Menyeimbangkan kebutuhan kreatif dengan tenggat waktu dan anggaran", "Organisasi aset kreatif: Manajemen sistematis file kreatif, versi, persetujuan. Tidak ada yang hilang", "Koordinasi produksi: Menjembatani antara visi kreatif dan eksekusi praktis. Memastikan pekerjaan kreatif diproduksi dengan benar", "Pemeliharaan standar kreatif: Mengembangkan dan menegakkan panduan merek atau standar kreatif tanpa membunuh kreativitas"]'::jsonb,
    '["Dilihat sebagai membatasi kreativitas: Orang kreatif mungkin merasa kamu memaksakan terlalu banyak batasan", "Proses versus aliran: Pekerjaan kreatif perlu keadaan aliran. Terlalu banyak struktur mengganggu proses kreatif", "Kreativitas sendiri ditekan: Sangat fokus mengorganisir pekerjaan kreatif orang lain mungkin tidak mengembangkan suara kreatif sendiri"]'::jsonb,
    '["Kerangka kerja fleksibel: Buat proses yang memberikan struktur tanpa mendikte hasil kreatif", "Perlindungan waktu kreatif: Gunakan keterampilan organisasi kamu untuk melindungi waktu kreatif tanpa gangguan untuk tim", "Praktik kreatif pribadi: Pertahankan proyek kreatif sendiri untuk tetap terhubung dengan pengalaman proses kreatif"]'::jsonb,
    '["Produksi kreatif: Manajemen produksi dalam film, periklanan, penerbitan", "Museum atau galeri: Peran kuratorial atau manajemen koleksi", "Operasi kreatif: Operasi atau manajemen proyek dalam agensi atau studio kreatif"]'::jsonb,
    '["Briefing kreatif: Brief jelas dan komprehensif yang memberikan arahan tanpa spesifikasi berlebihan", "Pelacakan status: Pengecekan reguler pada kemajuan proyek, hambatan, kebutuhan sumber daya", "Tinjauan kreatif terorganisir: Sesi umpan balik terstruktur dengan dokumentasi keputusan jelas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    36,
    'CS',
    'Conventional Social (CS)',
    'Conventional dan Social membalik SC, di mana fokus sistem memimpin diterapkan pada pekerjaan orang. Pikirkan spesialis sistem sumber daya manusia, koordinator program, atau manajer layanan administratif. Kamu melayani orang melalui sistem yang berjalan dengan baik.',
    '["Sistem pengiriman layanan: Merancang dan memelihara sistem yang memastikan layanan konsisten dan berkualitas kepada orang", "Manajemen basis data orang: Mempertahankan catatan akurat pada klien, siswa, pasien. Data yang tepat mendukung layanan lebih baik", "Peningkatan proses untuk layanan: Mengidentifikasi hambatan atau inefisiensi dalam bagaimana layanan dikirimkan. Membuat perbaikan", "Kepatuhan dalam layanan manusia: Memastikan pengiriman layanan memenuhi regulasi sambil tetap berpusat pada orang"]'::jsonb,
    '["Sistem versus individu: Kebijakan untuk kasus umum tapi individu punya kebutuhan unik. Ketegangan saat mencoba mengakomodasi pengecualian", "Jarak emosional: Fokus pada sistem mungkin terkesan birokratis atau tidak peduli meskipun niat adalah melayani", "Manajemen perubahan: Meningkatkan sistem berarti mengubah bagaimana hal dilakukan. Resistensi dari staf nyaman dengan cara saat ini"]'::jsonb,
    '["Rancang fleksibilitas ke dalam sistem: Bangun kebijaksanaan untuk penyesuaian kasus per kasus sambil mempertahankan struktur umum", "Komunikasikan alasan sistem: Bantu orang memahami mengapa sistem ada. Buat koneksi jelas antara proses dan layanan berkualitas", "Keterlibatan pengguna: Libatkan penyedia layanan dan penerima dalam desain sistem. Lebih mungkin diadopsi jika mereka membantu membuat"]'::jsonb,
    '["Layanan administratif: Peran mengelola operasi kantor, fasilitas, atau layanan dukungan", "Operasi sumber daya manusia: Sistem informasi sumber daya manusia, administrasi tunjangan, atau kepatuhan sumber daya manusia", "Koordinasi program: Mengelola pengiriman program sosial, pendidikan, atau kesehatan"]'::jsonb,
    '["Komunikasi prosedur jelas: Jelaskan bagaimana hal bekerja, apa yang perlu orang berikan, apa yang diharapkan", "Penegakan aturan empatik: Tegakkan kebijakan secara konsisten tapi dengan pemahaman keadaan individual", "Pemantauan kualitas layanan reguler: Periksa apakah sistem benar-benar melayani orang dengan baik"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    33,
    'CE',
    'Conventional Enterprising (CE)',
    'Conventional dan Enterprising membalik EC, di mana fokus sistem memimpin tapi dengan dorongan pencapaian. Pikirkan analis bisnis yang mendorong perubahan, konsultan peningkatan proses, atau manajer program transformasi. Kamu mencapai melalui sistemisasi.',
    '["Perubahan melalui sistem: Mendorong perubahan organisasi dengan merancang sistem dan proses baru. Perubahan berkelanjutan memerlukan perubahan sistem", "Rekayasa ulang proses bisnis: Menganalisis dan merancang ulang bagaimana pekerjaan dilakukan untuk mencapai keuntungan efisiensi atau peningkatan kualitas", "Sistem manajemen kinerja: Merancang dan mengimplementasikan sistem untuk melacak dan meningkatkan kinerja", "Keunggulan implementasi: Bukan hanya merancang sistem tapi memastikan mereka benar-benar diimplementasikan dan diadopsi. Lihat perubahan sampai selesai"]'::jsonb,
    '["Resistensi orang: Perubahan sulit. Orang menolak sistem baru bahkan jika secara objektif lebih baik", "Rekayasa berlebihan: Dapat menciptakan sistem terlalu kompleks mencoba menutupi setiap skenario. Kompleksitas menghambat adopsi", "Tidak sabar dengan adopsi: Ingin hasil segera tapi perubahan perilaku membutuhkan waktu. Sistem mungkin siap tapi orang tidak"]'::jsonb,
    '["Investasi manajemen perubahan: Habiskan upaya sebanyak pada sisi orang dari perubahan seperti pada desain sistem teknis", "Peluncuran bertahap: Implementasikan secara bertahap. Memungkinkan pembelajaran dan penyesuaian berdasarkan umpan balik awal", "Cerita kesuksesan: Dokumentasikan dan bagikan contoh dampak positif. Bantu pergeseran sentimen lebih luas menuju penerimaan"]'::jsonb,
    '["Konsultasi manajemen: Membantu organisasi meningkatkan operasi atau mengimplementasikan perubahan", "Tim transformasi internal: Memimpin inisiatif perubahan organisasi", "Analisis bisnis: Peran menganalisis proses bisnis dan merekomendasikan perbaikan"]'::jsonb,
    '["Presentasi berbasis data: Gunakan metrik dan analisis untuk membuat kasus untuk perubahan", "Manajemen pemangku kepentingan: Navigasi politik dan hubungan untuk mendorong adopsi perubahan", "Pengiriman pelatihan: Lakukan sesi mengajarkan orang sistem atau proses baru"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    39,
    'RAI',
    'Realistic Artistic Investigative (RAI)',
    'Kombinasi RAI menciptakan pemecah masalah yang sangat serbaguna. Kamu menggabungkan keterampilan langsung (R) dengan pemikiran kreatif (A) dan kedalaman analitis (I). Perpaduan langka ini unggul dalam inovasi teknis yang memerlukan kreativitas dan ketelitian. Pikirkan insinyur riset di laboratorium desain, insinyur biomedis yang menciptakan prostetik, atau spesialis visualisasi data. Kamu tidak cuma bisa membuat sesuatu yang berfungsi, tapi berfungsi dengan cara inovatif yang didasarkan pada analisis solid. Yang kuat adalah keseimbangan tiga arah antara melakukan, menciptakan, dan berpikir.',
    '["Solusi teknis inovatif: Kamu mendekati masalah teknis dengan lensa kreatif tapi memvalidasi dengan analisis. Hasilnya adalah solusi yang baru dan masuk akal", "Pembuatan prototipe kreatif cepat: Bisa dengan cepat mengubah konsep kreatif menjadi prototipe kerja untuk menguji. Tidak terjebak dalam kelumpuhan analisis atau ideasi murni", "Desain berdasarkan riset: Karya kreatif kamu didukung oleh riset. Tidak asal kreatif, ada bukti atau logika di baliknya", "Pemecahan masalah multidimensional: Bisa menyerang masalah dari berbagai sudut. Pendekatan teknis tidak berhasil? Coba reframe kreatif. Butuh lebih banyak data? Menyelam ke analisis"]'::jsonb,
    '["Tarikan tiga arah: Ketegangan antara ingin menciptakan dengan indah (A), memahami secara mendalam (I), dan mengeksekusi secara praktis (R). Sulit memprioritaskan", "Perfeksionisme lintas dimensi: Ingin berfungsi dengan baik, terlihat bagus, dan secara teoretis solid. Standar tiga kali lipat bisa melumpuhkan", "Kompleksitas komunikasi: Sulit menjelaskan pendekatan integratif kamu ke orang yang hanya kuat di satu dimensi"]'::jsonb,
    '["Fase berurutan: Pisahkan fase analisis, ideasi, dan pembangunan. Tidak harus semua simultan", "Temukan tim interdisipliner: Kelilingi dengan orang yang menghargai pendekatan multifaset", "Dokumentasi portofolio: Tunjukkan bagaimana tiga elemen terintegrasi dalam karyamu. Buat nilai unik kamu terlihat"]'::jsonb,
    '["Laboratorium inovasi: Lingkungan riset dan pengembangan yang menghargai solusi teknis kreatif", "Teknik desain: Peran yang menggabungkan estetika dengan persyaratan teknis", "Riset terapan: Riset yang menghasilkan produk atau prototipe aktual"]'::jsonb,
    '["Tunjukkan, jelaskan, buktikan: Demonstrasikan prototipe sambil menjelaskan alasan kreatif didukung dengan data", "Presentasi multimodal: Gabungkan konten visual, teknis, dan analitis", "Hargai kompleksitas: Hormati orang yang berpikir mendalam tentang kerajinan terlepas dari orientasi utama mereka"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    40,
    'RAS',
    'Realistic Artistic Social (RAS)',
    'RAS menciptakan penolong kreatif yang langsung. Kamu membuat sesuatu (R) secara kreatif (A) untuk melayani orang (S). Pikirkan terapis okupasi yang merancang peralatan adaptif, guru seni yang sangat langsung, atau fasilitator ruang pembuat. Kamu membantu orang melalui pembuatan kreatif. Yang indah dari RAS adalah layananmu nyata. Orang dapat melihat dan menyentuh hasil dari bantuanmu.',
    '["Bantuan praktis kreatif: Solusi kamu untuk masalah orang inovatif dan benar-benar dapat diimplementasikan", "Pengajaran melalui pembuatan: Sangat baik dalam mengajar orang lain melalui aktivitas kreatif langsung. Belajar dengan melakukan", "Kreativitas yang dapat diakses: Membuat proses kreatif mudah didekati. Orang merasa \"Saya bisa melakukan ini\" di bawah bimbingan kamu", "Pembuatan terapeutik: Memahami bagaimana bekerja dengan tangan dan menciptakan bisa menyembuhkan atau mengembangkan"]'::jsonb,
    '["Menyeimbangkan tiga prioritas: Membantu orang (S), integritas kreatif (A), kendala praktis (R). Sesuatu biasanya dikompromikan", "Intensif sumber daya: Pekerjaan kreatif langsung dengan orang memerlukan material, ruang, waktu. Mahal dan menantang untuk diskalakan", "Investasi emosional dalam hasil: Ketika orang bergulat dengan proses pembuatan, kamu merasakannya secara pribadi"]'::jsonb,
    '["Lokakarya kelompok: Layani lebih banyak orang secara bersamaan sambil mempertahankan pendekatan kreatif langsung", "Kecerdikan material: Kreatif dalam mendapatkan material. Bermitra dengan bisnis atau program daur ulang", "Fokus pada proses bukan produk: Tekankan pembelajaran dan pengalaman di atas karya jadi sempurna. Kurangi tekanan pada diri sendiri dan peserta"]'::jsonb,
    '["Ruang pembuat atau lokakarya komunitas: Ruang dirancang untuk pembelajaran kreatif langsung", "Pengaturan terapeutik: Terapi seni, terapi okupasi, terapi hortikultura", "Pendidikan: Guru seni teknis, instruktur kejuruan"]'::jsonb,
    '["Fasilitasi langsung: Bekerja bersama orang, mendemonstrasikan dan mendukung saat mereka menciptakan", "Umpan balik mendorong: Tunjukkan apa yang bekerja dengan baik dalam proses mereka, bangun kepercayaan diri", "Berbagi material dan ruang: Ciptakan perasaan komunitas dalam ruang kerja kreatif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    38,
    'RAE',
    'Realistic Artistic Enterprising (RAE)',
    'RAE menggabungkan keterampilan teknis (R), visi kreatif (A), dengan dorongan kewirausahaan (E). Pikirkan desainer produk yang memulai perusahaan sendiri, teknolog kreatif yang membangun startup, atau arsitek dengan perusahaan pengembangan. Kamu tidak hanya menciptakan, kamu menciptakan untuk berhasil secara komersial. Kreativitas praktis dengan ambisi bisnis.',
    '["Inovasi yang layak secara komersial: Menciptakan produk atau layanan yang inovatif dan layak pasar. Menyeimbangkan seni dengan perdagangan", "Kemampuan ujung ke ujung: Membayangkan konsep kreatif, membangunnya sendiri, dan membawa ke pasar. Ketergantungan lebih sedikit pada orang lain", "Iterasi cepat: Keterampilan teknis memungkinkan pembuatan prototipe cepat untuk menguji respons pasar. Gagal cepat, belajar, tingkatkan", "Kepemimpinan kreatif kredibel: Memimpin usaha kreatif dengan visi artistik dan keterampilan eksekusi praktis"]'::jsonb,
    '["Melakukan terlalu banyak sendiri: Karena bisa melakukan segalanya, kecenderungan adalah melakukan segalanya. Sulit mendelegasikan", "Kompromi kreatif untuk pasar: Ketegangan antara integritas artistik dan tuntutan komersial. Kapan mempertahankan tanah versus beradaptasi?", "Keterbatasan penskalaan: Kerajinan pribadi kamu adalah pembeda tapi membatasi skala. Sulit tumbuh melampaui apa yang bisa kamu buat secara pribadi"]'::jsonb,
    '["Bangun tim produksi: Akhirnya perlu orang lain yang mengeksekusi sementara kamu fokus pada desain dan bisnis", "Definisikan gaya tanda tangan: Kembangkan pendekatan yang dapat dikenali yang dapat dipertahankan bahkan saat skala", "Kemitraan strategis: Berkolaborasi dengan orang yang kuat di area yang bukan kamu, seperti pemasaran atau keuangan"]'::jsonb,
    '["Kewirausahaan kreatif: Studio, toko, atau perusahaan sendiri menciptakan dan menjual produk kreatif", "Pengembangan produk: Memimpin pengembangan kreatif teknis dalam startup atau tim inovasi", "Kreatif teknis lepas: Praktik independen melakukan pekerjaan kreatif teknis untuk klien"]'::jsonb,
    '["Penjualan portofolio: Tunjukkan apa yang kamu buat sebagai alat penjualan utama. Biarkan karya berbicara", "Promosi kreatif percaya diri: Presentasikan ide dengan keyakinan didukung oleh kredibilitas \"Saya bisa membuat ini\"", "Kolaborasi klien: Bekerja erat dengan klien melalui proses desain dan pembangunan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    37,
    'RAC',
    'Realistic Artistic Conventional (RAC)',
    'RAC menciptakan pengrajin kreatif yang disiplin. Keterampilan teknis (R), ekspresi kreatif (A), eksekusi terorganisir (C). Pikirkan pengrajin master dengan praktik studio sistematis, ilustrator teknis dengan alur kerja tepat, atau fabrikator yang mempertahankan organisasi bengkel sempurna. Kreativitasmu disalurkan melalui disiplin. Keunggulan kerajinan melalui praktik yang ketat.',
    '["Keterampilan kerajinan konsisten: Setiap karya memenuhi standar tinggi karena sistem memastikan kontrol kualitas", "Produksi kreatif efisien: Alur kerja terorganisir memungkinkan output produktif tanpa kekacauan. Membuat lebih banyak tanpa mengorbankan kualitas", "Metode yang dapat diajarkan: Karena proses sistematis, dapat secara efektif mengajar orang lain kerajinan kamu", "Penguasaan keterampilan jangka panjang: Praktik disiplin dari waktu ke waktu mengembangkan keahlian mendalam dalam kerajinan kamu"]'::jsonb,
    '["Kekakuan dalam proses kreatif: Alur kerja tetap mungkin membatasi eksplorasi kreatif spontan", "Perfeksionisme menunda: Kombinasi presisi teknis, standar artistik, dan ketelitian organisasi menciptakan standar sangat tinggi", "Resistensi terhadap metode baru: Berinvestasi dalam teknik terbukti mungkin memperlambat adopsi alat atau pendekatan baru"]'::jsonb,
    '["Eksperimen terjadwal: Sisihkan waktu reguler untuk bermain dengan teknik baru di luar alur kerja produksi", "Penguasaan progresif: Terima bahwa penguasaan adalah perjalanan. Izinkan diri kamu membuat karya tidak sempurna saat belajar keterampilan baru", "Dokumentasikan evolusi: Simpan karya awal sebagai referensi untuk melihat pertumbuhan. Ingatkan diri sendiri kesempurnaan adalah tujuan bukan titik awal"]'::jsonb,
    '["Studio kerajinan tradisional: Pengerjaan kayu, keramik, logam, atau produksi kreatif langsung lainnya", "Layanan kreatif teknis: Ilustrasi, gambar teknis, pembuatan model", "Desain produksi: Set, prop, kostum untuk teater atau film"]'::jsonb,
    '["Pengajaran sistematis: Pelajaran terstruktur membangun keterampilan secara progresif. Perkembangan jelas dari dasar ke lanjutan", "Disiplin studio: Harapkan kebersihan, organisasi, pemeliharaan alat yang tepat dari diri sendiri dan orang lain", "Apresiasi kerajinan: Hormati kualitas pengerjaan terlepas dari medium atau gaya"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    41,
    'RCA',
    'Realistic Conventional Artistic (RCA)',
    'RCA menggabungkan keterampilan teknis praktis dengan kecintaan pada organisasi dan sentuhan kreatif. Ini adalah kombinasi yang menciptakan profesional teknis yang sistematis namun memiliki kepekaan estetika. Pikirkan desainer produk industri, arsitek teknis, atau spesialis dokumentasi teknis yang juga visual designer. Kamu tidak hanya membuat sesuatu yang berfungsi dan terorganisir, tetapi juga mempertimbangkan bagaimana tampilannya. Yang unik dari RCA adalah kemampuanmu menyeimbangkan fungsi, sistem, dan bentuk.',
    '["Desain teknis sistematis: Kamu bisa merancang solusi teknis yang tidak hanya berfungsi dengan baik tetapi juga memiliki struktur yang jelas dan visual yang menarik", "Dokumentasi visual yang terorganisir: Sangat baik dalam membuat dokumentasi teknis yang terstruktur rapi dan mudah dipahami secara visual", "Kontrol kualitas estetika: Memastikan produk atau sistem tidak hanya memenuhi spesifikasi teknis dan prosedur, tetapi juga standar visual", "Produksi yang efisien dan berkualitas: Menggabungkan efisiensi operasional dengan standar kualitas tinggi dalam aspek teknis dan estetika"]'::jsonb,
    '["Perfeksionisme tiga dimensi: Ingin sempurna secara teknis, terorganisir dengan baik, dan indah secara visual. Standar tinggi ini bisa memperlambat kemajuan", "Kesulitan dengan spontanitas: Kombinasi kebutuhan akan struktur dan eksekusi teknis yang tepat membuat sulit untuk berimprovisasi", "Frustrasi dengan keterbatasan: Batasan teknis atau anggaran yang membatasi baik fungsi maupun estetika bisa sangat mengecewakan"]'::jsonb,
    '["Prioritaskan dimensi per fase: Fokus pada fungsi teknis dulu, lalu organisasi, kemudian poles estetika. Tidak semua harus sempurna bersamaan", "Tetapkan standar kontekstual: Tentukan tingkat kesempurnaan yang sesuai untuk setiap proyek. Tidak semua memerlukan standar tertinggi di semua dimensi", "Bangun template dan sistem: Ciptakan kerangka kerja yang sudah menyeimbangkan ketiga aspek, sehingga tidak harus mulai dari nol setiap kali"]'::jsonb,
    '["Desain produk atau industri: Peran yang menggabungkan fungsi teknis dengan estetika dan produksi sistematis", "Arsitektur teknis: Posisi yang memerlukan ketelitian teknis, organisasi proyek, dan sensibilitas desain", "Komunikasi teknis visual: Peran yang melibatkan pembuatan dokumentasi atau materi teknis yang terstruktur dan menarik secara visual"]'::jsonb,
    '["Presentasi visual terstruktur: Menyajikan informasi teknis dengan cara yang terorganisir dan menarik secara visual", "Standar dokumentasi tinggi: Mengharapkan dokumentasi yang tidak hanya lengkap dan akurat, tetapi juga rapi dan mudah dibaca", "Perhatian pada detail presentasi: Peduli tentang bagaimana pekerjaan teknis dipresentasikan, tidak hanya kontennya"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    42,
    'RCE',
    'Realistic Conventional Enterprising (RCE)',
    'RCE menggabungkan kemampuan teknis praktis, kecintaan pada sistem terorganisir, dan dorongan untuk mencapai hasil. Ini adalah kombinasi yang sangat efektif untuk manajemen operasional dan peningkatan efisiensi. Pikirkan manajer pabrik, direktur operasi manufaktur, atau konsultan produktivitas. Kamu tidak hanya memahami pekerjaan teknis dan sistem, tetapi juga tahu cara mengoptimalkannya untuk hasil maksimal. Yang kuat dari RCE adalah kemampuanmu menggerakkan operasi teknis secara efisien menuju target yang ambisius.',
    '["Optimasi operasional: Sangat terampil dalam mengidentifikasi inefisiensi dalam operasi teknis dan merancang sistem yang lebih baik", "Manajemen produksi berbasis data: Menggunakan metrik dan sistem pelacakan untuk memastikan target produksi tercapai dengan kualitas konsisten", "Kepemimpinan teknis yang sistematis: Memimpin tim teknis dengan struktur yang jelas dan fokus pada hasil terukur", "Peningkatan berkelanjutan: Tidak puas dengan status quo, selalu mencari cara untuk meningkatkan efisiensi dan output"]'::jsonb,
    '["Tekanan berlebihan pada efisiensi: Fokus kuat pada produktivitas bisa membuat tim merasa seperti mesin, bukan manusia", "Resistensi terhadap fleksibilitas: Sistem yang kaku mungkin tidak mengakomodasi situasi khusus atau inovasi yang tidak sesuai prosedur", "Mengabaikan faktor manusia: Terlalu fokus pada metrik dan sistem bisa mengabaikan kesejahteraan atau ide dari tim"]'::jsonb,
    '["Libatkan tim dalam peningkatan: Ajak orang yang melakukan pekerjaan untuk membantu merancang sistem yang lebih baik", "Seimbangkan efisiensi dengan keberlanjutan: Pastikan peningkatan produktivitas tidak menciptakan kelelahan atau turnover tinggi", "Rayakan pencapaian: Kenali dan hargai ketika target tercapai, bukan hanya fokus pada apa yang masih perlu ditingkatkan"]'::jsonb,
    '["Manajemen manufaktur: Peran yang mengawasi produksi dengan fokus pada efisiensi dan kualitas", "Manajemen rantai pasokan: Posisi yang mengoptimalkan aliran material dan produk", "Konsultan operasional: Membantu organisasi meningkatkan efisiensi operasional mereka"]'::jsonb,
    '["Komunikasi berbasis metrik: Diskusi sering berpusat pada angka, target, dan indikator kinerja", "Rapat berorientasi solusi: Mengidentifikasi masalah dan langsung membahas cara memperbaikinya", "Ekspektasi akuntabilitas tinggi: Jelas tentang tanggung jawab dan mengharapkan orang memenuhi komitmen mereka"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    43,
    'RCI',
    'Realistic Conventional Investigative (RCI)',
    'RCI menggabungkan keterampilan teknis praktis, pendekatan sistematis, dan keingintahuan analitis. Ini menciptakan profesional teknis yang tidak hanya mengikuti prosedur tetapi juga memahami mengapa prosedur itu ada dan bagaimana meningkatkannya berdasarkan data. Pikirkan insinyur kualitas yang melakukan riset, analis sistem yang juga programmer, atau teknisi laboratorium yang merancang eksperimen. Kamu adalah jembatan antara pelaksanaan teknis, sistem terorganisir, dan pemahaman mendalam.',
    '["Validasi sistematis: Tidak hanya mengikuti prosedur tetapi memvalidasinya dengan data dan pengujian", "Dokumentasi berbasis bukti: Membuat dokumentasi yang tidak hanya lengkap tetapi juga didukung oleh data dan analisis", "Pemecahan masalah metodis: Mendekati masalah teknis dengan cara yang terstruktur dan analitis, mendokumentasikan temuan", "Peningkatan berbasis riset: Menggunakan pendekatan ilmiah untuk mengidentifikasi dan mengimplementasikan perbaikan sistem"]'::jsonb,
    '["Terlalu teliti untuk situasi cepat: Keinginan untuk menganalisis dan mendokumentasikan dengan benar bisa memperlambat respons terhadap masalah mendesak", "Frustrasi dengan keputusan tanpa data: Tidak nyaman ketika keputusan teknis dibuat berdasarkan intuisi atau tekanan politik", "Isolasi dalam detail: Bisa terlalu tenggelam dalam analisis dan dokumentasi sehingga kehilangan gambaran besar"]'::jsonb,
    '["Kategorisasi berdasarkan urgensi: Tetapkan tingkat analisis berbeda untuk situasi berbeda. Tidak semua masalah memerlukan investigasi penuh", "Komunikasikan nilai analisis: Bantu orang lain memahami bagaimana pendekatan metodis kamu menghemat waktu dan biaya jangka panjang", "Kolaborasi dengan tipe strategis: Bekerja dengan orang yang bisa membantu menghubungkan analisis detail kamu dengan tujuan organisasi lebih luas"]'::jsonb,
    '["Jaminan kualitas analitis: Peran yang menggabungkan pengujian teknis dengan analisis statistik dan peningkatan proses", "Riset dan pengembangan teknis: Laboratorium atau fasilitas di mana pekerjaan teknis dilakukan dengan pendekatan riset sistematis", "Analisis sistem: Posisi yang memerlukan pemahaman teknis, organisasi data, dan kemampuan analitis"]'::jsonb,
    '["Laporan teknis terstruktur: Menyajikan temuan dengan format yang jelas, didukung data, dan terorganisir dengan baik", "Diskusi berbasis bukti: Membawa data dan dokumentasi ke dalam diskusi teknis", "Pertanyaan metodologis: Secara natural bertanya tentang metode dan validitas ketika mengevaluasi pekerjaan atau klaim"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    44,
    'RCS',
    'Realistic Conventional Social (RCS)',
    'RCS menggabungkan keterampilan teknis praktis, pendekatan sistematis, dan orientasi membantu orang. Ini menciptakan profesional yang memberikan layanan teknis dengan cara yang terorganisir dan peduli. Pikirkan teknisi medis, koordinator layanan teknis, atau manajer fasilitas dengan fokus pada pengguna. Kamu memastikan sistem teknis berjalan lancar untuk melayani orang dengan lebih baik, dan kamu melakukannya dengan cara yang terorganisir dan dapat diandalkan.',
    '["Layanan teknis yang dapat diandalkan: Memberikan dukungan teknis yang konsisten dan terorganisir kepada orang yang membutuhkan", "Sistem berorientasi pengguna: Merancang prosedur teknis yang tidak hanya efisien tetapi juga mempertimbangkan kebutuhan pengguna", "Dokumentasi yang mudah diakses: Membuat panduan teknis dan dokumentasi yang terstruktur dengan baik dan dapat dipahami orang awam", "Pelatihan sistematis: Mengajarkan keterampilan teknis dengan cara yang terstruktur dan mendukung"]'::jsonb,
    '["Frustrasi dengan permintaan yang melanggar prosedur: Ingin membantu tetapi juga ingin mengikuti sistem yang tepat", "Konflik antara efisiensi dan perhatian personal: Sistem dirancang untuk efisiensi tetapi orang kadang butuh perhatian individual", "Kelelahan dari tuntuan ganda: Menjaga standar teknis dan sistem sambil juga responsif terhadap kebutuhan manusia bisa menguras energi"]'::jsonb,
    '["Bangun fleksibilitas terstruktur: Buat sistem dengan ruang untuk penyesuaian kasus per kasus dalam parameter yang jelas", "Dokumentasikan kasus khusus: Ketika membuat pengecualian, dokumentasikan alasannya untuk membangun basis pengetahuan", "Tetapkan jam konsultasi: Alokasikan waktu khusus untuk interaksi yang lebih personal, terpisah dari operasi rutin"]'::jsonb,
    '["Layanan teknis pelanggan: Departemen dukungan yang menyediakan bantuan teknis terorganisir kepada pengguna", "Manajemen fasilitas kesehatan: Peran yang memastikan peralatan dan sistem medis berfungsi untuk perawatan pasien", "Layanan dukungan pendidikan: Posisi yang memberikan dukungan teknis terorganisir untuk lingkungan belajar"]'::jsonb,
    '["Komunikasi teknis yang sabar: Menjelaskan hal teknis dengan cara yang terstruktur tetapi ramah dan mudah dipahami", "Prosedur yang manusiawi: Menegakkan prosedur tetapi dengan pemahaman terhadap situasi individual", "Tindak lanjut sistematis: Memeriksa kembali dengan orang untuk memastikan masalah terselesaikan, didokumentasikan dengan baik"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    46,
    'REC',
    'Realistic Enterprising Conventional (REC)',
    'REC menggabungkan kemampuan teknis praktis, ambisi untuk mencapai, dan kecintaan pada sistem terorganisir. Ini adalah kombinasi yang sangat efektif untuk kepemimpinan operasional yang berfokus pada hasil terukur. Pikirkan direktur operasi di perusahaan manufaktur, manajer proyek konstruksi, atau pemilik bisnis layanan teknis. Kamu memahami pekerjaan teknis, tahu cara mengorganisirnya secara efisien, dan memiliki dorongan untuk mencapai target yang ambisius.',
    '["Kepemimpinan operasional yang terukur: Memimpin operasi teknis dengan fokus jelas pada metrik kinerja dan hasil", "Sistem untuk pertumbuhan: Membangun infrastruktur dan proses yang memungkinkan operasi berkembang secara efisien", "Eksekusi yang dapat diprediksi: Menciptakan sistem yang memberikan hasil konsisten dan dapat diandalkan", "Manajemen sumber daya yang efektif: Mengoptimalkan penggunaan sumber daya teknis, manusia, dan finansial untuk mencapai tujuan"]'::jsonb,
    '["Birokratisasi yang berlebihan: Kecintaan pada sistem bisa menciptakan proses yang memperlambat ketangkasan", "Fokus berlebih pada efisiensi: Mengoptimalkan untuk metrik jangka pendek bisa mengorbankan inovasi atau pengembangan jangka panjang", "Resistensi terhadap perubahan yang mengganggu: Berinvestasi dalam sistem yang ada membuat sulit menerima inovasi yang memerlukan perubahan radikal"]'::jsonb,
    '["Tinjauan sistem berkala: Secara rutin evaluasi apakah sistem masih melayani tujuan atau sudah menjadi hambatan", "Seimbangkan eksploitasi dengan eksplorasi: Alokasikan sumber daya untuk mengoptimalkan sistem yang ada dan mengeksplorasi pendekatan baru", "Dengarkan garis depan: Orang yang melakukan pekerjaan sering punya wawasan tentang bagaimana sistem bisa lebih baik"]'::jsonb,
    '["Operasi manufaktur atau produksi: Lingkungan di mana kepemimpinan teknis, sistem, dan fokus hasil semuanya penting", "Manajemen proyek teknis: Peran yang mengawasi proyek kompleks dengan banyak komponen teknis", "Kewirausahaan layanan teknis: Memiliki atau mengelola bisnis yang menyediakan layanan teknis"]'::jsonb,
    '["Rapat singkat berorientasi aksi: Diskusi terstruktur yang dengan cepat mengarah ke keputusan dan penugasan", "Pelaporan kinerja reguler: Pembaruan terjadwal tentang metrik kunci dan kemajuan terhadap target", "Ekspektasi yang jelas: Komunikasi tegas tentang standar, prosedur, dan hasil yang diharapkan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    47,
    'REI',
    'Realistic Enterprising Investigative (REI)',
    'REI menggabungkan kemampuan teknis praktis, ambisi strategis, dan keingintahuan analitis. Ini menciptakan pemimpin teknis yang membuat keputusan berdasarkan data dan dorongan untuk inovasi. Pikirkan direktur riset dan pengembangan, pendiri startup teknologi, atau konsultan teknis strategis. Kamu tidak hanya memahami teknologi dan memiliki visi bisnis, tetapi juga menggunakan analisis untuk menginformasikan arah strategis.',
    '["Inovasi berbasis riset: Mengidentifikasi peluang untuk inovasi teknis berdasarkan analisis pasar dan kemampuan teknis", "Strategi teknis berbasis data: Membuat keputusan strategis tentang arah teknis didukung oleh riset dan analisis", "Kepemimpinan yang kredibel: Dapat memimpin tim teknis dengan kredibilitas karena memahami pekerjaan dan dapat mengartikulasikan visi berbasis bukti", "Eksekusi ambisius yang terukur: Menetapkan target yang menantang tetapi dapat dicapai berdasarkan analisis kemampuan"]'::jsonb,
    '["Tidak sabar dengan riset yang lambat: Ingin hasil dan kemajuan cepat, tetapi riset yang baik membutuhkan waktu", "Terlalu percaya diri dengan data: Data memberikan keyakinan tetapi tidak menghilangkan semua risiko dalam keputusan strategis", "Kesulitan dengan ambiguitas: Lebih nyaman dengan keputusan yang bisa divalidasi dengan data, kurang nyaman dengan lompatan intuitif"]'::jsonb,
    '["Pendekatan bertahap untuk inovasi: Pecah proyek besar menjadi fase yang lebih kecil dengan validasi di setiap tahap", "Keseimbangan data dengan intuisi: Kenali bahwa tidak semua keputusan strategis bisa sepenuhnya didukung data", "Bangun budaya eksperimen: Ciptakan ruang untuk pengujian cepat dan pembelajaran dari kegagalan"]'::jsonb,
    '["Riset dan pengembangan komersial: Organisasi di mana inovasi teknis dikaitkan dengan tujuan bisnis", "Startup teknologi: Lingkungan kewirausahaan yang memerlukan kepemimpinan teknis dan strategi berbasis data", "Konsultasi teknis strategis: Peran yang membantu organisasi membuat keputusan teknis strategis"]'::jsonb,
    '["Presentasi visi berbasis bukti: Mengartikulasikan arah strategis dengan dukungan data dan analisis teknis", "Diskusi strategis mendalam: Menikmati eksplorasi kemungkinan teknis dengan pemahaman detail", "Tantangan konstruktif: Mempertanyakan asumsi dan mendorong tim untuk memvalidasi ide dengan data"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    48,
    'RES',
    'Realistic Enterprising Social (RES)',
    'RES menggabungkan kemampuan teknis praktis, ambisi untuk mencapai, dan kepedulian terhadap orang. Ini menciptakan pemimpin yang ingin membangun sesuatu yang signifikan sambil mengembangkan tim mereka. Pikirkan pendiri sosial dengan latar belakang teknis, direktur program teknis dengan misi sosial, atau manajer yang membangun tim teknis berkinerja tinggi. Kamu ingin mencapai hasil ambisius melalui pekerjaan teknis, dan kamu peduli tentang orang yang melakukannya.',
    '["Kepemimpinan yang memberdayakan: Memimpin proyek teknis sambil mengembangkan kemampuan dan karier tim", "Orientasi dampak: Fokus pada bagaimana pekerjaan teknis menciptakan nilai untuk orang atau masyarakat", "Membangun tim yang loyal: Orang ingin bekerja untuk kamu karena merasa dihargai dan didukung", "Keseimbangan tujuan dan manusia: Mendorong hasil tanpa mengabaikan kesejahteraan tim"]'::jsonb,
    '["Konflik loyalitas: Terkadang terjebak antara tekanan untuk hasil dan perhatian terhadap kesejahteraan tim", "Kesulitan dengan keputusan sulit: Membuat keputusan yang berdampak negatif pada individu (seperti PHK) sangat sulit", "Beban emosional kepemimpinan: Merasa bertanggung jawab atas kesuksesan organisasi dan kesejahteraan tim"]'::jsonb,
    '["Komunikasi transparan: Jelaskan konteks dan alasan di balik keputusan sulit, hormati kecerdasan dan kedewasaan tim", "Dukungan transisi: Ketika keputusan sulit tidak bisa dihindari, berikan dukungan maksimal untuk yang terdampak", "Delegasi dengan pengembangan: Berikan tanggung jawab yang menantang sebagai peluang pengembangan, bukan hanya untuk mengosongkan piring kamu"]'::jsonb,
    '["Perusahaan sosial teknologi: Organisasi yang menggunakan teknologi untuk misi sosial", "Organisasi nirlaba dengan operasi teknis: Lingkungan yang menggabungkan misi sosial dengan pengiriman teknis", "Tim teknis dengan budaya kuat: Departemen teknologi dalam organisasi yang menghargai orang dan kinerja"]'::jsonb,
    '["Check-in reguler: Tidak hanya tentang status proyek tetapi juga bagaimana orang menanganinya", "Merayakan kesuksesan bersama: Mengakui kontribusi individu dan tim ketika mencapai milestone", "Umpan balik yang peduli: Memberikan umpan balik jujur dengan niat membantu orang berkembang"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    45,
    'REA',
    'Realistic Enterprising Artistic (REA)',
    'REA menggabungkan kemampuan teknis praktis, ambisi bisnis, dan visi kreatif. Ini menciptakan pengusaha kreatif yang bisa mewujudkan ide inovatif menjadi produk komersial. Pikirkan pendiri startup desain produk, direktur kreatif dengan latar belakang teknis, atau pengusaha di industri kreatif dengan operasi nyata. Kamu bisa membayangkan produk inovatif, membangunnya sendiri, dan membawanya ke pasar dengan strategi bisnis yang solid.',
    '["Visi ke pasar: Dapat mengambil konsep kreatif dan menerjemahkannya menjadi produk yang dapat diproduksi dan dipasarkan", "Prototipe cepat untuk validasi: Keterampilan teknis memungkinkan pembuatan prototipe cepat untuk menguji ide di pasar", "Kepemimpinan kreatif praktis: Memimpin tim dengan visi kreatif yang jelas dan pemahaman tentang apa yang secara praktis dapat dicapai", "Diferensiasi produk: Menciptakan produk yang menonjol di pasar melalui inovasi teknis dan desain"]'::jsonb,
    '["Kompromi antara visi dan viabilitas: Terkadang harus mengorbankan elemen kreatif untuk membuat produk yang secara komersial layak", "Melakukan terlalu banyak sendiri: Kemampuan untuk merancang dan membangun bisa membuat sulit mendelegasikan", "Ketegangan antara seni dan perdagangan: Keputusan bisnis kadang bertentangan dengan visi kreatif"]'::jsonb,
    '["Definisikan elemen inti: Tentukan aspek kreatif mana yang tidak bisa dikompromikan versus yang fleksibel", "Bangun tim pelengkap: Rekrut orang yang kuat di area yang bukan keahlian kamu, seperti pemasaran atau keuangan", "Iterasi berdasarkan umpan balik: Gunakan umpan balik pasar untuk menyempurnakan produk tanpa kehilangan visi inti"]'::jsonb,
    '["Startup produk desain: Perusahaan yang menciptakan produk inovatif dengan desain kuat", "Industri kreatif dengan manufaktur: Bisnis yang menggabungkan desain kreatif dengan produksi fisik", "Konsultasi inovasi produk: Membantu organisasi mengembangkan produk baru yang inovatif dan dapat diproduksi"]'::jsonb,
    '["Pitch produk: Mempresentasikan produk dengan kombinasi storytelling kreatif dan detail teknis", "Kolaborasi kreatif praktis: Bekerja dengan desainer dan insinyur untuk menyeimbangkan visi dengan realitas", "Jaringan industri: Membangun hubungan dengan manufaktur, distributor, dan mitra potensial"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    50,
    'RIC',
    'Realistic Investigative Conventional (RIC)',
    'RIC menggabungkan kemampuan teknis praktis, keingintahuan analitis, dan kecintaan pada sistem terorganisir. Ini menciptakan profesional teknis yang metodis dan berbasis riset. Pikirkan ilmuwan laboratorium, insinyur riset dengan fokus kualitas, atau analis sistem yang juga programmer. Kamu tidak hanya melakukan pekerjaan teknis tetapi juga memahami teori di baliknya dan mendokumentasikan semuanya dengan sistematis.',
    '["Riset teknis yang terstruktur: Melakukan pekerjaan riset dengan metodologi yang ketat dan dokumentasi yang rapi", "Validasi sistematis: Tidak hanya mengikuti teori tetapi mengujinya dalam praktik dan mendokumentasikan hasilnya", "Keandalan eksperimental: Eksperimen atau tes yang kamu lakukan dapat direproduksi karena dokumentasi yang menyeluruh", "Pemecahan masalah berbasis bukti: Mendekati masalah teknis dengan pendekatan ilmiah yang terdokumentasi"]'::jsonb,
    '["Lambat dalam lingkungan cepat: Pendekatan metodis dan dokumentasi menyeluruh membutuhkan waktu", "Frustrasi dengan pendekatan coba-coba: Tidak nyaman ketika orang mengabaikan metodologi yang tepat", "Terlalu detail: Bisa tenggelam dalam detail metodologi dan dokumentasi sehingga kehilangan momentum"]'::jsonb,
    '["Protokol cepat untuk situasi mendesak: Kembangkan prosedur yang disederhanakan untuk situasi yang memerlukan respons cepat", "Dokumentasi bertahap: Dokumentasikan hal penting segera, detail bisa ditambahkan kemudian", "Kolaborasi dengan tipe pragmatis: Bekerja dengan orang yang bisa membantu menyeimbangkan ketelitian dengan kecepatan"]'::jsonb,
    '["Laboratorium riset: Fasilitas di mana pekerjaan teknis dilakukan dengan standar ilmiah yang ketat", "Jaminan kualitas berbasis riset: Departemen QA yang menggunakan pendekatan analitis sistematis", "Pengembangan standar teknis: Organisasi yang mengembangkan spesifikasi dan standar industri"]'::jsonb,
    '["Laporan metodologis detail: Dokumentasi yang menjelaskan tidak hanya hasil tetapi juga proses", "Diskusi berbasis data: Percakapan yang berpusat pada temuan, metode, dan validitas", "Peer review: Menghargai dan berpartisipasi dalam proses tinjauan ilmiah"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    49,
    'RIA',
    'Realistic Investigative Artistic (RIA)',
    'RIA menggabungkan kemampuan teknis praktis, kedalaman analitis, dan kreativitas. Ini adalah kombinasi yang menciptakan inovator teknis yang pendekatan kreatifnya didasarkan pada pemahaman mendalam. Pikirkan peneliti desain yang juga engineer, ilmuwan data yang membuat visualisasi inovatif, atau inventor yang menggabungkan riset dengan eksperimen kreatif. Kamu melakukan, memahami, dan menciptakan secara bersamaan.',
    '["Inovasi yang diinformasikan: Ide kreatif kamu didasarkan pada pemahaman teknis dan analitis yang solid", "Eksperimen yang terdokumentasi: Eksplorasi kreatif kamu dilakukan dengan metodologi yang memungkinkan pembelajaran sistematis", "Pemecahan masalah kreatif berbasis riset: Menggunakan wawasan dari riset untuk menginformasikan solusi kreatif", "Komunikasi teknis yang menarik: Bisa menyajikan informasi teknis kompleks dengan cara yang kreatif dan mudah dipahami"]'::jsonb,
    '["Tarikan antara ketelitian dan kreativitas: Rigor analitis bisa membatasi aliran kreatif, sementara kreativitas bisa membuat analisis kurang fokus", "Perfeksionisme multidimensi: Ingin solusi yang kreatif, terbukti secara analitis, dan dapat diimplementasikan secara teknis", "Komunikasi kompleks: Sulit menjelaskan pendekatan integratif kamu kepada orang yang hanya kuat di satu area"]'::jsonb,
    '["Pemisahan fase: Waktu untuk eksplorasi kreatif, waktu untuk analisis ketat, waktu untuk implementasi teknis", "Dokumentasi visual: Gunakan sketsa, diagram, dan visualisasi untuk mengkomunikasikan ide kompleks", "Kolaborasi interdisipliner: Bekerja dengan tim yang menghargai pendekatan multifaset"]'::jsonb,
    '["Laboratorium inovasi: Lingkungan riset yang menghargai kreativitas berbasis bukti", "Studio desain berbasis riset: Praktik desain yang mengintegrasikan riset pengguna dan eksperimen", "Visualisasi data: Peran yang menggabungkan analisis data dengan komunikasi visual kreatif"]'::jsonb,
    '["Presentasi yang menggabungkan data dan visual: Menggunakan visualisasi kreatif untuk mengkomunikasikan temuan analitis", "Demo interaktif: Lebih suka menunjukkan prototipe dan memungkinkan eksplorasi langsung", "Diskusi konseptual teknis: Menikmati percakapan yang mengeksplorasi ide di tingkat teoritis dan praktis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    51,
    'RIE',
    'Realistic Investigative Enterprising (RIE)',
    'RIE menggabungkan kemampuan teknis praktis, pemikiran analitis mendalam, dan ambisi untuk mencapai. Ini menciptakan pemimpin teknis yang membuat keputusan strategis berdasarkan analisis dan memahami implementasi. Pikirkan CTO di startup teknologi, direktur teknis di firma konsultan, atau ilmuwan yang juga pengusaha. Kamu bisa menganalisis, mengimplementasikan, dan mengarahkan secara strategis.',
    '["Kepemimpinan teknis berbasis data: Membuat keputusan strategis tentang teknologi berdasarkan analisis menyeluruh", "Kredibilitas ganda: Dapat berbicara bahasa teknis dengan engineer dan bahasa bisnis dengan eksekutif", "Eksekusi strategi yang praktis: Strategi yang kamu buat dapat diimplementasikan karena pemahaman teknis", "Inovasi yang terukur: Mengidentifikasi peluang inovasi berdasarkan analisis dan mendorong implementasinya"]'::jsonb,
    '["Tidak sabar dengan non-teknis: Frustrasi ketika harus menyederhanakan terlalu banyak untuk audiens non-teknis", "Terlalu percaya diri: Kombinasi pemahaman teknis dan analitis bisa membuat terlalu yakin dengan keputusan", "Kesulitan mendelegasikan: Bisa melakukan baik analisis maupun implementasi, sulit mempercayai orang lain"]'::jsonb,
    '["Bangun tim lengkap: Rekrut orang yang kuat di area yang berbeda, percayai mereka dengan keahlian mereka", "Komunikasi berlapis: Siapkan versi berbeda dari presentasi untuk audiens teknis dan non-teknis", "Cari umpan balik eksternal: Minta perspektif dari orang di luar domain teknis untuk menantang asumsi"]'::jsonb,
    '["Kepemimpinan teknologi: Peran CTO atau VP Engineering di perusahaan teknologi", "Konsultasi teknis strategis: Membantu organisasi membuat keputusan teknologi strategis", "Kewirausahaan teknologi: Mendirikan atau memimpin startup berbasis teknologi"]'::jsonb,
    '["Presentasi eksekutif teknis: Menyajikan analisis teknis dengan implikasi bisnis yang jelas", "Diskusi strategi mendalam: Menikmati eksplorasi kemungkinan teknologi dengan detail teknis", "Mentorship teknis: Membimbing engineer junior dengan berbagi pemahaman teknis dan strategis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    52,
    'RIS',
    'Realistic Investigative Social (RIS)',
    'RIS menggabungkan kemampuan teknis praktis, keingintahuan analitis, dan kepedulian terhadap orang. Ini menciptakan profesional teknis yang menggunakan keterampilan mereka untuk memahami dan membantu orang dengan cara yang berbasis riset. Pikirkan peneliti kesehatan masyarakat dengan latar belakang teknis, ergonomis, atau teknolog pendidikan yang melakukan riset pengguna. Kamu menggunakan kemampuan teknis dan analitis untuk membuat hidup orang lebih baik.',
    '["Riset berpusat manusia dengan ketelitian teknis: Mempelajari orang dengan metodologi yang ketat dan empati", "Solusi teknis berdasarkan pemahaman pengguna: Mengembangkan teknologi yang benar-benar memenuhi kebutuhan orang", "Evaluasi dampak: Tidak hanya membangun tetapi juga mengukur bagaimana solusi teknis memengaruhi orang", "Advokasi berbasis bukti: Menggunakan data untuk mengadvokasi perubahan yang membantu orang"]'::jsonb,
    '["Frustrasi dengan implementasi lambat: Melihat masalah yang membutuhkan solusi teknis tetapi perubahan membutuhkan waktu", "Beban emosional riset: Mempelajari masalah orang bisa secara emosional menantang", "Ketegangan antara ketelitian dan urgensi: Riset yang baik membutuhkan waktu tetapi kebutuhan orang mendesak"]'::jsonb,
    '["Pendekatan riset partisipatif: Libatkan pengguna dalam proses riset dan desain untuk mempercepat adopsi", "Implementasi bertahap: Luncurkan solusi dalam fase untuk memberikan manfaat lebih cepat sambil terus menyempurnakan", "Komunikasi dampak: Bagikan cerita tentang bagaimana pekerjaan kamu memengaruhi orang untuk mempertahankan motivasi"]'::jsonb,
    '["Riset kesehatan atau rehabilitasi: Mengembangkan teknologi atau intervensi untuk perawatan kesehatan", "Teknologi pendidikan: Merancang dan meneliti alat pembelajaran berbasis teknologi", "Desain pengalaman pengguna: Riset dan desain yang berfokus pada kebutuhan pengguna nyata"]'::jsonb,
    '["Riset pengguna empatik: Melakukan riset dengan mendengarkan aktif dan kepedulian terhadap partisipan", "Presentasi berbasis cerita: Menggabungkan data dengan narasi manusia untuk mengkomunikasikan temuan", "Kolaborasi dengan pemangku kepentingan: Bekerja erat dengan komunitas yang dilayani"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    53,
    'RSA',
    'Realistic Social Artistic (RSA)',
    'RSA menggabungkan kemampuan teknis praktis, orientasi membantu orang, dan kreativitas. Ini menciptakan fasilitator kreatif yang menggunakan keterampilan teknis untuk membantu orang mengekspresikan diri. Pikirkan terapis seni dengan keterampilan teknis, koordinator program kreatif komunitas, atau desainer yang bekerja langsung dengan klien. Kamu membantu orang melalui pembuatan kreatif yang didukung keterampilan teknis.',
    '["Fasilitasi kreatif yang terampil: Dapat mengajarkan keterampilan teknis sambil mendorong ekspresi kreatif individual", "Adaptasi untuk kebutuhan individu: Menyesuaikan pendekatan teknis dan kreatif berdasarkan kemampuan dan minat orang", "Menciptakan lingkungan yang mendukung: Membuat ruang di mana orang merasa aman untuk bereksperimen secara kreatif", "Dampak yang terlihat: Pekerjaan kamu menghasilkan karya nyata yang dibuat orang, memberikan kepuasan langsung"]'::jsonb,
    '["Keseimbangan arahan teknis dengan kebebasan kreatif: Terlalu banyak arahan teknis bisa membatasi kreativitas, terlalu sedikit bisa membuat frustrasi", "Investasi emosional dalam kesuksesan partisipan: Ketika orang kesulitan, kamu merasakannya secara personal", "Sumber daya terbatas: Pekerjaan kreatif langsung dengan orang memerlukan material dan ruang yang bisa mahal"]'::jsonb,
    '["Pengajaran bertingkat: Berikan tingkat panduan teknis berbeda berdasarkan kebutuhan dan keinginan individu", "Rayakan proses bukan hanya produk: Fokus pada pembelajaran dan pengalaman, bukan kesempurnaan hasil akhir", "Kemitraan sumber daya: Bekerja dengan bisnis lokal atau program daur ulang untuk material"]'::jsonb,
    '["Program seni komunitas: Organisasi yang menyediakan akses ke seni dan kerajinan untuk komunitas", "Terapi kreatif: Penggunaan terapeutik seni dengan panduan teknis", "Pendidikan seni terapan: Mengajar keterampilan seni dan kerajinan dengan aplikasi praktis"]'::jsonb,
    '["Demo langsung yang mendukung: Menunjukkan teknik sambil mendorong interpretasi personal", "Umpan balik yang membangun: Mengakui upaya dan kemajuan sambil memberikan panduan teknis yang konstruktif", "Pembelajaran kolaboratif: Menciptakan lingkungan di mana partisipan belajar dari satu sama lain"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    54,
    'RSC',
    'Realistic Social Conventional (RSC)',
    'RSC menggabungkan kemampuan teknis praktis, orientasi membantu orang, dan kecintaan pada sistem terorganisir. Ini menciptakan penyedia layanan teknis yang sistematis dan peduli. Pikirkan koordinator layanan kesehatan, manajer program layanan sosial dengan komponen teknis, atau supervisor layanan pelanggan teknis. Kamu memastikan orang mendapatkan bantuan teknis yang mereka butuhkan melalui sistem yang terorganisir dengan baik.',
    '["Layanan yang dapat diandalkan: Memberikan dukungan teknis yang konsisten melalui prosedur yang jelas", "Dokumentasi yang melayani: Membuat panduan dan dokumentasi yang membantu orang membantu diri sendiri", "Koordinasi layanan: Mengelola sistem yang memastikan orang mendapat layanan tepat waktu", "Pelatihan yang terstruktur: Mengajarkan keterampilan teknis dengan cara yang sistematis dan mudah diikuti"]'::jsonb,
    '["Ketegangan antara prosedur dan fleksibilitas: Ingin mengikuti sistem tetapi juga ingin membantu setiap individu", "Frustrasi dengan sistem yang gagal melayani: Menyadari ketika prosedur menghalangi bantuan yang efektif", "Kelelahan dari tuntutan ganda: Menjaga standar sistem sambil responsif terhadap kebutuhan individual"]'::jsonb,
    '["Bangun eskalasi yang jelas: Sistem untuk menangani kasus yang tidak sesuai dengan prosedur standar", "Dokumentasi pembelajaran: Ketika menemukan cara baru untuk membantu, dokumentasikan untuk referensi masa depan", "Advokasi untuk perbaikan sistem: Gunakan pengalaman lapangan untuk menyarankan peningkatan prosedur"]'::jsonb,
    '["Koordinasi layanan sosial: Mengelola program yang memberikan bantuan praktis kepada orang", "Layanan dukungan teknis terstruktur: Departemen yang memberikan bantuan teknis melalui sistem yang jelas", "Manajemen kasus: Peran yang mengkoordinasikan berbagai layanan untuk klien"]'::jsonb,
    '["Komunikasi yang jelas dan peduli: Menjelaskan prosedur dengan cara yang ramah dan dapat dipahami", "Tindak lanjut sistematis: Check-in reguler untuk memastikan masalah terselesaikan", "Advokasi dalam sistem: Membantu orang menavigasi prosedur untuk mendapatkan bantuan yang mereka butuhkan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    55,
    'RSE',
    'Realistic Social Enterprising (RSE)',
    'RSE menggabungkan kemampuan teknis praktis, kepedulian terhadap orang, dan ambisi untuk mencapai dampak. Ini menciptakan pemimpin yang membangun organisasi atau program yang menggunakan keterampilan teknis untuk melayani orang dalam skala besar. Pikirkan pendiri organisasi nirlaba yang memberikan pelatihan teknis, direktur program pengembangan masyarakat, atau pengusaha sosial dengan latar belakang teknis. Kamu ingin memberdayakan orang dengan keterampilan praktis dan melakukannya secara sistemik.',
    '["Pemberdayaan melalui keterampilan: Membantu orang mengembangkan kemampuan teknis yang meningkatkan prospek mereka", "Skalabilitas dampak: Merancang program yang dapat melayani banyak orang secara efektif", "Kepemimpinan yang praktis dan peduli: Memimpin dengan memahami pekerjaan teknis dan perhatian terhadap orang", "Mobilisasi sumber daya untuk misi: Baik dalam mendapatkan dukungan untuk program yang melayani orang"]'::jsonb,
    '["Keseimbangan kualitas dengan skala: Melayani lebih banyak orang kadang berarti mengorbankan perhatian individual", "Ketegangan pendanaan dan misi: Tekanan untuk keberlanjutan finansial versus memberikan layanan gratis atau murah", "Kelelahan dari beban ganda: Tanggung jawab untuk hasil organisasi dan kesejahteraan orang yang dilayani"]'::jsonb,
    '["Model pelatih pelatih: Latih orang untuk mengajar orang lain, melipatgandakan dampak", "Kemitraan strategis: Bekerja dengan organisasi lain untuk memperluas jangkauan tanpa mengencerkan kualitas", "Evaluasi dampak: Ukur dan komunikasikan dampak untuk mendukung penggalangan dana"]'::jsonb,
    '["Organisasi pengembangan masyarakat: Program yang memberikan pelatihan dan sumber daya teknis", "Perusahaan sosial: Bisnis yang menggunakan pelatihan teknis sebagai alat pemberdayaan", "Program pengembangan tenaga kerja: Inisiatif yang membantu orang mendapatkan keterampilan yang dapat dipekerjakan"]'::jsonb,
    '["Komunikasi yang menginspirasi dan praktis: Mengartikulasikan visi sambil memberikan langkah konkret", "Jaringan untuk dampak: Membangun hubungan dengan pendana, mitra, dan komunitas", "Berbagi cerita kesuksesan: Menggunakan narasi orang yang diberdayakan untuk memotivasi dan mendukung"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    56,
    'RSI',
    'Realistic Social Investigative (RSI)',
    'RSI menggabungkan kemampuan teknis praktis, kepedulian terhadap orang, dan keingintahuan analitis. Ini menciptakan profesional yang menggunakan riset untuk memahami bagaimana teknologi dapat lebih baik melayani orang. Pikirkan peneliti teknologi assistif, evaluator program sosial dengan latar belakang teknis, atau desainer yang melakukan riset pengguna mendalam. Kamu ingin memahami kebutuhan orang secara sistematis untuk mengembangkan solusi teknis yang benar-benar membantu.',
    '["Riset pengguna yang mendalam: Menggunakan metode riset untuk benar-benar memahami kebutuhan dan konteks orang", "Solusi berbasis bukti: Mengembangkan intervensi teknis yang diinformasikan oleh data dan riset", "Evaluasi dampak: Mengukur secara sistematis bagaimana solusi teknis memengaruhi kehidupan orang", "Iterasi berdasarkan pembelajaran: Menyempurnakan solusi berdasarkan umpan balik dan evaluasi"]'::jsonb,
    '["Frustrasi dengan adopsi lambat: Riset menunjukkan apa yang dibutuhkan tetapi implementasi membutuhkan waktu", "Ketegangan antara ketelitian dan kecepatan: Riset yang baik membutuhkan waktu tetapi orang membutuhkan bantuan sekarang", "Beban emosional dari riset: Mempelajari kesulitan orang bisa secara emosional menantang"]'::jsonb,
    '["Riset aksi partisipatif: Libatkan pengguna dalam riset dan desain untuk mempercepat implementasi", "Prototipe cepat untuk umpan balik: Buat versi awal untuk menguji dengan pengguna lebih cepat", "Dukungan rekan: Proses pengalaman riset dengan kolega untuk mengelola beban emosional"]'::jsonb,
    '["Riset teknologi assistif: Mengembangkan teknologi untuk orang dengan disabilitas atau kebutuhan khusus", "Evaluasi program sosial: Menilai efektivitas program yang memiliki komponen teknis", "Riset dan desain berpusat pengguna: Peran yang menggabungkan riset dengan pengembangan produk"]'::jsonb,
    '["Wawancara mendalam yang empatik: Melakukan riset dengan mendengarkan aktif dan kepedulian", "Presentasi temuan yang dapat diakses: Menyajikan riset dengan cara yang dapat dipahami dan ditindaklanjuti", "Kolaborasi dengan praktisi: Bekerja dengan orang yang akan mengimplementasikan solusi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    99,
    'SAI',
    'Social Artistic Investigative (SAI)',
    'SAI menggabungkan orientasi pada orang, kreativitas, dan keingintahuan analitis. Ini menciptakan peneliti kreatif yang mempelajari pengalaman manusia dan mengomunikasikannya dengan cara yang menarik. Pikirkan peneliti etnografi dengan pendekatan kreatif, jurnalis investigatif dengan storytelling kuat, atau peneliti desain yang menggunakan metode kreatif. Kamu memahami orang melalui riset dan mengkomunikasikan temuan dengan cara yang kreatif dan menarik.',
    '["Riset kualitatif yang kaya: Menggunakan metode kreatif untuk mendapatkan pemahaman mendalam tentang pengalaman orang", "Komunikasi temuan yang menarik: Menyajikan riset dengan cara yang beresonansi secara emosional dan intelektual", "Empati yang terinformasi: Memahami orang dengan kedalaman yang datang dari riset sistematis", "Sintesis kreatif: Mengintegrasikan temuan dari berbagai sumber dengan cara yang novel dan bermakna"]'::jsonb,
    '["Ketegangan antara objektivitas dan empati: Kedekatan dengan subjek riset bisa memengaruhi analisis", "Kompleksitas komunikasi: Temuan kamu kaya dan bernuansa, sulit untuk disederhanakan", "Validitas dalam metode kreatif: Orang lain mungkin mempertanyakan ketelitian pendekatan kreatif"]'::jsonb,
    '["Triangulasi metode: Gunakan berbagai metode untuk memvalidasi temuan", "Transparansi metodologis: Jelaskan dengan jelas bagaimana kamu mencapai kesimpulan", "Kolaborasi interdisipliner: Bekerja dengan peneliti dari tradisi berbeda untuk memperkuat riset"]'::jsonb,
    '["Riset kualitatif: Institusi atau proyek yang menggunakan metode riset interpretatif", "Jurnalisme investigatif: Media yang melakukan liputan mendalam berbasis riset", "Riset desain: Praktik yang menggabungkan riset pengguna dengan kreativitas"]'::jsonb,
    '["Storytelling berbasis riset: Menggunakan narasi untuk mengkomunikasikan temuan", "Presentasi multimedia: Menggabungkan berbagai media untuk menyampaikan kompleksitas", "Dialog reflektif: Diskusi yang mengeksplorasi makna dan interpretasi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    97,
    'SAC',
    'Social Artistic Conventional (SAC)',
    'SAC menggabungkan orientasi pada orang, kreativitas, dan kecintaan pada organisasi. Ini menciptakan fasilitator kreatif yang terorganisir dengan baik. Pikirkan koordinator program seni komunitas, manajer acara kreatif, atau kurator pendidikan di museum. Kamu membawa orang bersama melalui pengalaman kreatif yang dirancang dan dikelola dengan baik.',
    '["Program kreatif yang terorganisir: Merancang dan mengelola program yang menyediakan pengalaman kreatif berkualitas untuk orang", "Fasilitasi yang dapat diandalkan: Orang tahu mereka bisa bergantung padamu untuk mengorganisir pengalaman kreatif yang bermakna", "Dokumentasi yang baik: Menjaga catatan dan dokumentasi program untuk evaluasi dan replikasi", "Koordinasi sumber daya: Efisien dalam mengelola jadwal, ruang, material, dan orang"]'::jsonb,
    '["Ketegangan struktur versus spontanitas: Terlalu banyak struktur bisa membunuh spontanitas kreatif", "Beban administratif: Mengorganisir program kreatif memerlukan banyak pekerjaan logistik", "Keseimbangan visi dengan keberlanjutan: Ingin program yang transformatif tetapi juga perlu berkelanjutan secara operasional"]'::jsonb,
    '["Struktur dengan ruang bernapas: Buat kerangka yang kuat tetapi biarkan fleksibilitas dalam eksekusi", "Delegasi administratif: Cari bantuan dengan tugas logistik untuk melindungi energi untuk fasilitasi", "Evaluasi partisipatif: Libatkan peserta dalam mengevaluasi dan menyempurnakan program"]'::jsonb,
    '["Organisasi seni komunitas: Program yang menyediakan akses ke pengalaman seni untuk komunitas", "Pendidikan museum: Departemen yang merancang program pendidikan kreatif", "Manajemen acara kreatif: Peran yang mengorganisir festival, pameran, atau acara seni"]'::jsonb,
    '["Komunikasi yang jelas tentang logistik: Memberikan informasi yang jelas tentang jadwal, lokasi, apa yang dibawa", "Fasilitasi yang hangat: Membuat orang merasa disambut dan didukung dalam berpartisipasi", "Dokumentasi pengalaman: Mengambil foto, mengumpulkan testimoni untuk berbagi dampak program"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    98,
    'SAE',
    'Social Artistic Enterprising (SAE)',
    'SAE menggabungkan orientasi pada orang, kreativitas, dan ambisi untuk dampak. Ini menciptakan pemimpin kreatif yang membangun organisasi atau gerakan yang menggunakan seni untuk perubahan sosial. Pikirkan pendiri organisasi seni sosial, direktur artistik dengan misi sosial, atau pengusaha kreatif yang fokus pada dampak komunitas. Kamu ingin menggunakan kreativitas untuk mengubah masyarakat dalam skala yang signifikan.',
    '["Visi transformatif: Dapat mengartikulasikan bagaimana seni dan kreativitas dapat menciptakan perubahan sosial", "Mobilisasi melalui kreativitas: Menggunakan seni untuk menggerakkan dan menginspirasi orang", "Kepemimpinan yang inklusif: Memimpin dengan cara yang membuat orang merasa mereka bisa berkontribusi secara kreatif", "Penggalangan dana kreatif: Baik dalam mengkomunikasikan misi untuk mendapatkan dukungan"]'::jsonb,
    '["Ketegangan antara visi artistik dan viabilitas: Harus menyeimbangkan integritas kreatif dengan keberlanjutan organisasi", "Mengukur dampak sosial seni: Sulit mengukur dan mengkomunikasikan dampak dalam cara yang memuaskan pendana", "Kelelahan dari kepemimpinan: Bertanggung jawab untuk visi kreatif dan organisasi bisa sangat menuntut"]'::jsonb,
    '["Dokumentasi dampak: Kumpulkan cerita, testimoni, dan bukti visual tentang bagaimana pekerjaan memengaruhi orang", "Kemitraan strategis: Berkolaborasi dengan organisasi lain untuk memperluas jangkauan", "Delegasi operasional: Fokus pada visi dan kepemimpinan, delegasikan manajemen operasional"]'::jsonb,
    '["Organisasi seni sosial: Perusahaan sosial atau nirlaba yang menggunakan seni untuk misi sosial", "Kepemimpinan kreatif komunitas: Peran yang memimpin inisiatif kreatif untuk perubahan komunitas", "Kewirausahaan kreatif dengan dampak: Bisnis kreatif yang mengintegrasikan misi sosial"]'::jsonb,
    '["Komunikasi yang menginspirasi: Berbicara tentang visi dengan cara yang menggerakkan orang untuk bertindak", "Jaringan lintas sektor: Membangun hubungan dengan seniman, aktivis, pendana, dan pemimpin komunitas", "Storytelling untuk dampak: Menggunakan narasi kuat untuk mengkomunikasikan misi dan dampak"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    100,
    'SAR',
    'Social Artistic Realistic (SAR)',
    'SAR menggabungkan orientasi pada orang, kreativitas, dan kemampuan teknis praktis. Ini menciptakan fasilitator kreatif yang terampil secara teknis. Pikirkan instruktur seni dengan keterampilan teknis tinggi, terapis seni dengan keahlian khusus, atau fasilitator lokakarya yang mahir dalam berbagai medium. Kamu membantu orang mengekspresikan diri secara kreatif dengan memberikan panduan teknis yang solid.',
    '["Pengajaran kreatif yang terampil: Dapat mengajarkan teknik sambil mendorong ekspresi individual", "Pembuatan ruang yang aman: Menciptakan lingkungan di mana orang merasa nyaman bereksperimen", "Adaptabilitas teknis: Dapat menyesuaikan teknik untuk berbagai tingkat keterampilan dan kebutuhan", "Demonstrasi yang efektif: Terampil dalam menunjukkan teknik dengan cara yang mudah diikuti"]'::jsonb,
    '["Keseimbangan teknik dengan ekspresi: Terlalu fokus pada teknik bisa menghambat kreativitas, terlalu sedikit bisa membuat frustrasi", "Investasi emosional: Sangat peduli tentang perjalanan kreatif orang bisa secara emosional menguras", "Keterbatasan sumber daya: Memerlukan material dan ruang yang memadai untuk fasilitasi efektif"]'::jsonb,
    '["Instruksi yang diferensiasi: Berikan tingkat dukungan teknis berbeda berdasarkan kebutuhan individual", "Fokus pada proses: Tekankan pembelajaran dan eksplorasi, bukan kesempurnaan hasil", "Membangun komunitas: Ciptakan lingkungan di mana peserta saling mendukung"]'::jsonb,
    '["Studio seni komunitas: Ruang yang menyediakan akses ke material dan instruksi", "Terapi seni: Penggunaan terapeutik kreativitas dengan panduan terampil", "Pendidikan seni: Mengajar seni dengan fokus pada pengembangan keterampilan dan ekspresi"]'::jsonb,
    '["Demo sambil mendorong: Menunjukkan teknik sambil mendorong interpretasi personal", "Umpan balik yang membangun: Mengakui usaha dan memberikan saran teknis yang konstruktif", "Berbagi antusiasme: Antusiasme kamu untuk medium kreatif menginspirasi orang lain"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    101,
    'SCA',
    'Social Conventional Artistic (SCA)',
    'SCA menggabungkan orientasi pada orang, kecintaan pada organisasi, dan kreativitas. Ini menciptakan profesional yang mengorganisir pengalaman kreatif untuk orang dengan cara yang terstruktur. Pikirkan manajer program pendidikan museum, koordinator acara budaya, atau kurator yang fokus pada keterlibatan publik. Kamu memastikan orang dapat mengakses dan menikmati pengalaman kreatif melalui program yang terorganisir dengan baik.',
    '["Program kreatif yang dapat diakses: Merancang pengalaman kreatif yang terstruktur sehingga orang dari berbagai latar belakang dapat berpartisipasi", "Manajemen acara yang detail: Mengorganisir setiap aspek acara atau program kreatif dengan teliti", "Dokumentasi untuk keberlanjutan: Membuat dokumentasi yang memungkinkan program berhasil direplikasi atau dikembangkan", "Koordinasi pemangku kepentingan: Mengelola hubungan dengan seniman, sponsor, peserta, dan organisasi mitra"]'::jsonb,
    '["Ketegangan kreativitas versus prosedur: Seniman mungkin menginginkan lebih banyak kebebasan daripada yang sistem izinkan", "Beban administratif berat: Mengorganisir program kreatif memerlukan banyak pekerjaan logistik dan dokumentasi", "Keseimbangan inklusivitas dengan kualitas: Ingin program dapat diakses semua orang tetapi juga mempertahankan standar kreatif"]'::jsonb,
    '["Konsultasi dengan seniman: Libatkan kreator dalam merancang struktur program untuk memastikan sistem mendukung, bukan menghambat", "Sistem yang efisien: Kembangkan template dan prosedur yang menghemat waktu untuk pekerjaan berulang", "Evaluasi partisipatif: Kumpulkan umpan balik dari semua pihak untuk terus menyempurnakan program"]'::jsonb,
    '["Institusi budaya: Museum, galeri, atau pusat seni dengan program pendidikan terstruktur", "Organisasi seni komunitas: Program yang menyediakan akses terorganisir ke seni untuk masyarakat", "Manajemen acara budaya: Peran yang mengorganisir festival, pameran, atau program kreatif"]'::jsonb,
    '["Komunikasi logistik yang jelas: Memberikan informasi terstruktur tentang program, jadwal, dan persyaratan", "Hubungan yang membangun: Mempertahankan hubungan baik dengan seniman, peserta, dan mitra", "Dokumentasi visual: Menggunakan foto dan video untuk mendokumentasikan dan mempromosikan program"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    102,
    'SCE',
    'Social Conventional Enterprising (SCE)',
    'SCE menggabungkan orientasi pada orang, kecintaan pada sistem, dan ambisi untuk dampak. Ini menciptakan pemimpin organisasi layanan yang efisien dan berorientasi pertumbuhan. Pikirkan direktur eksekutif organisasi nirlaba, manajer program layanan sosial yang berfokus pada hasil, atau konsultan pengembangan organisasi sosial. Kamu ingin melayani orang secara efektif dalam skala besar melalui sistem yang terorganisir dengan baik.',
    '["Manajemen organisasi yang efektif: Membangun dan mengelola sistem yang memungkinkan layanan sosial berkembang", "Orientasi pada hasil terukur: Menetapkan target yang jelas dan melacak kemajuan menuju dampak", "Penggalangan sumber daya: Terampil dalam mendapatkan pendanaan dan sumber daya untuk misi sosial", "Kepemimpinan yang sistematis: Memimpin dengan struktur yang jelas sambil mempertahankan fokus pada orang yang dilayani"]'::jsonb,
    '["Tekanan antara efisiensi dan kualitas layanan: Sistem untuk efisiensi kadang terasa tidak personal", "Tuntutan akuntabilitas: Harus membuktikan dampak kepada pendana sambil tetap melayani dengan baik", "Kelelahan kepemimpinan: Bertanggung jawab untuk keberlanjutan organisasi dan kualitas layanan"]'::jsonb,
    '["Metrik yang bermakna: Kembangkan indikator yang benar-benar menangkap dampak, bukan hanya output", "Budaya berbasis nilai: Pastikan efisiensi tidak mengorbankan nilai inti organisasi", "Delegasi yang memberdayakan: Bangun tim kepemimpinan yang kuat untuk berbagi beban"]'::jsonb,
    '["Kepemimpinan organisasi nirlaba: Peran eksekutif dalam organisasi layanan sosial", "Manajemen program berskala: Program sosial besar yang melayani banyak orang", "Konsultasi organisasi sosial: Membantu organisasi layanan meningkatkan efektivitas"]'::jsonb,
    '["Komunikasi berbasis hasil: Berbicara tentang dampak, target, dan pencapaian", "Jaringan strategis: Membangun hubungan dengan pendana, mitra, dan pemimpin sektor", "Transparansi akuntabilitas: Komunikasi terbuka tentang penggunaan sumber daya dan hasil"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    103,
    'SCI',
    'Social Conventional Investigative (SCI)',
    'SCI menggabungkan orientasi pada orang, kecintaan pada sistem, dan keingintahuan analitis. Ini menciptakan peneliti atau evaluator layanan sosial yang sistematis. Pikirkan evaluator program sosial, peneliti kebijakan dengan fokus implementasi, atau analis data di organisasi layanan. Kamu menggunakan riset untuk memahami bagaimana sistem melayani orang dan bagaimana meningkatkannya.',
    '["Evaluasi program yang ketat: Mengukur dampak layanan sosial dengan metodologi yang solid", "Analisis berbasis data untuk perbaikan: Mengidentifikasi area peningkatan berdasarkan bukti sistematis", "Dokumentasi pembelajaran: Mendokumentasikan apa yang berhasil dan tidak untuk pembelajaran organisasi", "Riset implementasi: Memahami tidak hanya apa yang efektif tetapi bagaimana mengimplementasikannya dalam praktik"]'::jsonb,
    '["Ketegangan antara ketelitian dan kecepatan: Evaluasi yang baik membutuhkan waktu tetapi organisasi butuh jawaban cepat", "Temuan sulit: Kadang data menunjukkan program tidak bekerja seperti yang diharapkan", "Kesenjangan riset-praktik: Rekomendasi berbasis riset tidak selalu mudah diimplementasikan dalam kenyataan"]'::jsonb,
    '["Evaluasi formatif: Lakukan evaluasi selama program berjalan untuk memungkinkan penyesuaian real-time", "Komunikasi yang sensitif: Sampaikan temuan dengan cara yang konstruktif, fokus pada pembelajaran", "Keterlibatan praktisi: Libatkan staf program dalam riset untuk memastikan relevansi dan adopsi"]'::jsonb,
    '["Evaluasi program sosial: Departemen atau firma yang mengevaluasi efektivitas layanan", "Riset kebijakan: Institusi yang mempelajari implementasi kebijakan sosial", "Analisis data nirlaba: Peran yang menggunakan data untuk meningkatkan layanan"]'::jsonb,
    '["Presentasi temuan yang dapat ditindaklanjuti: Menyajikan data dengan rekomendasi yang jelas", "Kolaborasi dengan praktisi: Bekerja erat dengan orang yang memberikan layanan", "Laporan yang terstruktur: Dokumentasi yang terorganisir dengan baik untuk pengambilan keputusan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    104,
    'SCR',
    'Social Conventional Realistic (SCR)',
    'SCR menggabungkan orientasi pada orang, kecintaan pada sistem, dan kemampuan teknis praktis. Ini menciptakan penyedia layanan teknis yang terorganisir dan peduli. Pikirkan manajer operasi di klinik kesehatan, koordinator layanan fasilitas, atau supervisor layanan dukungan teknis. Kamu memastikan sistem teknis berjalan lancar untuk melayani kebutuhan orang secara konsisten.',
    '["Layanan yang dapat diprediksi: Memberikan dukungan teknis yang konsisten melalui prosedur yang jelas", "Sistem berorientasi pengguna: Merancang operasi teknis yang memudahkan orang mendapatkan bantuan", "Dokumentasi yang ramah pengguna: Membuat panduan yang terstruktur tetapi mudah dipahami", "Manajemen tim layanan: Memimpin tim teknis dengan fokus pada kualitas layanan kepada orang"]'::jsonb,
    '["Ketegangan prosedur versus fleksibilitas: Ingin mengikuti sistem tetapi situasi individual kadang memerlukan penyimpangan", "Beban dari tuntutan ganda: Mempertahankan standar teknis sambil responsif terhadap kebutuhan manusia", "Frustrasi dengan sistem yang kaku: Menyadari ketika prosedur menghalangi layanan yang baik"]'::jsonb,
    '["Prosedur dengan eskalasi: Sistem yang memiliki jalur jelas untuk menangani situasi di luar standar", "Pelatihan orientasi layanan: Pastikan tim teknis memahami mereka melayani orang, bukan hanya sistem", "Umpan balik pengguna: Secara teratur kumpulkan masukan dari orang yang dilayani untuk perbaikan"]'::jsonb,
    '["Operasi layanan kesehatan: Manajemen fasilitas atau operasi dalam pengaturan perawatan", "Manajemen fasilitas layanan: Peran yang memastikan infrastruktur mendukung layanan kepada orang", "Layanan dukungan terstruktur: Departemen yang memberikan bantuan teknis sistematis"]'::jsonb,
    '["Komunikasi yang jelas dan peduli: Menjelaskan prosedur teknis dengan empati", "Responsif terhadap masalah: Menindaklanjuti dengan cepat ketika sistem tidak melayani dengan baik", "Koordinasi antar departemen: Bekerja dengan berbagai unit untuk memastikan layanan yang mulus"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    105,
    'SEA',
    'Social Enterprising Artistic (SEA)',
    'SEA menggabungkan orientasi pada orang, ambisi untuk dampak, dan kreativitas. Ini menciptakan pemimpin gerakan kreatif untuk perubahan sosial. Pikirkan aktivis yang menggunakan seni untuk advokasi, direktur festival dengan misi sosial, atau pengusaha kreatif yang fokus pada inklusi. Kamu menggunakan kreativitas dan kepemimpinan untuk menggerakkan perubahan sosial yang bermakna.',
    '["Mobilisasi melalui kreativitas: Menggunakan seni dan budaya untuk menginspirasi tindakan kolektif", "Kepemimpinan visi yang inklusif: Mengartikulasikan visi perubahan yang membuat orang merasa bisa berkontribusi", "Jaringan lintas sektor: Menghubungkan seniman, aktivis, pendana, dan komunitas", "Komunikasi yang menarik: Menyampaikan pesan sosial dengan cara yang secara emosional resonan"]'::jsonb,
    '["Keseimbangan seni dan aktivisme: Kadang ketegangan antara nilai estetika dan efektivitas kampanye", "Keberlanjutan finansial: Sulit mendapatkan pendanaan untuk pekerjaan yang menggabungkan seni dengan perubahan sosial", "Kelelahan dari intensitas: Pekerjaan yang menggabungkan kreativitas, kepemimpinan, dan misi sosial sangat menuntut"]'::jsonb,
    '["Koalisi strategis: Bangun aliansi dengan organisasi yang berbagi misi", "Dokumentasi dampak kreatif: Kumpulkan bukti bagaimana seni menciptakan perubahan", "Delegasi dan kolaborasi: Bagikan kepemimpinan dengan orang lain untuk keberlanjutan"]'::jsonb,
    '["Organisasi seni aktivis: Kelompok yang menggunakan kreativitas untuk keadilan sosial", "Festival atau acara dengan misi: Platform yang menggabungkan seni dengan perubahan sosial", "Kewirausahaan kreatif sosial: Bisnis yang menggunakan seni untuk dampak komunitas"]'::jsonb,
    '["Komunikasi yang menginspirasi: Storytelling yang menggerakkan orang untuk bergabung", "Kolaborasi kreatif: Bekerja dengan seniman untuk menciptakan karya yang bermakna secara sosial", "Advokasi publik: Berbicara di forum publik tentang isu sosial dengan perspektif kreatif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    106,
    'SEC',
    'Social Enterprising Conventional (SEC)',
    'SEC menggabungkan orientasi pada orang, ambisi untuk dampak, dan kecintaan pada sistem. Ini menciptakan pemimpin organisasi sosial yang efisien dan berorientasi pertumbuhan. Pikirkan pendiri organisasi nirlaba yang berskala, direktur operasi di perusahaan sosial, atau konsultan strategi untuk sektor sosial. Kamu ingin menciptakan dampak sosial yang besar melalui organisasi yang terkelola dengan baik.',
    '["Pertumbuhan organisasi yang terkelola: Mengembangkan organisasi sosial sambil mempertahankan kualitas dan misi", "Sistem untuk dampak: Membangun infrastruktur yang memungkinkan layanan berkembang secara efisien", "Kepemimpinan yang akuntabel: Mengelola dengan transparansi dan pengukuran dampak yang jelas", "Penggalangan dana strategis: Mengamankan sumber daya dengan menunjukkan efektivitas organisasi"]'::jsonb,
    '["Tekanan pertumbuhan versus kualitas: Berkembang terlalu cepat bisa mengorbankan kualitas layanan", "Birokratisasi misi: Sistem yang terlalu banyak bisa membuat organisasi kehilangan koneksi dengan misi", "Tuntutan kepemimpinan ganda: Harus efektif baik dalam manajemen maupun kepemimpinan misi"]'::jsonb,
    '["Pertumbuhan bertahap: Kembangkan dengan kecepatan yang memungkinkan sistem matang", "Budaya yang kuat: Investasikan dalam mempertahankan nilai organisasi sambil berkembang", "Kepemimpinan bersama: Bangun tim kepemimpinan dengan keahlian komplementer"]'::jsonb,
    '["Organisasi nirlaba yang berkembang: Organisasi sosial dalam fase pertumbuhan", "Perusahaan sosial: Bisnis dengan misi sosial yang jelas", "Konsultasi sektor sosial: Membantu organisasi sosial meningkatkan efektivitas"]'::jsonb,
    '["Komunikasi visi dengan data: Mengartikulasikan misi sambil menunjukkan bukti dampak", "Jaringan strategis: Membangun hubungan dengan pendana, mitra, dan pemimpin sektor", "Manajemen pemangku kepentingan: Mengelola ekspektasi dewan, staf, dan komunitas yang dilayani"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    107,
    'SEI',
    'Social Enterprising Investigative (SEI)',
    'SEI menggabungkan orientasi pada orang, ambisi untuk dampak, dan keingintahuan analitis. Ini menciptakan pemimpin yang menggunakan riset dan data untuk mendorong inovasi sosial. Pikirkan pendiri startup dampak sosial berbasis riset, direktur inovasi di organisasi sosial, atau peneliti yang juga pengusaha sosial. Kamu menggunakan wawasan berbasis bukti untuk menciptakan solusi baru untuk masalah sosial.',
    '["Inovasi berbasis bukti: Mengidentifikasi solusi baru berdasarkan pemahaman mendalam tentang masalah", "Kepemimpinan yang informasi: Membuat keputusan strategis berdasarkan data dan riset", "Artikulasi dampak: Dapat menjelaskan bagaimana dan mengapa pendekatan kamu bekerja", "Pembelajaran adaptif: Menggunakan data untuk terus menyempurnakan strategi"]'::jsonb,
    '["Tidak sabar dengan implementasi lambat: Ingin melihat dampak cepat tetapi perubahan sosial membutuhkan waktu", "Ketegangan riset versus aksi: Keinginan untuk lebih banyak data bisa menunda tindakan yang dibutuhkan", "Komunikasi kompleksitas: Solusi berbasis riset bisa sulit dijelaskan kepada audiens non-teknis"]'::jsonb,
    '["Pendekatan uji coba: Implementasikan dalam skala kecil untuk menguji sambil mengumpulkan data", "Komunikasi berlapis: Siapkan versi sederhana dan detail dari penjelasan", "Kemitraan riset-praktik: Berkolaborasi dengan akademisi dan praktisi"]'::jsonb,
    '["Startup dampak sosial: Organisasi baru yang menggunakan pendekatan inovatif untuk masalah sosial", "Laboratorium inovasi sosial: Inkubator atau akselerator untuk solusi sosial", "Riset aksi terapan: Organisasi yang menggabungkan riset dengan implementasi"]'::jsonb,
    '["Pitch berbasis data: Mempresentasikan solusi dengan bukti efektivitas", "Diskusi strategis mendalam: Eksplorasi analitis tentang pendekatan dan dampak", "Jaringan peneliti-praktisi: Membangun jembatan antara akademisi dan implementor"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    108,
    'SER',
    'Social Enterprising Realistic (SER)',
    'SER menggabungkan orientasi pada orang, ambisi untuk dampak, dan kemampuan teknis praktis. Ini menciptakan pengusaha sosial yang membangun solusi praktis untuk masalah sosial. Pikirkan pendiri yang menciptakan teknologi untuk komunitas kurang terlayani, direktur program pelatihan keterampilan teknis, atau pemimpin perusahaan sosial yang memproduksi barang. Kamu memberdayakan orang dengan keterampilan dan produk praktis dalam skala yang bermakna.',
    '["Solusi praktis untuk masalah sosial: Menciptakan intervensi nyata yang dapat digunakan atau dipelajari orang", "Pemberdayaan melalui keterampilan: Mengajarkan kemampuan praktis yang meningkatkan kesempatan ekonomi", "Kepemimpinan yang kredibel: Dapat memimpin karena memahami pekerjaan teknis yang terlibat", "Skalabilitas melalui replikasi: Solusi praktis lebih mudah direplikasi di lokasi berbeda"]'::jsonb,
    '["Keseimbangan misi dengan viabilitas: Harus menghasilkan pendapatan sambil melayani komunitas yang mungkin tidak mampu membayar", "Kompleksitas operasional: Menjalankan operasi teknis sambil mengelola misi sosial", "Keterbatasan sumber daya: Sulit mendapatkan investasi untuk perusahaan sosial dengan margin rendah"]'::jsonb,
    '["Model pendapatan campuran: Kombinasikan penjualan, hibah, dan subsidi silang", "Kemitraan strategis: Bekerja dengan perusahaan atau pemerintah untuk memperluas jangkauan", "Fokus pada keberlanjutan: Bangun model bisnis yang dapat bertahan jangka panjang"]'::jsonb,
    '["Perusahaan sosial manufaktur: Bisnis yang memproduksi barang sambil memberdayakan orang", "Program pelatihan teknis: Inisiatif yang mengajarkan keterampilan yang dapat dipekerjakan", "Teknologi untuk komunitas: Organisasi yang mengembangkan solusi teknis untuk kebutuhan sosial"]'::jsonb,
    '["Demonstrasi praktis: Menunjukkan bagaimana produk atau keterampilan bekerja", "Storytelling dampak: Berbagi cerita orang yang diberdayakan", "Jaringan lintas sektor: Menghubungkan dengan bisnis, nirlaba, dan pemerintah"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    109,
    'SIA',
    'Social Investigative Artistic (SIA)',
    'SIA menggabungkan orientasi pada orang, keingintahuan analitis, dan kreativitas. Ini menciptakan peneliti kreatif yang mempelajari pengalaman manusia untuk perubahan sosial. Pikirkan peneliti etnografi yang menggunakan metode kreatif, jurnalis investigatif dengan storytelling kuat, atau peneliti desain partisipatif. Kamu menggunakan riset untuk memahami orang dan kreativitas untuk mengkomunikasikan temuan dengan cara yang menggerakkan tindakan.',
    '["Riset yang bernuansa: Menggunakan pendekatan kreatif untuk mendapatkan pemahaman kaya tentang pengalaman hidup orang", "Komunikasi yang menyentuh: Menyajikan temuan dengan cara yang beresonansi secara emosional", "Keterlibatan partisipan: Melibatkan orang dalam proses riset dengan cara yang memberdayakan", "Advokasi berbasis cerita: Menggunakan narasi untuk mengadvokasi perubahan berdasarkan bukti"]'::jsonb,
    '["Ketegangan objektivitas versus empati: Kedekatan dengan subjek bisa memengaruhi analisis", "Validitas metode kreatif: Harus mempertahankan ketelitian metodologi sambil menggunakan pendekatan inovatif", "Beban emosional: Mendengarkan pengalaman sulit orang secara mendalam bisa menguras"]'::jsonb,
    '["Refleksivitas: Secara eksplisit refleksikan bagaimana posisi kamu memengaruhi riset", "Triangulasi: Gunakan berbagai metode untuk memvalidasi temuan", "Dukungan diri: Cari supervisi atau dukungan rekan untuk memproses pengalaman riset"]'::jsonb,
    '["Riset kualitatif sosial: Proyek yang mempelajari pengalaman hidup untuk perubahan kebijakan", "Jurnalisme investigatif: Media yang melakukan liputan mendalam tentang isu sosial", "Desain partisipatif: Praktik yang melibatkan komunitas dalam riset dan desain solusi"]'::jsonb,
    '["Storytelling berbasis riset: Menggunakan narasi untuk mengkomunikasikan temuan", "Presentasi multimedia: Menggabungkan berbagai media untuk menyampaikan kompleksitas", "Keterlibatan komunitas: Berbagi temuan dengan cara yang dapat diakses dan bermakna"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    110,
    'SIC',
    'Social Investigative Conventional (SIC)',
    'SIC menggabungkan orientasi pada orang, keingintahuan analitis, dan kecintaan pada sistem. Ini menciptakan peneliti layanan sosial yang sistematis dan berbasis bukti. Pikirkan evaluator program dengan dokumentasi ketat, peneliti kebijakan sosial, atau analis sistem layanan kesehatan. Kamu menggunakan riset terorganisir untuk memahami dan meningkatkan bagaimana sistem melayani orang.',
    '["Riset yang dapat direplikasi: Melakukan studi dengan dokumentasi yang memungkinkan verifikasi dan replikasi", "Evaluasi sistematis: Mengukur dampak program secara konsisten dan dapat dipercaya", "Rekomendasi yang dapat diimplementasikan: Memberikan saran yang praktis untuk perbaikan sistem", "Manajemen data yang etis: Menangani data sensitif tentang orang dengan ketelitian dan kehormatan"]'::jsonb,
    '["Ketegangan ketelitian versus relevansi: Riset yang ketat membutuhkan waktu tetapi kebijakan membutuhkan bukti cepat", "Temuan yang tidak populer: Data kadang menunjukkan program favorit tidak efektif", "Kompleksitas implementasi: Rekomendasi berbasis riset tidak selalu mudah diterapkan dalam sistem yang ada"]'::jsonb,
    '["Keterlibatan pemangku kepentingan: Libatkan pembuat kebijakan dan praktisi sejak awal untuk memastikan relevansi", "Komunikasi sensitif: Sampaikan temuan sulit dengan fokus pada pembelajaran dan perbaikan", "Studi implementasi: Tidak hanya tanyakan apa yang bekerja tetapi bagaimana membuatnya bekerja dalam praktik"]'::jsonb,
    '["Lembaga riset kebijakan: Organisasi yang mempelajari layanan dan program sosial", "Evaluasi program pemerintah: Departemen yang menilai efektivitas layanan publik", "Konsultasi riset sosial: Firma yang membantu organisasi menggunakan bukti untuk perbaikan"]'::jsonb,
    '["Laporan yang terstruktur: Dokumentasi yang jelas dengan temuan, metode, dan rekomendasi", "Presentasi berbasis data: Menyajikan bukti dengan visualisasi yang dapat dipahami", "Kolaborasi dengan pembuat kebijakan: Bekerja erat dengan orang yang akan menggunakan temuan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    111,
    'SIE',
    'Social Investigative Enterprising (SIE)',
    'SIE menggabungkan orientasi pada orang, keingintahuan analitis, dan ambisi untuk dampak. Ini menciptakan peneliti yang ingin risetnya menciptakan perubahan nyata dalam skala besar. Pikirkan peneliti yang mendirikan organisasi berdasarkan temuannya, konsultan riset yang juga implementor, atau pemimpin inovasi sosial berbasis bukti. Kamu tidak puas hanya dengan publikasi, kamu ingin risetmu mengubah cara sistem melayani orang.',
    '["Riset yang berorientasi aksi: Merancang studi dengan implementasi praktis dalam pikiran", "Kepemimpinan berbasis bukti: Mendorong perubahan dengan otoritas data dan analisis", "Terjemahan penelitian ke praktik: Terampil dalam mengubah temuan menjadi program atau kebijakan", "Mobilisasi untuk perubahan: Menggunakan riset untuk membangun kasus persuasif untuk inovasi"]'::jsonb,
    '["Tidak sabar dengan proses akademis: Publikasi dan peer review lambat ketika perubahan dibutuhkan sekarang", "Ketegangan objektivitas versus advokasi: Harus menyeimbangkan analisis netral dengan dorongan untuk perubahan", "Frustrasi dengan adopsi lambat: Riset menunjukkan apa yang perlu dilakukan tetapi sistem lambat berubah"]'::jsonb,
    '["Riset aksi partisipatif: Libatkan pemangku kepentingan dalam riset untuk mempercepat adopsi", "Komunikasi multi-audiens: Publikasi akademis dan brief kebijakan untuk menjangkau berbagai audiens", "Kemitraan implementasi: Bekerja dengan organisasi yang dapat mengimplementasikan temuan"]'::jsonb,
    '["Lembaga pemikir kebijakan: Organisasi riset yang fokus pada pengaruh kebijakan", "Inovasi sosial berbasis riset: Organisasi yang menggunakan bukti untuk merancang intervensi baru", "Konsultasi strategi sosial: Membantu organisasi menggunakan riset untuk keputusan strategis"]'::jsonb,
    '["Presentasi persuasif berbasis data: Menggunakan bukti untuk membangun kasus untuk perubahan", "Jaringan pembuat kebijakan: Membangun hubungan dengan orang yang dapat mengimplementasikan rekomendasi", "Advokasi berbasis bukti: Berbicara publik tentang perlunya perubahan berdasarkan riset"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    112,
    'SIR',
    'Social Investigative Realistic (SIR)',
    'SIR menggabungkan orientasi pada orang, keingintahuan analitis, dan kemampuan teknis praktis. Ini menciptakan peneliti terapan yang tidak hanya mempelajari masalah tetapi juga membangun solusi. Pikirkan peneliti teknologi assistif yang juga engineer, ilmuwan kesehatan yang merancang intervensi, atau peneliti pendidikan yang mengembangkan alat pembelajaran. Kamu menggunakan riset untuk memahami kebutuhan dan keterampilan teknis untuk menciptakan solusi nyata.',
    '["Penelitian translasional: Mengubah temuan riset menjadi produk atau intervensi yang dapat digunakan", "Validasi dalam praktik: Menguji solusi dengan pengguna nyata untuk memastikan efektivitas", "Iterasi berbasis bukti: Menyempurnakan solusi berdasarkan data dan umpan balik", "Pemahaman konteks: Memahami keduanya kebutuhan orang dan keterbatasan teknis"]'::jsonb,
    '["Keseimbangan riset versus pengembangan: Kadang tidak jelas apakah prioritas adalah memahami atau membangun", "Kompleksitas metodologis: Menggabungkan riset pengguna dengan pengembangan teknis memerlukan banyak keahlian", "Waktu untuk dampak: Proses dari riset ke produk yang berfungsi membutuhkan waktu signifikan"]'::jsonb,
    '["Pendekatan desain berpusat pengguna: Libatkan pengguna di setiap tahap dari riset hingga pengembangan", "Prototipe cepat: Buat versi awal untuk menguji asumsi lebih cepat", "Kolaborasi interdisipliner: Bekerja dengan ahli dari berbagai bidang"]'::jsonb,
    '["Riset dan pengembangan sosial: Lab atau organisasi yang mengembangkan teknologi untuk kebutuhan sosial", "Desain universal: Praktik yang menciptakan produk dapat diakses untuk semua", "Inovasi kesehatan: Organisasi yang mengembangkan solusi medis atau kesehatan berbasis riset"]'::jsonb,
    '["Demo dengan penjelasan: Menunjukkan solusi sambil menjelaskan riset di baliknya", "Riset partisipatif: Melibatkan pengguna dalam proses pengembangan", "Dokumentasi teknis yang dapat diakses: Menjelaskan bagaimana solusi bekerja untuk audiens berbeda"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    117,
    'EAC',
    'Enterprising Artistic Conventional (EAC)',
    'EAC menggabungkan ambisi untuk kesuksesan, kreativitas, dan kecintaan pada sistem. Ini menciptakan pemimpin kreatif yang membangun bisnis atau organisasi kreatif yang terkelola dengan baik. Pikirkan CEO agensi kreatif, pendiri studio desain yang sistematis, atau direktur operasi di perusahaan media. Kamu ingin kesuksesan komersial melalui keunggulan kreatif yang didukung oleh sistem yang efisien.',
    '["Operasi kreatif yang efisien: Membangun sistem yang memungkinkan pekerjaan kreatif berkualitas diproduksi secara konsisten", "Kepemimpinan yang menyeimbangkan: Mendorong hasil sambil melindungi ruang untuk kreativitas", "Manajemen proyek kreatif: Mengelola timeline, anggaran, dan kualitas untuk proyek kreatif", "Pertumbuhan bisnis kreatif: Mengembangkan organisasi kreatif sambil mempertahankan standar"]'::jsonb,
    '["Ketegangan kreativitas versus efisiensi: Sistem untuk produktivitas bisa membatasi eksplorasi kreatif", "Ekspektasi klien versus visi artistik: Harus menyeimbangkan permintaan komersial dengan integritas kreatif", "Skalabilitas kreativitas: Sulit mempertahankan kualitas kreatif sambil berkembang"]'::jsonb,
    '["Proses yang melindungi kreativitas: Sistem yang memberikan struktur tetapi menjaga ruang untuk eksplorasi", "Rekrutmen yang selektif: Merekrut talenta yang dapat menghasilkan karya berkualitas dalam sistem", "Standar kualitas yang jelas: Mendefinisikan apa yang dimaksud dengan keunggulan kreatif dalam organisasi"]'::jsonb,
    '["Agensi kreatif: Periklanan, desain, atau media dalam peran kepemimpinan", "Studio produksi: Film, animasi, atau konten yang memerlukan manajemen proyek kreatif", "Perusahaan desain: Bisnis yang menyediakan layanan kreatif kepada klien"]'::jsonb,
    '["Komunikasi klien yang profesional: Mempresentasikan karya kreatif dengan cara yang membangun kepercayaan bisnis", "Manajemen tim yang terstruktur: Rapat reguler, timeline yang jelas, ekspektasi terdefinisi", "Presentasi hasil: Fokus pada bagaimana karya kreatif mencapai tujuan bisnis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    118,
    'EAI',
    'Enterprising Artistic Investigative (EAI)',
    'EAI menggabungkan ambisi untuk dampak, kreativitas, dan keingintahuan analitis. Ini menciptakan inovator kreatif yang menggunakan riset untuk menginformasikan visi mereka. Pikirkan direktur kreatif yang juga peneliti, pengusaha desain berbasis riset, atau pemimpin inovasi yang menggabungkan kreativitas dengan data. Kamu ingin menciptakan sesuatu yang baru dan bermakna, didukung oleh pemahaman mendalam.',
    '["Inovasi yang diinformasikan: Ide kreatif yang didasarkan pada riset dan wawasan", "Visi yang persuasif: Dapat mengartikulasikan konsep kreatif dengan dukungan logika dan data", "Diferensiasi berbasis wawasan: Menciptakan produk atau layanan yang menonjol karena pemahaman unik", "Kepemimpinan yang kredibel: Dihormati karena keduanya kreativitas dan kedalaman pemikiran"]'::jsonb,
    '["Paralisis analisis kreatif: Terlalu banyak riset bisa menghambat lompatan kreatif", "Ketegangan intuisi versus data: Kadang keputusan kreatif terbaik tidak didukung oleh data", "Komunikasi kompleksitas: Konsep yang diinformasikan riset bisa sulit dijelaskan dengan sederhana"]'::jsonb,
    '["Fase terpisah: Waktu untuk riset, waktu untuk kreativitas, waktu untuk eksekusi", "Percaya intuisi terinformasi: Gunakan riset untuk menginformasikan tetapi biarkan kreativitas memimpin", "Storytelling yang menyederhanakan: Buat narasi yang membuat konsep kompleks dapat diakses"]'::jsonb,
    '["Laboratorium inovasi kreatif: Organisasi yang menggabungkan riset dengan desain", "Konsultasi strategi kreatif: Membantu organisasi dengan pendekatan berbasis wawasan", "Startup produk inovatif: Perusahaan yang menciptakan produk baru berdasarkan pemahaman unik"]'::jsonb,
    '["Presentasi yang menggabungkan data dan visi: Menggunakan riset untuk membangun kasus untuk ide kreatif", "Diskusi konseptual yang mendalam: Menikmati eksplorasi ide dengan kedalaman intelektual", "Jaringan pemikir kreatif: Terhubung dengan orang yang menghargai pendekatan hybrid"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    119,
    'EAR',
    'Enterprising Artistic Realistic (EAR)',
    'EAR menggabungkan ambisi untuk kesuksesan, kreativitas, dan kemampuan teknis praktis. Ini menciptakan pengusaha kreatif yang bisa mewujudkan visi mereka sendiri. Pikirkan desainer produk yang memulai lini produk sendiri, arsitek dengan firma pembangunan, atau pengrajin yang membangun merek. Kamu tidak hanya membayangkan produk kreatif tetapi juga bisa membuatnya dan membawanya ke pasar.',
    '["Visi ke pasar: Mengambil konsep kreatif dan mengubahnya menjadi produk komersial", "Prototipe cepat: Keterampilan teknis memungkinkan iterasi cepat berdasarkan umpan balik pasar", "Kemandirian: Tidak bergantung sepenuhnya pada orang lain untuk eksekusi", "Diferensiasi melalui kerajinan: Produk menonjol karena kualitas teknis dan visi kreatif"]'::jsonb,
    '["Melakukan terlalu banyak: Sulit mendelegasikan karena bisa melakukan semua aspek", "Keterbatasan skala: Kerajinan personal membatasi seberapa besar bisnis dapat tumbuh", "Keseimbangan pembuatan versus manajemen: Harus memilih antara bekerja dalam bisnis versus pada bisnis"]'::jsonb,
    '["Rekrut dan latih: Temukan orang yang dapat mempelajari keterampilan kamu untuk memperluas kapasitas", "Fokus pada desain: Seiring pertumbuhan, fokuskan pada menciptakan desain dan delegasikan produksi", "Bangun merek: Ciptakan identitas merek yang dapat dipertahankan bahkan ketika tidak membuat setiap item sendiri"]'::jsonb,
    '["Kewirausahaan produk kreatif: Bisnis sendiri yang menciptakan dan menjual produk", "Studio desain-build: Praktik yang menangani keduanya desain dan konstruksi", "Merek kerajinan: Bisnis yang berbasis pada keterampilan pembuat"]'::jsonb,
    '["Menunjukkan keahlian: Demo keterampilan dan proses sebagai bagian dari branding", "Storytelling pembuat: Berbagi cerita tentang bagaimana produk dibuat", "Keterlibatan klien: Bekerja erat dengan klien dari konsep hingga pengiriman"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    120,
    'EAS',
    'Enterprising Artistic Social (EAS)',
    'EAS menggabungkan ambisi untuk dampak, kreativitas, dan orientasi pada orang. Ini menciptakan pemimpin yang menggunakan kreativitas untuk menggerakkan perubahan sosial dalam skala besar. Pikirkan pendiri organisasi seni sosial, direktur festival dengan misi pemberdayaan, atau pengusaha kreatif yang fokus pada inklusi. Kamu ingin menggunakan seni dan kreativitas untuk menciptakan perubahan yang bermakna bagi banyak orang.',
    '["Mobilisasi kreatif: Menggunakan seni untuk menginspirasi dan mengorganisir orang menuju tujuan bersama", "Kepemimpinan inklusif: Membuat orang merasa mereka bisa berkontribusi secara kreatif terlepas dari latar belakang", "Storytelling untuk perubahan: Menggunakan narasi kreatif yang kuat untuk mengadvokasi isu sosial", "Jaringan lintas sektor: Menghubungkan seniman, aktivis, bisnis, dan komunitas"]'::jsonb,
    '["Keseimbangan seni dan dampak: Ketegangan antara nilai estetika dan efektivitas sosial", "Keberlanjutan finansial: Mendanai pekerjaan yang menggabungkan seni dengan misi sosial bisa sulit", "Mengukur dampak kreatif: Sulit mengukur bagaimana seni menciptakan perubahan sosial"]'::jsonb,
    '["Dokumentasi dampak: Kumpulkan cerita, foto, dan testimoni tentang bagaimana pekerjaan memengaruhi orang", "Model pendapatan campuran: Kombinasikan tiket, sponsor, dan hibah", "Kemitraan strategis: Berkolaborasi dengan organisasi yang berbagi misi"]'::jsonb,
    '["Organisasi seni sosial: Perusahaan sosial atau nirlaba menggunakan kreativitas untuk misi", "Festival atau platform dengan misi: Acara yang menggabungkan seni dengan perubahan sosial", "Kewirausahaan kreatif inklusif: Bisnis kreatif yang memprioritaskan akses dan keragaman"]'::jsonb,
    '["Komunikasi yang menginspirasi: Storytelling yang menggerakkan orang untuk bergabung", "Kolaborasi kreatif luas: Bekerja dengan berbagai seniman dan komunitas", "Advokasi melalui seni: Menggunakan platform kreatif untuk berbicara tentang isu sosial"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    121,
    'ECA',
    'Enterprising Conventional Artistic (ECA)',
    'ECA menggabungkan ambisi untuk kesuksesan, kecintaan pada sistem, dan kreativitas. Ini menciptakan pemimpin bisnis kreatif yang sangat terorganisir. Pikirkan COO di agensi kreatif, manajer produksi di studio, atau pemilik bisnis desain dengan operasi yang ketat. Kamu ingin kesuksesan komersial melalui operasi kreatif yang efisien dan terkelola dengan baik.',
    '["Operasi kreatif yang efisien: Membangun sistem yang memungkinkan produktivitas tinggi tanpa mengorbankan kualitas", "Manajemen sumber daya yang efektif: Mengoptimalkan penggunaan waktu, talenta, dan material kreatif", "Pertumbuhan yang terkelola: Mengembangkan bisnis kreatif dengan cara yang berkelanjutan", "Prediktabilitas dalam kreativitas: Menciptakan sistem yang memberikan output kreatif yang konsisten"]'::jsonb,
    '["Ketegangan sistem versus spontanitas: Terlalu banyak proses bisa menghambat kreativitas", "Resistensi dari talenta kreatif: Orang kreatif mungkin menolak sistem yang terasa membatasi", "Keseimbangan efisiensi dengan kualitas: Tekanan untuk produktivitas bisa mengorbankan keunggulan kreatif"]'::jsonb,
    '["Libatkan talenta dalam desain sistem: Buat proses bersama dengan orang kreatif untuk memastikan dukungan", "Fleksibilitas terstruktur: Sistem yang memberikan kerangka tetapi memungkinkan ruang kreatif", "Metrik yang bermakna: Ukur kualitas kreatif, bukan hanya output atau efisiensi"]'::jsonb,
    '["Produksi kreatif berskala: Studio atau agensi dengan volume pekerjaan tinggi", "Operasi media: Perusahaan yang memproduksi konten kreatif secara reguler", "Manajemen bisnis kreatif: Peran operasional dalam organisasi kreatif"]'::jsonb,
    '["Rapat terstruktur tentang kreativitas: Diskusi kreatif dengan agenda dan timeline", "Komunikasi berbasis proses: Menjelaskan bagaimana sistem mendukung kualitas kreatif", "Pelaporan kinerja: Update reguler tentang produktivitas dan pencapaian kreatif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    122,
    'ECI',
    'Enterprising Conventional Investigative (ECI)',
    'ECI menggabungkan ambisi untuk hasil, kecintaan pada sistem, dan keingintahuan analitis. Ini menciptakan pemimpin yang menggunakan data dan analisis untuk mendorong perbaikan organisasi yang sistematis. Pikirkan direktur transformasi digital, konsultan manajemen analitis, atau kepala strategi dengan fokus operasional. Kamu ingin mencapai kesuksesan melalui keputusan berbasis data dan sistem yang dioptimalkan.',
    '["Optimasi berbasis data: Menggunakan analisis untuk mengidentifikasi dan menerapkan perbaikan operasional", "Perubahan yang terukur: Mendorong transformasi dengan metrik yang jelas dan pelacakan kemajuan", "Kepemimpinan berbasis bukti: Membuat keputusan strategis berdasarkan analisis menyeluruh", "Sistem untuk pembelajaran: Membangun infrastruktur yang memungkinkan pembelajaran dan adaptasi berkelanjutan"]'::jsonb,
    '["Resistensi terhadap perubahan berbasis data: Orang mungkin menolak perubahan bahkan dengan bukti yang kuat", "Terlalu percaya pada metrik: Data tidak menangkap semua yang penting dalam organisasi", "Kecepatan perubahan: Ingin hasil cepat tetapi transformasi sistematis membutuhkan waktu"]'::jsonb,
    '["Manajemen perubahan yang kuat: Investasikan dalam membantu orang memahami mengapa perubahan perlu", "Metrik seimbang: Gunakan berbagai indikator, termasuk kualitatif, untuk menilai kesuksesan", "Kemenangan cepat: Identifikasi perbaikan yang dapat memberikan hasil cepat untuk membangun momentum"]'::jsonb,
    '["Konsultasi manajemen: Membantu organisasi dengan transformasi berbasis data", "Kepemimpinan operasional: Peran COO atau serupa dengan fokus pada perbaikan", "Transformasi digital: Memimpin adopsi teknologi dan proses baru"]'::jsonb,
    '["Presentasi berbasis data yang persuasif: Menggunakan analisis untuk membangun kasus untuk perubahan", "Rapat tinjauan kinerja: Diskusi reguler tentang metrik dan kemajuan", "Komunikasi perubahan: Menjelaskan bagaimana perubahan akan meningkatkan hasil"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    123,
    'ECR',
    'Enterprising Conventional Realistic (ECR)',
    'ECR menggabungkan ambisi untuk hasil, kecintaan pada sistem, dan kemampuan teknis praktis. Ini menciptakan pemimpin operasional yang sangat efektif dalam lingkungan teknis. Pikirkan direktur manufaktur, VP operasi di perusahaan teknis, atau pemilik bisnis konstruksi yang berkembang. Kamu memahami pekerjaan teknis, tahu cara mengorganisirnya secara efisien, dan memiliki dorongan untuk mencapai target yang ambisius.',
    '["Kepemimpinan operasional yang kuat: Mengelola operasi teknis dengan fokus jelas pada hasil dan efisiensi", "Sistem produksi yang dioptimalkan: Membangun proses yang memaksimalkan output sambil mempertahankan kualitas", "Pertumbuhan yang terkelola: Mengembangkan operasi teknis dengan cara yang sistematis dan berkelanjutan", "Eksekusi yang dapat diprediksi: Menciptakan operasi yang memberikan hasil konsisten"]'::jsonb,
    '["Fokus berlebih pada efisiensi: Mengoptimalkan untuk produktivitas jangka pendek bisa mengabaikan kesejahteraan atau inovasi", "Kekakuan sistem: Proses yang terlalu ketat bisa menghambat adaptasi ketika kondisi berubah", "Resistensi terhadap perubahan: Berinvestasi dalam sistem yang ada membuat sulit menerima pendekatan baru"]'::jsonb,
    '["Keterlibatan tim: Libatkan orang yang melakukan pekerjaan dalam merancang perbaikan proses", "Peningkatan berkelanjutan: Bangun kultur di mana sistem terus disempurnakan, bukan tetap", "Keseimbangan metrik: Ukur tidak hanya produktivitas tetapi juga keselamatan, kualitas, dan kepuasan"]'::jsonb,
    '["Operasi manufaktur: Pabrik atau fasilitas produksi dalam peran kepemimpinan", "Konstruksi atau teknik: Manajemen proyek atau operasi dalam industri pembangunan", "Logistik dan rantai pasokan: Mengelola pergerakan barang dalam sistem kompleks"]'::jsonb,
    '["Komunikasi metrik yang jelas: Diskusi berfokus pada angka, target, dan kinerja", "Standar yang tegas: Ekspektasi jelas tentang kualitas, keselamatan, dan produktivitas", "Rapat singkat berorientasi aksi: Identifikasi masalah dan putuskan solusi dengan cepat"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    124,
    'ECS',
    'Enterprising Conventional Social (ECS)',
    'ECS menggabungkan ambisi untuk dampak, kecintaan pada sistem, dan orientasi pada orang. Ini menciptakan pemimpin organisasi layanan yang efisien dan berorientasi pertumbuhan. Pikirkan CEO organisasi layanan kesehatan berskala, direktur eksekutif jaringan layanan sosial, atau pemimpin franchise yang fokus pada layanan pelanggan. Kamu ingin melayani orang secara efektif dalam skala besar melalui sistem yang terkelola dengan baik.',
    '["Layanan berskala: Membangun sistem yang memungkinkan layanan berkualitas kepada banyak orang", "Manajemen pertumbuhan: Mengembangkan organisasi layanan sambil mempertahankan kualitas", "Efisiensi operasional: Mengoptimalkan proses untuk melayani lebih banyak orang dengan sumber daya yang ada", "Kepemimpinan yang akuntabel: Mengelola dengan transparansi dan pengukuran dampak layanan"]'::jsonb,
    '["Ketegangan efisiensi versus personalisasi: Sistem untuk skala bisa membuat layanan terasa tidak personal", "Tekanan pertumbuhan: Berkembang terlalu cepat bisa mengorbankan kualitas layanan", "Kompleksitas regulasi: Layanan sosial sering sangat diatur, menambah lapisan sistem"]'::jsonb,
    '["Pertumbuhan dengan kualitas: Kembangkan dengan kecepatan yang memungkinkan pemeliharaan standar layanan", "Desentralisasi dengan standar: Berikan otonomi lokal dalam kerangka kualitas yang jelas", "Umpan balik pelanggan: Secara sistematis kumpulkan dan gunakan masukan dari orang yang dilayani"]'::jsonb,
    '["Organisasi layanan kesehatan: Jaringan klinik, rumah sakit, atau penyedia layanan kesehatan", "Franchise layanan: Bisnis yang memberikan layanan konsisten di banyak lokasi", "Jaringan layanan sosial: Organisasi yang mengkoordinasikan layanan di wilayah geografis luas"]'::jsonb,
    '["Komunikasi berorientasi pelanggan: Fokus pada bagaimana sistem melayani kebutuhan orang", "Pelaporan kinerja layanan: Update reguler tentang metrik kepuasan dan kualitas", "Manajemen pemangku kepentingan: Koordinasi dengan regulator, pendana, dan komunitas yang dilayani"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    126,
    'EIC',
    'Enterprising Investigative Conventional (EIC)',
    'EIC menggabungkan ambisi untuk hasil, keingintahuan analitis, dan kecintaan pada sistem. Ini menciptakan pemimpin strategis yang menggunakan data dan proses untuk mendorong kesuksesan organisasi. Pikirkan direktur analitik bisnis, kepala strategi data, atau konsultan transformasi berbasis bukti. Kamu ingin mencapai target ambisius melalui keputusan berbasis data yang didukung oleh sistem yang terorganisir dengan baik.',
    '["Strategi berbasis data yang sistematis: Menggunakan analisis untuk menginformasikan keputusan strategis dan mengimplementasikannya melalui proses yang jelas", "Manajemen kinerja yang terukur: Membangun sistem pelacakan yang memberikan wawasan real-time tentang kemajuan menuju tujuan", "Optimasi berkelanjutan: Menggunakan data untuk mengidentifikasi peluang perbaikan secara sistematis", "Kepemimpinan yang akuntabel: Mengelola dengan transparansi berdasarkan metrik yang jelas"]'::jsonb,
    '["Terlalu bergantung pada data: Tidak semua yang penting dapat diukur, risiko mengabaikan faktor kualitatif", "Kompleksitas sistem: Dapat menciptakan infrastruktur data dan proses yang terlalu rumit", "Tidak sabar dengan proses: Ingin hasil cepat tetapi membangun sistem analitik yang baik membutuhkan waktu"]'::jsonb,
    '["Keseimbangan metrik: Gunakan kombinasi indikator kuantitatif dan kualitatif", "Mulai sederhana: Bangun sistem analitik secara bertahap, dimulai dengan metrik paling penting", "Komunikasi wawasan: Pastikan data diterjemahkan menjadi rekomendasi yang dapat ditindaklanjuti"]'::jsonb,
    '["Analitik bisnis: Departemen yang menggunakan data untuk menginformasikan strategi", "Konsultasi strategi: Firma yang membantu organisasi dengan transformasi berbasis data", "Kepemimpinan operasional: Peran yang mengelola dengan fokus berat pada metrik kinerja"]'::jsonb,
    '["Presentasi data yang persuasif: Menggunakan analisis untuk membangun kasus untuk keputusan strategis", "Tinjauan kinerja sistematis: Rapat reguler untuk mengevaluasi kemajuan berdasarkan metrik", "Dokumentasi keputusan: Mencatat alasan di balik keputusan strategis untuk pembelajaran organisasi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    127,
    'EIR',
    'Enterprising Investigative Realistic (EIR)',
    'EIR menggabungkan ambisi untuk dampak, keingintahuan analitis, dan kemampuan teknis praktis. Ini menciptakan pemimpin inovasi teknis yang berbasis riset. Pikirkan CTO yang juga peneliti, pendiri startup deep tech, atau direktur riset dan pengembangan dengan orientasi komersial. Kamu ingin menciptakan terobosan teknis berdasarkan pemahaman mendalam dan membawanya ke pasar.',
    '["Inovasi teknis berbasis riset: Mengidentifikasi peluang untuk terobosan berdasarkan pemahaman ilmiah dan teknis", "Kepemimpinan yang kredibel: Dapat memimpin tim teknis dengan otoritas karena memahami pekerjaan secara mendalam", "Visi ke produk: Menerjemahkan riset menjadi produk atau layanan yang dapat dikomersialisasikan", "Keputusan strategis yang informasi: Membuat pilihan tentang arah teknis berdasarkan analisis menyeluruh"]'::jsonb,
    '["Tidak sabar dengan riset murni: Ingin melihat aplikasi praktis, bisa meremehkan riset dasar", "Terlalu percaya diri teknis: Pemahaman mendalam bisa membuat terlalu yakin dengan kelayakan", "Kesenjangan komunikasi: Sulit menjelaskan konsep teknis kompleks ke audiens non-teknis"]'::jsonb,
    '["Kemitraan riset-bisnis: Berkolaborasi dengan akademisi untuk riset sambil fokus pada aplikasi", "Validasi pasar awal: Uji asumsi teknis dengan pelanggan potensial lebih awal", "Bangun tim beragam: Rekrut orang dengan keahlian bisnis untuk melengkapi kekuatan teknis"]'::jsonb,
    '["Startup teknologi mendalam: Perusahaan berbasis pada inovasi ilmiah atau teknis", "Riset dan pengembangan komersial: Lab yang mengembangkan teknologi untuk produk", "Kepemimpinan teknologi: Peran CTO atau VP Engineering yang strategis"]'::jsonb,
    '["Presentasi teknis strategis: Menjelaskan visi teknis dengan implikasi bisnis", "Diskusi mendalam: Eksplorasi analitis tentang kemungkinan teknis", "Demo dan prototipe: Menunjukkan kelayakan melalui bukti konsep"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    128,
    'EIS',
    'Enterprising Investigative Social (EIS)',
    'EIS menggabungkan ambisi untuk dampak sosial, keingintahuan analitis, dan kepedulian terhadap orang. Ini menciptakan pemimpin yang menggunakan riset dan bukti untuk mendorong perubahan sosial sistemik. Pikirkan direktur kebijakan berbasis bukti, peneliti yang juga aktivis, atau pemimpin organisasi yang menggunakan data untuk dampak. Kamu ingin menggunakan riset untuk menciptakan perubahan yang bermakna bagi orang dalam skala besar.',
    '["Advokasi berbasis bukti: Menggunakan data dan riset untuk membangun kasus yang kuat untuk perubahan sosial", "Kepemimpinan yang kredibel: Dihormati karena kedalaman pemahaman tentang isu sosial", "Strategi dampak yang informasi: Membuat keputusan tentang intervensi berdasarkan bukti efektivitas", "Mobilisasi melalui wawasan: Menggunakan temuan riset untuk menginspirasi tindakan kolektif"]'::jsonb,
    '["Frustrasi dengan perubahan lambat: Bukti menunjukkan apa yang perlu dilakukan tetapi sistem sosial lambat berubah", "Ketegangan riset versus advokasi: Harus menyeimbangkan objektivitas ilmiah dengan dorongan untuk perubahan", "Beban dari mengetahui: Pemahaman mendalam tentang masalah sosial bisa sangat membebani"]'::jsonb,
    '["Koalisi strategis: Bangun aliansi dengan organisasi yang dapat mengimplementasikan rekomendasi", "Komunikasi multi-level: Publikasi akademis dan komunikasi publik untuk menjangkau berbagai audiens", "Perawatan diri: Jaga batasan untuk menghindari kelelahan dari intensitas pekerjaan"]'::jsonb,
    '["Lembaga pemikir kebijakan sosial: Organisasi riset yang fokus pada pengaruh kebijakan", "Organisasi advokasi berbasis bukti: Kelompok yang menggunakan data untuk mendorong perubahan", "Kepemimpinan riset sosial: Peran yang mengarahkan agenda riset untuk dampak sosial"]'::jsonb,
    '["Presentasi yang menggerakkan: Menyajikan data dengan cara yang menginspirasi tindakan", "Testimoni berbasis cerita dan data: Menggabungkan narasi manusia dengan bukti kuantitatif", "Jaringan pembuat kebijakan: Membangun hubungan dengan orang yang dapat mengimplementasikan perubahan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    125,
    'EIA',
    'Enterprising Investigative Artistic (EIA)',
    'EIA menggabungkan ambisi untuk dampak, keingintahuan analitis, dan kreativitas. Ini menciptakan inovator yang menggunakan riset untuk menginformasikan visi kreatif mereka. Pikirkan direktur inovasi yang menggabungkan riset dengan desain, pengusaha di industri kreatif yang berbasis data, atau pemimpin yang menggunakan wawasan untuk diferensiasi kreatif. Kamu ingin menciptakan sesuatu yang baru dan bermakna, didukung oleh pemahaman mendalam.',
    '["Inovasi yang diinformasikan: Ide kreatif yang didasarkan pada wawasan dari riset dan analisis", "Diferensiasi strategis: Menciptakan produk atau layanan yang menonjol berdasarkan pemahaman unik pasar atau pengguna", "Komunikasi visi yang persuasif: Dapat mengartikulasikan konsep kreatif dengan dukungan logika dan data", "Kepemimpinan yang menginspirasi dan kredibel: Dihormati karena keduanya kreativitas dan kedalaman pemikiran"]'::jsonb,
    '["Ketegangan analisis versus intuisi: Terlalu banyak data bisa menghambat lompatan kreatif yang diperlukan untuk inovasi", "Kompleksitas komunikasi: Konsep yang menggabungkan riset dan kreativitas bisa sulit dijelaskan", "Tidak sabar dengan proses: Ingin bergerak cepat dari wawasan ke eksekusi kreatif"]'::jsonb,
    '["Fase terpisah: Waktu untuk riset mendalam, waktu untuk eksplorasi kreatif, waktu untuk pengembangan", "Percaya intuisi yang informasi: Gunakan riset sebagai dasar tetapi biarkan kreativitas memimpin", "Storytelling untuk visi: Buat narasi yang membuat konsep kompleks dapat diakses dan menarik"]'::jsonb,
    '["Inovasi produk: Peran yang menggabungkan riset pasar dengan pengembangan kreatif", "Konsultasi strategi kreatif: Membantu organisasi dengan diferensiasi berbasis wawasan", "Startup kreatif berbasis riset: Perusahaan yang menggunakan pemahaman unik untuk menciptakan produk inovatif"]'::jsonb,
    '["Presentasi yang menggabungkan data dan visi: Menggunakan wawasan untuk membangun kasus untuk ide kreatif", "Workshop ideasi berbasis riset: Fasilitasi sesi kreatif yang diinformasikan oleh temuan", "Jaringan pemikir hybrid: Terhubung dengan orang yang menghargai pendekatan integratif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    130,
    'ERC',
    'Enterprising Realistic Conventional (ERC)',
    'ERC menggabungkan ambisi untuk hasil, kemampuan teknis praktis, dan kecintaan pada sistem. Ini menciptakan pemimpin operasional yang sangat efektif. Pikirkan direktur operasi manufaktur, pemilik bisnis konstruksi yang berkembang, atau manajer rantai pasokan senior. Kamu memahami pekerjaan teknis, tahu cara mengorganisirnya dengan efisien, dan memiliki dorongan kuat untuk mencapai target ambisius.',
    '["Kepemimpinan operasional yang kuat: Mengelola operasi teknis dengan fokus jelas pada efisiensi dan hasil", "Sistem produksi yang dioptimalkan: Membangun dan menyempurnakan proses untuk memaksimalkan output berkualitas", "Eksekusi yang dapat diprediksi: Menciptakan operasi yang memberikan hasil konsisten dan terukur", "Pertumbuhan yang terkelola: Mengembangkan operasi dengan cara yang sistematis dan berkelanjutan"]'::jsonb,
    '["Fokus berlebih pada efisiensi jangka pendek: Mengoptimalkan untuk metrik saat ini bisa mengabaikan inovasi atau kesejahteraan", "Kekakuan dalam sistem: Proses yang sangat terstruktur bisa menghambat fleksibilitas ketika kondisi berubah", "Tekanan pada tim: Dorongan untuk hasil bisa menciptakan lingkungan yang sangat menuntut"]'::jsonb,
    '["Keterlibatan tim dalam perbaikan: Libatkan orang yang melakukan pekerjaan dalam merancang sistem yang lebih baik", "Keseimbangan metrik: Ukur tidak hanya produktivitas tetapi juga keselamatan, kualitas, dan kepuasan tim", "Investasi jangka panjang: Alokasikan sumber daya untuk peningkatan proses dan pengembangan orang"]'::jsonb,
    '["Manufaktur atau produksi: Operasi yang memproduksi barang fisik dalam volume", "Konstruksi atau teknik: Manajemen proyek atau operasi dalam pembangunan", "Logistik: Mengelola pergerakan dan penyimpanan barang dalam sistem kompleks"]'::jsonb,
    '["Komunikasi metrik yang tegas: Diskusi berfokus pada angka kinerja, target, dan hasil", "Standar yang jelas: Ekspektasi yang tidak ambigu tentang kualitas dan produktivitas", "Rapat singkat berorientasi keputusan: Identifikasi masalah, putuskan solusi, lanjutkan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    129,
    'ERA',
    'Enterprising Realistic Artistic (ERA)',
    'ERA menggabungkan ambisi untuk kesuksesan, kemampuan teknis praktis, dan kreativitas. Ini menciptakan pengusaha kreatif yang bisa mewujudkan visi mereka sendiri dan membawanya ke pasar. Pikirkan desainer produk yang memulai perusahaan manufaktur, arsitek dengan firma pembangunan sendiri, atau pengrajin yang membangun merek global. Kamu tidak hanya membayangkan produk kreatif tetapi juga bisa membuatnya dan menjualnya dalam skala yang signifikan.',
    '["Visi ke pasar yang lengkap: Mengambil konsep kreatif dari ide hingga produk komersial yang sukses", "Kemandirian dalam eksekusi: Dapat membangun prototipe dan produk sendiri, mengurangi ketergantungan", "Diferensiasi melalui kerajinan: Produk menonjol di pasar karena kualitas teknis dan visi kreatif", "Skalabilitas melalui sistem: Membangun proses produksi yang memungkinkan pertumbuhan"]'::jsonb,
    '["Transisi dari pembuat ke pemimpin: Sulit melepaskan pembuatan langsung untuk fokus pada pertumbuhan bisnis", "Keseimbangan kualitas dengan skala: Kerajinan personal yang membuat merek mungkin sulit dipertahankan saat berkembang", "Kompromi kreatif untuk produksi: Harus menyesuaikan desain untuk kelayakan manufaktur atau biaya"]'::jsonb,
    '["Rekrut dan latih pengrajin: Temukan orang yang dapat mempelajari standar kualitas kamu", "Fokus pada desain dan strategi: Seiring pertumbuhan, delegasikan produksi sambil mempertahankan kontrol kreatif", "Bangun merek berbasis cerita: Ciptakan identitas yang lebih besar dari produk individual"]'::jsonb,
    '["Kewirausahaan produk: Bisnis sendiri yang menciptakan dan menjual produk fisik", "Desain-manufaktur terintegrasi: Perusahaan yang menangani keduanya desain dan produksi", "Merek berbasis kerajinan: Bisnis yang dibangun di sekitar keterampilan dan visi pembuat"]'::jsonb,
    '["Storytelling produk: Berbagi proses dan visi di balik produk sebagai bagian dari branding", "Demo keahlian: Menunjukkan keterampilan sebagai cara membangun kepercayaan dan diferensiasi", "Keterlibatan pelanggan: Membangun komunitas di sekitar merek dan nilai"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    131,
    'ERI',
    'Enterprising Realistic Investigative (ERI)',
    'ERI menggabungkan ambisi untuk dampak, kemampuan teknis praktis, dan keingintahuan analitis. Ini menciptakan pemimpin inovasi teknis yang berbasis data. Pikirkan VP Engineering dengan fokus inovasi, pendiri startup teknologi yang juga engineer, atau direktur teknis yang menggunakan riset untuk keputusan. Kamu ingin mencapai terobosan teknis berdasarkan pemahaman mendalam dan membawanya ke implementasi nyata.',
    '["Inovasi teknis berbasis bukti: Mengidentifikasi peluang untuk perbaikan atau terobosan berdasarkan analisis", "Kepemimpinan yang kredibel: Dapat memimpin tim teknis dengan otoritas karena memahami pekerjaan dan data", "Keputusan strategis yang informasi: Membuat pilihan tentang teknologi dan arsitektur berdasarkan riset", "Eksekusi yang terukur: Mendorong inovasi dengan pelacakan kemajuan yang jelas"]'::jsonb,
    '["Tidak sabar dengan riset tanpa aplikasi: Ingin melihat hasil praktis cepat", "Terlalu percaya diri teknis: Pemahaman mendalam bisa membuat meremehkan kompleksitas", "Keseimbangan eksplorasi dengan pengiriman: Ketegangan antara riset untuk inovasi dan tekanan untuk hasil"]'::jsonb,
    '["Alokasi waktu untuk riset: Sisihkan persentase kapasitas tim untuk eksplorasi teknis", "Validasi bertahap: Uji asumsi teknis dalam skala kecil sebelum investasi penuh", "Kolaborasi eksternal: Bermitra dengan universitas atau lab riset untuk penelitian mendalam"]'::jsonb,
    '["Riset dan pengembangan teknologi: Organisasi yang mengembangkan teknologi baru", "Startup deep tech: Perusahaan berbasis pada inovasi teknis atau ilmiah", "Kepemimpinan teknis: Peran yang menggabungkan strategi teknologi dengan implementasi"]'::jsonb,
    '["Presentasi teknis dengan data: Menjelaskan keputusan teknis dengan dukungan analisis", "Diskusi arsitektur mendalam: Eksplorasi teknis tentang trade-off dan pilihan desain", "Review kode dan desain: Keterlibatan langsung dalam evaluasi pekerjaan teknis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    132,
    'ERS',
    'Enterprising Realistic Social (ERS)',
    'ERS menggabungkan ambisi untuk dampak, kemampuan teknis praktis, dan kepedulian terhadap orang. Ini menciptakan pemimpin yang membangun solusi teknis untuk memberdayakan orang dalam skala besar. Pikirkan pendiri yang menciptakan teknologi untuk komunitas yang kurang terlayani, direktur program pelatihan keterampilan teknis berskala, atau pengusaha sosial yang memproduksi barang sambil memberdayakan. Kamu ingin menciptakan perubahan sosial bermakna melalui solusi praktis.',
    '["Pemberdayaan melalui keterampilan teknis: Mengajarkan kemampuan praktis yang meningkatkan prospek ekonomi orang", "Solusi praktis untuk masalah sosial: Menciptakan produk atau layanan nyata yang memenuhi kebutuhan", "Kepemimpinan yang kredibel dan peduli: Dapat memimpin karena memahami pekerjaan dan benar-benar peduli tentang orang", "Skalabilitas dampak: Merancang intervensi yang dapat melayani banyak orang"]'::jsonb,
    '["Keseimbangan misi dengan viabilitas: Harus menghasilkan pendapatan sambil melayani komunitas yang mungkin tidak mampu membayar penuh", "Kompleksitas operasional ganda: Menjalankan operasi teknis sambil mengelola misi sosial", "Keterbatasan sumber daya: Sulit mendapatkan investasi atau hibah yang cukup"]'::jsonb,
    '["Model pendapatan campuran: Kombinasikan penjualan, hibah, kontrak pemerintah, dan subsidi silang", "Kemitraan strategis: Bekerja dengan perusahaan, pemerintah, atau organisasi lain untuk memperluas jangkauan", "Dokumentasi dampak: Kumpulkan dan bagikan cerita tentang bagaimana pekerjaan mengubah hidup"]'::jsonb,
    '["Perusahaan sosial teknis: Bisnis yang menggunakan produksi atau pelatihan teknis untuk misi sosial", "Program pengembangan keterampilan: Inisiatif berskala yang mengajarkan kemampuan yang dapat dipekerjakan", "Teknologi untuk komunitas: Organisasi yang mengembangkan solusi teknis untuk kebutuhan sosial"]'::jsonb,
    '["Storytelling dampak: Berbagi narasi tentang bagaimana solusi mengubah hidup orang", "Demo praktis: Menunjukkan bagaimana produk atau keterampilan bekerja", "Jaringan lintas sektor: Membangun hubungan dengan bisnis, nirlaba, dan pemerintah"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    133,
    'ESA',
    'Enterprising Social Artistic (ESA)',
    'ESA menggabungkan ambisi untuk dampak sosial, kepedulian terhadap orang, dan kreativitas. Ini menciptakan pemimpin gerakan kreatif untuk perubahan sosial. Pikirkan pendiri organisasi seni untuk keadilan sosial, direktur festival yang fokus pada inklusi, atau pengusaha kreatif yang membangun platform untuk seniman marjinal. Kamu menggunakan kreativitas dan kepemimpinan untuk menggerakkan perubahan sosial yang bermakna dan inklusif.',
    '["Mobilisasi melalui kreativitas: Menggunakan seni dan budaya untuk menginspirasi tindakan kolektif", "Kepemimpinan yang inklusif: Menciptakan ruang di mana orang dari berbagai latar belakang merasa bisa berkontribusi", "Komunikasi yang resonan: Menyampaikan pesan sosial dengan cara yang menyentuh secara emosional", "Jaringan yang luas: Menghubungkan seniman, aktivis, pendana, dan komunitas"]'::jsonb,
    '["Keseimbangan visi artistik dengan misi sosial: Kadang ketegangan antara keunggulan estetika dan efektivitas kampanye", "Keberlanjutan finansial: Mendanai pekerjaan yang menggabungkan seni dengan perubahan sosial bisa sangat menantang", "Kelelahan dari intensitas: Pekerjaan yang menggabungkan kreativitas, kepemimpinan, dan misi sosial sangat menuntut"]'::jsonb,
    '["Koalisi lintas gerakan: Bangun aliansi dengan organisasi seni dan aktivis", "Model pendanaan campuran: Kombinasikan tiket, hibah seni, hibah sosial, dan sponsor", "Kepemimpinan bersama: Bagikan beban dengan membangun tim kepemimpinan kolektif"]'::jsonb,
    '["Organisasi seni untuk keadilan sosial: Kelompok yang menggunakan kreativitas untuk advokasi dan perubahan", "Platform untuk seniman marjinal: Organisasi yang memberikan ruang dan sumber daya untuk suara yang kurang terwakili", "Festival atau acara dengan misi: Platform yang menggabungkan seni dengan tujuan sosial"]'::jsonb,
    '["Storytelling yang menggerakkan: Menggunakan narasi untuk menginspirasi orang bergabung dalam gerakan", "Kolaborasi seniman luas: Bekerja dengan kreator dari berbagai medium dan latar belakang", "Advokasi publik: Berbicara di forum tentang isu sosial dengan perspektif kreatif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    134,
    'ESC',
    'Enterprising Social Conventional (ESC)',
    'ESC menggabungkan ambisi untuk dampak sosial, kepedulian terhadap orang, dan kecintaan pada sistem. Ini menciptakan pemimpin organisasi sosial yang efisien dan berorientasi pertumbuhan. Pikirkan CEO organisasi nirlaba berskala, direktur jaringan layanan sosial, atau pendiri perusahaan sosial dengan operasi yang ketat. Kamu ingin melayani orang secara efektif dalam skala besar melalui organisasi yang terkelola dengan sangat baik.',
    '["Manajemen pertumbuhan organisasi: Mengembangkan organisasi sosial sambil mempertahankan kualitas layanan dan misi", "Sistem untuk dampak berskala: Membangun infrastruktur yang memungkinkan layanan berkualitas kepada banyak orang", "Kepemimpinan yang akuntabel: Mengelola dengan transparansi dan pengukuran dampak yang jelas", "Penggalangan sumber daya yang efektif: Terampil dalam mendapatkan pendanaan dengan menunjukkan efisiensi dan dampak"]'::jsonb,
    '["Tekanan pertumbuhan versus kualitas: Berkembang terlalu cepat bisa mengorbankan kualitas layanan atau kehilangan sentuhan personal", "Birokratisasi misi: Sistem yang terlalu banyak bisa membuat organisasi kehilangan koneksi dengan tujuan", "Tuntutan kepemimpinan ganda: Harus efektif dalam manajemen operasional dan kepemimpinan misi"]'::jsonb,
    '["Pertumbuhan yang disengaja: Kembangkan dengan kecepatan yang memungkinkan sistem dan budaya matang", "Investasi budaya: Habiskan waktu dan sumber daya mempertahankan nilai organisasi sambil berkembang", "Tim kepemimpinan yang kuat: Bangun kelompok dengan keahlian komplementer untuk berbagi beban"]'::jsonb,
    '["Organisasi nirlaba berskala: Organisasi sosial besar yang melayani banyak orang atau wilayah", "Perusahaan sosial: Bisnis dengan misi sosial yang jelas dan model yang berkelanjutan", "Jaringan layanan: Organisasi yang mengkoordinasikan layanan di banyak lokasi"]'::jsonb,
    '["Komunikasi berbasis dampak: Mengartikulasikan visi dengan data tentang hasil", "Manajemen pemangku kepentingan: Mengelola hubungan dengan dewan, pendana, staf, dan komunitas", "Transparansi operasional: Komunikasi terbuka tentang bagaimana sumber daya digunakan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    135,
    'ESI',
    'Enterprising Social Investigative (ESI)',
    'ESI menggabungkan ambisi untuk dampak sosial, kepedulian terhadap orang, dan keingintahuan analitis. Ini menciptakan pemimpin yang menggunakan riset dan bukti untuk mendorong inovasi sosial berskala. Pikirkan pendiri organisasi yang menggunakan data untuk dampak, direktor inovasi sosial, atau pemimpin yang menggabungkan riset dengan pengembangan program. Kamu ingin menciptakan perubahan sosial yang bermakna berdasarkan pemahaman mendalam tentang apa yang bekerja.',
    '["Inovasi sosial berbasis bukti: Mengembangkan intervensi baru berdasarkan riset tentang apa yang efektif", "Kepemimpinan yang kredibel: Dihormati karena kedalaman pemahaman tentang isu dan solusi", "Skalabilitas yang informasi: Membuat keputusan tentang pertumbuhan berdasarkan data tentang dampak", "Pembelajaran adaptif: Menggunakan evaluasi untuk terus menyempurnakan pendekatan"]'::jsonb,
    '["Tidak sabar dengan riset lambat: Ingin melihat dampak cepat tetapi riset yang baik membutuhkan waktu", "Ketegangan bukti versus urgensi: Data menunjukkan apa yang perlu dilakukan tetapi kebutuhan mendesak", "Kesenjangan implementasi: Solusi berbasis bukti tidak selalu mudah diterapkan dalam praktik"]'::jsonb,
    '["Riset aksi cepat: Gunakan pendekatan yang memungkinkan pembelajaran sambil melakukan", "Kemitraan riset-praktik: Berkolaborasi dengan akademisi dan praktisi untuk menjembatani kesenjangan", "Komunikasi temuan: Bagikan pembelajaran dengan cara yang dapat diakses untuk mendorong adopsi lebih luas"]'::jsonb,
    '["Inovasi sosial: Organisasi yang mengembangkan dan menguji pendekatan baru untuk masalah sosial", "Perusahaan sosial berbasis riset: Bisnis yang menggunakan bukti untuk merancang solusi", "Lembaga pemikir terapan: Organisasi riset yang fokus pada implementasi"]'::jsonb,
    '["Presentasi berbasis data yang menginspirasi: Menggunakan bukti untuk membangun kasus untuk perubahan", "Berbagi pembelajaran: Terbuka tentang apa yang berhasil dan tidak untuk pembelajaran sektor", "Jaringan peneliti-praktisi: Membangun jembatan antara riset dan implementasi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    136,
    'ESR',
    'Enterprising Social Realistic (ESR)',
    'ESR menggabungkan ambisi untuk dampak sosial, kepedulian terhadap orang, dan kemampuan teknis praktis. Ini menciptakan pengusaha sosial yang membangun solusi praktis dalam skala besar. Pikirkan pendiri yang menciptakan produk untuk komunitas kurang terlayani, direktur program pelatihan teknis yang berkembang, atau pemimpin perusahaan sosial manufaktur. Kamu memberdayakan orang dengan keterampilan dan produk praktis, dan melakukannya dalam skala yang menciptakan perubahan sistemik.',
    '["Solusi praktis berskala: Menciptakan produk atau layanan nyata yang melayani banyak orang", "Pemberdayaan melalui keterampilan: Mengajarkan kemampuan teknis yang meningkatkan kesempatan ekonomi", "Kepemimpinan yang kredibel dan peduli: Memimpin dengan memahami pekerjaan dan benar-benar peduli tentang dampak", "Model yang dapat direplikasi: Mengembangkan pendekatan yang dapat diadopsi di lokasi atau konteks lain"]'::jsonb,
    '["Keseimbangan misi dengan keberlanjutan: Harus menghasilkan cukup pendapatan untuk bertahan sambil melayani yang membutuhkan", "Kompleksitas operasional: Menjalankan operasi teknis sambil mengelola misi sosial dan mengukur dampak", "Keterbatasan modal: Perusahaan sosial dengan margin rendah sulit mendapatkan investasi"]'::jsonb,
    '["Model hibrida: Kombinasikan penjualan komersial dengan program bersubsidi untuk yang membutuhkan", "Kemitraan sektor: Bekerja dengan perusahaan, pemerintah, dan organisasi untuk memperluas jangkauan dan sumber daya", "Dokumentasi dan replikasi: Buat manual yang memungkinkan orang lain mengadopsi model"]'::jsonb,
    '["Perusahaan sosial produksi: Bisnis yang memproduksi barang sambil memberdayakan orang", "Program pelatihan vokasional berskala: Inisiatif yang mengajarkan keterampilan teknis kepada banyak orang", "Teknologi untuk pembangunan: Organisasi yang menciptakan solusi teknis untuk kebutuhan komunitas"]'::jsonb,
    '["Demo praktis: Menunjukkan bagaimana produk atau keterampilan bekerja dan bagaimana mengubah hidup", "Storytelling dampak: Berbagi cerita transformasi melalui pemberdayaan praktis", "Jaringan ekosistem: Membangun hubungan dengan semua pihak dalam ekosistem dampak sosial"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    57,
    'IAC',
    'Investigative Artistic Conventional (IAC)',
    'IAC menggabungkan keingintahuan analitis, kreativitas, dan kecintaan pada sistem. Ini menciptakan peneliti kreatif yang sangat terorganisir. Pikirkan peneliti desain dengan dokumentasi ketat, kurator yang menggunakan metodologi sistematis, atau analis yang membuat visualisasi data kreatif dengan proses yang ketat. Kamu menggabungkan ketelitian riset dengan ekspresi kreatif, semua dalam kerangka kerja yang terorganisir.',
    '["Riset kreatif yang sistematis: Melakukan eksplorasi kreatif dengan metodologi yang dapat direplikasi", "Dokumentasi yang rapi: Membuat catatan menyeluruh dari proses riset dan kreatif", "Visualisasi yang diinformasikan: Menciptakan representasi kreatif yang didasarkan pada analisis solid", "Proses yang dapat diajarkan: Karena sistematis, dapat mengajarkan pendekatan kepada orang lain"]'::jsonb,
    '["Ketegangan struktur versus spontanitas: Kebutuhan akan sistem bisa membatasi aliran kreatif", "Waktu untuk dokumentasi: Mendokumentasikan proses kreatif dan analitis membutuhkan waktu signifikan", "Perfeksionisme tiga dimensi: Ingin riset yang ketat, output kreatif yang menarik, dan semua terdokumentasi dengan sempurna"]'::jsonb,
    '["Dokumentasi bertahap: Tangkap hal penting segera, detail bisa ditambahkan kemudian", "Fase terpisah: Waktu untuk eksplorasi bebas, waktu untuk analisis, waktu untuk dokumentasi", "Template yang fleksibel: Buat kerangka yang memberikan struktur tetapi memungkinkan kreativitas"]'::jsonb,
    '["Riset desain: Praktik yang menggabungkan riset pengguna dengan eksplorasi kreatif", "Kurasi museum: Peran yang memerlukan riset mendalam dan presentasi kreatif", "Visualisasi data: Posisi yang mengubah analisis menjadi komunikasi visual"]'::jsonb,
    '["Presentasi yang menggabungkan riset dan visual: Menyajikan temuan dengan visualisasi yang menarik", "Dokumentasi proses: Berbagi metodologi untuk transparansi dan pembelajaran", "Workshop terstruktur: Memfasilitasi sesi kreatif dengan kerangka yang jelas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    58,
    'IAE',
    'Investigative Artistic Enterprising (IAE)',
    'IAE menggabungkan keingintahuan analitis, kreativitas, dan ambisi untuk dampak. Ini menciptakan inovator kreatif yang menggunakan riset untuk menginformasikan visi dan mendorong perubahan. Pikirkan direktur kreatif yang juga peneliti, pengusaha di industri kreatif yang berbasis wawasan, atau pemimpin inovasi yang menggabungkan analisis dengan kreativitas. Kamu ingin menciptakan sesuatu yang baru dan bermakna, didukung oleh pemahaman mendalam, dan membawanya ke dunia.',
    '["Inovasi yang diinformasikan: Ide kreatif yang didasarkan pada wawasan dari riset mendalam", "Diferensiasi strategis: Menciptakan produk atau layanan yang menonjol karena pemahaman unik", "Kepemimpinan yang kredibel: Dihormati karena keduanya kreativitas dan kedalaman intelektual", "Visi yang persuasif: Dapat mengartikulasikan konsep dengan dukungan logika dan data"]'::jsonb,
    '["Kelumpuhan dari analisis: Terlalu banyak riset bisa menunda tindakan kreatif", "Ketegangan intuisi versus data: Kadang lompatan kreatif terbaik tidak didukung bukti", "Kompleksitas komunikasi: Konsep yang menggabungkan riset dan kreativitas bisa sulit dijelaskan dengan sederhana"]'::jsonb,
    '["Percaya intuisi yang informasi: Gunakan riset sebagai fondasi tetapi biarkan kreativitas memimpin", "Prototipe cepat: Uji ide kreatif lebih awal daripada menunggu riset sempurna", "Storytelling yang menyederhanakan: Buat narasi yang membuat konsep kompleks dapat diakses"]'::jsonb,
    '["Konsultasi inovasi: Membantu organisasi dengan diferensiasi berbasis wawasan", "Startup kreatif berbasis riset: Perusahaan yang menggunakan pemahaman unik untuk produk inovatif", "Kepemimpinan inovasi: Peran yang mengarahkan pengembangan produk atau layanan baru"]'::jsonb,
    '["Presentasi yang menggabungkan wawasan dan visi: Menggunakan riset untuk membangun kasus untuk ide kreatif", "Workshop ideasi berbasis bukti: Fasilitasi eksplorasi kreatif yang diinformasikan temuan", "Jaringan pemikir hybrid: Terhubung dengan orang yang menghargai pendekatan integratif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    59,
    'IAR',
    'Investigative Artistic Realistic (IAR)',
    'IAR menggabungkan keingintahuan analitis, kreativitas, dan kemampuan teknis praktis. Ini menciptakan peneliti kreatif yang dapat mewujudkan temuan mereka. Pikirkan peneliti desain yang juga pembuat, ilmuwan yang membuat visualisasi dan prototipe, atau analis yang membangun alat kreatif. Kamu tidak hanya mempelajari dan membayangkan tetapi juga membangun solusi nyata berdasarkan pemahaman.',
    '["Translasi riset ke prototipe: Mengubah temuan menjadi objek atau sistem yang dapat diuji", "Eksplorasi kreatif yang terukur: Melakukan eksperimen kreatif dengan metodologi yang ketat", "Pemahaman konteks yang mendalam: Memahami keduanya teori dan kendala praktis implementasi", "Komunikasi melalui artefak: Menggunakan prototipe untuk mengkomunikasikan wawasan"]'::jsonb,
    '["Keseimbangan tiga prioritas: Terjebak antara ingin menganalisis lebih, menciptakan lebih indah, atau membangun lebih fungsional", "Waktu untuk kesempurnaan: Menggabungkan riset, kreativitas, dan pembuatan membutuhkan waktu signifikan", "Kompleksitas metodologis: Menggabungkan riset dengan pengembangan kreatif memerlukan banyak keahlian"]'::jsonb,
    '["Iterasi cepat: Buat prototipe kasar untuk menguji ide lebih awal", "Kolaborasi interdisipliner: Bekerja dengan ahli dari berbagai bidang", "Dokumentasi visual: Gunakan foto dan video untuk menangkap proses"]'::jsonb,
    '["Riset dan pengembangan kreatif: Lab yang menggabungkan riset dengan pembuatan", "Desain spekulatif: Praktik yang menggunakan prototipe untuk mengeksplorasi kemungkinan", "Inovasi terapan: Organisasi yang mengubah riset menjadi produk atau alat"]'::jsonb,
    '["Demo prototipe: Menunjukkan artefak sambil menjelaskan riset di baliknya", "Dokumentasi proses: Berbagi metodologi dan pembelajaran", "Pameran riset: Presentasi yang menggabungkan temuan dengan artefak"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    60,
    'IAS',
    'Investigative Artistic Social (IAS)',
    'IAS menggabungkan keingintahuan analitis, kreativitas, dan kepedulian terhadap orang. Ini menciptakan peneliti kreatif yang fokus pada pengalaman manusia. Pikirkan peneliti etnografi dengan metode kreatif, seniman yang karya mereka diinformasikan riset sosial, atau desainer yang mempelajari pengalaman hidup. Kamu menggunakan riset untuk memahami orang dan kreativitas untuk mengkomunikasikan atau merespons temuan.',
    '["Riset yang bernuansa dan empatik: Menggunakan metode kreatif untuk mendapatkan pemahaman kaya tentang pengalaman", "Komunikasi yang menyentuh: Menyajikan temuan dengan cara yang beresonansi secara emosional", "Keterlibatan partisipan yang mendalam: Melibatkan orang dalam riset dengan cara yang memberdayakan", "Sintesis kreatif: Mengintegrasikan wawasan dari berbagai sumber dengan cara novel"]'::jsonb,
    '["Ketegangan objektivitas versus empati: Kedekatan dengan subjek bisa memengaruhi analisis", "Validitas metode kreatif: Harus mempertahankan ketelitian sambil menggunakan pendekatan inovatif", "Beban emosional: Mendengarkan pengalaman sulit orang secara mendalam bisa menguras"]'::jsonb,
    '["Refleksivitas metodologis: Secara eksplisit refleksikan bagaimana posisi kamu memengaruhi riset", "Triangulasi: Gunakan berbagai metode untuk memvalidasi temuan", "Dukungan rekan: Proses pengalaman riset dengan kolega untuk mengelola beban emosional"]'::jsonb,
    '["Riset kualitatif sosial: Proyek yang mempelajari pengalaman hidup untuk perubahan", "Seni berbasis riset: Praktik kreatif yang diinformasikan oleh riset sosial", "Desain partisipatif: Praktik yang melibatkan komunitas dalam riset dan desain"]'::jsonb,
    '["Storytelling berbasis riset: Menggunakan narasi untuk mengkomunikasikan temuan", "Presentasi multimedia: Menggabungkan berbagai media untuk menyampaikan kompleksitas", "Keterlibatan komunitas: Berbagi temuan dengan cara yang dapat diakses dan bermakna"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    62,
    'ICE',
    'Investigative Conventional Enterprising (ICE)',
    'ICE menggabungkan keingintahuan analitis, kecintaan pada sistem, dan ambisi untuk hasil. Ini menciptakan pemimpin yang menggunakan data dan proses untuk mendorong kesuksesan. Pikirkan direktur analitik dengan fokus pertumbuhan, konsultan transformasi berbasis data, atau kepala strategi operasional. Kamu ingin mencapai target ambisius melalui keputusan yang diinformasikan riset dan sistem yang dioptimalkan.',
    '["Optimasi berbasis bukti: Menggunakan data dan analisis untuk mengidentifikasi dan mengimplementasikan perbaikan", "Sistem pembelajaran: Membangun infrastruktur yang memungkinkan pembelajaran dan adaptasi berkelanjutan", "Kepemimpinan yang kredibel: Membuat keputusan dengan otoritas data dan riset", "Perubahan yang terukur: Mendorong transformasi dengan pelacakan kemajuan yang jelas"]'::jsonb,
    '["Terlalu bergantung pada metrik: Tidak semua yang penting dapat diukur dengan mudah", "Kompleksitas sistem analitik: Dapat membangun infrastruktur data yang terlalu rumit", "Tidak sabar dengan proses: Ingin hasil cepat tetapi riset dan sistem yang baik membutuhkan waktu"]'::jsonb,
    '["Mulai dengan metrik penting: Fokus pada indikator yang benar-benar menangkap kesuksesan", "Keseimbangan kuantitatif dan kualitatif: Gunakan berbagai jenis data untuk pemahaman lengkap", "Kemenangan cepat: Identifikasi perbaikan yang dapat memberikan hasil cepat untuk momentum"]'::jsonb,
    '["Konsultasi transformasi: Membantu organisasi dengan perubahan berbasis data", "Analitik bisnis: Departemen yang menggunakan data untuk strategi dan operasi", "Kepemimpinan operasional: Peran yang mengelola dengan fokus berat pada perbaikan berbasis bukti"]'::jsonb,
    '["Presentasi data yang persuasif: Menggunakan analisis untuk membangun kasus untuk perubahan", "Tinjauan kinerja reguler: Rapat untuk evaluasi kemajuan berdasarkan metrik", "Dokumentasi pembelajaran: Mencatat wawasan untuk pembelajaran organisasi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    63,
    'ICR',
    'Investigative Conventional Realistic (ICR)',
    'ICR menggabungkan keingintahuan analitis, kecintaan pada sistem, dan kemampuan teknis praktis. Ini menciptakan profesional teknis yang sangat metodis dan berbasis riset. Pikirkan ilmuwan laboratorium senior, insinyur kualitas dengan fokus riset, atau spesialis yang mengembangkan standar teknis. Kamu melakukan pekerjaan teknis dengan ketelitian ilmiah dan mendokumentasikan semuanya dengan sistematis.',
    '["Riset teknis yang ketat: Melakukan pekerjaan dengan metodologi yang dapat direplikasi", "Dokumentasi yang menyeluruh: Membuat catatan lengkap yang memungkinkan verifikasi dan pembelajaran", "Validasi sistematis: Menguji setiap aspek dengan teliti sebelum menerima sebagai valid", "Pengembangan standar: Terampil dalam menciptakan spesifikasi dan prosedur teknis"]'::jsonb,
    '["Lambat dalam lingkungan cepat: Pendekatan metodis membutuhkan waktu yang mungkin tidak tersedia", "Frustrasi dengan jalan pintas: Tidak nyaman ketika orang mengabaikan metodologi yang tepat", "Perfeksionisme yang melumpuhkan: Standar sangat tinggi bisa menunda kemajuan"]'::jsonb,
    '["Protokol bertingkat: Kembangkan prosedur yang disederhanakan untuk situasi mendesak", "Prioritas berbasis risiko: Fokuskan ketelitian penuh pada area paling kritis", "Komunikasi nilai: Bantu orang lain memahami mengapa metodologi ketat penting"]'::jsonb,
    '["Laboratorium riset: Fasilitas di mana pekerjaan teknis dilakukan dengan standar ilmiah", "Jaminan kualitas: Departemen yang memvalidasi pekerjaan teknis dengan ketelitian", "Pengembangan standar: Organisasi yang menciptakan spesifikasi untuk industri"]'::jsonb,
    '["Laporan metodologis: Dokumentasi yang detail tentang proses dan temuan", "Diskusi teknis mendalam: Percakapan yang mengeksplorasi detail dan validitas", "Peer review: Partisipasi aktif dalam proses tinjauan ilmiah"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    64,
    'ICS',
    'Investigative Conventional Social (ICS)',
    'ICS menggabungkan keingintahuan analitis, kecintaan pada sistem, dan kepedulian terhadap orang. Ini menciptakan peneliti atau evaluator layanan sosial yang sangat sistematis. Pikirkan evaluator program dengan dokumentasi ketat, peneliti kebijakan kesehatan, atau analis yang mempelajari sistem layanan. Kamu menggunakan riset untuk memahami bagaimana sistem melayani orang dan bagaimana meningkatkannya secara sistematis.',
    '["Evaluasi yang ketat: Mengukur dampak layanan dengan metodologi solid dan dokumentasi lengkap", "Analisis sistem untuk perbaikan: Mengidentifikasi bagaimana proses dapat ditingkatkan berdasarkan data", "Riset implementasi: Memahami tidak hanya apa yang efektif tetapi bagaimana mengimplementasikannya", "Dokumentasi pembelajaran: Membuat catatan menyeluruh untuk pembelajaran organisasi"]'::jsonb,
    '["Ketegangan ketelitian versus kecepatan: Evaluasi yang baik membutuhkan waktu tetapi organisasi butuh jawaban cepat", "Temuan sulit: Data kadang menunjukkan program tidak bekerja seperti diharapkan", "Kesenjangan riset-praktik: Rekomendasi tidak selalu mudah diimplementasikan"]'::jsonb,
    '["Evaluasi formatif: Lakukan evaluasi selama program berjalan untuk memungkinkan penyesuaian", "Komunikasi sensitif: Sampaikan temuan dengan cara konstruktif yang fokus pada pembelajaran", "Keterlibatan praktisi: Libatkan staf program dalam riset untuk relevansi dan adopsi"]'::jsonb,
    '["Evaluasi program sosial: Organisasi yang menilai efektivitas layanan", "Riset kebijakan kesehatan: Institusi yang mempelajari sistem perawatan", "Analisis data nirlaba: Peran yang menggunakan data untuk meningkatkan layanan sosial"]'::jsonb,
    '["Laporan yang terstruktur: Dokumentasi yang terorganisir dengan jelas untuk pengambilan keputusan", "Kolaborasi dengan praktisi: Bekerja erat dengan orang yang memberikan layanan", "Presentasi temuan yang dapat ditindaklanjuti: Menyajikan data dengan rekomendasi yang jelas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    61,
    'ICA',
    'Investigative Conventional Artistic (ICA)',
    'ICA menggabungkan keingintahuan analitis, kecintaan pada sistem, dan kreativitas. Ini menciptakan peneliti atau analis yang mengomunikasikan temuan dengan cara kreatif dalam kerangka sistematis. Pikirkan spesialis visualisasi data dengan proses ketat, kurator museum yang menggunakan metodologi riset, atau peneliti yang membuat output kreatif dengan dokumentasi lengkap. Kamu menggabungkan ketelitian analitis dengan ekspresi kreatif, semua terorganisir dengan baik.',
    '["Komunikasi data yang kreatif: Membuat visualisasi atau presentasi yang menyajikan temuan dengan cara menarik", "Riset dengan dokumentasi visual: Mendokumentasikan proses riset dengan cara yang sistematis dan kreatif", "Proses yang dapat diajarkan: Karena sistematis, dapat mengajarkan pendekatan kepada orang lain", "Ketelitian dengan aksesibilitas: Membuat riset kompleks dapat dipahami tanpa kehilangan ketelitian"]'::jsonb,
    '["Waktu untuk kesempurnaan: Menggabungkan analisis ketat, organisasi sistematis, dan output kreatif membutuhkan waktu", "Ketegangan struktur versus kreativitas: Kebutuhan akan sistem bisa membatasi aliran kreatif", "Perfeksionisme multidimensi: Ingin riset yang solid, presentasi yang indah, dan semua terdokumentasi sempurna"]'::jsonb,
    '["Template kreatif: Kembangkan kerangka yang memberikan struktur tetapi memungkinkan ekspresi kreatif", "Fase terpisah: Waktu untuk analisis, waktu untuk kreativitas, waktu untuk dokumentasi", "Kolaborasi: Bekerja dengan desainer atau seniman untuk aspek kreatif"]'::jsonb,
    '["Visualisasi data: Peran yang mengubah analisis kompleks menjadi komunikasi visual", "Riset dan kurasi: Posisi di museum atau arsip yang menggabungkan riset dengan presentasi", "Komunikasi sains: Membuat konten yang menjelaskan riset untuk audiens luas"]'::jsonb,
    '["Presentasi visual yang informatif: Menyajikan data dengan visualisasi yang menarik dan akurat", "Dokumentasi proses yang kreatif: Berbagi metodologi dengan cara yang dapat diakses", "Workshop yang terstruktur: Mengajarkan teknik dengan kerangka yang jelas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    70,
    'IRC',
    'Investigative Realistic Conventional (IRC)',
    'IRC menggabungkan keingintahuan analitis, kemampuan teknis praktis, dan kecintaan pada sistem. Ini menciptakan profesional teknis yang sangat metodis dan berbasis riset. Pikirkan ilmuwan laboratorium dengan dokumentasi ketat, insinyur riset yang sistematis, atau teknisi senior yang mengembangkan prosedur. Kamu melakukan pekerjaan teknis dengan ketelitian ilmiah dan mendokumentasikan semuanya secara sistematis untuk pembelajaran dan replikasi.',
    '["Riset teknis yang dapat direproduksi: Melakukan eksperimen atau pekerjaan teknis dengan metodologi yang memungkinkan verifikasi", "Dokumentasi yang komprehensif: Membuat catatan menyeluruh tentang proses, hasil, dan pembelajaran", "Validasi yang ketat: Menguji setiap aspek dengan teliti sebelum menerima sebagai benar", "Pengembangan prosedur: Terampil dalam menciptakan metode standar berdasarkan riset"]'::jsonb,
    '["Lambat dalam lingkungan yang menuntut kecepatan: Pendekatan metodis membutuhkan waktu yang mungkin tidak tersedia", "Frustrasi dengan pendekatan coba-coba: Tidak nyaman ketika orang mengabaikan metodologi yang tepat", "Perfeksionisme yang menghambat: Standar sangat tinggi bisa menunda penyelesaian"]'::jsonb,
    '["Protokol bertingkat: Kembangkan prosedur penuh dan prosedur cepat untuk situasi berbeda", "Prioritas berbasis kritikalitas: Fokuskan ketelitian penuh pada area yang paling penting", "Komunikasi nilai metodologi: Bantu orang lain memahami mengapa ketelitian menghemat waktu jangka panjang"]'::jsonb,
    '["Laboratorium riset teknis: Fasilitas di mana pekerjaan teknis dilakukan dengan standar ilmiah", "Jaminan kualitas berbasis riset: Departemen yang memvalidasi pekerjaan dengan metodologi ketat", "Pengembangan standar teknis: Organisasi yang menciptakan spesifikasi untuk industri"]'::jsonb,
    '["Dokumentasi metodologis yang detail: Laporan yang menjelaskan tidak hanya hasil tetapi juga proses", "Diskusi teknis yang mendalam: Percakapan yang mengeksplorasi detail metodologi", "Peer review yang aktif: Partisipasi dalam proses tinjauan ilmiah"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    71,
    'IRE',
    'Investigative Realistic Enterprising (IRE)',
    'IRE menggabungkan keingintahuan analitis, kemampuan teknis praktis, dan ambisi untuk dampak. Ini menciptakan pemimpin inovasi teknis yang berbasis riset. Pikirkan direktur riset dan pengembangan, pendiri startup teknologi yang juga engineer, atau CTO yang menggunakan riset untuk strategi. Kamu ingin mencapai terobosan teknis berdasarkan pemahaman mendalam dan membawanya ke implementasi yang berdampak.',
    '["Inovasi teknis berbasis riset: Mengidentifikasi peluang untuk terobosan berdasarkan pemahaman ilmiah dan teknis yang mendalam", "Kepemimpinan yang kredibel secara teknis: Dapat memimpin tim dengan otoritas karena memahami pekerjaan di tingkat detail", "Visi dari riset ke produk: Menerjemahkan temuan riset menjadi aplikasi praktis yang dapat dikomersialisasikan", "Keputusan strategis yang informasi: Membuat pilihan tentang arah teknis berdasarkan analisis menyeluruh"]'::jsonb,
    '["Tidak sabar dengan riset murni: Ingin melihat aplikasi praktis, kadang meremehkan nilai riset dasar", "Terlalu percaya diri teknis: Pemahaman mendalam bisa membuat terlalu yakin tentang kelayakan", "Kesenjangan komunikasi dengan non-teknis: Sulit menjelaskan konsep kompleks kepada audiens bisnis"]'::jsonb,
    '["Kemitraan riset-bisnis: Berkolaborasi dengan akademisi untuk riset sambil fokus pada aplikasi komersial", "Validasi pasar awal: Uji asumsi teknis dengan pelanggan potensial lebih awal dalam proses", "Bangun tim yang beragam: Rekrut orang dengan keahlian bisnis untuk melengkapi kekuatan teknis"]'::jsonb,
    '["Startup teknologi mendalam: Perusahaan berbasis pada inovasi ilmiah atau teknis yang signifikan", "Riset dan pengembangan komersial: Lab yang mengembangkan teknologi untuk produk atau layanan", "Kepemimpinan teknologi strategis: Peran CTO atau VP Engineering dengan fokus inovasi"]'::jsonb,
    '["Presentasi teknis strategis: Menjelaskan visi teknis dengan implikasi bisnis yang jelas", "Diskusi mendalam tentang kelayakan: Eksplorasi analitis tentang kemungkinan teknis", "Demo dan bukti konsep: Menunjukkan kelayakan melalui prototipe yang berfungsi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    69,
    'IRA',
    'Investigative Realistic Artistic (IRA)',
    'IRA menggabungkan keingintahuan analitis, kemampuan teknis praktis, dan kreativitas. Ini menciptakan peneliti kreatif yang dapat mewujudkan temuan mereka dalam bentuk nyata. Pikirkan peneliti desain yang juga pembuat, ilmuwan yang membuat visualisasi dan prototipe, atau engineer yang mengembangkan solusi inovatif berdasarkan riset. Kamu tidak hanya mempelajari dan membayangkan tetapi juga membangun solusi nyata yang kreatif.',
    '["Translasi riset ke artefak: Mengubah temuan penelitian menjadi objek atau sistem yang dapat diuji dan digunakan", "Eksplorasi kreatif yang terukur: Melakukan eksperimen kreatif dengan metodologi yang ketat", "Pemahaman konteks yang mendalam: Memahami keduanya teori dan kendala praktis dalam implementasi", "Komunikasi melalui prototipe: Menggunakan artefak untuk mengkomunikasikan wawasan dan konsep"]'::jsonb,
    '["Keseimbangan tiga prioritas: Terjebak antara ingin menganalisis lebih dalam, menciptakan lebih indah, atau membangun lebih fungsional", "Waktu untuk kesempurnaan multidimensi: Menggabungkan riset, kreativitas, dan pembuatan membutuhkan waktu yang signifikan", "Kompleksitas metodologis: Menggabungkan riset dengan pengembangan kreatif memerlukan banyak keahlian berbeda"]'::jsonb,
    '["Iterasi cepat dengan dokumentasi: Buat prototipe kasar untuk menguji ide lebih awal sambil mendokumentasikan pembelajaran", "Kolaborasi interdisipliner: Bekerja dengan ahli dari berbagai bidang untuk melengkapi keahlian", "Dokumentasi visual proses: Gunakan foto dan video untuk menangkap proses dan hasil"]'::jsonb,
    '["Riset dan pengembangan kreatif: Lab yang menggabungkan riset dengan pembuatan prototipe", "Desain spekulatif: Praktik yang menggunakan prototipe untuk mengeksplorasi kemungkinan masa depan", "Inovasi terapan: Organisasi yang mengubah riset menjadi produk atau alat yang dapat digunakan"]'::jsonb,
    '["Demo prototipe dengan penjelasan: Menunjukkan artefak sambil menjelaskan riset dan proses di baliknya", "Dokumentasi proses yang kaya: Berbagi metodologi dan pembelajaran dengan detail", "Pameran riset: Presentasi yang menggabungkan temuan ilmiah dengan artefak fisik"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    72,
    'IRS',
    'Investigative Realistic Social (IRS)',
    'IRS menggabungkan keingintahuan analitis, kemampuan teknis praktis, dan kepedulian terhadap orang. Ini menciptakan peneliti terapan yang tidak hanya mempelajari masalah tetapi juga membangun solusi untuk membantu orang. Pikirkan peneliti teknologi assistif yang juga engineer, ilmuwan kesehatan yang merancang intervensi praktis, atau peneliti pendidikan yang mengembangkan alat pembelajaran. Kamu menggunakan riset untuk memahami kebutuhan orang dan keterampilan teknis untuk menciptakan solusi nyata.',
    '["Riset translasional berpusat manusia: Mengubah temuan riset menjadi produk atau intervensi yang dapat digunakan orang", "Validasi dengan pengguna nyata: Menguji solusi dengan orang yang akan menggunakannya untuk memastikan efektivitas", "Iterasi berbasis bukti dan umpan balik: Menyempurnakan solusi berdasarkan data dan masukan dari pengguna", "Pemahaman konteks penggunaan: Memahami keduanya kebutuhan orang dan keterbatasan teknis"]'::jsonb,
    '["Keseimbangan riset versus pengembangan: Kadang tidak jelas apakah prioritas adalah memahami lebih dalam atau membangun solusi", "Kompleksitas metodologis: Menggabungkan riset pengguna dengan pengembangan teknis memerlukan banyak keahlian", "Waktu dari riset ke dampak: Proses dari riset hingga produk yang berfungsi membutuhkan waktu yang signifikan"]'::jsonb,
    '["Pendekatan desain berpusat pengguna: Libatkan pengguna di setiap tahap dari riset awal hingga pengujian akhir", "Prototipe cepat untuk umpan balik: Buat versi awal untuk menguji asumsi dengan pengguna lebih cepat", "Kolaborasi interdisipliner: Bekerja dengan ahli dari berbagai bidang untuk perspektif yang lengkap"]'::jsonb,
    '["Riset dan pengembangan sosial: Lab atau organisasi yang mengembangkan teknologi untuk kebutuhan sosial atau kesehatan", "Desain universal: Praktik yang menciptakan produk dapat diakses untuk semua orang", "Inovasi kesehatan: Organisasi yang mengembangkan solusi medis atau kesehatan berbasis riset"]'::jsonb,
    '["Demo dengan penjelasan konteks: Menunjukkan solusi sambil menjelaskan riset dan kebutuhan pengguna di baliknya", "Riset partisipatif: Melibatkan pengguna sebagai mitra dalam proses pengembangan", "Dokumentasi yang dapat diakses: Menjelaskan bagaimana solusi bekerja untuk audiens yang berbeda"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    78,
    'ACI',
    'Artistic Conventional Investigative (ACI)',
    'ACI menggabungkan kreativitas, kecintaan pada sistem, dan keingintahuan analitis. Ini menciptakan pencipta yang menggabungkan ekspresi kreatif dengan riset dan organisasi yang sistematis. Pikirkan kurator museum dengan latar belakang riset, desainer yang menggunakan data untuk menginformasikan karya, atau peneliti kreatif dengan dokumentasi ketat. Kamu menciptakan karya yang tidak hanya indah tetapi juga diinformasikan oleh riset dan terorganisir dengan baik.',
    '["Kreativitas yang diinformasikan riset: Karya kreatif yang didasarkan pada pemahaman mendalam dari riset", "Dokumentasi proses kreatif: Membuat catatan sistematis tentang proses kreatif untuk pembelajaran", "Kurasi yang berbasis bukti: Membuat keputusan kuratorial berdasarkan riset dan analisis", "Presentasi yang terorganisir: Menyajikan karya kreatif dengan struktur dan konteks yang jelas"]'::jsonb,
    '["Ketegangan antara spontanitas dan struktur: Kebutuhan akan sistem bisa membatasi aliran kreatif", "Waktu untuk kesempurnaan tiga dimensi: Menggabungkan kreativitas, riset, dan organisasi membutuhkan waktu", "Kompleksitas metodologis: Menggabungkan pendekatan kreatif dengan riset memerlukan keseimbangan yang sulit"]'::jsonb,
    '["Fase terpisah: Waktu untuk riset, waktu untuk eksplorasi kreatif, waktu untuk organisasi dan dokumentasi", "Template yang fleksibel: Kembangkan kerangka yang memberikan struktur tetapi memungkinkan kreativitas", "Kolaborasi: Bekerja dengan peneliti atau administrator untuk aspek riset dan organisasi"]'::jsonb,
    '["Museum atau galeri dengan fokus riset: Institusi yang menggabungkan kurasi kreatif dengan riset akademis", "Praktik desain berbasis riset: Studio yang menggunakan riset untuk menginformasikan pekerjaan kreatif", "Arsip atau koleksi: Peran yang memerlukan kreativitas dalam presentasi dan ketelitian dalam dokumentasi"]'::jsonb,
    '["Presentasi yang menggabungkan estetika dan riset: Menyajikan karya dengan konteks akademis dan visual yang menarik", "Dokumentasi kuratorial: Membuat catatan yang menjelaskan alasan di balik pilihan kreatif", "Workshop yang terstruktur: Mengajarkan proses kreatif dengan kerangka yang sistematis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    77,
    'ACE',
    'Artistic Conventional Enterprising (ACE)',
    'ACE menggabungkan kreativitas, kecintaan pada sistem, dan ambisi untuk kesuksesan. Ini menciptakan pemimpin bisnis kreatif yang sangat terorganisir dan berorientasi hasil. Pikirkan direktur operasi di agensi kreatif, pemilik studio desain dengan sistem yang ketat, atau manajer produksi di perusahaan media. Kamu ingin mencapai kesuksesan komersial melalui keunggulan kreatif yang didukung oleh operasi yang efisien.',
    '["Operasi kreatif yang efisien: Membangun sistem yang memungkinkan pekerjaan kreatif berkualitas diproduksi secara konsisten", "Manajemen proyek kreatif yang ketat: Mengelola timeline, anggaran, dan kualitas dengan sangat baik", "Pertumbuhan bisnis kreatif yang terkelola: Mengembangkan organisasi kreatif sambil mempertahankan standar", "Keandalan dalam pengiriman: Klien tahu mereka bisa mengandalkan kamu untuk mengirimkan pekerjaan berkualitas tepat waktu"]'::jsonb,
    '["Ketegangan kreativitas versus efisiensi: Sistem untuk produktivitas bisa membatasi eksplorasi kreatif yang diperlukan", "Ekspektasi klien versus visi artistik: Harus menyeimbangkan permintaan komersial dengan integritas kreatif", "Skalabilitas kreativitas: Sulit mempertahankan kualitas kreatif sambil meningkatkan volume produksi"]'::jsonb,
    '["Proses yang melindungi kreativitas: Sistem yang memberikan struktur tanpa mendikte hasil kreatif", "Rekrutmen yang selektif: Merekrut talenta yang dapat menghasilkan karya berkualitas dalam sistem", "Standar kualitas yang terdefinisi: Mendefinisikan dengan jelas apa yang dimaksud dengan keunggulan dalam organisasi"]'::jsonb,
    '["Agensi kreatif dalam peran operasional: Periklanan, desain, atau media di posisi manajemen", "Studio produksi: Film, animasi, atau konten yang memerlukan manajemen proyek yang ketat", "Perusahaan desain: Bisnis yang menyediakan layanan kreatif dengan sistem yang terorganisir"]'::jsonb,
    '["Komunikasi klien yang profesional: Mempresentasikan karya kreatif dengan cara yang membangun kepercayaan bisnis", "Manajemen tim yang terstruktur: Rapat reguler, timeline yang jelas, ekspektasi yang terdefinisi", "Pelaporan kemajuan: Update sistematis tentang status proyek dan pencapaian"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    79,
    'ACR',
    'Artistic Conventional Realistic (ACR)',
    'ACR menggabungkan kreativitas, kecintaan pada sistem, dan kemampuan teknis praktis. Ini menciptakan pengrajin kreatif yang sangat terorganisir. Pikirkan desainer produk dengan workshop yang rapi, pengrajin dengan proses produksi sistematis, atau ilustrator teknis dengan alur kerja yang ketat. Kamu menciptakan karya yang indah dan fungsional dengan proses yang terorganisir dengan sempurna.',
    '["Proses kreatif yang sistematis: Memiliki alur kerja yang jelas dari konsep hingga produksi yang menghasilkan output konsisten", "Kualitas yang dapat diprediksi: Setiap karya memenuhi standar tinggi karena sistem kontrol kualitas yang ketat", "Efisiensi produksi kreatif: Dapat menghasilkan volume yang baik tanpa mengorbankan kualitas", "Dokumentasi untuk replikasi: Proses terdokumentasi dengan baik sehingga dapat diajarkan atau direplikasi"]'::jsonb,
    '["Kekakuan dalam proses: Alur kerja yang tetap mungkin membatasi eksplorasi kreatif spontan", "Perfeksionisme yang menghambat: Kombinasi standar kreatif, teknis, dan organisasi yang tinggi bisa melumpuhkan", "Resistensi terhadap eksperimen: Sistem yang terbukti membuat sulit mencoba pendekatan baru"]'::jsonb,
    '["Waktu untuk eksperimen: Sisihkan waktu reguler untuk bermain dengan teknik baru di luar produksi", "Penguasaan bertahap: Terima bahwa penguasaan adalah perjalanan, izinkan diri membuat karya tidak sempurna saat belajar", "Dokumentasi evolusi: Simpan karya awal sebagai referensi untuk melihat pertumbuhan"]'::jsonb,
    '["Studio kerajinan dengan sistem: Workshop yang menggabungkan kreativitas dengan produksi yang terorganisir", "Produksi desain: Perusahaan yang membuat produk kreatif dalam volume", "Layanan kreatif teknis: Ilustrasi, pembuatan model, atau produksi kreatif lainnya"]'::jsonb,
    '["Pengajaran sistematis: Pelajaran terstruktur yang membangun keterampilan secara progresif", "Disiplin workshop: Harapkan organisasi, kebersihan, dan pemeliharaan alat yang tepat", "Apresiasi kerajinan: Hormati kualitas pengerjaan dalam medium apa pun"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    80,
    'ACS',
    'Artistic Conventional Social (ACS)',
    'ACS menggabungkan kreativitas, kecintaan pada sistem, dan kepedulian terhadap orang. Ini menciptakan fasilitator program kreatif yang sangat terorganisir. Pikirkan manajer program seni komunitas, koordinator acara kreatif, atau kurator pendidikan di museum. Kamu membawa orang bersama melalui pengalaman kreatif yang dirancang dan dikelola dengan sangat baik.',
    '["Program kreatif yang dapat diakses: Merancang pengalaman kreatif dengan struktur yang memungkinkan partisipasi luas", "Manajemen acara yang detail: Mengorganisir setiap aspek program atau acara kreatif dengan teliti", "Dokumentasi untuk keberlanjutan: Membuat catatan yang memungkinkan program berhasil direplikasi", "Koordinasi yang efektif: Mengelola hubungan dengan seniman, peserta, sponsor, dan mitra"]'::jsonb,
    '["Ketegangan struktur versus spontanitas: Seniman atau peserta mungkin menginginkan lebih banyak kebebasan daripada sistem izinkan", "Beban administratif: Mengorganisir program kreatif memerlukan banyak pekerjaan logistik dan dokumentasi", "Keseimbangan inklusivitas dengan kualitas: Ingin program dapat diakses semua orang tetapi juga mempertahankan standar"]'::jsonb,
    '["Konsultasi dengan seniman: Libatkan kreator dalam merancang struktur untuk memastikan sistem mendukung", "Sistem yang efisien: Kembangkan template dan prosedur yang menghemat waktu untuk tugas berulang", "Evaluasi partisipatif: Kumpulkan umpan balik dari semua pihak untuk terus menyempurnakan"]'::jsonb,
    '["Institusi budaya: Museum, galeri, atau pusat seni dengan program pendidikan", "Organisasi seni komunitas: Program yang menyediakan akses terorganisir ke seni", "Manajemen acara budaya: Peran yang mengorganisir festival, pameran, atau program kreatif"]'::jsonb,
    '["Komunikasi logistik yang jelas: Memberikan informasi terstruktur tentang program dan persyaratan", "Hubungan yang hangat: Mempertahankan koneksi personal sambil mengelola sistem", "Dokumentasi visual: Menggunakan foto dan media untuk mendokumentasikan dan mempromosikan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    81,
    'AEC',
    'Artistic Enterprising Conventional (AEC)',
    'AEC menggabungkan kreativitas, ambisi untuk kesuksesan, dan kecintaan pada sistem. Ini menciptakan pemimpin bisnis kreatif yang sangat terorganisir dan berorientasi pertumbuhan. Pikirkan CEO agensi kreatif, pendiri studio dengan operasi yang ketat, atau direktur kreatif yang juga mengelola bisnis. Kamu ingin kesuksesan komersial melalui keunggulan kreatif yang didukung oleh sistem yang efisien.',
    '["Kepemimpinan bisnis kreatif: Memimpin organisasi kreatif dengan visi artistik dan keterampilan manajemen", "Sistem untuk skalabilitas: Membangun infrastruktur yang memungkinkan pertumbuhan sambil mempertahankan kualitas", "Manajemen keuangan yang ketat: Mengelola anggaran dan profitabilitas dengan disiplin", "Pertumbuhan yang terkelola: Mengembangkan bisnis kreatif dengan cara yang berkelanjutan"]'::jsonb,
    '["Ketegangan visi versus viabilitas: Kadang harus mengorbankan aspek kreatif untuk membuat bisnis yang layak", "Transisi dari kreator ke manajer: Sulit melepaskan pembuatan langsung untuk fokus pada kepemimpinan", "Keseimbangan kreativitas dengan sistem: Terlalu banyak proses bisa membunuh inovasi yang diperlukan"]'::jsonb,
    '["Delegasi kreatif: Rekrut talenta yang dapat menjalankan visi kreatif sambil kamu fokus pada bisnis", "Sistem yang melindungi kreativitas: Proses yang memberikan struktur tanpa mengekang inovasi", "Metrik yang bermakna: Ukur kesuksesan tidak hanya dalam pendapatan tetapi juga kualitas dan inovasi"]'::jsonb,
    '["Kepemimpinan agensi kreatif: CEO atau pendiri di periklanan, desain, atau media", "Studio yang berkembang: Bisnis kreatif dalam fase pertumbuhan", "Perusahaan kreatif yang mapan: Organisasi yang memerlukan kepemimpinan kreatif dan bisnis"]'::jsonb,
    '["Komunikasi visi dan metrik: Mengartikulasikan arah kreatif sambil berbicara tentang hasil bisnis", "Manajemen pemangku kepentingan: Mengelola hubungan dengan klien, talenta, dan investor", "Kepemimpinan yang menginspirasi: Memotivasi tim dengan visi sambil mengelola dengan sistem"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    82,
    'AEI',
    'Artistic Enterprising Investigative (AEI)',
    'AEI menggabungkan kreativitas, ambisi untuk dampak, dan keingintahuan analitis. Ini menciptakan inovator kreatif yang menggunakan riset untuk menginformasikan visi dan mendorong kesuksesan. Pikirkan direktur inovasi di industri kreatif, pengusaha desain berbasis wawasan, atau pemimpin yang menggabungkan kreativitas dengan data. Kamu ingin menciptakan sesuatu yang baru dan bermakna, didukung oleh pemahaman mendalam, dan membawanya ke kesuksesan komersial.',
    '["Inovasi kreatif berbasis riset: Ide kreatif yang didasarkan pada wawasan dari riset dan analisis mendalam", "Diferensiasi strategis yang kuat: Menciptakan produk atau layanan yang menonjol karena pemahaman unik pasar", "Kepemimpinan yang kredibel: Dihormati karena keduanya kreativitas dan kedalaman intelektual", "Visi yang persuasif: Dapat mengartikulasikan konsep kreatif dengan dukungan logika dan data"]'::jsonb,
    '["Kelumpuhan dari analisis kreatif: Terlalu banyak riset bisa menghambat lompatan kreatif yang diperlukan", "Ketegangan intuisi versus data: Kadang keputusan kreatif terbaik tidak didukung oleh bukti", "Kompleksitas komunikasi: Konsep yang menggabungkan riset dan kreativitas bisa sulit dijelaskan dengan sederhana"]'::jsonb,
    '["Fase terpisah untuk riset dan kreativitas: Waktu untuk riset, waktu untuk eksplorasi kreatif, waktu untuk eksekusi", "Percaya intuisi yang informasi: Gunakan riset sebagai fondasi tetapi biarkan kreativitas memimpin keputusan akhir", "Storytelling yang menyederhanakan: Buat narasi yang membuat konsep kompleks dapat diakses"]'::jsonb,
    '["Laboratorium inovasi kreatif: Organisasi yang menggabungkan riset dengan desain", "Konsultasi strategi kreatif: Membantu organisasi dengan diferensiasi berbasis wawasan", "Startup produk inovatif: Perusahaan yang menciptakan produk baru berdasarkan pemahaman unik"]'::jsonb,
    '["Presentasi yang menggabungkan data dan visi: Menggunakan riset untuk membangun kasus untuk ide kreatif", "Workshop ideasi berbasis wawasan: Fasilitasi eksplorasi kreatif yang diinformasikan temuan", "Jaringan pemikir kreatif: Terhubung dengan orang yang menghargai pendekatan hybrid"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    83,
    'AER',
    'Artistic Enterprising Realistic (AER)',
    'AER menggabungkan kreativitas, ambisi untuk kesuksesan, dan kemampuan teknis praktis. Ini menciptakan pengusaha kreatif yang bisa mewujudkan visi mereka sendiri dan membawanya ke pasar. Pikirkan desainer produk yang memulai perusahaan manufaktur, arsitek dengan firma pembangunan, atau pengrajin yang membangun merek global. Kamu tidak hanya membayangkan produk kreatif tetapi juga bisa membuatnya dan menjualnya dalam skala yang signifikan.',
    '["Visi ke pasar yang lengkap: Mengambil konsep kreatif dari ide hingga produk komersial yang sukses", "Kemandirian dalam eksekusi: Dapat membangun prototipe dan produk sendiri tanpa ketergantungan penuh pada orang lain", "Diferensiasi melalui kerajinan: Produk menonjol di pasar karena kualitas teknis dan visi kreatif yang unik", "Skalabilitas melalui sistem: Membangun proses produksi yang memungkinkan pertumbuhan"]'::jsonb,
    '["Transisi dari pembuat ke pemimpin: Sulit melepaskan pembuatan langsung untuk fokus pada pertumbuhan bisnis", "Keseimbangan kualitas dengan skala: Kerajinan personal yang membuat merek mungkin sulit dipertahankan saat berkembang", "Kompromi kreatif untuk produksi: Harus menyesuaikan desain untuk kelayakan manufaktur atau biaya"]'::jsonb,
    '["Rekrut dan latih pengrajin: Temukan orang yang dapat mempelajari standar kualitas kamu untuk memperluas kapasitas", "Fokus pada desain dan strategi: Seiring pertumbuhan, delegasikan produksi sambil mempertahankan kontrol kreatif", "Bangun merek berbasis cerita: Ciptakan identitas yang lebih besar dari produk individual"]'::jsonb,
    '["Kewirausahaan produk kreatif: Bisnis sendiri yang menciptakan dan menjual produk fisik", "Desain-manufaktur terintegrasi: Perusahaan yang menangani keduanya desain dan produksi", "Merek berbasis kerajinan: Bisnis yang dibangun di sekitar keterampilan dan visi pembuat"]'::jsonb,
    '["Storytelling produk: Berbagi proses dan visi di balik produk sebagai bagian dari branding", "Demo keahlian: Menunjukkan keterampilan untuk membangun kepercayaan dan diferensiasi", "Keterlibatan pelanggan: Membangun komunitas di sekitar merek dan nilai"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    84,
    'AES',
    'Artistic Enterprising Social (AES)',
    'AES menggabungkan kreativitas, ambisi untuk dampak, dan kepedulian terhadap orang. Ini menciptakan pemimpin gerakan kreatif untuk perubahan sosial. Pikirkan pendiri organisasi seni untuk keadilan sosial, direktur festival dengan misi pemberdayaan, atau pengusaha kreatif yang membangun platform untuk seniman marjinal. Kamu menggunakan kreativitas dan kepemimpinan untuk menggerakkan perubahan sosial yang bermakna dan inklusif.',
    '["Mobilisasi melalui kreativitas: Menggunakan seni dan budaya untuk menginspirasi tindakan kolektif dan perubahan", "Kepemimpinan yang inklusif: Menciptakan ruang di mana orang dari berbagai latar belakang merasa bisa berkontribusi secara kreatif", "Komunikasi yang resonan: Menyampaikan pesan sosial dengan cara yang menyentuh secara emosional", "Jaringan lintas sektor: Menghubungkan seniman, aktivis, pendana, dan komunitas untuk dampak maksimal"]'::jsonb,
    '["Keseimbangan visi artistik dengan misi sosial: Kadang ketegangan antara keunggulan estetika dan efektivitas kampanye", "Keberlanjutan finansial: Mendanai pekerjaan yang menggabungkan seni dengan perubahan sosial bisa sangat menantang", "Kelelahan dari intensitas: Pekerjaan yang menggabungkan kreativitas, kepemimpinan, dan misi sosial sangat menuntut"]'::jsonb,
    '["Koalisi lintas gerakan: Bangun aliansi dengan organisasi seni dan organisasi aktivis", "Model pendanaan campuran: Kombinasikan tiket, hibah seni, hibah sosial, dan sponsor korporat", "Kepemimpinan bersama: Bagikan beban dengan membangun tim kepemimpinan kolektif"]'::jsonb,
    '["Organisasi seni untuk keadilan sosial: Kelompok yang menggunakan kreativitas untuk advokasi", "Platform untuk seniman marjinal: Organisasi yang memberikan ruang untuk suara yang kurang terwakili", "Festival atau acara dengan misi: Platform yang menggabungkan seni dengan tujuan sosial"]'::jsonb,
    '["Storytelling yang menggerakkan: Menggunakan narasi untuk menginspirasi orang bergabung dalam gerakan", "Kolaborasi seniman yang luas: Bekerja dengan kreator dari berbagai medium dan komunitas", "Advokasi publik: Berbicara di forum tentang isu sosial dengan perspektif kreatif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    85,
    'AIC',
    'Artistic Investigative Conventional (AIC)',
    'AIC menggabungkan kreativitas, keingintahuan analitis, dan kecintaan pada sistem. Ini menciptakan peneliti kreatif yang sangat terorganisir dan metodis. Pikirkan kurator museum dengan latar belakang riset akademis, desainer yang menggunakan data dengan dokumentasi ketat, atau peneliti kreatif yang sistematis. Kamu menciptakan karya yang tidak hanya indah tetapi juga diinformasikan oleh riset yang ketat dan terorganisir dengan sempurna.',
    '["Kreativitas berbasis riset yang sistematis: Karya kreatif yang didasarkan pada pemahaman mendalam yang terdokumentasi dengan baik", "Kurasi yang berbasis bukti: Membuat keputusan kuratorial berdasarkan riset dan analisis yang menyeluruh", "Dokumentasi proses yang komprehensif: Membuat catatan sistematis tentang riset dan proses kreatif", "Presentasi yang terorganisir dan informatif: Menyajikan karya dengan struktur yang jelas dan konteks akademis"]'::jsonb,
    '["Ketegangan antara spontanitas dan struktur: Kebutuhan akan sistem dan riset bisa membatasi aliran kreatif", "Waktu untuk kesempurnaan tiga dimensi: Menggabungkan kreativitas, riset, dan organisasi membutuhkan waktu yang sangat signifikan", "Kompleksitas metodologis: Menggabungkan pendekatan kreatif dengan riset ketat memerlukan keseimbangan yang sulit"]'::jsonb,
    '["Fase terpisah yang jelas: Waktu untuk riset, waktu untuk eksplorasi kreatif, waktu untuk organisasi dan dokumentasi", "Template yang fleksibel: Kembangkan kerangka yang memberikan struktur tetapi memungkinkan kreativitas", "Kolaborasi interdisipliner: Bekerja dengan peneliti atau administrator untuk aspek riset dan organisasi"]'::jsonb,
    '["Museum atau galeri dengan fokus akademis: Institusi yang menggabungkan kurasi kreatif dengan riset", "Praktik desain berbasis riset: Studio yang menggunakan riset untuk menginformasikan pekerjaan kreatif", "Arsip atau koleksi: Peran yang memerlukan kreativitas dalam presentasi dan ketelitian dalam dokumentasi"]'::jsonb,
    '["Presentasi yang menggabungkan estetika dan akademis: Menyajikan karya dengan konteks riset dan visual yang menarik", "Dokumentasi kuratorial yang detail: Membuat catatan yang menjelaskan alasan di balik pilihan kreatif", "Workshop yang terstruktur: Mengajarkan proses kreatif dengan kerangka yang sistematis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    86,
    'AIE',
    'Artistic Investigative Enterprising (AIE)',
    'AIE menggabungkan kreativitas, keingintahuan analitis, dan ambisi untuk dampak. Ini menciptakan inovator kreatif yang menggunakan riset untuk menginformasikan visi dan mendorong perubahan atau kesuksesan. Pikirkan direktur kreatif yang juga peneliti, pengusaha di industri kreatif yang berbasis wawasan, atau pemimpin inovasi yang menggabungkan analisis dengan kreativitas untuk hasil bisnis. Kamu ingin menciptakan sesuatu yang baru dan bermakna, didukung oleh pemahaman mendalam, dan membawanya ke dunia dengan dampak.',
    '["Inovasi yang diinformasikan riset: Ide kreatif yang didasarkan pada wawasan dari riset dan analisis mendalam", "Diferensiasi strategis yang kuat: Menciptakan produk atau layanan yang menonjol karena pemahaman unik tentang pasar atau pengguna", "Kepemimpinan yang kredibel dan inspiratif: Dihormati karena keduanya kreativitas dan kedalaman intelektual", "Visi yang persuasif: Dapat mengartikulasikan konsep kreatif dengan dukungan logika yang kuat dan data"]'::jsonb,
    '["Kelumpuhan dari analisis: Terlalu banyak riset bisa menunda tindakan kreatif yang diperlukan", "Ketegangan intuisi versus data: Kadang lompatan kreatif terbaik tidak didukung oleh bukti yang kuat", "Kompleksitas komunikasi: Konsep yang menggabungkan riset dan kreativitas bisa sulit dijelaskan dengan sederhana"]'::jsonb,
    '["Percaya intuisi yang informasi: Gunakan riset sebagai fondasi tetapi biarkan kreativitas memimpin keputusan akhir", "Prototipe cepat untuk validasi: Uji ide kreatif lebih awal daripada menunggu riset yang sempurna", "Storytelling yang menyederhanakan: Buat narasi yang membuat konsep kompleks dapat diakses dan menarik"]'::jsonb,
    '["Konsultasi inovasi kreatif: Membantu organisasi dengan diferensiasi berbasis wawasan", "Startup kreatif berbasis riset: Perusahaan yang menggunakan pemahaman unik untuk produk inovatif", "Kepemimpinan inovasi: Peran yang mengarahkan pengembangan produk atau layanan baru"]'::jsonb,
    '["Presentasi yang menggabungkan wawasan dan visi: Menggunakan riset untuk membangun kasus untuk ide kreatif", "Workshop ideasi berbasis bukti: Fasilitasi eksplorasi kreatif yang diinformasikan oleh temuan riset", "Jaringan pemikir hybrid: Terhubung dengan orang yang menghargai pendekatan integratif"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    87,
    'AIR',
    'Artistic Investigative Realistic (AIR)',
    'AIR menggabungkan kreativitas, keingintahuan analitis, dan kemampuan teknis praktis. Ini menciptakan peneliti kreatif yang dapat mewujudkan temuan mereka dalam bentuk nyata yang inovatif. Pikirkan peneliti desain yang juga pembuat, seniman yang karyanya berbasis riset ilmiah, atau engineer yang mengembangkan solusi inovatif berdasarkan riset kreatif. Kamu tidak hanya mempelajari dan membayangkan tetapi juga membangun solusi nyata yang kreatif dan berbasis bukti.',
    '["Translasi riset ke artefak kreatif: Mengubah temuan penelitian menjadi objek atau sistem yang dapat diuji dan digunakan", "Eksplorasi kreatif yang terukur: Melakukan eksperimen kreatif dengan metodologi riset yang ketat", "Pemahaman konteks yang mendalam: Memahami keduanya teori, kreativitas, dan kendala praktis dalam implementasi", "Komunikasi melalui prototipe: Menggunakan artefak untuk mengkomunikasikan wawasan dan konsep kompleks"]'::jsonb,
    '["Keseimbangan tiga prioritas: Terjebak antara ingin menganalisis lebih dalam, menciptakan lebih indah, atau membangun lebih fungsional", "Waktu untuk kesempurnaan multidimensi: Menggabungkan riset, kreativitas, dan pembuatan membutuhkan waktu yang sangat signifikan", "Kompleksitas metodologis: Menggabungkan riset dengan pengembangan kreatif memerlukan banyak keahlian yang berbeda"]'::jsonb,
    '["Iterasi cepat dengan dokumentasi: Buat prototipe kasar untuk menguji ide lebih awal sambil mendokumentasikan pembelajaran", "Kolaborasi interdisipliner: Bekerja dengan ahli dari berbagai bidang untuk melengkapi keahlian", "Dokumentasi visual proses: Gunakan foto dan video untuk menangkap proses dan hasil dengan baik"]'::jsonb,
    '["Riset dan pengembangan kreatif: Lab yang menggabungkan riset dengan pembuatan prototipe", "Desain spekulatif: Praktik yang menggunakan prototipe untuk mengeksplorasi kemungkinan", "Inovasi terapan: Organisasi yang mengubah riset menjadi produk atau alat yang dapat digunakan"]'::jsonb,
    '["Demo prototipe dengan penjelasan riset: Menunjukkan artefak sambil menjelaskan riset dan proses di baliknya", "Dokumentasi proses yang kaya: Berbagi metodologi dan pembelajaran dengan detail yang komprehensif", "Pameran riset: Presentasi yang menggabungkan temuan ilmiah dengan artefak fisik"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    88,
    'AIS',
    'Artistic Investigative Social (AIS)',
    'AIS menggabungkan kreativitas, keingintahuan analitis, dan kepedulian terhadap orang. Ini menciptakan peneliti kreatif yang fokus pada pengalaman manusia dan mengkomunikasikannya dengan cara yang menarik. Pikirkan peneliti etnografi dengan pendekatan kreatif, seniman yang karya mereka diinformasikan riset sosial, atau desainer yang mempelajari pengalaman hidup dengan metode inovatif. Kamu menggunakan riset untuk memahami orang dan kreativitas untuk mengkomunikasikan atau merespons temuan.',
    '["Riset yang bernuansa dan empatik: Menggunakan metode kreatif untuk mendapatkan pemahaman kaya tentang pengalaman manusia", "Komunikasi yang menyentuh: Menyajikan temuan riset dengan cara yang beresonansi secara emosional dan intelektual", "Keterlibatan partisipan yang mendalam: Melibatkan orang dalam riset dengan cara yang memberdayakan dan bermakna", "Sintesis kreatif: Mengintegrasikan wawasan dari berbagai sumber dengan cara yang novel dan menarik"]'::jsonb,
    '["Ketegangan objektivitas versus empati: Kedekatan emosional dengan subjek bisa memengaruhi analisis", "Validitas metode kreatif: Harus mempertahankan ketelitian metodologi sambil menggunakan pendekatan inovatif", "Beban emosional: Mendengarkan pengalaman sulit orang secara mendalam bisa sangat menguras"]'::jsonb,
    '["Refleksivitas metodologis: Secara eksplisit refleksikan bagaimana posisi kamu memengaruhi riset", "Triangulasi metode: Gunakan berbagai metode untuk memvalidasi temuan", "Dukungan rekan: Proses pengalaman riset dengan kolega untuk mengelola beban emosional"]'::jsonb,
    '["Riset kualitatif sosial: Proyek yang mempelajari pengalaman hidup untuk perubahan kebijakan atau sosial", "Seni berbasis riset: Praktik kreatif yang diinformasikan oleh riset sosial mendalam", "Desain partisipatif: Praktik yang melibatkan komunitas dalam riset dan desain solusi"]'::jsonb,
    '["Storytelling berbasis riset: Menggunakan narasi untuk mengkomunikasikan temuan dengan dampak", "Presentasi multimedia: Menggabungkan berbagai media untuk menyampaikan kompleksitas pengalaman", "Keterlibatan komunitas: Berbagi temuan dengan cara yang dapat diakses dan bermakna bagi komunitas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    89,
    'ARC',
    'Artistic Realistic Conventional (ARC)',
    'ARC menggabungkan kreativitas, kemampuan teknis praktis, dan kecintaan pada sistem. Ini menciptakan pengrajin kreatif yang sangat terorganisir dan metodis. Pikirkan desainer produk industri dengan workshop yang rapi, ilustrator teknis dengan alur kerja sistematis, atau pengrajin master dengan proses produksi yang ketat. Kamu menciptakan karya yang indah, fungsional, dan diproduksi dengan proses yang terorganisir dengan sempurna.',
    '["Proses kreatif yang sistematis dan efisien: Memiliki alur kerja yang jelas yang menghasilkan output berkualitas konsisten", "Kualitas yang dapat diprediksi: Setiap karya memenuhi standar tinggi karena sistem kontrol kualitas yang ketat", "Dokumentasi untuk pembelajaran: Proses terdokumentasi dengan baik sehingga dapat diajarkan atau direplikasi", "Efisiensi produksi kreatif: Dapat menghasilkan volume yang baik tanpa mengorbankan kualitas atau kreativitas"]'::jsonb,
    '["Kekakuan dalam proses kreatif: Alur kerja yang tetap mungkin membatasi eksplorasi kreatif yang spontan", "Perfeksionisme tiga dimensi: Kombinasi standar kreatif, teknis, dan organisasi yang sangat tinggi bisa melumpuhkan", "Resistensi terhadap eksperimen: Sistem yang terbukti efektif membuat sulit mencoba pendekatan baru"]'::jsonb,
    '["Waktu terjadwal untuk eksperimen: Sisihkan waktu reguler untuk bermain dengan teknik baru di luar alur kerja produksi", "Penguasaan sebagai perjalanan: Terima bahwa penguasaan adalah proses, izinkan diri membuat karya tidak sempurna saat belajar", "Dokumentasi evolusi: Simpan karya awal sebagai referensi untuk melihat pertumbuhan dan pembelajaran"]'::jsonb,
    '["Studio kerajinan dengan sistem produksi: Workshop yang menggabungkan kreativitas dengan produksi yang terorganisir", "Produksi desain industri: Perusahaan yang membuat produk kreatif dalam volume dengan standar tinggi", "Layanan kreatif teknis: Ilustrasi, pembuatan model, atau produksi kreatif lainnya dengan sistem"]'::jsonb,
    '["Pengajaran sistematis yang terstruktur: Pelajaran yang membangun keterampilan secara progresif dan jelas", "Disiplin workshop: Harapkan organisasi, kebersihan, dan pemeliharaan alat yang tepat dari semua", "Apresiasi kerajinan: Hormati kualitas pengerjaan dalam medium apa pun"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    90,
    'ARE',
    'Artistic Realistic Enterprising (ARE)',
    'ARE menggabungkan kreativitas, kemampuan teknis praktis, dan ambisi untuk kesuksesan. Ini menciptakan pengusaha kreatif yang bisa mewujudkan visi mereka sendiri dan membawanya ke pasar dengan strategi yang kuat. Pikirkan desainer produk yang memulai perusahaan sukses, arsitek dengan firma yang berkembang, atau pengrajin yang membangun merek internasional. Kamu tidak hanya membayangkan dan membuat produk kreatif tetapi juga menjualnya dengan sangat efektif.',
    '["Visi ke pasar yang lengkap: Mengambil konsep kreatif dari ide hingga produk komersial yang sukses di pasar", "Kemandirian dalam eksekusi: Dapat membangun prototipe dan produk sendiri tanpa ketergantungan penuh pada orang lain", "Diferensiasi melalui kerajinan: Produk menonjol di pasar karena kombinasi kualitas teknis dan visi kreatif yang unik", "Skalabilitas melalui sistem: Membangun proses produksi yang memungkinkan pertumbuhan bisnis yang signifikan"]'::jsonb,
    '["Transisi dari pembuat ke pemimpin bisnis: Sulit melepaskan pembuatan langsung untuk fokus pada pertumbuhan dan strategi bisnis", "Keseimbangan kualitas kerajinan dengan skala: Kerajinan personal yang membuat merek mungkin sulit dipertahankan saat produksi meningkat", "Kompromi kreatif untuk viabilitas: Harus menyesuaikan desain ideal untuk kelayakan manufaktur atau biaya produksi"]'::jsonb,
    '["Rekrut dan latih pengrajin berkualitas: Temukan orang yang dapat mempelajari standar kualitas kamu untuk memperluas kapasitas", "Fokus pada desain dan strategi bisnis: Seiring pertumbuhan, delegasikan produksi sambil mempertahankan kontrol kreatif dan arah", "Bangun merek berbasis cerita dan nilai: Ciptakan identitas yang lebih besar dari produk individual"]'::jsonb,
    '["Kewirausahaan produk kreatif: Bisnis sendiri yang menciptakan dan menjual produk fisik yang inovatif", "Desain-manufaktur terintegrasi: Perusahaan yang menangani keduanya desain dan produksi dengan kontrol penuh", "Merek berbasis kerajinan: Bisnis yang dibangun di sekitar keterampilan unik dan visi pembuat"]'::jsonb,
    '["Storytelling produk yang kuat: Berbagi proses dan visi di balik produk sebagai bagian integral dari branding", "Demo keahlian dan kualitas: Menunjukkan keterampilan dan kualitas untuk membangun kepercayaan pelanggan", "Keterlibatan komunitas pelanggan: Membangun komunitas yang loyal di sekitar merek dan nilai yang dianut"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    91,
    'ARI',
    'Artistic Realistic Investigative (ARI)',
    'ARI menggabungkan kreativitas, kemampuan teknis praktis, dan keingintahuan analitis. Ini menciptakan inovator kreatif yang menggabungkan pembuatan dengan riset. Pikirkan desainer yang melakukan riset pengguna dan membuat prototipe, seniman yang mengeksplorasi material melalui eksperimen, atau inventor yang menggabungkan kreativitas dengan riset ilmiah. Kamu menciptakan solusi inovatif yang indah, fungsional, dan diinformasikan oleh pemahaman mendalam.',
    '["Inovasi yang diinformasikan riset: Solusi kreatif yang didasarkan pada pemahaman mendalam dari riset dan eksperimen", "Prototipe untuk pembelajaran: Membuat prototipe sebagai cara untuk menguji ide dan belajar", "Pemahaman material dan teknis: Menggabungkan pengetahuan tentang material, teknik, dan teori", "Iterasi berbasis temuan: Menyempurnakan desain berdasarkan pembelajaran dari riset dan pengujian"]'::jsonb,
    '["Keseimbangan tiga prioritas: Terjebak antara ingin menganalisis lebih, menciptakan lebih indah, atau membangun lebih baik", "Waktu untuk kesempurnaan: Menggabungkan riset, kreativitas, dan pembuatan membutuhkan waktu yang sangat signifikan", "Kompleksitas proses: Menggabungkan riset dengan pengembangan kreatif dan pembuatan teknis sangat kompleks"]'::jsonb,
    '["Iterasi cepat: Buat prototipe kasar untuk menguji ide lebih awal daripada menunggu desain sempurna", "Dokumentasi pembelajaran: Tangkap wawasan dari setiap iterasi untuk pembelajaran yang berkelanjutan", "Kolaborasi: Bekerja dengan ahli dari berbagai bidang untuk melengkapi keahlian"]'::jsonb,
    '["Riset dan pengembangan produk: Lab atau studio yang menggabungkan riset dengan pengembangan", "Inovasi material: Organisasi yang mengeksplorasi material baru atau aplikasi baru", "Desain eksperimental: Praktik yang menggunakan pembuatan untuk mengeksplorasi kemungkinan"]'::jsonb,
    '["Demo dengan penjelasan riset: Menunjukkan prototipe sambil menjelaskan riset dan pembelajaran", "Dokumentasi proses yang detail: Berbagi eksperimen, kegagalan, dan pembelajaran", "Diskusi teknis dan kreatif: Percakapan yang mengintegrasikan aspek teknis, kreatif, dan analitis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    92,
    'ARS',
    'Artistic Realistic Social (ARS)',
    'ARS menggabungkan kreativitas, kemampuan teknis praktis, dan kepedulian terhadap orang. Ini menciptakan fasilitator kreatif yang terampil secara teknis dan peduli. Pikirkan terapis seni dengan keterampilan teknis tinggi, instruktur seni yang sangat terampil, atau fasilitator lokakarya yang mahir dalam berbagai medium. Kamu membantu orang mengekspresikan diri secara kreatif dengan memberikan panduan teknis yang solid dan dukungan yang peduli.',
    '["Pengajaran kreatif yang terampil: Dapat mengajarkan teknik sambil mendorong ekspresi individual yang otentik", "Pembuatan ruang yang aman: Menciptakan lingkungan di mana orang merasa nyaman bereksperimen tanpa takut gagal", "Adaptabilitas teknis: Dapat menyesuaikan teknik untuk berbagai tingkat keterampilan dan kebutuhan individual", "Demonstrasi yang efektif: Terampil dalam menunjukkan teknik dengan cara yang mudah diikuti dan dipahami"]'::jsonb,
    '["Keseimbangan teknik dengan ekspresi: Terlalu fokus pada teknik bisa menghambat kreativitas, terlalu sedikit bisa membuat frustrasi", "Investasi emosional dalam perjalanan orang: Sangat peduli tentang perjalanan kreatif orang bisa secara emosional menguras", "Keterbatasan sumber daya: Memerlukan material dan ruang yang memadai untuk fasilitasi yang efektif"]'::jsonb,
    '["Instruksi yang diferensiasi: Berikan tingkat dukungan teknis yang berbeda berdasarkan kebutuhan individual", "Fokus pada proses bukan produk: Tekankan pembelajaran dan eksplorasi, bukan kesempurnaan hasil akhir", "Membangun komunitas pembelajaran: Ciptakan lingkungan di mana peserta saling mendukung dan belajar bersama"]'::jsonb,
    '["Studio seni komunitas: Ruang yang menyediakan akses ke material dan instruksi berkualitas", "Terapi seni: Penggunaan terapeutik kreativitas dengan panduan terampil dan peduli", "Pendidikan seni: Mengajar seni dengan fokus pada pengembangan keterampilan dan ekspresi personal"]'::jsonb,
    '["Demo sambil mendorong: Menunjukkan teknik sambil mendorong interpretasi dan ekspresi personal", "Umpan balik yang membangun: Mengakui usaha dan memberikan saran teknis yang konstruktif dan mendukung", "Berbagi antusiasme: Antusiasme kamu untuk medium kreatif menginspirasi dan memotivasi orang lain"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    149,
    'CRA',
    'Conventional Realistic Artistic (CRA)',
    'CRA menggabungkan kecintaan pada sistem, kemampuan teknis praktis, dan kreativitas. Ini menciptakan pengrajin atau produsen yang sangat terorganisir dengan sentuhan kreatif. Pikirkan desainer produk industri dengan sistem produksi ketat, pengrajin dengan workshop yang rapi, atau produser konten dengan alur kerja yang sistematis. Kamu menciptakan karya yang indah dan fungsional melalui proses yang terorganisir dengan sempurna.',
    '["Produksi kreatif yang efisien: Memiliki sistem yang memungkinkan output kreatif berkualitas secara konsisten", "Kualitas yang dapat diprediksi: Setiap karya memenuhi standar karena kontrol kualitas yang sistematis", "Dokumentasi proses: Alur kerja terdokumentasi dengan baik untuk pembelajaran dan replikasi", "Keseimbangan fungsi dan estetika: Produk yang tidak hanya bekerja dengan baik tetapi juga terlihat bagus"]'::jsonb,
    '["Kekakuan dalam kreativitas: Sistem yang ketat bisa membatasi eksplorasi kreatif spontan", "Perfeksionisme tiga dimensi: Ingin sempurna secara teknis, terorganisir, dan indah secara visual", "Resistensi terhadap eksperimen: Proses yang terbukti membuat sulit mencoba pendekatan baru"]'::jsonb,
    '["Waktu untuk eksplorasi: Sisihkan waktu khusus untuk eksperimen di luar produksi reguler", "Iterasi bertahap: Coba variasi kecil dalam sistem yang ada sebelum perubahan besar", "Dokumentasi pembelajaran: Simpan catatan tentang eksperimen untuk referensi masa depan"]'::jsonb,
    '["Desain produk dengan manufaktur: Perusahaan yang menangani desain dan produksi", "Studio kerajinan dengan sistem: Workshop yang menggabungkan kreativitas dengan organisasi", "Produksi konten: Media atau konten yang memerlukan kualitas konsisten dengan kreativitas"]'::jsonb,
    '["Presentasi terstruktur: Menunjukkan karya dengan penjelasan proses yang jelas", "Standar tinggi: Ekspektasi jelas tentang kualitas teknis dan estetika", "Apresiasi detail: Perhatian pada kualitas pengerjaan dan organisasi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    150,
    'CRE',
    'Conventional Realistic Enterprising (CRE)',
    'CRE menggabungkan kecintaan pada sistem, kemampuan teknis praktis, dan ambisi untuk hasil. Ini menciptakan manajer operasional yang sangat efektif. Pikirkan direktur operasi manufaktur, manajer rantai pasokan senior, atau pemilik bisnis layanan teknis yang berkembang. Kamu memahami pekerjaan teknis, tahu cara mengorganisirnya dengan efisien, dan memiliki dorongan kuat untuk mencapai target yang ambisius.',
    '["Kepemimpinan operasional yang kuat: Mengelola operasi teknis dengan fokus jelas pada efisiensi dan hasil", "Sistem produksi yang dioptimalkan: Membangun proses yang memaksimalkan output berkualitas", "Eksekusi yang dapat diprediksi: Menciptakan operasi yang memberikan hasil konsisten dan terukur", "Pertumbuhan yang terkelola: Mengembangkan operasi dengan cara yang sistematis dan berkelanjutan"]'::jsonb,
    '["Fokus berlebih pada efisiensi jangka pendek: Mengoptimalkan metrik saat ini bisa mengabaikan inovasi", "Kekakuan sistem: Proses yang sangat terstruktur bisa menghambat adaptasi", "Tekanan pada tim: Dorongan untuk hasil bisa menciptakan lingkungan yang sangat menuntut"]'::jsonb,
    '["Keterlibatan tim dalam perbaikan: Libatkan orang yang melakukan pekerjaan dalam merancang sistem", "Keseimbangan metrik: Ukur produktivitas, kualitas, keselamatan, dan kepuasan tim", "Investasi jangka panjang: Alokasikan sumber daya untuk peningkatan proses berkelanjutan"]'::jsonb,
    '["Operasi manufaktur: Pabrik atau fasilitas produksi dalam peran kepemimpinan", "Logistik dan distribusi: Mengelola pergerakan barang dalam sistem kompleks", "Layanan teknis berskala: Bisnis yang menyediakan layanan teknis kepada banyak pelanggan"]'::jsonb,
    '["Komunikasi berbasis metrik: Diskusi fokus pada angka kinerja dan target", "Standar yang tegas: Ekspektasi jelas tentang kualitas dan produktivitas", "Rapat singkat berorientasi aksi: Identifikasi masalah, putuskan solusi, lanjutkan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    151,
    'CRI',
    'Conventional Realistic Investigative (CRI)',
    'CRI menggabungkan kecintaan pada sistem, kemampuan teknis praktis, dan keingintahuan analitis. Ini menciptakan profesional teknis yang sangat metodis dan berbasis riset. Pikirkan ilmuwan laboratorium dengan dokumentasi ketat, insinyur kualitas dengan fokus riset, atau teknisi senior yang mengembangkan prosedur standar. Kamu melakukan pekerjaan teknis dengan ketelitian ilmiah dan mendokumentasikan semuanya secara sistematis.',
    '["Riset teknis yang dapat direproduksi: Melakukan pekerjaan dengan metodologi yang memungkinkan verifikasi", "Dokumentasi yang komprehensif: Membuat catatan menyeluruh tentang proses, hasil, dan pembelajaran", "Validasi yang ketat: Menguji setiap aspek dengan teliti sebelum menerima sebagai valid", "Pengembangan standar: Terampil dalam menciptakan metode dan spesifikasi teknis"]'::jsonb,
    '["Lambat dalam lingkungan cepat: Pendekatan metodis membutuhkan waktu yang mungkin tidak tersedia", "Frustrasi dengan pendekatan coba-coba: Tidak nyaman ketika orang mengabaikan metodologi", "Perfeksionisme yang menghambat: Standar sangat tinggi bisa menunda penyelesaian"]'::jsonb,
    '["Protokol bertingkat: Kembangkan prosedur penuh dan prosedur cepat untuk situasi berbeda", "Prioritas berbasis kritikalitas: Fokuskan ketelitian penuh pada area yang paling penting", "Komunikasi nilai: Bantu orang lain memahami mengapa metodologi ketat penting"]'::jsonb,
    '["Laboratorium riset teknis: Fasilitas di mana pekerjaan teknis dilakukan dengan standar ilmiah", "Jaminan kualitas berbasis riset: Departemen yang memvalidasi dengan metodologi ketat", "Pengembangan standar: Organisasi yang menciptakan spesifikasi untuk industri"]'::jsonb,
    '["Dokumentasi metodologis: Laporan yang menjelaskan proses dengan detail", "Diskusi teknis mendalam: Percakapan yang mengeksplorasi detail metodologi", "Peer review aktif: Partisipasi dalam proses tinjauan ilmiah"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    152,
    'CRS',
    'Conventional Realistic Social (CRS)',
    'CRS menggabungkan kecintaan pada sistem, kemampuan teknis praktis, dan kepedulian terhadap orang. Ini menciptakan penyedia layanan teknis yang sangat terorganisir dan peduli. Pikirkan manajer operasi di klinik kesehatan, koordinator layanan fasilitas, atau supervisor layanan dukungan teknis. Kamu memastikan sistem teknis berjalan lancar untuk melayani kebutuhan orang secara konsisten.',
    '["Layanan yang dapat diprediksi: Memberikan dukungan teknis yang konsisten melalui prosedur jelas", "Sistem berorientasi pengguna: Merancang operasi teknis yang memudahkan orang mendapatkan bantuan", "Dokumentasi yang ramah pengguna: Membuat panduan yang terstruktur tetapi mudah dipahami", "Koordinasi tim layanan: Memimpin tim teknis dengan fokus pada kualitas layanan"]'::jsonb,
    '["Ketegangan prosedur versus fleksibilitas: Ingin mengikuti sistem tetapi situasi individual butuh penyimpangan", "Beban dari tuntutan ganda: Mempertahankan standar teknis sambil responsif terhadap kebutuhan manusia", "Frustrasi dengan sistem kaku: Menyadari ketika prosedur menghalangi layanan yang baik"]'::jsonb,
    '["Prosedur dengan eskalasi: Sistem dengan jalur jelas untuk menangani situasi di luar standar", "Pelatihan orientasi layanan: Pastikan tim teknis memahami mereka melayani orang", "Umpan balik pengguna: Kumpulkan masukan dari orang yang dilayani untuk perbaikan"]'::jsonb,
    '["Operasi layanan kesehatan: Manajemen fasilitas atau operasi dalam pengaturan perawatan", "Manajemen fasilitas layanan: Peran yang memastikan infrastruktur mendukung layanan", "Layanan dukungan terstruktur: Departemen yang memberikan bantuan teknis sistematis"]'::jsonb,
    '["Komunikasi yang jelas dan peduli: Menjelaskan prosedur teknis dengan empati", "Responsif terhadap masalah: Menindaklanjuti ketika sistem tidak melayani dengan baik", "Koordinasi antar departemen: Bekerja dengan berbagai unit untuk layanan mulus"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    141,
    'CEA',
    'Conventional Enterprising Artistic (CEA)',
    'CEA menggabungkan kecintaan pada sistem, ambisi untuk kesuksesan, dan kreativitas. Ini menciptakan pemimpin bisnis kreatif yang sangat terorganisir. Pikirkan COO di agensi kreatif, manajer produksi di studio, atau pemilik bisnis desain dengan operasi ketat. Kamu ingin kesuksesan komersial melalui operasi kreatif yang efisien dan terkelola dengan sangat baik.',
    '["Operasi kreatif yang efisien: Membangun sistem yang memungkinkan produktivitas tinggi tanpa mengorbankan kualitas", "Manajemen sumber daya yang efektif: Mengoptimalkan penggunaan waktu, talenta, dan material", "Pertumbuhan yang terkelola: Mengembangkan bisnis kreatif dengan cara yang berkelanjutan", "Prediktabilitas dalam kreativitas: Menciptakan sistem yang memberikan output konsisten"]'::jsonb,
    '["Ketegangan sistem versus spontanitas: Terlalu banyak proses bisa menghambat kreativitas", "Resistensi dari talenta kreatif: Orang kreatif mungkin menolak sistem yang terasa membatasi", "Keseimbangan efisiensi dengan kualitas: Tekanan produktivitas bisa mengorbankan keunggulan"]'::jsonb,
    '["Libatkan talenta dalam desain sistem: Buat proses bersama dengan orang kreatif", "Fleksibilitas terstruktur: Sistem yang memberikan kerangka tetapi memungkinkan ruang kreatif", "Metrik yang bermakna: Ukur kualitas kreatif, bukan hanya output atau efisiensi"]'::jsonb,
    '["Produksi kreatif berskala: Studio atau agensi dengan volume pekerjaan tinggi", "Operasi media: Perusahaan yang memproduksi konten kreatif secara reguler", "Manajemen bisnis kreatif: Peran operasional dalam organisasi kreatif"]'::jsonb,
    '["Rapat terstruktur tentang kreativitas: Diskusi kreatif dengan agenda dan timeline", "Komunikasi berbasis proses: Menjelaskan bagaimana sistem mendukung kualitas", "Pelaporan kinerja: Update reguler tentang produktivitas dan pencapaian"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    142,
    'CEI',
    'Conventional Enterprising Investigative (CEI)',
    'CEI menggabungkan kecintaan pada sistem, ambisi untuk hasil, dan keingintahuan analitis. Ini menciptakan pemimpin yang menggunakan data dan proses untuk mendorong kesuksesan organisasi. Pikirkan direktur analitik bisnis, konsultan transformasi berbasis data, atau kepala strategi operasional. Kamu ingin mencapai target ambisius melalui keputusan berbasis data yang didukung sistem yang dioptimalkan.',
    '["Optimasi berbasis bukti: Menggunakan data dan analisis untuk mengidentifikasi perbaikan", "Sistem pembelajaran: Membangun infrastruktur yang memungkinkan adaptasi berkelanjutan", "Kepemimpinan yang kredibel: Membuat keputusan dengan otoritas data dan riset", "Perubahan yang terukur: Mendorong transformasi dengan pelacakan kemajuan yang jelas"]'::jsonb,
    '["Terlalu bergantung pada metrik: Tidak semua yang penting dapat diukur dengan mudah", "Kompleksitas sistem analitik: Dapat membangun infrastruktur data yang terlalu rumit", "Tidak sabar dengan proses: Ingin hasil cepat tetapi sistem yang baik membutuhkan waktu"]'::jsonb,
    '["Mulai dengan metrik penting: Fokus pada indikator yang benar-benar menangkap kesuksesan", "Keseimbangan kuantitatif dan kualitatif: Gunakan berbagai jenis data", "Kemenangan cepat: Identifikasi perbaikan yang dapat memberikan hasil cepat"]'::jsonb,
    '["Konsultasi transformasi: Membantu organisasi dengan perubahan berbasis data", "Analitik bisnis: Departemen yang menggunakan data untuk strategi dan operasi", "Kepemimpinan operasional: Peran yang mengelola dengan fokus pada perbaikan berbasis bukti"]'::jsonb,
    '["Presentasi data yang persuasif: Menggunakan analisis untuk membangun kasus perubahan", "Tinjauan kinerja reguler: Rapat untuk evaluasi kemajuan berdasarkan metrik", "Dokumentasi pembelajaran: Mencatat wawasan untuk pembelajaran organisasi"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    143,
    'CER',
    'Conventional Enterprising Realistic (CER)',
    'CER menggabungkan kecintaan pada sistem, ambisi untuk hasil, dan kemampuan teknis praktis. Ini menciptakan pemimpin operasional yang sangat efektif dalam lingkungan teknis. Pikirkan direktur manufaktur, VP operasi di perusahaan teknis, atau pemilik bisnis konstruksi yang berkembang. Kamu memahami pekerjaan teknis, tahu cara mengorganisirnya secara efisien, dan memiliki dorongan untuk mencapai target ambisius.',
    '["Kepemimpinan operasional yang kuat: Mengelola operasi teknis dengan fokus pada hasil", "Sistem produksi yang dioptimalkan: Membangun proses yang memaksimalkan output berkualitas", "Pertumbuhan yang terkelola: Mengembangkan operasi teknis dengan cara sistematis", "Eksekusi yang dapat diprediksi: Menciptakan operasi yang memberikan hasil konsisten"]'::jsonb,
    '["Fokus berlebih pada efisiensi: Mengoptimalkan produktivitas jangka pendek bisa mengabaikan kesejahteraan", "Kekakuan sistem: Proses yang terlalu ketat bisa menghambat adaptasi", "Resistensi terhadap perubahan: Berinvestasi dalam sistem yang ada membuat sulit menerima pendekatan baru"]'::jsonb,
    '["Keterlibatan tim: Libatkan orang yang melakukan pekerjaan dalam merancang perbaikan", "Peningkatan berkelanjutan: Bangun kultur di mana sistem terus disempurnakan", "Keseimbangan metrik: Ukur produktivitas, kualitas, keselamatan, dan kepuasan"]'::jsonb,
    '["Operasi manufaktur: Pabrik atau fasilitas produksi dalam peran kepemimpinan", "Konstruksi atau teknik: Manajemen proyek atau operasi dalam industri pembangunan", "Logistik dan rantai pasokan: Mengelola pergerakan barang dalam sistem kompleks"]'::jsonb,
    '["Komunikasi metrik yang jelas: Diskusi fokus pada angka, target, dan kinerja", "Standar yang tegas: Ekspektasi jelas tentang kualitas dan produktivitas", "Rapat singkat berorientasi aksi: Identifikasi masalah dan putuskan solusi cepat"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    144,
    'CES',
    'Conventional Enterprising Social (CES)',
    'CES menggabungkan kecintaan pada sistem, ambisi untuk dampak, dan kepedulian terhadap orang. Ini menciptakan pemimpin organisasi layanan yang efisien dan berorientasi pertumbuhan. Pikirkan CEO organisasi layanan kesehatan, direktur jaringan layanan sosial, atau pemimpin franchise yang fokus pada layanan pelanggan. Kamu ingin melayani orang secara efektif dalam skala besar melalui sistem yang terkelola dengan sangat baik.',
    '["Layanan berskala: Membangun sistem yang memungkinkan layanan berkualitas kepada banyak orang", "Manajemen pertumbuhan: Mengembangkan organisasi layanan sambil mempertahankan kualitas", "Efisiensi operasional: Mengoptimalkan proses untuk melayani lebih banyak orang", "Kepemimpinan yang akuntabel: Mengelola dengan transparansi dan pengukuran dampak"]'::jsonb,
    '["Ketegangan efisiensi versus personalisasi: Sistem untuk skala bisa membuat layanan tidak personal", "Tekanan pertumbuhan: Berkembang terlalu cepat bisa mengorbankan kualitas", "Kompleksitas regulasi: Layanan sosial sering sangat diatur"]'::jsonb,
    '["Pertumbuhan dengan kualitas: Kembangkan dengan kecepatan yang memungkinkan pemeliharaan standar", "Desentralisasi dengan standar: Berikan otonomi lokal dalam kerangka kualitas yang jelas", "Umpan balik pelanggan: Kumpulkan dan gunakan masukan dari orang yang dilayani"]'::jsonb,
    '["Organisasi layanan kesehatan: Jaringan klinik, rumah sakit, atau penyedia layanan", "Franchise layanan: Bisnis yang memberikan layanan konsisten di banyak lokasi", "Jaringan layanan sosial: Organisasi yang mengkoordinasikan layanan di wilayah luas"]'::jsonb,
    '["Komunikasi berorientasi pelanggan: Fokus pada bagaimana sistem melayani kebutuhan", "Pelaporan kinerja layanan: Update reguler tentang metrik kepuasan dan kualitas", "Manajemen pemangku kepentingan: Koordinasi dengan regulator, pendana, dan komunitas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    145,
    'CIA',
    'Conventional Investigative Artistic (CIA)',
    'CIA menggabungkan kecintaan pada sistem, keingintahuan analitis, dan kreativitas. Ini menciptakan peneliti atau analis yang mengomunikasikan temuan dengan cara kreatif dalam kerangka sistematis. Pikirkan spesialis visualisasi data dengan proses ketat, kurator museum dengan metodologi riset, atau peneliti yang membuat output kreatif dengan dokumentasi lengkap. Kamu menggabungkan ketelitian analitis dengan ekspresi kreatif, semua terorganisir dengan baik.',
    '["Komunikasi data yang kreatif: Membuat visualisasi yang menyajikan temuan dengan cara menarik", "Riset dengan dokumentasi visual: Mendokumentasikan proses riset dengan cara sistematis dan kreatif", "Proses yang dapat diajarkan: Karena sistematis, dapat mengajarkan pendekatan kepada orang lain", "Ketelitian dengan aksesibilitas: Membuat riset kompleks dapat dipahami tanpa kehilangan ketelitian"]'::jsonb,
    '["Waktu untuk kesempurnaan: Menggabungkan analisis, organisasi, dan output kreatif membutuhkan waktu", "Ketegangan struktur versus kreativitas: Kebutuhan sistem bisa membatasi aliran kreatif", "Perfeksionisme multidimensi: Ingin riset solid, presentasi indah, dan semua terdokumentasi sempurna"]'::jsonb,
    '["Template kreatif: Kembangkan kerangka yang memberikan struktur tetapi memungkinkan ekspresi kreatif", "Fase terpisah: Waktu untuk analisis, waktu untuk kreativitas, waktu untuk dokumentasi", "Kolaborasi: Bekerja dengan desainer atau seniman untuk aspek kreatif"]'::jsonb,
    '["Visualisasi data: Peran yang mengubah analisis kompleks menjadi komunikasi visual", "Riset dan kurasi: Posisi di museum atau arsip yang menggabungkan riset dengan presentasi", "Komunikasi sains: Membuat konten yang menjelaskan riset untuk audiens luas"]'::jsonb,
    '["Presentasi visual yang informatif: Menyajikan data dengan visualisasi menarik dan akurat", "Dokumentasi proses yang kreatif: Berbagi metodologi dengan cara yang dapat diakses", "Workshop yang terstruktur: Mengajarkan teknik dengan kerangka yang jelas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    146,
    'CIE',
    'Conventional Investigative Enterprising (CIE)',
    'CIE menggabungkan kecintaan pada sistem, keingintahuan analitis, dan ambisi untuk hasil. Ini menciptakan pemimpin strategis yang menggunakan data dan proses untuk mendorong kesuksesan. Pikirkan direktor analitik dengan fokus pertumbuhan, konsultan transformasi berbasis bukti, atau kepala strategi data. Kamu ingin mencapai target ambisius melalui keputusan berbasis riset yang didukung sistem yang terorganisir.',
    '["Strategi berbasis data yang sistematis: Menggunakan analisis untuk menginformasikan keputusan dan mengimplementasikan melalui proses jelas", "Manajemen kinerja yang terukur: Membangun sistem pelacakan yang memberikan wawasan real-time", "Optimasi berkelanjutan: Menggunakan data untuk mengidentifikasi peluang perbaikan", "Kepemimpinan yang akuntabel: Mengelola dengan transparansi berdasarkan metrik yang jelas"]'::jsonb,
    '["Terlalu bergantung pada data: Tidak semua yang penting dapat diukur", "Kompleksitas sistem: Dapat menciptakan infrastruktur data yang terlalu rumit", "Tidak sabar dengan proses: Ingin hasil cepat tetapi membangun sistem membutuhkan waktu"]'::jsonb,
    '["Keseimbangan metrik: Gunakan kombinasi indikator kuantitatif dan kualitatif", "Mulai sederhana: Bangun sistem analitik secara bertahap", "Komunikasi wawasan: Pastikan data diterjemahkan menjadi rekomendasi yang dapat ditindaklanjuti"]'::jsonb,
    '["Analitik bisnis: Departemen yang menggunakan data untuk menginformasikan strategi", "Konsultasi strategi: Firma yang membantu organisasi dengan transformasi berbasis data", "Kepemimpinan operasional: Peran yang mengelola dengan fokus berat pada metrik"]'::jsonb,
    '["Presentasi data yang persuasif: Menggunakan analisis untuk membangun kasus strategis", "Tinjauan kinerja sistematis: Rapat reguler untuk mengevaluasi kemajuan", "Dokumentasi keputusan: Mencatat alasan di balik keputusan strategis"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    147,
    'CIR',
    'Conventional Investigative Realistic (CIR)',
    'CIR menggabungkan kecintaan pada sistem, keingintahuan analitis, dan kemampuan teknis praktis. Ini menciptakan profesional teknis yang sangat metodis dan berbasis riset. Pikirkan ilmuwan laboratorium senior, insinyur kualitas dengan fokus riset, atau spesialis yang mengembangkan standar teknis. Kamu melakukan pekerjaan teknis dengan ketelitian ilmiah dan mendokumentasikan semuanya dengan sangat sistematis.',
    '["Riset teknis yang ketat: Melakukan pekerjaan dengan metodologi yang dapat direplikasi", "Dokumentasi yang menyeluruh: Membuat catatan lengkap yang memungkinkan verifikasi", "Validasi sistematis: Menguji setiap aspek dengan teliti sebelum menerima sebagai valid", "Pengembangan standar: Terampil dalam menciptakan spesifikasi dan prosedur teknis"]'::jsonb,
    '["Lambat dalam lingkungan cepat: Pendekatan metodis membutuhkan waktu yang mungkin tidak tersedia", "Frustrasi dengan jalan pintas: Tidak nyaman ketika orang mengabaikan metodologi yang tepat", "Perfeksionisme yang melumpuhkan: Standar sangat tinggi bisa menunda kemajuan"]'::jsonb,
    '["Protokol bertingkat: Kembangkan prosedur yang disederhanakan untuk situasi mendesak", "Prioritas berbasis risiko: Fokuskan ketelitian penuh pada area paling kritis", "Komunikasi nilai: Bantu orang lain memahami mengapa metodologi ketat penting"]'::jsonb,
    '["Laboratorium riset: Fasilitas di mana pekerjaan teknis dilakukan dengan standar ilmiah", "Jaminan kualitas: Departemen yang memvalidasi pekerjaan teknis dengan ketelitian", "Pengembangan standar: Organisasi yang menciptakan spesifikasi untuk industri"]'::jsonb,
    '["Laporan metodologis: Dokumentasi yang detail tentang proses dan temuan", "Diskusi teknis mendalam: Percakapan yang mengeksplorasi detail dan validitas", "Peer review: Partisipasi aktif dalam proses tinjauan ilmiah"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    148,
    'CIS',
    'Conventional Investigative Social (CIS)',
    'CIS menggabungkan kecintaan pada sistem, keingintahuan analitis, dan kepedulian terhadap orang. Ini menciptakan peneliti atau evaluator layanan sosial yang sangat sistematis. Pikirkan evaluator program dengan dokumentasi ketat, peneliti kebijakan kesehatan, atau analis yang mempelajari sistem layanan. Kamu menggunakan riset untuk memahami bagaimana sistem melayani orang dan bagaimana meningkatkannya secara sistematis.',
    '["Evaluasi yang ketat: Mengukur dampak layanan dengan metodologi solid dan dokumentasi lengkap", "Analisis sistem untuk perbaikan: Mengidentifikasi bagaimana proses dapat ditingkatkan berdasarkan data", "Riset implementasi: Memahami tidak hanya apa yang efektif tetapi bagaimana mengimplementasikannya", "Dokumentasi pembelajaran: Membuat catatan menyeluruh untuk pembelajaran organisasi"]'::jsonb,
    '["Ketegangan ketelitian versus kecepatan: Evaluasi yang baik membutuhkan waktu tetapi organisasi butuh jawaban cepat", "Temuan sulit: Data kadang menunjukkan program tidak bekerja seperti diharapkan", "Kesenjangan riset-praktik: Rekomendasi tidak selalu mudah diimplementasikan"]'::jsonb,
    '["Evaluasi formatif: Lakukan evaluasi selama program berjalan untuk memungkinkan penyesuaian", "Komunikasi sensitif: Sampaikan temuan dengan cara konstruktif yang fokus pada pembelajaran", "Keterlibatan praktisi: Libatkan staf program dalam riset untuk relevansi dan adopsi"]'::jsonb,
    '["Evaluasi program sosial: Organisasi yang menilai efektivitas layanan", "Riset kebijakan kesehatan: Institusi yang mempelajari sistem perawatan", "Analisis data nirlaba: Peran yang menggunakan data untuk meningkatkan layanan sosial"]'::jsonb,
    '["Laporan yang terstruktur: Dokumentasi yang terorganisir dengan jelas untuk pengambilan keputusan", "Kolaborasi dengan praktisi: Bekerja erat dengan orang yang memberikan layanan", "Presentasi temuan yang dapat ditindaklanjuti: Menyajikan data dengan rekomendasi yang jelas"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    153,
    'CSA',
    'Conventional Social Artistic (CSA)',
    'CSA menggabungkan kecintaan pada sistem, kepedulian terhadap orang, dan kreativitas. Ini menciptakan fasilitator program kreatif yang sangat terorganisir. Pikirkan manajer program seni komunitas, koordinator acara budaya, atau kurator pendidikan di museum. Kamu membawa orang bersama melalui pengalaman kreatif yang dirancang dan dikelola dengan sangat baik.',
    '["Program kreatif yang dapat diakses: Merancang pengalaman kreatif dengan struktur yang memungkinkan partisipasi luas", "Manajemen acara yang detail: Mengorganisir setiap aspek program atau acara kreatif dengan teliti", "Dokumentasi untuk keberlanjutan: Membuat catatan yang memungkinkan program berhasil direplikasi", "Koordinasi yang efektif: Mengelola hubungan dengan seniman, peserta, sponsor, dan mitra"]'::jsonb,
    '["Ketegangan struktur versus spontanitas: Seniman atau peserta mungkin menginginkan lebih banyak kebebasan", "Beban administratif: Mengorganisir program kreatif memerlukan banyak pekerjaan logistik", "Keseimbangan inklusivitas dengan kualitas: Ingin program dapat diakses semua orang tetapi juga mempertahankan standar"]'::jsonb,
    '["Konsultasi dengan seniman: Libatkan kreator dalam merancang struktur untuk memastikan sistem mendukung", "Sistem yang efisien: Kembangkan template dan prosedur yang menghemat waktu", "Evaluasi partisipatif: Kumpulkan umpan balik dari semua pihak untuk terus menyempurnakan"]'::jsonb,
    '["Institusi budaya: Museum, galeri, atau pusat seni dengan program pendidikan", "Organisasi seni komunitas: Program yang menyediakan akses terorganisir ke seni", "Manajemen acara budaya: Peran yang mengorganisir festival, pameran, atau program kreatif"]'::jsonb,
    '["Komunikasi logistik yang jelas: Memberikan informasi terstruktur tentang program dan persyaratan", "Hubungan yang hangat: Mempertahankan koneksi personal sambil mengelola sistem", "Dokumentasi visual: Menggunakan foto dan media untuk mendokumentasikan dan mempromosikan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    154,
    'CSE',
    'Conventional Social Enterprising (CSE)',
    'CSE menggabungkan kecintaan pada sistem, kepedulian terhadap orang, dan ambisi untuk dampak. Ini menciptakan pemimpin organisasi sosial yang efisien dan berorientasi pertumbuhan. Pikirkan direktur eksekutif organisasi nirlaba, manajer program layanan sosial yang berfokus pada hasil, atau konsultan pengembangan organisasi sosial. Kamu ingin melayani orang secara efektif dalam skala besar melalui sistem yang terorganisir dengan baik.',
    '["Manajemen organisasi yang efektif: Membangun dan mengelola sistem yang memungkinkan layanan berkembang", "Orientasi pada hasil terukur: Menetapkan target yang jelas dan melacak kemajuan menuju dampak", "Penggalangan sumber daya: Terampil dalam mendapatkan pendanaan dan sumber daya untuk misi sosial", "Kepemimpinan yang sistematis: Memimpin dengan struktur yang jelas sambil mempertahankan fokus pada orang"]'::jsonb,
    '["Tekanan antara efisiensi dan kualitas layanan: Sistem untuk efisiensi kadang terasa tidak personal", "Tuntutan akuntabilitas: Harus membuktikan dampak kepada pendana sambil tetap melayani dengan baik", "Kelelahan kepemimpinan: Bertanggung jawab untuk keberlanjutan organisasi dan kualitas layanan"]'::jsonb,
    '["Metrik yang bermakna: Kembangkan indikator yang benar-benar menangkap dampak, bukan hanya output", "Budaya berbasis nilai: Pastikan efisiensi tidak mengorbankan nilai inti organisasi", "Delegasi yang memberdayakan: Bangun tim kepemimpinan yang kuat untuk berbagi beban"]'::jsonb,
    '["Kepemimpinan organisasi nirlaba: Peran eksekutif dalam organisasi layanan sosial", "Manajemen program berskala: Program sosial besar yang melayani banyak orang", "Konsultasi organisasi sosial: Membantu organisasi layanan meningkatkan efektivitas"]'::jsonb,
    '["Komunikasi berbasis hasil: Berbicara tentang dampak, target, dan pencapaian", "Jaringan strategis: Membangun hubungan dengan pendana, mitra, dan pemimpin sektor", "Transparansi akuntabilitas: Komunikasi terbuka tentang penggunaan sumber daya dan hasil"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    155,
    'CSI',
    'Conventional Social Investigative (CSI)',
    'CSI menggabungkan kecintaan pada sistem, kepedulian terhadap orang, dan keingintahuan analitis. Ini menciptakan peneliti atau evaluator layanan sosial yang sistematis. Pikirkan evaluator program sosial, peneliti kebijakan dengan fokus implementasi, atau analis data di organisasi layanan. Kamu menggunakan riset untuk memahami bagaimana sistem melayani orang dan bagaimana meningkatkannya.',
    '["Evaluasi program yang ketat: Mengukur dampak layanan sosial dengan metodologi yang solid", "Analisis berbasis data untuk perbaikan: Mengidentifikasi area peningkatan berdasarkan bukti sistematis", "Dokumentasi pembelajaran: Mendokumentasikan apa yang berhasil dan tidak untuk pembelajaran organisasi", "Riset implementasi: Memahami tidak hanya apa yang efektif tetapi bagaimana mengimplementasikannya dalam praktik"]'::jsonb,
    '["Ketegangan antara ketelitian dan kecepatan: Evaluasi yang baik membutuhkan waktu tetapi organisasi butuh jawaban cepat", "Temuan sulit: Kadang data menunjukkan program tidak bekerja seperti yang diharapkan", "Kesenjangan riset-praktik: Rekomendasi berbasis riset tidak selalu mudah diimplementasikan dalam kenyataan"]'::jsonb,
    '["Evaluasi formatif: Lakukan evaluasi selama program berjalan untuk memungkinkan penyesuaian real-time", "Komunikasi yang sensitif: Sampaikan temuan dengan cara yang konstruktif, fokus pada pembelajaran", "Keterlibatan praktisi: Libatkan staf program dalam riset untuk memastikan relevansi dan adopsi"]'::jsonb,
    '["Evaluasi program sosial: Departemen atau firma yang mengevaluasi efektivitas layanan", "Riset kebijakan: Institusi yang mempelajari implementasi kebijakan sosial", "Analisis data nirlaba: Peran yang menggunakan data untuk meningkatkan layanan"]'::jsonb,
    '["Presentasi temuan yang dapat ditindaklanjuti: Menyajikan data dengan rekomendasi yang jelas", "Kolaborasi dengan praktisi: Bekerja erat dengan orang yang memberikan layanan", "Laporan yang terstruktur: Dokumentasi yang terorganisir dengan baik untuk pengambilan keputusan"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);

INSERT INTO riasec_codes (
    id,
    riasec_code,
    riasec_title,
    riasec_description,
    strengths,
    challenges,
    strategies,
    work_environments,
    interaction_styles,
    congruent_code_ids,
    created_at,
    updated_at
) VALUES (
    156,
    'CSR',
    'Conventional Social Realistic (CSR)',
    'CSR menggabungkan kecintaan pada sistem, kepedulian terhadap orang, dan kemampuan teknis praktis. Ini menciptakan penyedia layanan teknis yang terorganisir dan peduli. Pikirkan manajer operasi di klinik kesehatan, koordinator layanan fasilitas, atau supervisor layanan pelanggan teknis. Kamu memastikan sistem teknis berjalan lancar untuk melayani orang dengan lebih baik, dan kamu melakukannya dengan cara yang terorganisir dan dapat diandalkan.',
    '["Layanan teknis yang dapat diandalkan: Memberikan dukungan teknis yang konsisten dan terorganisir kepada orang yang membutuhkan", "Sistem berorientasi pengguna: Merancang prosedur teknis yang tidak hanya efisien tetapi juga mempertimbangkan kebutuhan pengguna", "Dokumentasi yang mudah diakses: Membuat panduan teknis dan dokumentasi yang terstruktur dengan baik dan dapat dipahami orang awam", "Pelatihan sistematis: Mengajarkan keterampilan teknis dengan cara yang terstruktur dan mendukung"]'::jsonb,
    '["Frustrasi dengan permintaan yang melanggar prosedur: Ingin membantu tetapi juga ingin mengikuti sistem yang tepat", "Konflik antara efisiensi dan perhatian personal: Sistem dirancang untuk efisiensi tetapi orang kadang butuh perhatian individual", "Kelelahan dari tuntuan ganda: Menjaga standar teknis dan sistem sambil juga responsif terhadap kebutuhan manusia bisa menguras energi"]'::jsonb,
    '["Bangun fleksibilitas terstruktur: Buat sistem dengan ruang untuk penyesuaian kasus per kasus dalam parameter yang jelas", "Dokumentasikan kasus khusus: Ketika membuat pengecualian, dokumentasikan alasannya untuk membangun basis pengetahuan", "Tetapkan jam konsultasi: Alokasikan waktu khusus untuk interaksi yang lebih personal, terpisah dari operasi rutin"]'::jsonb,
    '["Layanan teknis pelanggan: Departemen dukungan yang menyediakan bantuan teknis terorganisir kepada pengguna", "Manajemen fasilitas kesehatan: Peran yang memastikan peralatan dan sistem medis berfungsi untuk perawatan pasien", "Layanan dukungan pendidikan: Posisi yang memberikan dukungan teknis terorganisir untuk lingkungan belajar"]'::jsonb,
    '["Komunikasi teknis yang sabar: Menjelaskan hal teknis dengan cara yang terstruktur tetapi ramah dan mudah dipahami", "Prosedur yang manusiawi: Menegakkan prosedur tetapi dengan pemahaman terhadap situasi individual", "Tindak lanjut sistematis: Memeriksa kembali dengan orang untuk memastikan masalah terselesaikan, didokumentasikan dengan baik"]'::jsonb,
    '[]'::jsonb,
    NOW(),
    NOW()
);