-- 관리자 페이지 '응답 삭제' 기능 추가 (supabase-setup.sql 을 이미 실행한 뒤 한 번 실행)
-- 이 파일은 수정 없이 그대로 붙여넣고 Run 하면 됩니다. (비밀 코드는 그대로 유지됩니다)

-- 결과 조회: 삭제할 때 쓸 응답 번호(id)를 함께 돌려주도록 바꿈 (관리자 코드가 맞을 때만)
drop function if exists public.training_survey_results(text);
create function public.training_survey_results(p_code text)
returns table (id uuid, scores smallint[], comment text, submitted_at timestamptz)
language sql
security definer
set search_path = public
as $$
  select r.respondent_id, r.scores, r.comment, r.submitted_at
  from training_survey_responses r
  where exists (select 1 from training_survey_admin a where a.code = p_code and a.code <> 'CHANGE-ME')
  order by r.submitted_at;
$$;

-- 응답 삭제 (관리자 코드가 맞을 때만, 지운 개수를 돌려줌)
create or replace function public.delete_training_survey_response(p_code text, p_id uuid)
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
  delete from training_survey_responses where respondent_id = p_id;
  get diagnostics n = row_count;
  return n;
end;
$$;

revoke all on function public.training_survey_results(text) from public;
revoke all on function public.delete_training_survey_response(text, uuid) from public;
grant execute on function public.training_survey_results(text) to anon, authenticated;
grant execute on function public.delete_training_survey_response(text, uuid) to anon, authenticated;

notify pgrst, 'reload schema';
