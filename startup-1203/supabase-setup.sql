-- 2026 창업체험활성화운영교 성과나눔 참석 조사: 응답 저장 표와 함수
-- 결과 보기·삭제 비밀 코드는 연수 만족도 조사와 같은 코드를 씁니다.
-- 수정 없이 그대로 Supabase SQL Editor 에 붙여넣고 Run 하세요.

create table if not exists public.startup_attend_responses (
  respondent_id uuid primary key,
  school        text not null check (char_length(btrim(school)) between 1 and 100),
  attend        boolean not null,
  name1         text check (name1 is null or char_length(name1) <= 50),
  phone1        text check (phone1 is null or phone1 ~ '^01[0-9]-[0-9]{3,4}-[0-9]{4}$'),
  name2         text check (name2 is null or char_length(name2) <= 50),
  phone2        text check (phone2 is null or phone2 ~ '^01[0-9]-[0-9]{3,4}-[0-9]{4}$'),
  consent       boolean not null check (consent),
  submitted_at  timestamptz not null default now(),
  -- 참석이면 참석자 1 필수, 불참이면 명단 없음, 참석자 2는 이름·연락처를 함께
  check ((attend and name1 is not null and phone1 is not null)
         or (not attend and name1 is null and phone1 is null and name2 is null and phone2 is null)),
  check ((name2 is null) = (phone2 is null))
);
alter table public.startup_attend_responses enable row level security;
revoke all on public.startup_attend_responses from anon, authenticated;

-- 회신 제출 (같은 브라우저에서 다시 제출하면 기존 회신을 고칩니다)
create or replace function public.submit_startup_attend(
  p_id uuid, p_school text, p_attend boolean,
  p_name1 text, p_phone1 text, p_name2 text, p_phone2 text, p_consent boolean)
returns void
language sql
security definer
set search_path = public
as $$
  insert into startup_attend_responses
    (respondent_id, school, attend, name1, phone1, name2, phone2, consent, submitted_at)
  values (p_id, btrim(p_school), p_attend,
          nullif(btrim(p_name1), ''), nullif(btrim(p_phone1), ''),
          nullif(btrim(p_name2), ''), nullif(btrim(p_phone2), ''), p_consent, now())
  on conflict (respondent_id) do update set
    school = excluded.school, attend = excluded.attend,
    name1 = excluded.name1, phone1 = excluded.phone1,
    name2 = excluded.name2, phone2 = excluded.phone2,
    consent = excluded.consent, submitted_at = now();
$$;

-- 결과 조회 (관리자 코드가 맞을 때만)
create or replace function public.startup_attend_results(p_code text)
returns table (id uuid, school text, attend boolean, name1 text, phone1 text,
               name2 text, phone2 text, submitted_at timestamptz)
language sql
security definer
set search_path = public
as $$
  select r.respondent_id, r.school, r.attend, r.name1, r.phone1, r.name2, r.phone2, r.submitted_at
  from startup_attend_responses r
  where exists (select 1 from training_survey_admin a where a.code = p_code and a.code <> 'CHANGE-ME')
  order by r.submitted_at;
$$;

-- 회신 한 건 삭제 (관리자 코드가 맞을 때만)
create or replace function public.delete_startup_attend_response(p_code text, p_id uuid)
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
  delete from startup_attend_responses where respondent_id = p_id;
  get diagnostics n = row_count;
  return n;
end;
$$;

-- 행사 후 전체 파기 (관리자 코드가 맞을 때만, 지운 개수를 돌려줌)
create or replace function public.purge_startup_attend(p_code text)
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
  delete from startup_attend_responses where true;
  get diagnostics n = row_count;
  return n;
end;
$$;

revoke all on function public.submit_startup_attend(uuid, text, boolean, text, text, text, text, boolean) from public;
revoke all on function public.startup_attend_results(text) from public;
revoke all on function public.delete_startup_attend_response(text, uuid) from public;
revoke all on function public.purge_startup_attend(text) from public;
grant execute on function public.submit_startup_attend(uuid, text, boolean, text, text, text, text, boolean) to anon, authenticated;
grant execute on function public.startup_attend_results(text) to anon, authenticated;
grant execute on function public.delete_startup_attend_response(text, uuid) to anon, authenticated;
grant execute on function public.purge_startup_attend(text) to anon, authenticated;

notify pgrst, 'reload schema';
