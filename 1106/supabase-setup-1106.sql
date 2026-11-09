-- 11/6 연수(미니쇼핑몰 만들기) 만족도 조사: 응답 저장 표와 함수
-- 첫 번째 설문과 응답이 섞이지 않도록 표를 따로 만듭니다.
-- 결과 보기·삭제 비밀 코드는 첫 번째 설문과 같은 코드를 씁니다.
-- 수정 없이 그대로 Supabase SQL Editor 에 붙여넣고 Run 하세요.

create table if not exists public.training_survey_1106_responses (
  respondent_id uuid primary key,
  scores        smallint[] not null
                check (array_length(scores, 1) = 13 and 1 <= all(scores) and 5 >= all(scores)),
  comment       text not null check (char_length(btrim(comment)) between 1 and 2000),
  submitted_at  timestamptz not null default now()
);
alter table public.training_survey_1106_responses enable row level security;
revoke all on public.training_survey_1106_responses from anon, authenticated;

-- 응답 제출 (같은 브라우저에서 다시 제출하면 기존 응답을 고칩니다)
create or replace function public.submit_training_survey_1106(p_id uuid, p_scores smallint[], p_comment text)
returns void
language sql
security definer
set search_path = public
as $$
  insert into training_survey_1106_responses (respondent_id, scores, comment, submitted_at)
  values (p_id, p_scores, btrim(p_comment), now())
  on conflict (respondent_id) do update
    set scores = excluded.scores, comment = excluded.comment, submitted_at = now();
$$;

-- 결과 조회 (관리자 코드가 맞을 때만)
create or replace function public.training_survey_results_1106(p_code text)
returns table (id uuid, scores smallint[], comment text, submitted_at timestamptz)
language sql
security definer
set search_path = public
as $$
  select r.respondent_id, r.scores, r.comment, r.submitted_at
  from training_survey_1106_responses r
  where exists (select 1 from training_survey_admin a where a.code = p_code and a.code <> 'CHANGE-ME')
  order by r.submitted_at;
$$;

-- 응답 삭제 (관리자 코드가 맞을 때만)
create or replace function public.delete_training_survey_response_1106(p_code text, p_id uuid)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare n int;
begin
  if not exists (select 1 from training_survey_admin a where a.code = p_code and a.code <> 'CHANGE-ME') then
    raise exception '관리자 코드가 맞지 않습니다';
  end if;
  delete from training_survey_1106_responses where respondent_id = p_id;
  get diagnostics n = row_count;
  return n;
end;
$$;

revoke all on function public.submit_training_survey_1106(uuid, smallint[], text) from public;
revoke all on function public.training_survey_results_1106(text) from public;
revoke all on function public.delete_training_survey_response_1106(text, uuid) from public;
grant execute on function public.submit_training_survey_1106(uuid, smallint[], text) to anon, authenticated;
grant execute on function public.training_survey_results_1106(text) to anon, authenticated;
grant execute on function public.delete_training_survey_response_1106(text, uuid) to anon, authenticated;

notify pgrst, 'reload schema';
