/**
 * Central configuration for Tamanina public web pages.
 * Edit these values in one place before uploading to your server.
 */
window.TAMANINA_SITE_CONFIG = {
  publisherAr: 'عبدالله عصام',
  publisherEn: 'Abdalluh Essam',
  supportEmail: 'abdallhesam100@gmail.com',
  effectiveDateAr: '25 نوفمبر 2026',
  effectiveDateEn: 'November 25, 2026',
  appVersion: '1.0.1',
};

(function () {
  const cfg = window.TAMANINA_SITE_CONFIG;
  const page = document.body.dataset.page || 'home';

  function detectInitialLang() {
    const param = new URLSearchParams(window.location.search).get('lang');
    if (param === 'ar' || param === 'en') return param;
    const saved = localStorage.getItem('tamanina_web_lang');
    if (saved === 'ar' || saved === 'en') return saved;
    return 'ar';
  }

  function detectInitialTheme() {
    const saved = localStorage.getItem('tamanina_web_theme');
    if (saved === 'light' || saved === 'dark') return saved;
    return window.matchMedia &&
      window.matchMedia('(prefers-color-scheme: dark)').matches
      ? 'dark'
      : 'light';
  }

  function navChip(href, key, labelAr, labelEn) {
    const active = page === key ? ' is-active' : '';
    return `<a class="nav-chip${active}" href="${href}">
      <span data-lang="ar">${labelAr}</span>
      <span data-lang="en">${labelEn}</span>
    </a>`;
  }

  function renderHeader() {
    const host = document.getElementById('site-header');
    if (!host) return;
    host.className = 'site-header';
    host.innerHTML = `
      <div class="container header-inner">
        <a class="brand-link" href="./index.html">
          <span class="brand-badge">
            <img src="./assets/images/brand_mark.svg" alt="Tamanina logo" />
          </span>
          <span>
            <span class="brand-title">
              <span data-lang="ar">طمأنينة</span>
              <span data-lang="en">Tamanina</span>
            </span>
            <span class="brand-subtitle">
              <span data-lang="ar">القرآن · الأذكار · مواقيت الصلاة</span>
              <span data-lang="en">Quran · Adhkar · Prayer Times</span>
            </span>
          </span>
        </a>

        <nav class="header-nav" aria-label="Primary navigation">
          ${navChip('./index.html', 'home', 'الرئيسية', 'Overview')}
          ${navChip('./help.html', 'help', 'المساعدة والدعم', 'Help & Support')}
          ${navChip('./privacy.html', 'privacy', 'سياسة الخصوصية', 'Privacy Policy')}
          ${navChip('./terms.html', 'terms', 'شروط الاستخدام', 'Terms')}
        </nav>

        <div class="header-controls">
          <button type="button" class="control-btn" id="lang-toggle" aria-label="Switch language">
            <span data-lang="ar">English</span>
            <span data-lang="en">العربية</span>
          </button>
          <button type="button" class="control-btn" id="theme-toggle" aria-label="Toggle theme">
            <span id="theme-icon" aria-hidden="true">☾</span>
            <span data-lang="ar" id="theme-label-ar">الوضع الداكن</span>
            <span data-lang="en" id="theme-label-en">Dark mode</span>
          </button>
        </div>
      </div>
    `;
  }

  function renderFooter() {
    const host = document.getElementById('site-footer');
    if (!host) return;
    host.className = 'site-footer';
    host.innerHTML = `
      <div class="container footer-inner">
        <div class="footer-brand">
          <span class="brand-badge">
            <img src="./assets/images/brand_mark.svg" alt="" aria-hidden="true" />
          </span>
          <div>
            <strong data-lang="ar">تطبيق طمأنينة</strong>
            <strong data-lang="en">Tamanina App</strong>
            <div style="font-size:0.84rem;color:var(--muted)">
              <span data-lang="ar">تشغيل وإدارة: ${cfg.publisherAr}</span>
              <span data-lang="en">Operated by ${cfg.publisherEn}</span>
            </div>
          </div>
        </div>

        <div class="footer-links">
          <a href="./help.html">
            <span data-lang="ar">مركز المساعدة</span>
            <span data-lang="en">Help &amp; Support</span>
          </a>
          <a href="./privacy.html">
            <span data-lang="ar">سياسة الخصوصية</span>
            <span data-lang="en">Privacy Policy</span>
          </a>
          <a href="./terms.html">
            <span data-lang="ar">شروط الاستخدام</span>
            <span data-lang="en">Terms of Service</span>
          </a>
          <a href="mailto:${cfg.supportEmail}">${cfg.supportEmail}</a>
        </div>

        <div class="footer-meta">
          <span>
            <span data-lang="ar">© 2026 طمأنينة (${cfg.publisherAr}). جميع الحقوق محفوظة.</span>
            <span data-lang="en">© 2026 Tamanina (${cfg.publisherEn}). All rights reserved.</span>
          </span>
          <span>
            <span data-lang="ar">الإصدار ${cfg.appVersion} · تاريخ السريان: ${cfg.effectiveDateAr}</span>
            <span data-lang="en">Version ${cfg.appVersion} · Effective ${cfg.effectiveDateEn}</span>
          </span>
        </div>
      </div>
    `;
  }

  function populateConfigPlaceholders() {
    document.querySelectorAll('[data-config]').forEach((el) => {
      const key = el.getAttribute('data-config');
      if (key && cfg[key]) {
        el.textContent = cfg[key];
      }
    });
    document.querySelectorAll('[data-mailto]').forEach((el) => {
      el.setAttribute('href', `mailto:${cfg.supportEmail}`);
      if (!el.dataset.keepText) {
        el.textContent = cfg.supportEmail;
      }
    });
  }

  function applyLang(lang) {
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
    localStorage.setItem('tamanina_web_lang', lang);

    const titleAr = document.body.dataset.titleAr;
    const titleEn = document.body.dataset.titleEn;
    if (titleAr && titleEn) {
      document.title = lang === 'ar' ? titleAr : titleEn;
    }
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('tamanina_web_theme', theme);
    const icon = document.getElementById('theme-icon');
    const labelAr = document.getElementById('theme-label-ar');
    const labelEn = document.getElementById('theme-label-en');
    if (icon) icon.textContent = theme === 'dark' ? '☀' : '☾';
    if (labelAr) labelAr.textContent = theme === 'dark' ? 'الوضع الفاتح' : 'الوضع الداكن';
    if (labelEn) labelEn.textContent = theme === 'dark' ? 'Light mode' : 'Dark mode';
  }

  function setupCopyButtons() {
    document.querySelectorAll('[data-copy-email]').forEach((btn) => {
      btn.addEventListener('click', async () => {
        try {
          await navigator.clipboard.writeText(cfg.supportEmail);
          const status = btn.parentElement?.querySelector('.copy-toast');
          if (status) {
            const isAr = document.documentElement.lang === 'ar';
            status.textContent = isAr ? 'تم النسخ' : 'Copied';
            setTimeout(() => {
              status.textContent = '';
            }, 2200);
          }
        } catch {
          window.location.href = `mailto:${cfg.supportEmail}`;
        }
      });
    });
  }

  renderHeader();
  renderFooter();
  populateConfigPlaceholders();
  applyLang(detectInitialLang());
  applyTheme(detectInitialTheme());
  setupCopyButtons();

  document.getElementById('lang-toggle')?.addEventListener('click', () => {
    const next = document.documentElement.lang === 'ar' ? 'en' : 'ar';
    applyLang(next);
  });

  document.getElementById('theme-toggle')?.addEventListener('click', () => {
    const current = document.documentElement.getAttribute('data-theme');
    applyTheme(current === 'dark' ? 'light' : 'dark');
  });
})();
