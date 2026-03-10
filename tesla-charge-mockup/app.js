const soc = document.getElementById('soc');
const temp = document.getElementById('temp');
const socValue = document.getElementById('socValue');
const tempValue = document.getElementById('tempValue');
const simulateBtn = document.getElementById('simulateBtn');
const routeVisual = document.getElementById('routeVisual');
const recommendations = document.getElementById('recommendations');
const timeline = document.getElementById('timeline');
const tripDistance = document.getElementById('tripDistance');
const tripTime = document.getElementById('tripTime');
const arrivalSoc = document.getElementById('arrivalSoc');

const routes = {
  '서울-부산': {
    distance: 390,
    travelTime: '4시간 32분',
    routes: [
      {
        name: '추풍령휴게소 DC콤보',
        tag: '추천 1',
        stopMinutes: 23,
        arrival: 17,
        depart: 58,
        finalSoc: 14,
        preheat: '도착 28분 전',
        x: 45, y: 48,
      },
      {
        name: '선산휴게소 DC콤보',
        tag: '대안',
        stopMinutes: 19,
        arrival: 21,
        depart: 55,
        finalSoc: 11,
        preheat: '도착 24분 전',
        x: 58, y: 54,
      },
    ],
  },
  '서울-강릉': {
    distance: 238,
    travelTime: '2시간 54분',
    routes: [
      {
        name: '횡성휴게소 DC콤보',
        tag: '추천 1',
        stopMinutes: 16,
        arrival: 24,
        depart: 62,
        finalSoc: 19,
        preheat: '도착 20분 전',
        x: 50, y: 43,
      },
      {
        name: '홍천휴게소 DC콤보',
        tag: '대안',
        stopMinutes: 14,
        arrival: 28,
        depart: 60,
        finalSoc: 17,
        preheat: '도착 18분 전',
        x: 37, y: 47,
      },
    ],
  },
  '서울-광주': {
    distance: 332,
    travelTime: '4시간 08분',
    routes: [
      {
        name: '정안휴게소 DC콤보',
        tag: '추천 1',
        stopMinutes: 20,
        arrival: 18,
        depart: 57,
        finalSoc: 13,
        preheat: '도착 26분 전',
        x: 44, y: 55,
      },
      {
        name: '이서휴게소 DC콤보',
        tag: '대안',
        stopMinutes: 17,
        arrival: 23,
        depart: 54,
        finalSoc: 10,
        preheat: '도착 22분 전',
        x: 63, y: 68,
      },
    ],
  },
  '서울-전주': {
    distance: 217,
    travelTime: '2시간 47분',
    routes: [
      {
        name: '천안삼거리휴게소 DC콤보',
        tag: '추천 1',
        stopMinutes: 14,
        arrival: 31,
        depart: 63,
        finalSoc: 21,
        preheat: '도착 16분 전',
        x: 43, y: 58,
      },
      {
        name: '정읍휴게소 DC콤보',
        tag: '대안',
        stopMinutes: 18,
        arrival: 19,
        depart: 56,
        finalSoc: 15,
        preheat: '도착 24분 전',
        x: 67, y: 72,
      },
    ],
  }
};

function updateLabels() {
  socValue.textContent = `${soc.value}%`;
  tempValue.textContent = `${temp.value}℃`;
}

function metricLabel(style, route, baseFinalSoc) {
  if (style === 'fast') return `${route.stopMinutes - 3 > 8 ? route.stopMinutes - 3 : route.stopMinutes}분 충전 · 빠른 진행`;
  if (style === 'safe') return `${route.stopMinutes + 4}분 충전 · 여유 잔량 ${baseFinalSoc + 5}%`;
  return `${route.stopMinutes}분 충전 · 균형 추천`;
}

function renderSimulation() {
  const origin = document.getElementById('origin').value;
  const destination = document.getElementById('destination').value;
  const style = document.getElementById('style').value;
  const key = `${origin}-${destination}`;
  const selected = routes[key] || routes['서울-부산'];
  const coldPenalty = Math.max(0, (10 - Number(temp.value)) * 0.35);
  const lowSocPenalty = Math.max(0, (35 - Number(soc.value)) * 0.18);

  const primary = selected.routes[0];
  const adjustedFinalSoc = Math.max(5, Math.round(primary.finalSoc - coldPenalty - lowSocPenalty));

  tripDistance.textContent = `${selected.distance}km`;
  tripTime.textContent = selected.travelTime;
  arrivalSoc.textContent = `${adjustedFinalSoc}%`;

  routeVisual.innerHTML = '';
  const nodes = [
    { label: origin, x: 12, y: 18, cls: 'start' },
    { label: primary.name, x: primary.x, y: primary.y, cls: 'charge' },
    { label: destination, x: 86, y: 78, cls: 'end' },
  ];

  for (let i = 0; i < nodes.length - 1; i += 1) {
    const a = nodes[i];
    const b = nodes[i + 1];
    const dx = b.x - a.x;
    const dy = b.y - a.y;
    const length = Math.sqrt(dx * dx + dy * dy);
    const angle = Math.atan2(dy, dx) * 180 / Math.PI;
    const segment = document.createElement('div');
    segment.className = 'path-segment';
    segment.style.left = `${a.x}%`;
    segment.style.top = `${a.y}%`;
    segment.style.width = `${length}%`;
    segment.style.transform = `rotate(${angle}deg)`;
    routeVisual.appendChild(segment);
  }

  nodes.forEach((node) => {
    const el = document.createElement('div');
    el.className = `node ${node.cls}`;
    el.style.left = `${node.x}%`;
    el.style.top = `${node.y}%`;
    el.textContent = node.label;
    routeVisual.appendChild(el);
  });

  recommendations.innerHTML = selected.routes.map((route, index) => {
    const finalSoc = Math.max(4, Math.round(route.finalSoc - coldPenalty - lowSocPenalty + (style === 'safe' ? 5 : style === 'fast' ? -2 : 0)));
    return `
      <div class="rec-card">
        <div class="rec-head">
          <div>
            <div class="rec-title">${route.name}</div>
            <div class="metric-row">${metricLabel(style, route, finalSoc)}</div>
          </div>
          <span class="pill">${route.tag}</span>
        </div>
        <div class="metric-row">
          <span>충전소 도착 ${Math.max(6, Math.round(route.arrival - lowSocPenalty))}%</span>
          <span>출발 ${route.depart}%</span>
          <span>최종 도착 ${finalSoc}%</span>
        </div>
        <div class="metric-row" style="margin-top:8px;">
          <span>프리히팅 권장: ${route.preheat}</span>
          <span>${index === 0 ? '우회 적음' : '혼잡 분산용'}</span>
        </div>
      </div>
    `;
  }).join('');

  const timelineItems = [
    { t: '출발 직후', title: `${origin} 출발`, desc: `현재 배터리 ${soc.value}% · 외기온도 ${temp.value}℃ · ${document.getElementById('model').selectedOptions[0].text}` },
    { t: '주행 중', title: '에너지 모델 업데이트', desc: `온도/잔량 반영하여 ${primary.name} 경유 추천 유지` },
    { t: primary.preheat, title: '프리히팅 시작 권장', desc: 'Tesla API 목적지 연동 또는 차량 내 네비 목적지 지정 유도' },
    { t: `${primary.stopMinutes}분 충전`, title: `${primary.name} 충전`, desc: `도착 ${Math.max(6, Math.round(primary.arrival - lowSocPenalty))}% → 출발 ${primary.depart}%` },
    { t: '도착', title: `${destination} 도착`, desc: `예상 잔량 ${adjustedFinalSoc}% · 장거리 종료` },
  ];

  timeline.innerHTML = timelineItems.map(item => `
    <div class="timeline-item">
      <div class="timeline-time">${item.t}</div>
      <div class="timeline-body">
        <strong>${item.title}</strong>
        <p>${item.desc}</p>
      </div>
    </div>
  `).join('');
}

soc.addEventListener('input', () => { updateLabels(); renderSimulation(); });
temp.addEventListener('input', () => { updateLabels(); renderSimulation(); });
simulateBtn.addEventListener('click', renderSimulation);
document.querySelectorAll('select').forEach(el => el.addEventListener('change', renderSimulation));
updateLabels();
renderSimulation();
