const STORAGE_KEY = "studyflow:v1";
const todayKey = () => new Date().toISOString().slice(0, 10);

const subjects = [
  { id: "math", name: "수학", color: "#2563eb" },
  { id: "english", name: "영어", color: "#059669" },
  { id: "science", name: "과학", color: "#b7791f" },
  { id: "korean", name: "국어", color: "#dc2626" },
];

const sampleState = {
  tasks: [
    { id: crypto.randomUUID(), subjectId: "math", title: "미적분 오답 정리", minutes: 60, done: false, date: todayKey() },
    { id: crypto.randomUUID(), subjectId: "english", title: "단어 80개 암기", minutes: 40, done: true, date: todayKey() },
    { id: crypto.randomUUID(), subjectId: "science", title: "물리 개념 노트", minutes: 50, done: false, date: todayKey() },
  ],
  focusLog: {
    [todayKey()]: 35,
  },
};

let state = loadState();
let currentFilter = "all";
let timer = {
  secondsLeft: 25 * 60,
  running: false,
  mode: "focus",
  intervalId: null,
};

const $ = (selector) => document.querySelector(selector);
const $$ = (selector) => document.querySelectorAll(selector);

function loadState() {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (!saved) return structuredClone(sampleState);

  try {
    const parsed = JSON.parse(saved);
    return {
      tasks: Array.isArray(parsed.tasks) ? parsed.tasks : [],
      focusLog: parsed.focusLog && typeof parsed.focusLog === "object" ? parsed.focusLog : {},
    };
  } catch {
    return structuredClone(sampleState);
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function subjectName(id) {
  return subjects.find((subject) => subject.id === id)?.name ?? "기타";
}

function subjectColor(id) {
  return subjects.find((subject) => subject.id === id)?.color ?? "#647386";
}

function formatMinutes(minutes) {
  if (minutes < 60) return `${minutes}m`;
  const hours = Math.floor(minutes / 60);
  const rest = minutes % 60;
  return rest ? `${hours}h ${rest}m` : `${hours}h`;
}

function renderTask(container, task) {
  const template = $("#taskTemplate");
  const node = template.content.firstElementChild.cloneNode(true);
  node.classList.toggle("done", task.done);
  node.dataset.id = task.id;
  node.querySelector(".task-main strong").textContent = task.title;
  node.querySelector(".task-main span").textContent = subjectName(task.subjectId);
  node.querySelector("time").textContent = formatMinutes(task.minutes);
  node.querySelector(".check-button").addEventListener("click", () => toggleTask(task.id));
  node.querySelector(".delete-button").addEventListener("click", () => deleteTask(task.id));
  container.appendChild(node);
}

function renderEmpty(container, text) {
  const empty = document.createElement("div");
  empty.className = "empty-state";
  empty.textContent = text;
  container.appendChild(empty);
}

function render() {
  const today = todayKey();
  const todaysTasks = state.tasks.filter((task) => task.date === today);
  const openTasks = todaysTasks.filter((task) => !task.done);
  const doneTasks = todaysTasks.filter((task) => task.done);
  const plannedMinutes = todaysTasks.reduce((sum, task) => sum + task.minutes, 0);
  const focusedMinutes = state.focusLog[today] ?? 0;

  $("#completedToday").textContent = doneTasks.length;
  $("#goalToday").textContent = formatMinutes(plannedMinutes);
  $("#focusToday").textContent = formatMinutes(focusedMinutes);
  $("#openCount").textContent = `${openTasks.length}개 남음`;
  $("#todayLabel").textContent = new Intl.DateTimeFormat("ko-KR", {
    dateStyle: "full",
  }).format(new Date());

  const todayTasks = $("#todayTasks");
  todayTasks.textContent = "";
  if (todaysTasks.length) {
    todaysTasks.forEach((task) => renderTask(todayTasks, task));
  } else {
    renderEmpty(todayTasks, "오늘 계획이 아직 없습니다.");
  }

  renderPlanner();
  renderSubjects(todaysTasks);
  renderStats();
}

function renderPlanner() {
  const plannerTasks = $("#plannerTasks");
  plannerTasks.textContent = "";

  const filteredTasks = state.tasks.filter((task) => {
    if (currentFilter === "open") return !task.done;
    if (currentFilter === "done") return task.done;
    return true;
  });

  if (!filteredTasks.length) {
    renderEmpty(plannerTasks, "조건에 맞는 계획이 없습니다.");
    return;
  }

  filteredTasks.forEach((task) => renderTask(plannerTasks, task));
}

function renderSubjects(todaysTasks) {
  const container = $("#subjectProgress");
  container.textContent = "";
  const maxMinutes = Math.max(...subjects.map((subject) =>
    todaysTasks
      .filter((task) => task.subjectId === subject.id)
      .reduce((sum, task) => sum + task.minutes, 0)
  ), 1);

  subjects.forEach((subject) => {
    const minutes = todaysTasks
      .filter((task) => task.subjectId === subject.id)
      .reduce((sum, task) => sum + task.minutes, 0);
    const row = document.createElement("div");
    row.className = "subject-row";
    row.innerHTML = `
      <div class="subject-head"><strong>${subject.name}</strong><span>${formatMinutes(minutes)}</span></div>
      <div class="progress-track"><div class="progress-fill"></div></div>
    `;
    const fill = row.querySelector(".progress-fill");
    fill.style.background = subject.color;
    fill.style.transform = `scaleX(${minutes / maxMinutes})`;
    container.appendChild(row);
  });
}

function renderStats() {
  const chart = $("#weeklyChart");
  chart.textContent = "";
  const days = [...Array(7)].map((_, index) => {
    const date = new Date();
    date.setDate(date.getDate() - (6 - index));
    const key = date.toISOString().slice(0, 10);
    return {
      key,
      label: new Intl.DateTimeFormat("ko-KR", { weekday: "short" }).format(date),
      minutes: state.focusLog[key] ?? 0,
    };
  });
  const max = Math.max(...days.map((day) => day.minutes), 1);
  const total = days.reduce((sum, day) => sum + day.minutes, 0);
  $("#weeklyTotal").textContent = formatMinutes(total);

  days.forEach((day) => {
    const bar = document.createElement("div");
    bar.className = "bar";
    const height = Math.max(8, (day.minutes / max) * 230);
    bar.innerHTML = `
      <div class="bar-fill" style="height:${height}px" title="${day.minutes}분"></div>
      <span>${day.label}</span>
    `;
    chart.appendChild(bar);
  });
}

function toggleTask(id) {
  state.tasks = state.tasks.map((task) =>
    task.id === id ? { ...task, done: !task.done } : task
  );
  saveState();
  render();
}

function deleteTask(id) {
  state.tasks = state.tasks.filter((task) => task.id !== id);
  saveState();
  render();
}

function addTask(event) {
  event.preventDefault();
  const title = $("#titleInput").value.trim();
  const minutes = Number($("#minutesInput").value);
  if (!title || !Number.isFinite(minutes)) return;

  state.tasks.unshift({
    id: crypto.randomUUID(),
    subjectId: $("#subjectInput").value,
    title,
    minutes,
    done: false,
    date: todayKey(),
  });
  event.currentTarget.reset();
  $("#minutesInput").value = 60;
  saveState();
  render();
}

function switchView(viewId) {
  $$(".view").forEach((view) => view.classList.toggle("active", view.id === viewId));
  $$(".nav-item").forEach((item) => item.classList.toggle("active", item.dataset.view === viewId));
}

function updateTimerReadout() {
  const minutes = Math.floor(timer.secondsLeft / 60).toString().padStart(2, "0");
  const seconds = (timer.secondsLeft % 60).toString().padStart(2, "0");
  $("#timerReadout").textContent = `${minutes}:${seconds}`;
  $("#timerMode").textContent = timer.mode === "focus" ? "집중 세션" : "휴식";
}

function setTimerLength() {
  if (timer.running) return;
  timer.mode = "focus";
  timer.secondsLeft = Number($("#focusLength").value) * 60;
  $("#focusLengthLabel").textContent = `${$("#focusLength").value}분`;
  $("#breakLengthLabel").textContent = `${$("#breakLength").value}분`;
  $("#timerHint").textContent = `${$("#focusLength").value}분 집중`;
  updateTimerReadout();
}

function startTimer() {
  if (timer.running) return;
  timer.running = true;
  timer.intervalId = window.setInterval(() => {
    timer.secondsLeft -= 1;
    if (timer.secondsLeft <= 0) finishTimerRound();
    updateTimerReadout();
  }, 1000);
}

function pauseTimer() {
  timer.running = false;
  clearInterval(timer.intervalId);
}

function resetTimer() {
  pauseTimer();
  setTimerLength();
}

function finishTimerRound() {
  if (timer.mode === "focus") {
    const focused = Number($("#focusLength").value);
    state.focusLog[todayKey()] = (state.focusLog[todayKey()] ?? 0) + focused;
    timer.mode = "break";
    timer.secondsLeft = Number($("#breakLength").value) * 60;
    saveState();
    render();
  } else {
    timer.mode = "focus";
    timer.secondsLeft = Number($("#focusLength").value) * 60;
  }
}

function init() {
  $("#subjectInput").innerHTML = subjects
    .map((subject) => `<option value="${subject.id}">${subject.name}</option>`)
    .join("");

  $$(".nav-item").forEach((item) =>
    item.addEventListener("click", () => switchView(item.dataset.view))
  );
  $$(".segment").forEach((item) =>
    item.addEventListener("click", () => {
      currentFilter = item.dataset.filter;
      $$(".segment").forEach((segment) => segment.classList.toggle("active", segment === item));
      renderPlanner();
    })
  );

  $("#taskForm").addEventListener("submit", addTask);
  $("#focusLength").addEventListener("input", setTimerLength);
  $("#breakLength").addEventListener("input", setTimerLength);
  $("#startTimer").addEventListener("click", startTimer);
  $("#pauseTimer").addEventListener("click", pauseTimer);
  $("#resetTimer").addEventListener("click", resetTimer);
  $("#resetDemo").addEventListener("click", () => {
    state = structuredClone(sampleState);
    saveState();
    resetTimer();
    render();
  });

  setTimerLength();
  render();
}

init();
