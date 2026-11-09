# 상업교과교육연구회 공개 연수 만족도 조사

- `index.html` — 응답자용 설문 페이지 (배포 링크)
- `results.html` — 결과 보기 (관리자 코드 필요, CSV 내려받기)
- `survey.js` — 문항 내용과 Supabase 연결 정보 (문항을 고치려면 이 파일만 수정)
- `supabase-setup.sql` — 응답을 저장할 표와 함수. Supabase SQL Editor에서 한 번 실행

응답은 기존 점심 메뉴 조사와 같은 Supabase 프로젝트의 `training_survey_responses` 표에 저장됩니다.

## 두 번째 설문 (11/6 미니쇼핑몰 만들기 연수)
- `1106/index.html`, `1106/results.html` — 설문·결과 페이지 (주소: /training-survey/1106/)
- `1106/survey.js` — 이 설문의 연수 정보
- `1106/supabase-setup-1106.sql` — 이 설문 전용 응답 표와 함수 (비밀 코드는 첫 번째 설문과 공통)
