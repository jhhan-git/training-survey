// 설문 내용과 Supabase 연결 정보 (두 페이지가 함께 씁니다)
// anon/publishable 키는 공개되어도 되는 키입니다.
const SUPABASE_URL = "https://qipuagaqzvwghxuvulgr.supabase.co";
const SUPABASE_KEY = "sb_publishable_DXM8lm6acAEJ0HBpBi-Fnw_GWzjE2qf";

const SURVEY = {
  title: "상업교과교육연구회 공개 연수 만족도 조사",
  eyebrow: "2026학년도 교간형 전문적학습공동체",
  info: [
    ["공동체명", "상업교과교육연구회"],
    ["연수명", "생성형 AI와 교사 제작 앱으로 만드는 전문교과 수업 및 평가자료"],
    ["연수기간", "2026. 10. 28.(수) 15:00~17:00 (2시간)"],
    ["연수대상", "관내 중등교사 중 희망자"],
    ["연수시간", "2시간 (직무연수 인정 안 됨)"],
  ],
  scale: ["전혀 아니다", "아니다", "보통이다", "그렇다", "매우 그렇다"],
  sections: [
    { title: "강사에 대하여", items: [
      "강사의 교육내용이 교육목적에 적합하게 구성되었다.",
      "강사는 교육내용에 대한 충분한 지식을 갖고 있었다.",
      "강사는 학습목표를 명확히 제시하고 체계적으로 내용을 전달하였다.",
      "강사의 교육방법이 흥미를 유발하고, 사례나 예시 등이 적절히 사용되어 집중도를 높였다.",
      "강사는 교육생의 이해도 및 소속 기관 상황에 맞는 교육을 하였다.",
      "강사의 교육 진행 시 시간 배분(전달내용의 조직화, 설명, 토론)은 적절하였다.",
      "강사의 교육 보조자료를 활용하는 기술은 적절하였다.",
    ]},
    { title: "강의 주제에 대하여", items: [
      "강의 주제 및 내용은 나에겐 새로운 개념과 유익한 정보들이 제공되었다.",
      "강의 주제 및 내용은 나의 일상생활에 실질적으로 도움이 될 것이다.",
      "강의 주제 및 내용에 대하여 전반적으로 만족한다.",
    ]},
    { title: "강의 운영과 관련하여", items: [
      "교육 운영(일정, 교육 준비 등)이 잘 준비되었다.",
      "강의장 환경은 학습에 도움이 되었다.",
      "교육생 인원은 교육 효과를 달성하는 데 적합한 규모였다.",
    ]},
  ],
  comment: "본 교육과정 운영 사항 관련 개선을 위한 건의사항 또는 차년도 과정을 위한 제안 등을 자유롭게 적어 주십시오.",
};

async function rpc(fn, args) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: { apikey: SUPABASE_KEY, "Content-Type": "application/json" },
    body: JSON.stringify(args),
  });
  if (!res.ok) throw new Error(`${fn} ${res.status}`);
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}
