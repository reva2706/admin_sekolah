// Beri tahu browser untuk memuat skrip Firebase versi v9
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

// Inisialisasi Firebase di Background Service Worker
firebase.initializeApp({
  apiKey: "AIzaSyB3_BlZbLyD1HeNZyZPDsAlNhlBqWDeUhU",
  authDomain: "pengaduansekolah-eb875.firebaseapp.com",
  projectId: "pengaduansekolah-eb875",
  storageBucket: "pengaduansekolah-eb875.firebasestorage.app",
  messagingSenderId: "265155033945",
  appId: "1:265155033945:web:87b10e00993670c2922a48",
  measurementId: "G-WN6RZCQHEL",
});

const messaging = firebase.messaging();

// Menangkap push notification saat background
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification.title || 'Laporan Baru Masuk!';
  const notificationOptions = {
    body: payload.notification.body || 'Ada siswa mengirimkan aspirasi baru.',
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
