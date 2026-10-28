const state = {
  token: localStorage.getItem('token') || '',
  mealType: 'breakfast',
  profile: null,
  parsedItems: [],
};

const baseUrl = window.location.origin;

const views = {
  login: document.getElementById('view-login'),
  home: document.getElementById('view-home'),
  add: document.getElementById('view-add'),
  history: document.getElementById('view-history'),
  profile: document.getElementById('view-profile'),
};

function setStatus(id, text) {
  document.getElementById(id).innerText = text || '';
}

function showView(name) {
  Object.entries(views).forEach(([key, el]) => {
    el.classList.toggle('active', key === name);
  });
  document.querySelectorAll('.nav-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.view === name);
  });
}

function setAuthenticatedUI(isLoggedIn) {
  document.getElementById('bottomNav').style.display = isLoggedIn ? 'grid' : 'none';
  document.getElementById('refreshTopBtn').style.display = isLoggedIn ? 'inline-block' : 'none';
  showView(isLoggedIn ? 'home' : 'login');
}

async function api(path, options = {}) {
  const headers = options.headers || {};
  if (state.token) headers['Authorization'] = `Bearer ${state.token}`;
  const res = await fetch(`${baseUrl}${path}`, { ...options, headers });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.detail || 'Request failed');
  return data;
}

async function login() {
  const body = new URLSearchParams();
  body.append('username', document.getElementById('email').value.trim());
  body.append('password', document.getElementById('password').value);

  try {
    const res = await fetch(`${baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body,
    });
    const data = await res.json();
    if (!res.ok || !data.access_token) throw new Error(data.detail || 'Login failed');
    state.token = data.access_token;
    localStorage.setItem('token', state.token);
    setStatus('loginStatus', 'Logged in successfully');
    setAuthenticatedUI(true);
    await Promise.all([loadSummary(), loadMeals(), loadProfile()]);
  } catch (err) {
    setStatus('loginStatus', err.message);
  }
}

async function loadSummary() {
  try {
    const data = await api('/api/meals/daily-summary');
    document.getElementById('sumCalories').innerText = data.calories ?? 0;
    document.getElementById('sumRemaining').innerText = data.remaining_calories ?? '-';
    document.getElementById('sumProtein').innerText = data.protein ?? 0;
    document.getElementById('sumFat').innerText = data.fat ?? 0;
    document.getElementById('sumCarbs').innerText = data.carbs ?? 0;
    document.getElementById('sumTarget').innerText = data.target_calories ?? '-';

    let progress = 0;
    if (data.target_calories && data.target_calories > 0) {
      progress = Math.min((data.calories / data.target_calories) * 100, 100);
    }
    document.getElementById('summaryProgress').style.width = `${progress}%`;
  } catch (err) {
    setStatus('saveStatus', err.message);
  }
}

function mealTypeOptions(selected) {
  return ['breakfast', 'lunch', 'dinner', 'snack']
    .map(type => `<option value="${type}" ${selected === type ? 'selected' : ''}>${type}</option>`)
    .join('');
}

async function editMeal(meal) {
  const grams = prompt(`Edit grams for ${meal.name}`, meal.grams);
  if (grams === null) return;
  const mealType = prompt(`Edit meal type for ${meal.name} (breakfast/lunch/dinner/snack)`, meal.meal_type || 'snack');
  if (mealType === null) return;

  try {
    await api(`/api/meals/${meal.id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ grams: Number(grams), meal_type: mealType }),
    });
    await Promise.all([loadSummary(), loadMeals()]);
  } catch (err) {
    alert(err.message);
  }
}

async function deleteMeal(mealId) {
  const ok = confirm('Delete this meal?');
  if (!ok) return;
  try {
    await api(`/api/meals/${mealId}`, { method: 'DELETE' });
    await Promise.all([loadSummary(), loadMeals()]);
  } catch (err) {
    alert(err.message);
  }
}

async function loadMeals() {
  try {
    const data = await api('/api/meals/today');
    const box = document.getElementById('todayMeals');
    if (!data.length) {
      box.className = 'list-wrap empty-state';
      box.innerHTML = 'No meals yet.';
      return;
    }
    box.className = 'list-wrap';
    box.innerHTML = data.map(item => `
      <div class="list-item">
        <div class="item-title">${item.name}</div>
        <div class="item-sub">${item.grams} g • ${item.calories} kcal • ${item.meal_type || ''}</div>
        <div class="item-actions">
          <button class="small-btn" onclick='editMeal(${JSON.stringify(item)})'>Edit</button>
          <button class="small-btn danger-small" onclick='deleteMeal("${item.id}")'>Delete</button>
        </div>
      </div>
    `).join('');
  } catch (err) {
    document.getElementById('todayMeals').innerHTML = `<div class="empty-state">${err.message}</div>`;
  }
}

async function loadHistory() {
  const from = document.getElementById('fromDate').value;
  const to = document.getElementById('toDate').value;
  try {
    const data = await api(`/api/meals/history?from=${from}&to=${to}`);
    const box = document.getElementById('historyList');
    if (!data.length) {
      box.className = 'list-wrap empty-state';
      box.innerHTML = 'No meals found for selected period.';
      return;
    }
    box.className = 'list-wrap';
    box.innerHTML = data.map(item => `
      <div class="list-item">
        <div class="item-title">${item.name}</div>
        <div class="item-sub">${item.grams} g • ${item.calories} kcal • ${item.meal_type || ''}</div>
      </div>
    `).join('');
  } catch (err) {
    document.getElementById('historyList').innerHTML = `<div class="empty-state">${err.message}</div>`;
  }
}

async function loadProfile() {
  try {
    const data = await api('/api/users/me');
    state.profile = data;
    document.getElementById('profileName').value = data.name || '';
    document.getElementById('profileTarget').value = data.daily_calorie_target || '';
  } catch (err) {
    setStatus('profileStatus', err.message);
  }
}

async function saveProfile() {
  try {
    const body = {
      name: document.getElementById('profileName').value,
      daily_calorie_target: Number(document.getElementById('profileTarget').value) || null,
    };
    await api('/api/users/me', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    setStatus('profileStatus', 'Profile saved');
    await loadSummary();
  } catch (err) {
    setStatus('profileStatus', err.message);
  }
}

function renderParsedItems() {
  const section = document.getElementById('parsedSection');
  const container = document.getElementById('parsedItems');
  if (!state.parsedItems.length) {
    section.classList.add('hidden');
    container.innerHTML = '';
    return;
  }
  section.classList.remove('hidden');
  container.innerHTML = state.parsedItems.map((item, index) => `
    <div class="parsed-card">
      <div class="parsed-name">${item.name}</div>
      <label>Grams</label>
      <input type="number" value="${item.grams}" data-index="${index}" class="parsed-grams" />
      <div class="small-note">Matched ID: ${item.matched_food_id ?? 'none'}</div>
    </div>
  `).join('');

  document.querySelectorAll('.parsed-grams').forEach(input => {
    input.addEventListener('input', (e) => {
      const idx = Number(e.target.dataset.index);
      state.parsedItems[idx].grams = Number(e.target.value) || state.parsedItems[idx].grams;
    });
  });
}

async function parseOnly() {
  const text = document.getElementById('mealText').value.trim();
  if (!text) {
    setStatus('saveStatus', 'Enter meal text first');
    return;
  }
  try {
    const data = await api('/api/meals/parse', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text }),
    });

    const items = (data.items && data.items.length) ? data.items : (data.fallback_items || []);
    state.parsedItems = items.map(item => ({
      name: item.name,
      grams: item.grams,
      matched_food_id: item.matched_food_id ?? null,
    }));

    let status = `Parsed ${state.parsedItems.length} item(s)`;
    if (data.provider) status += ` using ${data.provider}`;
    if (data.mode === 'fallback-after-llm-error') status += ' (fallback used)';
    setStatus('saveStatus', status);
    renderParsedItems();
  } catch (err) {
    setStatus('saveStatus', err.message);
  }
}

async function saveParsedItems() {
  if (!state.parsedItems.length) {
    setStatus('saveStatus', 'Parse meal first');
    return;
  }
  try {
    const data = await api('/api/meals/save-parsed', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ items: state.parsedItems, meal_type: state.mealType }),
    });
    setStatus('saveStatus', `Saved ${data.created_count} item(s)`);
    state.parsedItems = [];
    renderParsedItems();
    document.getElementById('mealText').value = '';
    await Promise.all([loadSummary(), loadMeals()]);
    showView('home');
  } catch (err) {
    setStatus('saveStatus', err.message);
  }
}

function logout() {
  state.token = '';
  localStorage.removeItem('token');
  state.parsedItems = [];
  renderParsedItems();
  setAuthenticatedUI(false);
  setStatus('loginStatus', 'Logged out');
}

function setMealType(type) {
  state.mealType = type;
  document.querySelectorAll('#mealTypeChips .chip').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.type === type);
  });
}

function initDates() {
  const now = new Date();
  const weekAgo = new Date(now);
  weekAgo.setDate(now.getDate() - 7);
  document.getElementById('fromDate').value = weekAgo.toISOString().split('T')[0];
  document.getElementById('toDate').value = now.toISOString().split('T')[0];
}

function bindEvents() {
  document.getElementById('loginBtn').addEventListener('click', login);
  document.getElementById('parseMealBtn').addEventListener('click', parseOnly);
  document.getElementById('saveMealBtn').addEventListener('click', saveParsedItems);
  document.getElementById('refreshTopBtn').addEventListener('click', async () => {
    await Promise.all([loadSummary(), loadMeals()]);
  });
  document.getElementById('refreshSummaryBtn').addEventListener('click', loadSummary);
  document.getElementById('refreshMealsBtn').addEventListener('click', loadMeals);
  document.getElementById('loadHistoryBtn').addEventListener('click', loadHistory);
  document.getElementById('saveProfileBtn').addEventListener('click', saveProfile);
  document.getElementById('logoutBtn').addEventListener('click', logout);

  document.querySelectorAll('.nav-btn').forEach(btn => {
    btn.addEventListener('click', () => showView(btn.dataset.view));
  });

  document.querySelectorAll('#mealTypeChips .chip').forEach(btn => {
    btn.addEventListener('click', () => setMealType(btn.dataset.type));
  });

  document.querySelectorAll('.sample-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.getElementById('mealText').value = btn.dataset.text;
      showView('add');
    });
  });
}

async function bootstrap() {
  bindEvents();
  initDates();
  setMealType('breakfast');
  renderParsedItems();

  if (state.token) {
    setAuthenticatedUI(true);
    try {
      await Promise.all([loadSummary(), loadMeals(), loadProfile()]);
    } catch (_) {
      logout();
    }
  } else {
    setAuthenticatedUI(false);
  }
}

window.editMeal = editMeal;
window.deleteMeal = deleteMeal;
bootstrap();
