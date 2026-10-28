-- 상업교과교육연구회 공개 연수 만족도 조사: 응답 저장 표와 함수
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 Run 하세요.
-- 브라우저는 표에 직접 접근하지 못하고, 아래 두 함수로만 응답 제출/결과 조회를 합니다.

create table if not exists public.training_survey_responses (
  respondent_id uuid primary key,
  scores        smallint[] not null
                check (array_length(scores, 1) = 13 and 1 <= all(scores) and 5 >= all(scores)),
  comment       text not null check (char_length(btrim(comment)) between 1 and 2000),
  submitted_at  timestamptz not null default now()
);

alter table public.training_survey_responses enable row level security;
revoke all on public.training_survey_responses from anon, authenticated;

-- 결과 보기용 관리자 코드 (아래 표에 한 줄만 둡니다)
create table if not exists public.training_survey_admin (
  id   int primary key default 1 check (id = 1),
  code text not null
);
alter table public.training_survey_admin enable row level security;
revoke all on public.training_survey_admin from anon, authenticated;

-- ⚠️ 'CHANGE-ME' 를 결과 확인용 비밀 코드로 바꾼 뒤 실행하세요.
insert into public.training_survey_admin (id, code) values (1, 'CHANGE-ME')
on conflict (id) do update set code = excluded.code;

-- 응답 제출 (같은 브라우저에서 다시 제출하면 기존 응답을 고칩니다)
create or replace function public.submit_training_survey(p_id uuid, p_scores smallint[], p_comment text)
returns void
language sql
security definer
set search_path = public
as $$
  insert into training_survey_responses (respondent_id, scores, comment, submitted_at)
  values (p_id, p_scores, btrim(p_comment), now())
  on conflict (respondent_id) do update
    set scores = excluded.scores, comment = excluded.comment, submitted_at = now();
$$;

revoke all on function public.submit_training_survey(uuid, smallint[], text) from public;
grant execute on function public.submit_training_survey(uuid, smallint[], text) to anon, authenticated;

-- 결과 조회·응답 삭제 함수는 supabase-update-delete.sql 에 있습니다. 이어서 그 파일도 실행하세요.
