/* ====================================================================
   Sprout — landing page interactivity
   Plain ES2017+. No build step. No dependencies.

   Responsibilities:
     1. Theme picker  — toggles body class, persists to localStorage.
     2. Density toggle — toggles body class, persists to localStorage.
     3. Mobile nav menu — show/hide top-nav links on small screens.
     4. Waitlist form  — pure-frontend stub: shows inline success state,
        hides the form, stops actually submitting anywhere. The real
        endpoint should be wired into the form's action attribute.
     5. Smooth-scroll polyfill for browsers that ignore CSS smooth-scroll
        (most modern browsers handle it natively via `html { scroll-behavior }`).
   ==================================================================== */

(function () {
  'use strict';

  var STORAGE = {
    theme: 'sprout-theme',
    density: 'sprout-density'
  };

  var THEMES = ['theme-lime-on-white', 'theme-teal-dominant', 'theme-cream'];
  var DENSITIES = ['density-tight', '', 'density-long']; // '' = medium / default

  var body = document.body;

  // ------------------------------------------------------------------
  // 1. Theme picker
  // ------------------------------------------------------------------
  function applyTheme(theme) {
    THEMES.forEach(function (t) { body.classList.remove(t); });
    if (THEMES.indexOf(theme) !== -1) body.classList.add(theme);

    document.querySelectorAll('.theme-swatch').forEach(function (btn) {
      btn.setAttribute('aria-pressed', btn.dataset.theme === theme ? 'true' : 'false');
    });

    // Swap nav logo on dark theme
    var defaultLogo = document.querySelector('.topnav .logo-default');
    var invertedLogo = document.querySelector('.topnav .logo-inverted');
    if (defaultLogo && invertedLogo) {
      if (theme === 'theme-teal-dominant') {
        defaultLogo.hidden = true;
        invertedLogo.hidden = false;
      } else {
        defaultLogo.hidden = false;
        invertedLogo.hidden = true;
      }
    }
  }

  document.querySelectorAll('.theme-swatch').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var theme = btn.dataset.theme;
      applyTheme(theme);
      try { localStorage.setItem(STORAGE.theme, theme); } catch (e) { /* private mode etc. */ }
    });
  });

  // Restore on load
  try {
    var savedTheme = localStorage.getItem(STORAGE.theme);
    if (savedTheme && THEMES.indexOf(savedTheme) !== -1) applyTheme(savedTheme);
  } catch (e) { /* ignore */ }

  // ------------------------------------------------------------------
  // 2. Density toggle
  // ------------------------------------------------------------------
  function applyDensity(density) {
    DENSITIES.filter(Boolean).forEach(function (d) { body.classList.remove(d); });
    if (density && DENSITIES.indexOf(density) !== -1) body.classList.add(density);

    document.querySelectorAll('.density-toggle button').forEach(function (btn) {
      btn.setAttribute('aria-pressed', (btn.dataset.density || '') === (density || '') ? 'true' : 'false');
    });
  }

  document.querySelectorAll('.density-toggle button').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var density = btn.dataset.density || '';
      applyDensity(density);
      try { localStorage.setItem(STORAGE.density, density); } catch (e) { /* ignore */ }
    });
  });

  try {
    var savedDensity = localStorage.getItem(STORAGE.density);
    if (savedDensity !== null && DENSITIES.indexOf(savedDensity) !== -1) applyDensity(savedDensity);
  } catch (e) { /* ignore */ }

  // ------------------------------------------------------------------
  // 3. Mobile nav menu
  // ------------------------------------------------------------------
  var menuToggle = document.getElementById('menu-toggle');
  var menu = document.getElementById('topnav-links');
  if (menuToggle && menu) {
    menuToggle.addEventListener('click', function () {
      var open = menu.classList.toggle('is-open');
      menuToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    // close menu on link click
    menu.querySelectorAll('a').forEach(function (a) {
      a.addEventListener('click', function () {
        menu.classList.remove('is-open');
        menuToggle.setAttribute('aria-expanded', 'false');
      });
    });
  }

  // ------------------------------------------------------------------
  // 4. Waitlist form — pure-frontend stub
  // ------------------------------------------------------------------
  var form = document.getElementById('waitlist-form');
  var success = document.getElementById('waitlist-success');
  if (form && success) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();

      var emailInput = form.querySelector('input[type="email"]');
      var email = (emailInput.value || '').trim();
      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        emailInput.focus();
        emailInput.setAttribute('aria-invalid', 'true');
        return;
      }
      emailInput.removeAttribute('aria-invalid');

      // TODO: replace with a real Formspree / Mailchimp / Resend endpoint.
      // Until then, just hide the form and show the success state.
      form.style.display = 'none';
      success.classList.add('is-visible');
      // Move focus to the success message for screen readers.
      success.setAttribute('tabindex', '-1');
      success.focus();
    });
  }

  // ------------------------------------------------------------------
  // 5. Smooth scroll fallback (most browsers honour CSS scroll-behavior)
  // ------------------------------------------------------------------
  if (!('scrollBehavior' in document.documentElement.style)) {
    document.querySelectorAll('a[href^="#"]').forEach(function (link) {
      link.addEventListener('click', function (e) {
        var id = link.getAttribute('href');
        if (!id || id === '#' || id.length < 2) return;
        var target = document.querySelector(id);
        if (!target) return;
        e.preventDefault();
        target.scrollIntoView({ behavior: 'smooth' });
      });
    });
  }
})();
