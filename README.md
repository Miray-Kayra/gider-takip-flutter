#  Kişisel Gider Takip ve Bütçe Uygulaması

Bu proje, kullanıcıların günlük harcamalarını kaydedip aylık bütçelerini kolayca takip edebilmeleri amacıyla geliştirilmiş bir mobil uygulamadır.

##  Özellikler

* **Tam CRUD Desteği:** Yeni harcama ekleme, listeleme, güncelleme ve silme (CRUD) işlemleri.
* **Çift Filtreleme Mantığı:** Harcamaları hem *kategoriye* (Yemek, Ulaşım, Fatura vb.) hem de *seçilen aya* göre dinamik filtreleme.
* **Görsel Raporlama:** fl_chart kütüphanesi kullanılarak oluşturulan dinamik ve interaktif pasta grafik (Pie Chart) ile harcama dağılımı gösterimi.
* **Bütçe Takibi:** Kategori bazlı harcama limitleri ve bütçe durum göstergeleri.
* **Veri Doğrulaması (Validation):** Hatalı veya negatif tutar girişlerini engelleyen arayüz kontrolleri ve kullanıcı uyarı mekanizmaları.
* **Yerel Veri Saklama:** İnternet bağlantısı gerektirmeksizin SQLite altyapısı ile verilerin cihazda güvenli şekilde depolanması.

##  Teknolojiler ve Mimari

* **Dil:** Flutter & Dart
* **Mimari:** MVVM (Model-ViewModel-View)
* **State Management:** Provider (ChangeNotifier)
* **Veritabanı:** SQLite (sqflite)
* **Grafik Kütüphanesi:** fl_chart
* **Tarih Formatlama:** intl

##  Proje Dizin Yapısı

```text
lib/
├── models/
│   └── expense_model.dart        # Harcama veri modeli
├── repositories/
│   └── expense_repository.dart   # Veritabanı veri erişim katmanı
├── services/
│   └── database_helper.dart      # SQLite veritabanı kurulumu
├── viewmodels/
│   └── expense_viewmodel.dart    # İş mantığı ve durum yönetimi (MVVM)
├── views/
│   └── expense_list_view.dart    # Ana ekran ve UI bileşenleri
└── main.dart                     # Uygulama başlangıç noktası
``` 
